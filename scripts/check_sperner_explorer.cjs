#!/usr/bin/env node
// Check the Sperner explorer's port of the figure code against Typst.
//
// The explorer of Example L2.3 reimplements figure code in JavaScript, so its
// output has to keep agreeing with the figures beside it. The colorings below
// were produced by content/figures/libs/nash.typ and the marking rule of
// content/figures/libs/sperner.typ. They must be regenerated from Typst, not
// from this file, or a bug in the port would become the new expectation: run the
// coloring loop of example_games.typ under `typst eval` and paste the result.
const fs = require('node:fs');
const path = require('node:path');

// Load the widget's pure math out of the shipped source, without its DOM half.
const source = fs.readFileSync(path.join(__dirname, '..', 'html-exporter', 'src', 'sperner-explorer.js'), 'utf8');
const from = source.indexOf('const cmap');
const to = source.indexOf('const centroid');
if (from < 0 || to < 0) throw new Error('Cannot locate the explorer math block.');
const api = new Function(`${source.slice(from, to)}
  return {presets, displacement, colorGrid, padGrid, trichromatic, walk, fieldFill};`)();

const failures = [];
const fail = message => failures.push(message);

// Typst reference output for the three games of Example L2.3, at the figure's
// own sperner_N = 8.
const FIGURES = {
  'Theater or football': 'rbrrrrrrr ybrrrrrrb ybrrrrrbb ybrrrrbbb ybrrrbbbb ybbrbbbbb ybrrbbbbb yyrrrrrrr yyyyyyyyb',
  "Prisoner's dilemma": 'rrrrrrrrb yyyyyyyyb yyyyyyyyb yyyyyyyyb yyyyyyyyb yyyyyyyyb yyyyyyyyb yyyyyyyyb yyyyyyyyb',
  'Penalty shot game': 'rrrrbbbbb rrrrbbbbb rrrrbbbbb rrrrbbbbb rrrryyyyb rrrryyyyb rrrryyyyb rrrryyyyb yyyyyyyyb',
};
for (const [name, want] of Object.entries(FIGURES)) {
  if (!api.presets[name]) {
    fail(`Missing preset: ${name}`);
    continue;
  }
  const got = api.colorGrid(8, api.displacement(...api.presets[name])).join(' ');
  if (got !== want) fail(`${name} no longer matches the figure:\n  want ${want}\n  got  ${got}`);
}

// The field color is nash_cmap.sample(atan2(dq, dp) - 45deg), so on the diagonals
// it is Typst's own sample of the figures' gradient at 0, 90, 180 and 270 degrees.
for (const [dp, dq, want] of [[1, 1, '#ffdc00'], [-1, 1, '#4c8fc7'], [-1, -1, '#a37095'], [1, -1, '#ff6934']]) {
  const got = api.fieldFill(dp, dq);
  if (got !== want) fail(`The color at (${dp}, ${dq}) is ${got}, not the figure's ${want}`);
}

function countTrichromatic(rows) {
  let total = 0;
  for (let i = 0; i < rows.length - 1; i++) {
    for (let j = 0; j < rows.length - 1; j++) {
      for (const half of ['upper', 'lower']) {
        if (api.trichromatic(rows, i, j, half)) total++;
      }
    }
  }
  return total;
}

// Theorem L2.1 forbids blue in the left column, red along the bottom and yellow
// on the right or top. Padding must extend that to the standard coloring of
// Section L2.2 (red down the left except at the bottom-left corner, yellow
// along the bottom except at the bottom-right), which leaves the count of
// trichromatic triangles odd and makes the bottom-left cell a source, so
// following its red-yellow edges out must reach a trichromatic sink.
function check(base, tag) {
  const n = base.length - 1;
  for (let k = 0; k <= n; k++) {
    if (base[k][0] === 'b' || base[0][k] === 'y') fail(`${tag}: blue left or yellow top at ${k}`);
    if (base[k][n] === 'y' || base[n][k] === 'r') fail(`${tag}: yellow right or red bottom at ${k}`);
  }
  const rows = api.padGrid(base);
  const P = rows.length;
  for (let k = 0; k < P; k++) {
    const want = [k === P - 1 ? 'y' : 'r', 'b', k === 0 ? 'r' : 'b', k === P - 1 ? 'b' : 'y'].join('');
    const got = [rows[k][0], rows[k][P - 1], rows[0][k], rows[P - 1][k]].join('');
    if (got !== want) fail(`${tag}: padded border ${k} is ${got} (left right top bottom), want ${want}`);
  }
  const count = countTrichromatic(rows);
  if (count !== countTrichromatic(base)) fail(`${tag}: padding changed the count to ${count}`);
  if (count % 2 === 0) fail(`${tag}: even number of trichromatic triangles (${count})`);
  const trail = api.walk(rows);
  if (!api.trichromatic(rows, ...trail[trail.length - 1])) fail(`${tag}: the path ends off a trichromatic triangle`);
  if (new Set(trail.map(node => node.join())).size !== trail.length) fail(`${tag}: the path revisits a node`);
}

// Readers type arbitrary payoffs, so the invariants must survive them.
let seed = 7;
let cases = 0;
const random = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
const matrix = () => [0, 1].map(() => [0, 1].map(() => Math.round((random() * 20 - 10) * 10) / 10));
const sweep = (A1, A2, tag) => [4, 7, 8, 13, 24].forEach(n => {
  check(api.colorGrid(n, api.displacement(A1, A2)), `${tag} N=${n}`);
  cases++;
});
for (let trial = 0; trial < 120; trial++) {
  sweep(matrix(), matrix(), `random game ${trial}`);
}
for (const [tag, value] of [['all-zero', 0], ['constant', 5], ['large', 1e6], ['small', 1e-9]]) {
  sweep([[value, value], [value, value]], [[value, -value], [-value, value]], tag);
}

failures.forEach(message => console.error(message));
console.log(failures.length
  ? `Sperner explorer: ${failures.length} failure(s).`
  : `Sperner explorer: matches the figures of Example L2.3; invariants hold over ${cases} colorings.`);
process.exitCode = failures.length ? 1 : 0;
