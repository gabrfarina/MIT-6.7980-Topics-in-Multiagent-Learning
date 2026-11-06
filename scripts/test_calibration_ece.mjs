import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, existsSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';
const page=fileURLToPath(new URL('../interactive/calibration_ece.html',import.meta.url));
const match=existsSync(page)&&readFileSync(page,'utf8').match(/<script id="ece-model">([\s\S]*?)<\/script>/);
const sandbox={};
if(match)vm.runInNewContext(match[1],sandbox);
const api=sandbox.ECE;
const enabled={skip:!api};
const close=(a,b)=>assert.ok(Math.abs(a-b)<1e-11,`${a} differs from ${b}`);
const plain=x=>JSON.parse(JSON.stringify(x));
const worked=random=>api.createExperiment({preset:'worked',m:4,strategy:'adaptive',random});
test('the self-contained companion exports a usable mathematical model',()=>assert.ok(api&&typeof api.createExperiment==='function','Missing ECE interactive model'));
test('worked history separates historical score and next-draw probabilities',enabled,()=>{
 const s=worked(()=>.5).snapshot();assert.equal(s.total,11);close(s.metrics.ece,23/44);close(s.metrics.c2,61/176);close(s.metrics.rms,Math.sqrt(61/176));
 assert.deepEqual(plain(s.N),[1,4,4,1,1]);close(s.distribution[1],1/3);close(s.distribution[2],2/3);close(s.distribution.reduce((a,b)=>a+b,0),1);
});
for(const [y,u,forecast,expected] of [[0,.1,.25,11/24],[0,.8,.5,25/48],[1,.1,.25,13/24],[1,.8,.5,7/16]]){
 test(`absolute ECE for committed y=${y}, forecast=${forecast}`,enabled,()=>{
  const m=worked(()=>u);m.commit(y);const s=m.draw();close(s.lastDraw.p,forecast);close(s.metrics.ece,expected);assert.equal(s.total,12);assert.equal(s.newRounds,1);
  const changed=s.N.map((n,i)=>n-[1,4,4,1,1][i]);assert.equal(changed.filter(x=>x!==0).length,1);assert.equal(s.phase,'ready');
 });
}
test('one higher-bucket zero recomputes the lottery to3/8,5/8',enabled,()=>{
 const m=worked(()=>.8);m.commit(0);const s=m.draw();close(s.distribution[1],3/8);close(s.distribution[2],5/8);
});
test('commit freezes historical lottery independently of hidden outcome',enabled,()=>{
 let calls=0;const a=worked(()=>{calls++;return .8}),b=worked(()=>{calls++;return .8});
 const d=a.snapshot().distribution;a.commit(0);b.commit(1);assert.equal(calls,0);assert.deepEqual(plain(a.snapshot().distribution),plain(d));assert.deepEqual(plain(b.snapshot().distribution),plain(d));
 assert.throws(()=>a.commit(1),/commit|locked/i);close(a.draw().lastDraw.p,.5);close(b.draw().lastDraw.p,.5);assert.equal(calls,2);
});
test('draw before commit cannot sample or mutate the history',enabled,()=>{
 let called=false;const m=worked(()=>{called=true;return .1});assert.throws(()=>m.draw(),/commit/i);assert.equal(called,false);assert.equal(m.snapshot().total,11);
});
test('preview returns all four hypothetical scores without appending a record',enabled,()=>{
 const m=worked(()=>.5);const before=JSON.stringify(m.snapshot());
 close(m.preview(.25,0).metrics.ece,11/24);close(m.preview(.5,0).metrics.ece,25/48);close(m.preview(.25,1).metrics.ece,13/24);close(m.preview(.5,1).metrics.ece,7/16);
 assert.equal(JSON.stringify(m.snapshot()),before);assert.throws(()=>m.preview(.33,0),/grid/i);
});
test('fresh m20 has finite empty scores, zero errors, then updates one unused bucket',enabled,()=>{
 const m=api.createExperiment({preset:'fresh',m:20,strategy:'adaptive',random:()=>.5});const s=m.snapshot();assert.equal(s.total,0);assert.equal(s.metrics.ece,0);assert.equal(s.metrics.rms,0);assert.ok(s.errors.every(x=>x===0));
 close(s.distribution[10],1);m.commit(0);const after=m.draw();assert.equal(after.total,1);assert.equal(after.N[10],1);close(after.metrics.ece,.5);
 const reset=m.reset();assert.equal(reset.total,0);assert.equal(reset.phase,'ready');close(reset.distribution[10],1);
});
test('boundary grid chooses unused zero errors before an opposite-sign mixture',enabled,()=>{
 const m=api.createExperiment({preset:'fresh',m:1,strategy:'adaptive',random:()=>.1});close(m.snapshot().distribution[0],1);m.commit(1);m.draw();close(m.snapshot().distribution[1],1);m.commit(0);m.draw();
 close(m.snapshot().distribution[0],.5);close(m.snapshot().distribution[1],.5);
});
for(const policy of ['zeros','ones','mean'])test(`batch ${policy} commits public-history outcome before every RNG call`,enabled,()=>{
 let m,calls=0;m=worked(()=>{const s=m.snapshot();assert.equal(s.phase,'committed');const mean=s.distribution.reduce((v,d,i)=>v+d*i/4,0);assert.equal(s.committedOutcome,policy==='zeros'?0:policy==='ones'?1:Number(mean<.65));calls++;return (calls%7)/7;});
 const after=m.run(100,policy);assert.equal(calls,100);assert.equal(after.total,111);assert.equal(after.newRounds,100);assert.ok(after.metrics.ece**2<=after.metrics.c2+1e-12);
 assert.ok(after.N.every((n,i)=>Number.isInteger(n)&&after.R[i]>=0&&after.R[i]<=n));
});
test('batch rejects unknown policy, unbounded requests and locked manual round',enabled,()=>{
 const m=worked(()=>.5);assert.throws(()=>m.run(100,'manual'),/policy/i);assert.throws(()=>m.run(10001,'ones'),/limit|10000|round/i);m.commit(0);assert.throws(()=>m.run(100,'ones'),/commit|locked/i);assert.equal(m.snapshot().total,11);
});
test('fixed lottery against ones retains its known nonzero long-run error',enabled,()=>{
 let k=0;const m=api.createExperiment({preset:'worked',m:4,strategy:'fixed',random:()=>[.1,.5,.9][k++%3]});const s=m.run(3000,'ones');assert.ok(Math.abs(s.metrics.ece-7/12)<.01);close(s.distribution[1],1/3);close(s.distribution[2],2/3);
});
test('snapshot objects cannot modify internal counts',enabled,()=>{
 const m=worked(()=>.5);const s=m.snapshot();s.N[0]=999;s.distribution[1]=0;assert.equal(m.snapshot().N[0],1);close(m.snapshot().distribution[1],1/3);
});
test('nonfinite branch previews are rejected without changing the record',enabled,()=>{
 const m=worked(()=>.5);assert.throws(()=>m.preview(Number.NaN,0),/grid|finite/i);assert.equal(m.snapshot().total,11);
});
