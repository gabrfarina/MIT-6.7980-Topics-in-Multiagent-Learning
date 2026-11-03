// Browser test runner, used only in the unprivileged build job.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const crypto = require('node:crypto');
const {chromium} = require('playwright');
const {accentIssue} = require('./math_audit.cjs');

async function main() {
  const [before, after, output] = process.argv.slice(2).map(p => path.resolve(p));
  fs.mkdirSync(output, {recursive:true});
  const roots = {before, after};
  const mime = {'.html':'text/html','.css':'text/css','.js':'text/javascript','.svg':'image/svg+xml',
    '.png':'image/png','.jpg':'image/jpeg','.woff':'font/woff','.woff2':'font/woff2','.ttf':'font/ttf'};
  const server = http.createServer((req,res) => {
    try {
      const parts = decodeURIComponent(new URL(req.url,'http://localhost').pathname).split('/').filter(Boolean);
      const root = roots[parts.shift()];
      if (!root) {res.writeHead(404).end();return;}
      const file = fs.realpathSync(path.resolve(root, ...parts));
      if (!file.startsWith(fs.realpathSync(root)+path.sep) || !fs.statSync(file).isFile()) {res.writeHead(403).end();return;}
      res.writeHead(200, {'Content-Type':mime[path.extname(file)] || 'application/octet-stream'});
      fs.createReadStream(file).pipe(res);
    } catch {res.writeHead(404).end();}
  });
  await new Promise(resolve => server.listen(0,'127.0.0.1',resolve));
  const origin = `http://127.0.0.1:${server.address().port}`;
  const browser = await chromium.launch();
  const report = {pages:[], findings:[], external:[]};
  try {
    for (const [side, root] of Object.entries(roots)) {
      if (!fs.existsSync(root)) continue;
      const fontDigest=crypto.createHash('sha256');
      function hashFonts(folder) {
        if(!fs.existsSync(folder))return;
        for(const entry of fs.readdirSync(folder,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))) {
          const file=path.join(folder,entry.name);
          if(entry.isDirectory())hashFonts(file);
          else if(entry.isFile()&&/\.(woff2?|ttf|otf)$/i.test(file))fontDigest.update(path.relative(root,file)).update(fs.readFileSync(file));
        }
      }
      hashFonts(path.join(root,'assets'));
      const fontHash=fontDigest.digest('hex');
      const files = fs.readdirSync(root).filter(f => /^[\w-]+\.html$/.test(f)).sort();
      for (const file of files) for (const width of [1280,390]) {
        const context = await browser.newContext({viewport:{width,height:900},deviceScaleFactor:1,
          colorScheme:'light',reducedMotion:'reduce',serviceWorkers:'block'});
        await context.route('**/*', route => route.request().url().startsWith(origin+'/')
          || /^(data:|blob:)/.test(route.request().url()) ? route.continue() : route.abort());
        const page = await context.newPage();
        const issue = (code,message,level='error') => report.findings.push({side,page:file,viewport:width,code,message,level});
        page.on('pageerror', error => issue('javascript',error.message.slice(0,250)));
        page.on('response', response => {if(response.status()>=400) issue('resource', `${response.status()} ${new URL(response.url()).pathname.replace(`/${side}/`,'')}`);});
        try {
          await page.goto(`${origin}/${side}/${file}`,{waitUntil:'networkidle',timeout:30000});
          await page.evaluate(async () => {
            await document.fonts.ready;
            document.querySelectorAll('article details').forEach(x => {x.open=true;});
            await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
          });
          await page.addStyleTag({content:'* { animation: none !important; transition: none !important; caret-color: transparent !important; }'});
          const snapshot = await page.evaluate(() => {
            const article = document.querySelector('article.lecture-content') || document.querySelector('main') || document.body;
            const bounds=article.getBoundingClientRect();
            const visible = e => {const r=e.getBoundingClientRect();return r.width>0 && r.height>0 && getComputedStyle(e).visibility!=='hidden';};
            const issues=[], maths=[], external=[];
            const add=(code,message,level='error')=>issues.push({code,message,level});
            if(document.documentElement.scrollWidth>innerWidth+3) add('page-overflow',`Page exceeds the ${innerWidth}px viewport by ${document.documentElement.scrollWidth-innerWidth}px.`);
            for(const img of document.images) if(visible(img)&&(!img.complete||!img.naturalWidth)) add('broken-image',img.getAttribute('src')||'(image)');
            for(const svg of article.querySelectorAll('[data-image-source] svg, svg[data-image-source]')) {
              const r=svg.getBoundingClientRect();
              if(r.width<1||r.height<1) add('empty-figure','Zero-size figure: '+(svg.closest('[data-image-source]')?.getAttribute('data-image-source')||''));
            }
            for(const use of article.querySelectorAll('svg use')) {
              const href=use.getAttribute('href')||use.getAttribute('xlink:href');
              if(href?.startsWith('#')&&!document.getElementById(href.slice(1))) add('broken-svg-reference',href);
            }
            // Equation-line containers repeat the whole Typst expression while
            // their cells each contain a converted span. Audit those spans once.
            for(const e of article.querySelectorAll('span[data-typst-math]')) {
              const repr=e.getAttribute('data-typst-math');
              const annotation=e.querySelector('annotation[encoding="application/x-tex"]');
              const raw=e.textContent.trim();
              if(e.querySelector('.katex-error')) add('katex-error',raw.slice(0,180));
              else if(e.classList.contains('math-katex-source')&&raw&&!annotation) add('unrendered-math',raw.slice(0,180));
              else if(!e.classList.contains('math-katex-source') && e.querySelector('svg')) add('svg-math-fallback',repr.slice(0,160),'warning');
              if(annotation && window.katex) {
                try {
                  window.katex.renderToString(annotation.textContent,{throwOnError:true,
                    displayMode:e.getAttribute('data-math-display')==='block',
                    strict:code=>code==='unknownSymbol'?'error':'ignore',macros:{'\\nicefrac':'{\\,^{#1}\\!/\\!_{#2}}'}});
                } catch(error) {add('katex-parse',error.message.slice(0,220));}
              }
              maths.push({repr,tex:annotation?.textContent||null});
            }
            for(const a of document.querySelectorAll('a[href]')) {
              const href=a.getAttribute('href');
              if(/^https?:\/\//.test(href)) external.push(href);
            }
            const rail='.sidenote,.margin-note,.citation-note,.course-sidenote,.lecture-citation-sidenote,.lecture-citation-details';
            const describe=e=>e.closest('[data-image-source]')?.getAttribute('data-image-source')||e.getAttribute('src')||e.getAttribute('aria-label')||e.id||(e.innerText||e.textContent||'').replace(/\s+/g,' ').trim().slice(0,90);
            for(const e of article.querySelectorAll('img,svg,.katex-display,.equation,pre,table')) {
              if(!visible(e)||e.closest(rail))continue;
              const r=e.getBoundingClientRect();
              let scrollable=false;
              for(let p=e;p&&p!==article;p=p.parentElement) {
                const style=getComputedStyle(p);
                if(['auto','scroll'].includes(style.overflowX))scrollable=true;
                if(['hidden','clip'].includes(style.overflowX)&&p.scrollWidth>p.clientWidth+4)
                  add('clipped-content',`${p.tagName}: ${describe(p)}`);
              }
              if(!scrollable&&(r.left<bounds.left-3||r.right>bounds.right+3))add('content-overflow',`${e.tagName}: ${describe(e)}`);
            }
            const candidates=[...article.querySelectorAll('h1,h2,h3,h4,h5,p,figure,figcaption,img,svg,pre,ul,ol,li,table,details,summary,blockquote,dl,dt,dd,.statement,.proof,.env-title,.env-heading,.equation,.equation-line')]
              .filter(e=>visible(e)&&!e.closest(rail));
            const selected=new Set(candidates);
            const blocks=candidates.filter(e=>{for(let p=e.parentElement;p&&p!==article;p=p.parentElement)if(selected.has(p)&&p.getBoundingClientRect().height<1000)return false;return e.getBoundingClientRect().height<1000||!e.querySelector('p,figure,figcaption,li,summary,.env-title,.env-heading,.equation,img,svg');});
            const data=blocks.map(e=>{
              const r=e.getBoundingClientRect(),cs=getComputedStyle(e);
              const text=(e.innerText||e.textContent||'').replace(/\s+/g,' ').trim();
              if((r.left<bounds.left-3||r.right>bounds.right+3)) add('content-overflow',`${e.tagName}: ${describe(e)}`);
              if(e.scrollWidth>e.clientWidth+4&&e.clientWidth>0 && ['hidden','clip'].includes(cs.overflowX)) add('clipped-content',`${e.tagName}: ${describe(e)}`);
              const styles=[e,...e.querySelectorAll('*')].filter(n=>n===e||(!n.closest('.katex')&&(!n.closest('svg')||n.tagName.toLowerCase()==='svg'))).map(n=>{
                const s=getComputedStyle(n);return [s.fontFamily,s.fontSize,s.fontWeight,s.fontStyle,s.color,s.backgroundColor,s.overflowX,s.lineHeight,s.letterSpacing,s.textAlign,s.textDecoration,s.padding,s.margin,s.border,s.borderRadius,s.display,s.visibility,s.opacity,s.transform,s.position,s.left,s.right,s.top,s.bottom,s.backgroundImage.replace(/\/(before|after)\//g,'/')];});
              const visual=[e,...e.querySelectorAll('img,svg,canvas')].some(n=>/^(img|svg|canvas)$/i.test(n.tagName)&&!n.closest('.katex'));
              return {key:text||e.getAttribute('data-image-source')||e.getAttribute('src')||e.tagName,tag:e.tagName,id:e.id,
                top:Math.max(0,r.top-bounds.top),bottom:r.bottom-bounds.top,width:r.width,visual,styles};
            });
            return {bounds:{width:bounds.width,height:bounds.height},blocks:data,issues,maths,external};
          });
          for(const x of snapshot.issues) issue(x.code,x.message,x.level);
          for(const math of snapshot.maths) if(math.tex!==null) {
            const mismatch=accentIssue(math.repr,math.tex);if(mismatch)issue('math-accent',mismatch);
          }
          report.external.push(...snapshot.external.map(url=>({side,page:file,url})));
          if(snapshot.bounds.height>180000||snapshot.bounds.width>2500||snapshot.bounds.width*snapshot.bounds.height>120000000) {issue('screenshot-limit','Page exceeds the bounded screenshot size; inspect the HTML artifact.');continue;}
          const name=`${side}-${file.slice(0,-5)}-${width}.png`;
          let container=page.locator('article.lecture-content');
          if(!await container.count())container=page.locator('main');
          if(!await container.count())container=page.locator('body');
          await container.screenshot({path:path.join(output,name),animations:'disabled',timeout:30000});
          report.pages.push({side,page:file,viewport:width,image:name,blocks:snapshot.blocks,
            font_hash:fontHash,math_count:snapshot.maths.length,hash:crypto.createHash('sha256').update(fs.readFileSync(path.join(output,name))).digest('hex')});
          console.log(`${side} ${file} ${width}px: ${snapshot.blocks.length} blocks`);
        } catch(error) {issue('browser-incomplete',error.message.slice(0,250));}
        finally {await context.close();}
      }
    }
  } finally {await browser.close();await new Promise(resolve=>server.close(resolve));}
  fs.writeFileSync(path.join(output,'browser.json'),JSON.stringify(report,null,2));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
