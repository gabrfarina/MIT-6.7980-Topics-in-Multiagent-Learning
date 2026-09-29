#!/usr/bin/env node
// Validate exactly the TeX sources that the browser's local KaTeX will render.
const fs = require('node:fs');
const path = require('node:path');
const katex = require('../html-exporter/assets/katex/katex.min.js');

function decodeHtml(value) {
  return value.replace(/&(#x[0-9a-f]+|#\d+|quot|apos|lt|gt|amp);/gi, (_, entity) => {
    if (entity[0] === '#') {
      return String.fromCodePoint(entity[1].toLowerCase() === 'x'
        ? parseInt(entity.slice(2), 16) : parseInt(entity.slice(1), 10));
    }
    return {quot: '"', apos: "'", lt: '<', gt: '>', amp: '&'}[entity];
  });
}

const requested = process.argv.slice(2);
const files = (requested.length ? requested : ['html']).flatMap(input => {
  if (!fs.statSync(input).isDirectory()) return [input];
  return fs.readdirSync(input).filter(name => name.endsWith('.html'))
    .sort().map(name => path.join(input, name));
});
let total = 0;
let fallback = 0;
let failures = 0;
for (const file of files) {
  const html = fs.readFileSync(file, 'utf8');
  let converted = 0;
  let pageFallback = 0;
  const mathSpans = /<span\b([^>]*\bdata-typst-math="[^"]*"[^>]*)>([\s\S]*?)<\/span>/g;
  for (const match of html.matchAll(mathSpans)) {
    const attrs = Object.fromEntries([...match[1].matchAll(/([\w-]+)="([^"]*)"/g)]
      .map(([, key, value]) => [key, decodeHtml(value)]));
    if (!(attrs.class || '').split(/\s+/).includes('math-katex-source')) {
      pageFallback++;
      console.error(`${file}: untranslated math: ${attrs['data-typst-math'].slice(0, 160)}`);
      continue;
    }
    const source = decodeHtml(match[2]).trim();
    if (!source) continue; // Intentionally empty equation alignment cells.
    const display = source.startsWith('\\[');
    if (!(display && source.endsWith('\\]'))
        && !(source.startsWith('\\(') && source.endsWith('\\)'))) {
      failures++;
      console.error(`${file}: malformed KaTeX source delimiters: ${source}`);
      continue;
    }
    const tex = source.slice(2, -2);
    try {
      const ignoredLineBreaks = [];
      katex.renderToString(tex, {
        displayMode: display,
        throwOnError: true,
        strict: (code, message) => {
          if (code === 'newLineInDisplayMode') ignoredLineBreaks.push(message);
          return code === 'unknownSymbol' ? 'error' : 'ignore';
        },
        macros: {'\\nicefrac': '{\\,^{#1}\\!/\\!_{#2}}'},
      });
      if (ignoredLineBreaks.length) {
        throw new Error('Ignored formula line break: ' + ignoredLineBreaks[0]);
      }
      converted++;
    } catch (error) {
      failures++;
      console.error(`${file}: ${error.message}\n  ${tex}`);
    }
  }
  total += converted;
  fallback += pageFallback;
  if (path.basename(file) !== 'index.html' && converted === 0) {
    failures++;
    console.error(`${file}: lecture contains no valid KaTeX expressions`);
  }
  console.log(`${path.basename(file)}: ${converted} KaTeX expressions; ${pageFallback} SVG math fallbacks`);
}
console.log(`KaTeX ${katex.version}: ${total} expressions passed; ${failures} errors; ${fallback} fallbacks.`);
process.exitCode = failures || fallback ? 1 : 0;
