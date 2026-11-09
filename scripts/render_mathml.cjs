#!/usr/bin/env node
// Render [{tex, display}] JSON from stdin as [{html, error}] MathML for the EPUB build,
// with the same bundled KaTeX and macros that check_katex.cjs validates.
const fs = require('node:fs');
const katex = require('../html-exporter/assets/katex/katex.min.js');

const macros = {'\\nicefrac': '{\\,^{#1}\\!/\\!_{#2}}'};

function render(tex, display, throwOnError) {
  return katex.renderToString(tex, {
    displayMode: display,
    output: 'mathml',
    throwOnError,
    strict: 'ignore',
    macros: {...macros},
  });
}

const jobs = JSON.parse(fs.readFileSync(0, 'utf8'));
const results = jobs.map(({tex, display}) => {
  try {
    return {html: render(tex, display, true), error: null};
  } catch (error) {
    return {html: render(tex, display, false), error: error.message};
  }
});
process.stdout.write(JSON.stringify(results));
