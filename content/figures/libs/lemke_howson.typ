// The Lemke-Howson algorithm, in exact rational arithmetic, and drawings of
// its paths on labeled simplices. Used by the figures of the Lemke-Howson
// section in nash_algorithms.typ.
//
// Rationals are pairs (numerator, denominator) of integers with a positive
// denominator. Labels and strategies are 1-based, as in the notes.
#import "@preview/cetz:0.4.1"

// ---------------------------------------------------------------------------
// Rational arithmetic
// ---------------------------------------------------------------------------

#let _q(n, d: 1) = {
  let g = calc.gcd(n, d)
  if d < 0 { g = -g }
  (calc.quo(n, g), calc.quo(d, g))
}
#let _add(a, b) = _q(a.at(0) * b.at(1) + b.at(0) * a.at(1), d: a.at(1) * b.at(1))
#let _sub(a, b) = _q(a.at(0) * b.at(1) - b.at(0) * a.at(1), d: a.at(1) * b.at(1))
#let _mul(a, b) = _q(a.at(0) * b.at(0), d: a.at(1) * b.at(1))
#let _div(a, b) = _q(a.at(0) * b.at(1), d: a.at(1) * b.at(0))
#let _cmp(a, b) = {
  let d = a.at(0) * b.at(1) - b.at(0) * a.at(1)
  if d > 0 { 1 } else if d < 0 { -1 } else { 0 }
}
#let _float(a) = a.at(0) / a.at(1)

// Rational as content: 3, 1/8, -2/3.
#let rat(a) = if a.at(1) == 1 { str(a.at(0)) } else { str(a.at(0)) + "/" + str(a.at(1)) }

// ---------------------------------------------------------------------------
// Tableau for M v + s = 1, v >= 0, s >= 0
// ---------------------------------------------------------------------------

// `vars` lists (letter, index, label) for the structural variables, then the
// slacks; a variable at zero means its label is present.
#let _tableau(M, vars) = {
  let rows = M.len()
  let cols = M.at(0).len()
  (
    T: range(rows).map(r => M.at(r).map(v => _q(v)) + range(rows).map(i => _q(int(i == r)))),
    rhs: range(rows).map(_ => _q(1)),
    basis: range(rows).map(r => cols + r),
    slack: range(rows).map(r => cols + r),
    vars: vars,
  )
}

#let _value(tab, col) = {
  let r = tab.basis.position(b => b == col)
  if r == none { _q(0) } else { tab.rhs.at(r) }
}

#let _lex-less(a, b) = {
  for i in range(a.len()) {
    let c = _cmp(a.at(i), b.at(i))
    if c != 0 { return c < 0 }
  }
  false
}

// Leaving row for entering column `col`: lexicographic minimum ratio test,
// which resolves ties as a symbolic perturbation of the right-hand side.
#let _ratio-test(tab, col) = {
  let best = none
  let best-key = none
  for (r, row) in tab.T.enumerate() {
    if _cmp(row.at(col), _q(0)) > 0 {
      let key = (_div(tab.rhs.at(r), row.at(col)),) + tab.slack.map(s => _div(row.at(s), row.at(col)))
      if best == none or _lex-less(key, best-key) {
        best = r
        best-key = key
      }
    }
  }
  assert(best != none, message: "unbounded polytope: make the payoff matrix positive")
  best
}

#let _pivot(tab, row, col) = {
  let p = tab.T.at(row).at(col)
  let prow = tab.T.at(row).map(v => _div(v, p))
  let prhs = _div(tab.rhs.at(row), p)
  for r in range(tab.T.len()) {
    if r == row {
      tab.T.at(r) = prow
      tab.rhs.at(r) = prhs
    } else {
      let f = tab.T.at(r).at(col)
      tab.T.at(r) = tab.T.at(r).zip(prow).map(((a, b)) => _sub(a, _mul(f, b)))
      tab.rhs.at(r) = _sub(tab.rhs.at(r), _mul(f, prhs))
    }
  }
  tab.basis.at(row) = col
  tab
}

#let _normalize(v) = {
  let s = v.fold(_q(0), _add)
  v.map(a => _div(a, s))
}

// ---------------------------------------------------------------------------
// Symmetric version, as in the notes: polytope R z <= 1, z >= 0
// ---------------------------------------------------------------------------

// Returns (states, pivots, equilibrium). `states.at(t)` is the vertex v_t;
// `pivots.at(t - 1)` describes the step from v_(t-1) to v_t. Variable z_i
// is the inequality z_i >= 0 and w_i the slack of e_i^T R z <= 1.
#let lemke-howson-symmetric(R, k) = {
  let n = R.len()
  let tab = _tableau(R, range(n).map(i => ("z", i + 1, i + 1)) + range(n).map(i => ("w", i + 1, i + 1)))
  let states = (range(n).map(_ => _q(0)),)
  let pivots = ()
  let col = k - 1
  while true {
    let row = _ratio-test(tab, col)
    let leaving = tab.basis.at(row)
    tab = _pivot(tab, row, col)
    let label = tab.vars.at(leaving).at(2)
    let done = label == k
    pivots.push((
      entering: tab.vars.at(col),
      leaving: tab.vars.at(leaving),
      duplicate: if done { none } else { label },
    ))
    states.push(range(n).map(i => _value(tab, i)))
    if done { break }
    // Action `label` is represented twice: un-tighten its other inequality.
    col = calc.rem(leaving + n, 2 * n)
  }
  (states: states, pivots: pivots, equilibrium: _normalize(states.last()))
}

// ---------------------------------------------------------------------------
// Bimatrix version: P = {x >= 0 : C^T x <= 1}, Q = {y >= 0 : R y <= 1}
// ---------------------------------------------------------------------------

// Labels 1..m are Row's actions and m+1..m+n Column's. `states.at(t)` is the
// pair (x, y) after t pivots; each pivot records the polytope it happens in.
#let lemke-howson-bimatrix(R, C, k) = {
  let m = R.len()
  let n = R.at(0).len()
  let CT = range(n).map(j => range(m).map(i => C.at(i).at(j)))
  let tabs = (
    P: _tableau(CT, range(m).map(i => ("x", i + 1, i + 1)) + range(n).map(j => ("s", j + 1, m + j + 1))),
    Q: _tableau(R, range(n).map(j => ("y", j + 1, m + j + 1)) + range(m).map(i => ("r", i + 1, i + 1))),
  )
  let vertex(tabs) = (
    range(m).map(i => _value(tabs.P, i)),
    range(n).map(j => _value(tabs.Q, j)),
  )
  let states = (vertex(tabs),)
  let pivots = ()
  let side = if k <= m { "P" } else { "Q" }
  let label = k
  while true {
    let tab = tabs.at(side)
    let col = tab.vars.position(v => v.at(2) == label)
    let row = _ratio-test(tab, col)
    let leaving = tab.vars.at(tab.basis.at(row))
    tabs.at(side) = _pivot(tab, row, col)
    let done = leaving.at(2) == k
    pivots.push((
      polytope: side,
      entering: tab.vars.at(col),
      leaving: leaving,
      duplicate: if done { none } else { leaving.at(2) },
    ))
    states.push(vertex(tabs))
    if done { break }
    // The label just picked up is now duplicate: drop it in the other polytope.
    side = if side == "P" { "Q" } else { "P" }
    label = leaving.at(2)
  }
  let (x, y) = states.last()
  (states: states, pivots: pivots, equilibrium: (_normalize(x), _normalize(y)))
}

// ---------------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------------

#let lh-colors = (
  rgb("#1f5fa8"),
  rgb("#c0392b"),
  rgb("#2e8b57"),
  rgb("#d68910"),
  rgb("#7d3c98"),
  rgb("#17808a"),
)
#let lh-color(label) = lh-colors.at(calc.rem(label - 1, lh-colors.len()))

#let _clip(poly, c) = {
  let g(b) = b.zip(c).map(((x, y)) => x * y).sum()
  let out = ()
  for i in range(poly.len()) {
    let a = poly.at(i)
    let b = poly.at(calc.rem(i + 1, poly.len()))
    let (ga, gb) = (g(a), g(b))
    if ga >= -1e-12 { out.push(a) }
    if (ga >= -1e-12) != (gb >= -1e-12) {
      let t = ga / (ga - gb)
      out.push(a.zip(b).map(((u, v)) => u + t * (v - u)))
    }
  }
  out
}

#let _label-dot(pos, label, radius: .17) = {
  import cetz.draw: *
  circle(pos, radius: radius, fill: white, stroke: .6pt + lh-color(label))
  content(pos, text(fill: lh-color(label), size: 7.5pt, strong(str(label))))
}

// A labeled simplex for a player with 2 or 3 strategies, and Lemke-Howson
// paths on it. A strategy b lies in region r when region r's payoff
// sum_i M[r][i] b_i is maximal (best-response labels); the side or endpoint
// where b_i = 0 carries label `side-labels.at(i)`.
//
// `path` is a list of vertices (lists of rationals, unnormalized), drawn
// through their projections b / |b|_1; the zero vertex is drawn as the node
// labeled 0 outside the simplex. `steps` gives the step number shown next to
// each vertex (none to hide it); `label-end: false` hides it for the final
// vertex, which is circled.
#let labeled-simplex(
  M,
  region-labels,
  side-labels,
  coord: "x",
  path: (),
  steps: none,
  label-end: true,
  size: 2.6,
  name: none,
) = {
  import cetz.draw: *
  let dim = M.at(0).len()
  let V = if dim == 3 {
    ((0, 0), (size, 0), (size / 2, size * calc.sqrt(3) / 2))
  } else {
    ((0, 0), (size, 0))
  }
  let origin = if dim == 3 { (-.55, size * .42) } else { (size / 2, -.75) }
  let point(b) = {
    let s = b.sum()
    (
      V.zip(b).map(((p, w)) => p.at(0) * w / s).sum(),
      V.zip(b).map(((p, w)) => p.at(1) * w / s).sum(),
    )
  }
  let fM = M.map(row => row.map(v => if type(v) == array { _float(v) } else { float(v) }))

  // Best-response regions.
  for (r, row) in fM.enumerate() {
    let c = lh-color(region-labels.at(r))
    if dim == 3 {
      let poly = range(3).map(i => range(3).map(j => float(i == j)))
      for (s, other) in fM.enumerate() {
        if s != r and poly.len() > 0 { poly = _clip(poly, row.zip(other).map(((a, b)) => a - b)) }
      }
      if poly.len() < 3 { continue }
      let pts = poly.map(point)
      let area = calc.abs(range(pts.len()).map(i => {
        let (p, q) = (pts.at(i), pts.at(calc.rem(i + 1, pts.len())))
        p.at(0) * q.at(1) - q.at(0) * p.at(1)
      }).sum()) / 2
      if area < 1e-3 { continue }
      line(..pts, close: true, fill: c.lighten(78%), stroke: .4pt + c.lighten(30%))
      let ctr = (pts.map(p => p.at(0)).sum() / pts.len(), pts.map(p => p.at(1)).sum() / pts.len())
      if area < .15 {
        // Small region: label it near its longest edge on the boundary of
        // the simplex, away from the paths that cross its interior.
        let on-side(a, b) = range(3).any(j => calc.abs(a.at(j)) < 1e-9 and calc.abs(b.at(j)) < 1e-9)
        let best = none
        for i in range(poly.len()) {
          let (a, b) = (poly.at(i), poly.at(calc.rem(i + 1, poly.len())))
          let (p, q) = (pts.at(i), pts.at(calc.rem(i + 1, pts.len())))
          let len = calc.abs(p.at(0) - q.at(0)) + calc.abs(p.at(1) - q.at(1))
          if on-side(a, b) and (best == none or len > best.at(0)) {
            best = (len, ((p.at(0) + q.at(0)) / 2, (p.at(1) + q.at(1)) / 2))
          }
        }
        if best != none {
          let mid = best.at(1)
          ctr = (mid.at(0) + (ctr.at(0) - mid.at(0)) * .4, mid.at(1) + (ctr.at(1) - mid.at(1)) * .4)
        }
      }
      content(ctr, text(fill: c, size: if area < .15 { 7pt } else { 9pt }, strong(str(region-labels.at(r)))))
    } else {
      // On the segment b = (1 - t, t), region r is an interval of t.
      let (lo, hi) = (0.0, 1.0)
      for (s, other) in fM.enumerate() {
        if s == r { continue }
        let (a0, a1) = (row.at(0) - other.at(0), row.at(1) - other.at(1))
        let slope = a1 - a0
        if calc.abs(slope) < 1e-12 {
          if a0 < -1e-12 { (lo, hi) = (1.0, 0.0) }
        } else if slope > 0 {
          lo = calc.max(lo, -a0 / slope)
        } else {
          hi = calc.min(hi, -a0 / slope)
        }
      }
      if hi - lo < 1e-3 { continue }
      let (a, b) = (point((1 - lo, lo)), point((1 - hi, hi)))
      line(a, b, stroke: 5pt + c.lighten(60%))
      content(((a.at(0) + b.at(0)) / 2, .3), text(fill: c, size: 9pt, strong(str(region-labels.at(r)))))
    }
  }

  // Sides (or endpoints) where a coordinate is zero, and vertex names.
  if dim == 3 {
    let ctr = (size / 2, size * calc.sqrt(3) / 6)
    for i in range(3) {
      let (a, b) = (V.at(calc.rem(i + 1, 3)), V.at(calc.rem(i + 2, 3)))
      line(a, b, stroke: 1.6pt + lh-color(side-labels.at(i)))
      let mid = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
      let (dx, dy) = (mid.at(0) - ctr.at(0), mid.at(1) - ctr.at(1))
      let len = calc.sqrt(dx * dx + dy * dy)
      _label-dot((mid.at(0) + dx / len * .3, mid.at(1) + dy / len * .3), side-labels.at(i))
    }
    for (i, p) in V.enumerate() {
      let off = ((-.22, -.2), (.22, -.2), (-.3, .06)).at(i)
      content((p.at(0) + off.at(0), p.at(1) + off.at(1)), text(size: 8pt)[$bold(e)_#(i + 1)$])
    }
  } else {
    line(..V, stroke: .6pt + black)
    for i in range(2) {
      let p = V.at(1 - i)
      circle(p, radius: .06, fill: lh-color(side-labels.at(i)), stroke: none)
      _label-dot((p.at(0) + (if i == 0 { .38 } else { -.38 }), 0), side-labels.at(i))
      content((V.at(i).at(0), -.28), text(size: 8pt)[$bold(e)_#(i + 1)$])
    }
  }

  // The path.
  if path.len() > 0 {
    let is-zero(v) = v.all(a => a.at(0) == 0)
    let pts = path.map(v => if is-zero(v) { origin } else { point(v.map(_float)) })
    circle(origin, radius: .17, fill: white, stroke: .6pt + black)
    content(origin, text(size: 7.5pt)[$bold(0)$])
    for i in range(1, pts.len()) {
      let (a, b) = (pts.at(i - 1), pts.at(i))
      if calc.abs(a.at(0) - b.at(0)) + calc.abs(a.at(1) - b.at(1)) < 1e-9 { continue }
      // Shorten the segment so the arrowhead stops at the vertex dot.
      let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
      let len = calc.sqrt(dx * dx + dy * dy)
      let start = if is-zero(path.at(i - 1)) { (a.at(0) + dx / len * .17, a.at(1) + dy / len * .17) } else { a }
      let end = (b.at(0) - dx / len * .07, b.at(1) - dy / len * .07)
      line(start, end, stroke: .9pt + black, mark: (end: "stealth", fill: black, scale: .55))
    }
    let shown = ()
    for (i, p) in pts.enumerate() {
      if is-zero(path.at(i)) { continue }
      circle(p, radius: .055, fill: black, stroke: none)
      let hidden = not label-end and p == pts.last()
      if steps != none and steps.at(i) != none and p not in shown and not hidden {
        shown.push(p)
        content((p.at(0) + .1, p.at(1) + .08), anchor: "south-west", padding: .02, text(size: 7pt, fill: luma(25%), str(steps.at(i))))
      }
    }
    circle(pts.last(), radius: .1, fill: none, stroke: 1pt + black)
  }
}
