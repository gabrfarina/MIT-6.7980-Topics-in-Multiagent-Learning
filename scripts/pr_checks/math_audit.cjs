// Independent of the Rust converter: compare Typst accent metadata with emitted TeX.
const marks = new Map([['302','hat'], ['303','tilde'], ['304','bar'], ['305','bar'],
  ['307','dot'], ['308','ddot'], ['20d7','vec']]);
function accentCounts(repr, tex) {
  const expected = {}, actual = {};
  const add = (obj, key) => { obj[key] = (obj[key] || 0) + 1; };
  for (const m of repr.matchAll(/\b(hat|tilde|dot|overline|underline)\s*\(/g))
    add(expected, m[1] === 'overline' ? 'bar' : m[1]);
  for (const m of repr.matchAll(/\baccent\s*:\s*"([^"\n]+)"/g)) {
    const code = m[1].startsWith('\\u{') ? m[1].slice(3,-1).toLowerCase() : m[1].codePointAt(0).toString(16);
    add(expected, marks.get(code) || `unknown-${code}`);
  }
  for (const m of tex.matchAll(/\\(widehat|hat|widetilde|tilde|ddot|dot|bar|overline|underline|vec)\b/g))
    add(actual, ({widehat:'hat',widetilde:'tilde',overline:'bar'})[m[1]] || m[1]);
  return {expected, actual};
}
function accentIssue(repr, tex) {
  const {expected, actual} = accentCounts(repr, tex);
  const differences = [...new Set([...Object.keys(expected), ...Object.keys(actual)])]
    .filter(k => (expected[k] || 0) !== (actual[k] || 0));
  return differences.length ? `Accent mismatch: Typst ${JSON.stringify(expected)}; TeX ${JSON.stringify(actual)}; ${tex.slice(0,160)}` : null;
}
module.exports = {accentCounts, accentIssue};
