// Run with: node --test scripts/test_zero_sum_2xn.cjs
const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const source = fs.readFileSync(path.join(__dirname, '../interactive/zero_sum_2xn.html'), 'utf8').match(/<script>([\s\S]*?)<\/script>/)[1];
function context(matrix) {
  const nodes = [], elements = new Map();
  const c = vm.createContext({nodes, document: {
    getElementById(id) { if (!elements.has(id)) elements.set(id, {value: '0', innerHTML: ''}); return elements.get(id); },
    createTextNode(text) { return {text}; }
  }});
  vm.runInContext(source.split('\n(function () {')[0], c);
  c.state = {U: matrix.map(r => r.map(v => c.ZS.parse(String(v)))), highlighted: null};
  c.state.sol = c.ZS.solve(c.state.U);
  c.col = j => 'column-' + j;
  c.fmt = c.ZS.str;
  c.vec = v => '(' + v.map(c.ZS.str).join(', ') + ')';
  c.el = (tag, attrs, parent, text) => { const e = {tag, attrs, text, appendChild() {}}; nodes.push(e); return e; };
  for (const name of ['renderCursor', 'renderSolution', 'renderStrategy', 'highlightColumn', 'renderLP']) c[name] = () => {};
  return c;
}
function loadFunction(c, name, next) {
  vm.runInContext(source.slice(source.indexOf('  function ' + name + '('), source.indexOf('  function ' + next + '(')), c);
}
test('large common offsets render finite coordinates and bounded ticks', () => {
  for (const U of [
    [['10000000000000000'], ['10000000000000002']],
    [['100000000000000000000'], ['100000000000000000000']],
    [['9'.repeat(64), '-1'], ['0', '9'.repeat(64)]]
  ]) {
    const c = context(U); loadFunction(c, 'render', 'renderCursor');
    vm.runInContext('render()', c, {timeout: 1000});
    assert(c.nodes.length < 150);
    for (const e of c.nodes) for (const [key, v] of Object.entries(e.attrs)) {
      if (['x', 'y', 'x1', 'x2', 'y1', 'y2', 'cx', 'cy', 'width', 'height'].includes(key)) assert(Number.isFinite(v), key + ': ' + v);
      if (key === 'points') assert(!/NaN|Infinity/.test(v));
    }
  }
});
test('eight coincident labels stay inside the plot at either endpoint', () => {
  for (const U of [ [Array(8).fill(0), Array(8).fill(1)], [Array(8).fill(1), Array(8).fill(0)] ]) {
    const c = context(U); loadFunction(c, 'render', 'renderCursor'); c.render();
    const labels = c.nodes.filter(e => e.tag === 'text' && e.text === 'ℓ');
    assert.equal(labels.length, 8);
    labels.forEach(e => assert(e.attrs.y >= 32 && e.attrs.y <= 320));
    for (let i = 1; i < labels.length; i++) assert(labels[i].attrs.y - labels[i-1].attrs.y >= 16);
  }
});
test('large rational intermediates convert without Infinity divided by Infinity', () => {
  const c = context([[1], [0]]), huge = 10n ** 400n;
  assert(Math.abs(c.ZS.num(c.ZS.Q(huge + 1n, 3n * huge + 1n)) - 1/3) < 1e-14);
  assert.equal(c.ZS.parse('9'.repeat(65)), null);
  assert.equal(c.ZS.parse('1/0'), null);
});
test('pure-column explanation identifies the certificate strategy', () => {
  const c = context([[5,0,3,4,2],[0,4,1,3,2]]);
  c.state.endpoints = c.state.sol.yAll;
  c.document.getElementById('ymode').value = '1';
  loadFunction(c, 'rowPayoffs', 'highlightColumn'); c.renderStrategy();
  const text = c.document.getElementById('y-result').innerHTML;
  assert(text.includes('x = (1/2, 1/2), used in the certificate below'));
  assert(text.includes('Row payoffs: (0, 4)'));
  assert(text.includes('gap above the game value: 2'));
});
