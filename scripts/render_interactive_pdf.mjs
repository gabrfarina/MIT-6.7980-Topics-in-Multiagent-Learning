#!/usr/bin/env node
// Print a standalone interactive deck without an npm dependency. Node 22+
// provides fetch and WebSocket; Chrome provides the DevTools print API.
import {execFileSync, spawn} from 'node:child_process';
import {constants} from 'node:fs';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const [inputArg, outputArg]=process.argv.slice(2);
if(!inputArg || !outputArg)throw Error('Usage: node scripts/render_interactive_pdf.mjs input.html output.pdf');
const input=path.resolve(inputArg), output=path.resolve(outputArg);
const sleep=ms=>new Promise(resolve=>setTimeout(resolve,ms));
function limit(promise,ms,label){
  return new Promise((resolve,reject)=>{
    const timer=setTimeout(()=>reject(Error(`${label} timed out after ${ms} ms`)),ms);
    promise.then(value=>{clearTimeout(timer);resolve(value);},error=>{clearTimeout(timer);reject(error);});
  });
}

async function chromeExecutable(){
  const names=['google-chrome','google-chrome-stable','chromium','chromium-browser'];
  if(process.env.CHROME_BIN){
    await fs.access(process.env.CHROME_BIN,constants.X_OK);
    return process.env.CHROME_BIN;
  }
  const candidates=[
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium',
    '/usr/bin/google-chrome', '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium', '/usr/bin/chromium-browser',
    ...process.env.PATH.split(path.delimiter).flatMap(folder=>names.map(name=>path.join(folder,name)))
  ];
  for(const candidate of candidates){
    try{await fs.access(candidate,constants.X_OK);return candidate;}catch{}
  }
  throw Error('Chrome or Chromium is required to export interactive slide PDFs. Set CHROME_BIN to its executable.');
}

async function debuggingPort(profile,chrome,stderr){
  const filename=path.join(profile,'DevToolsActivePort');
  for(let attempt=0;attempt<150;attempt++){
    try{
      const port=Number((await fs.readFile(filename,'utf8')).split('\n')[0]);
      if(Number.isInteger(port)&&port>0)return port;
    }catch{}
    if(chrome.exitCode!==null || chrome.signalCode)
      throw Error(`Chrome exited before opening DevTools. ${stderr()}`);
    await sleep(100);
  }
  throw Error(`Chrome did not open DevTools. ${stderr()}`);
}

async function connect(url){
  const socket=new WebSocket(url),pending=new Map();
  let nextId=0;
  await limit(new Promise((resolve,reject)=>{
    socket.addEventListener('open',resolve,{once:true});
    socket.addEventListener('error',reject,{once:true});
  }),10000,'DevTools connection');
  socket.addEventListener('message',event=>{
    const message=JSON.parse(event.data);
    if(!message.id || !pending.has(message.id))return;
    const {resolve,reject}=pending.get(message.id);
    pending.delete(message.id);
    if(message.error)reject(Error(`${message.error.message} (${message.error.code})`));
    else resolve(message.result);
  });
  socket.addEventListener('close',()=>{
    for(const {reject} of pending.values())reject(Error('DevTools connection closed'));
    pending.clear();
  });
  return {
    send(method,params={}){
      const id=++nextId;
      const response=new Promise((resolve,reject)=>pending.set(id,{resolve,reject}));
      socket.send(JSON.stringify({id,method,params}));
      return limit(response,30000,method);
    },
    close(){socket.close();}
  };
}

async function evaluate(cdp,expression,awaitPromise=false){
  const result=await cdp.send('Runtime.evaluate',{expression,awaitPromise,returnByValue:true});
  if(result.exceptionDetails)throw Error(result.exceptionDetails.text);
  return result.result.value;
}

async function stopChrome(chrome){
  if(!chrome)return;
  const closed=new Promise(resolve=>{
    if(chrome.exitCode!==null)resolve();
    else chrome.once('close',resolve);
  });
  if(chrome.exitCode===null)chrome.kill('SIGTERM');
  await Promise.race([closed,sleep(3000)]);
  if(chrome.exitCode===null)chrome.kill('SIGKILL');
  await Promise.race([closed,sleep(1000)]);
}

async function render(){
  if(path.extname(input)!=='.html' || path.extname(output)!=='.pdf')
    throw Error('Expected an HTML deck and a PDF destination.');
  await fs.access(input);
  await fs.mkdir(path.dirname(output),{recursive:true});
  const profile=await fs.mkdtemp(path.join(os.tmpdir(),'course-slides-chrome-'));
  const temporary=`${output}.tmp-${process.pid}`;
  let chrome,cdp,log='';
  try{
    chrome=spawn(await chromeExecutable(),[
      '--headless=new','--disable-background-networking','--disable-component-update',
      '--disable-extensions','--no-first-run','--no-default-browser-check',
      `--user-data-dir=${profile}`,'--remote-debugging-port=0',
      '--window-size=1280,720','about:blank'
    ],{stdio:['ignore','ignore','pipe']});
    chrome.stderr.on('data',chunk=>{log=(log+chunk.toString()).slice(-4000);});
    const port=await debuggingPort(profile,chrome,()=>log);
    const response=await limit(fetch(`http://127.0.0.1:${port}/json/new?about:blank`,{method:'PUT'}),10000,'New browser tab');
    if(!response.ok)throw Error(`Chrome rejected the new tab (${response.status}).`);
    const tab=await response.json();
    cdp=await connect(tab.webSocketDebuggerUrl);
    await cdp.send('Page.enable');
    await cdp.send('Runtime.enable');
    const navigation=await cdp.send('Page.navigate',{url:pathToFileURL(input).href});
    if(navigation.errorText)throw Error(`Could not load the deck: ${navigation.errorText}`);
    let ready=false;
    for(let attempt=0;attempt<300;attempt++){
      ready=await evaluate(cdp,'Boolean(window.Deck?.ready)');
      if(ready)break;
      await sleep(100);
    }
    if(!ready)throw Error('Interactive deck did not initialize within 30 seconds.');
    const deck=await evaluate(cdp,`(async()=>{
      await document.fonts.ready;
      Deck.snapshot();
      Deck.preparePrint();
      return {
        slides:Deck.slides.length,
        pages:document.querySelectorAll('#print-deck>.slide').length,
        title:document.title
      };
    })()`,true);
    if(!deck?.slides || deck.pages<deck.slides)throw Error('Interactive deck has no printable slides.');
    await cdp.send('Emulation.setEmulatedMedia',{
      media:'print',features:[{name:'prefers-reduced-motion',value:'reduce'}]
    });
    const pdf=await cdp.send('Page.printToPDF',{
      printBackground:true,preferCSSPageSize:true,displayHeaderFooter:false,
      marginTop:0,marginRight:0,marginBottom:0,marginLeft:0
    });
    const bytes=Buffer.from(pdf.data||'','base64');
    if(bytes.subarray(0,5).toString()!=='%PDF-')throw Error('Chrome returned an invalid PDF.');
    await fs.writeFile(temporary,bytes);
    const details=execFileSync('pdfinfo',[temporary],{encoding:'utf8'});
    const pages=Number(details.match(/^Pages:\s+(\d+)/m)?.[1]);
    if(pages!==deck.pages)throw Error(`PDF has ${pages} pages, expected ${deck.pages}.`);
    await fs.rename(temporary,output);
    console.log(`Interactive slides: ${path.basename(output)} (${pages} pages).`);
  }finally{
    cdp?.close();
    await stopChrome(chrome);
    await fs.rm(temporary,{force:true});
    // Chrome helpers can briefly touch the profile after the browser exits.
    // A cleanup race must not invalidate a PDF that passed the page-count check.
    try{await fs.rm(profile,{recursive:true,force:true,maxRetries:20,retryDelay:100});}
    catch(error){console.warn(`Temporary Chrome profile remains at ${profile}: ${error.message}`);}
  }
}

await render();
