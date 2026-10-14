// End-to-end negative fixtures: the real browser must discover each defect.
const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const os=require('node:os');
const path=require('node:path');
const {execFileSync}=require('node:child_process');

test('browser detects wrong accents, malformed math, broken figures and overflow',{timeout:120000},()=>{
  const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'course-html-check-'));
  try {
    for(const side of ['before','after']) {
      const root=path.join(tmp,side);fs.mkdirSync(root);
      fs.cpSync(path.resolve(__dirname,'../../html-exporter/assets/katex'),path.join(root,'katex'),{recursive:true});
      const wrong=side==='after';
      const markup=String.raw`<!doctype html><meta charset="utf-8"><link rel="stylesheet" href="katex/katex.min.css">
        <style>body{margin:16px}article{max-width:720px}p{margin:12px 0}</style>
        <article class="lecture-content"><h1>Fixture</h1><p>Stable paragraph.</p>
        <div class="equation" data-typst-math="sequence(overline(body: [μ]), hat(body: [x]))"><span class="math-katex-source" data-typst-math="overline(body: [μ])">\(${wrong?'\\hat{\\mu}':'\\overline{\\mu}'}\)</span><span class="math-katex-source" data-typst-math="hat(body: [x])">\(\hat{x}\)</span></div>
        ${wrong?String.raw`<p style="width:1500px">Overflowing text</p><svg data-image-source="oversize-figure.svg" width="1500" height="30"><rect width="1500" height="30" fill="red"/></svg><details><summary>Solution</summary><img width="100" height="50" src="missing.png"></details>
          <p><span class="math-katex-source" data-typst-math="[x]">\(\thisCommandDoesNotExist{x}\)</span></p>`:''}
        </article><script src="katex/katex.min.js"></script><script src="katex/contrib/auto-render.min.js"></script>
        <script>renderMathInElement(document.body,{delimiters:[{left:'\\(',right:'\\)',display:false}],throwOnError:false});</script>`;
      fs.writeFileSync(path.join(root,'fixture.html'),markup);
    }
    execFileSync(process.execPath,[path.join(__dirname,'browser.cjs'),path.join(tmp,'before'),path.join(tmp,'after'),path.join(tmp,'result')],{timeout:110000,stdio:'pipe'});
    const report=JSON.parse(fs.readFileSync(path.join(tmp,'result/browser.json')));
    assert.equal(report.pages.length,4);
    assert(report.pages.every(page=>page.blocks.some(block=>block.tag==='DIV')),'Standalone display equations must appear in the visual diff');
    assert.deepEqual(report.findings.filter(x=>x.side==='before'),[]);
    const codes=new Set(report.findings.filter(x=>x.side==='after').map(x=>x.code));
    for(const code of ['math-accent','page-overflow','broken-image','katex-parse'])assert(codes.has(code),`Missing ${code}: ${JSON.stringify(report.findings)}`);
    assert(report.findings.some(x=>x.code==='content-overflow'&&x.message.includes('oversize-figure.svg')),'Overflow reports must identify their figure, not SVG stylesheet text');
  } finally {fs.rmSync(tmp,{recursive:true,force:true});}
});
