const test=require('node:test');
const assert=require('node:assert/strict');
const {accentIssue}=require('./math_audit.cjs');

test('hat and overline are different even when KaTeX accepts both',()=>{
  assert.equal(accentIssue('overline(body: [μ])',String.raw`\overline{\mu}`),null);
  assert.match(accentIssue('overline(body: [μ])',String.raw`\hat{\mu}`),/Accent mismatch/);
  assert.match(accentIssue('hat(body: [μ])',String.raw`\overline{\mu}`),/Accent mismatch/);
});
test('low-level combining accents and Unicode forms',()=>{
  assert.equal(accentIssue(String.raw`accent(base: [x], accent: "\u{304}")`,String.raw`\bar{x}`),null);
  assert.equal(accentIssue('accent(base: [x], accent: "̂")',String.raw`\hat{x}`),null);
  assert.match(accentIssue(String.raw`accent(base: [x], accent: "\u{305}")`,String.raw`\hat{x}`),/mismatch/);
});
test('missing or duplicated accents fail',()=>{
  assert.match(accentIssue('hat(body: [x])','x'),/mismatch/);
  assert.match(accentIssue('hat(body: [x])',String.raw`\hat{\hat{x}}`),/mismatch/);
  assert.equal(accentIssue('sequence([x], [+], [y])','x+y'),null);
});
