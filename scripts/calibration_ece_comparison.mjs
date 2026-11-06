// Reproduce the print figure with the actual self-contained browser model.
// node scripts/calibration_ece_comparison.mjs [--check]
import {readFileSync,writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';
const page=new URL('../interactive/calibration_ece.html',import.meta.url);
const source=readFileSync(page,'utf8').match(/<script id="ece-model">([\s\S]*?)<\/script>/)[1];
const sandbox={};vm.runInNewContext(source,sandbox);
const result=sandbox.ECE.createComparison({seed:20261105,policy:'ones'}).run(1000);
const data={seed:result.seed,policy:result.policy,initial_rounds:11,new_rounds:1000,grid_spacing:.25,
 protocol:'Identical seeded uniform streams; same predetermined all-one outcomes. Illustrative simulation, not a theorem proof.',
 series:result.fixed.history.map((p,i)=>[p.round,p.ece,result.adaptive.history[i].ece]),
 fixed:{N:result.fixed.N,R:result.fixed.R,distribution:result.fixed.distribution,ece:result.fixed.metrics.ece},
 adaptive:{N:result.adaptive.N,R:result.adaptive.R,distribution:result.adaptive.distribution,ece:result.adaptive.metrics.ece}};
const output=new URL('../content/figures/calibration_ece/ece_comparison.json',import.meta.url);
const text=JSON.stringify(data)+'\n';
if(process.argv.includes('--check')){
 if(readFileSync(output,'utf8')!==text)throw new Error('Print comparison data differs from the browser model. Regenerate it.');
 console.log('PASS: print comparison data exactly matches the browser model.');
}else{writeFileSync(output,text);console.log('Generated '+fileURLToPath(output));}
console.log(JSON.stringify({seed:data.seed,after100:data.series[100],after1000:data.series[1000],fixed:data.fixed,adaptive:data.adaptive},null,2));
