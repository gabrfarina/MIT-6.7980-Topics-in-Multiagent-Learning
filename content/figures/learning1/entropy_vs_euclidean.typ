#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../../meta/dyns.typ": brown
#import "../../meta/notation.typ": *

// FTRL on the three-action simplex with the fixed cumulated regret r below,
//   x_eta = argmax_x { <r, x> - psi(x) / eta },
// for the negative entropy (softmax) and the squared Euclidean norm (projection).
#let r = (1, 0.4, 0)
#let xlogx(x) = if x <= 0 { 0 } else { x * calc.ln(x) }
#let entropy(x) = x.map(xlogx).sum()
#let euclid(x) = x.map(v => v * v).sum() / 2
#let softmax(z) = {
  let m = calc.max(..z)
  let w = z.map(v => calc.exp(v - m))
  w.map(v => v / w.sum())
}
// Euclidean projection onto the simplex (sort-based algorithm).
#let project-simplex(y) = {
  let u = y.sorted().rev()
  let (k, cum, theta) = (0, 0, 0)
  for i in range(u.len()) {
    cum += u.at(i)
    let t = (cum - 1) / (i + 1)
    if u.at(i) - t > 0 { theta = t }
  }
  y.map(v => calc.max(v - theta, 0))
}
#let entropy-path(eta) = softmax(r.map(v => eta * v))
#let euclid-path(eta) = project-simplex(r.map(v => eta * v))

// Barycentric coordinates -> plane; action 1 bottom left, 2 top, 3 bottom right.
#let side = 3.4
#let corners = ((0, 0), (side / 2, side * calc.sqrt(3) / 2), (side, 0))
#let pt(x) = (0, 1).map(i => range(3).map(k => x.at(k) * corners.at(k).at(i)).sum())

#let low = rgb(150, 120, 200)
#let high = rgb(246, 243, 251)

#let N = 36
#let grid-pt(i, j) = (i / N, j / N, (N - i - j) / N)
#let triangles = {
  let tris = ()
  for i in range(N) {
    for j in range(N - i) {
      tris.push((grid-pt(i, j), grid-pt(i + 1, j), grid-pt(i, j + 1)))
      if i + j < N - 1 { tris.push((grid-pt(i + 1, j), grid-pt(i + 1, j + 1), grid-pt(i, j + 1))) }
    }
  }
  tris
}

// Shaded map of psi with level sets (marching triangles), plus the FTRL path
// eta -> x_eta for eta in [0, eta-max]. If `limit` is set, a dotted segment
// continues the path to its limit as eta -> oo.
#let panel(title, psi, levels, path, eta-max, marks, limit: none) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let (lo, hi) = (psi((1 / 3, 1 / 3, 1 / 3)), psi((1, 0, 0)))
  for tri in triangles {
    let level = (tri.map(psi).sum() / 3 - lo) / (hi - lo)
    let fill = color.mix((low, (1 - level) * 100%), (high, level * 100%), space: rgb)
    line(..tri.map(pt), close: true, fill: fill, stroke: .08mm + fill)
  }
  for c in levels {
    for tri in triangles {
      let vals = tri.map(psi)
      let crossings = ()
      for (a, b) in ((0, 1), (1, 2), (2, 0)) {
        let (fa, fb) = (vals.at(a), vals.at(b))
        if (fa - c) * (fb - c) < 0 {
          let s = (c - fa) / (fb - fa)
          crossings.push(pt(range(3).map(k => tri.at(a).at(k) + s * (tri.at(b).at(k) - tri.at(a).at(k)))))
        }
      }
      if crossings.len() == 2 { line(..crossings, stroke: .15mm + luma(45%)) }
    }
  }
  line(..corners, close: true, stroke: .3mm + luma(35%))
  content(corners.at(0), anchor: "north-east", padding: .06, $ve_1$)
  content(corners.at(1), anchor: "south", padding: .08, $ve_2$)
  content(corners.at(2), anchor: "north-west", padding: .06, $ve_3$)
  // Sample eta on a log scale from 10^-2 to eta-max.
  let top = calc.log(eta-max)
  let pts = (pt((1 / 3, 1 / 3, 1 / 3)),) + range(0, 201).map(i => pt(path(calc.pow(10, -2 + (top + 2) * i / 200))))
  line(..pts, stroke: .55mm + brown)
  if limit != none {
    let (target, anchor, body) = limit
    line(pts.last(), pt(target), stroke: (paint: brown, thickness: .35mm, dash: "dotted"))
    content(pt(target), anchor: anchor, padding: .1, text(size: 7.5pt, body))
  }
  for (eta, anchor, body) in marks {
    let p = pt(path(eta))
    circle(p, radius: .055, fill: brown, stroke: .15mm + white)
    content(p, anchor: anchor, padding: .1, text(size: 7.5pt, body))
  }
  circle(pt((1 / 3, 1 / 3, 1 / 3)), radius: .06, fill: white, stroke: .25mm + brown)
  content(pt((1 / 3, 1 / 3, 1 / 3)), anchor: "west", padding: .12, text(size: 7.5pt, $eta = 0$))
  content((side / 2, -.62), title)
})

#align(
  center,
  grid(
    columns: 2,
    column-gutter: 9mm,
    panel(
      [Entropy: $vx_eta = "softmax"(eta vr)$],
      entropy,
      (-1.08, -1.0, -0.9, -0.8, -0.65, -0.5, -0.3),
      entropy-path,
      4,
      ((1 / 2, "north", $1\/2$), (1, "south", $1$), (2, "south-east", $2$), (4, "south-east", $4$)),
      limit: ((1, 0, 0), "south-east", $eta -> oo$),
    ),
    panel(
      [Euclidean: $vx_eta = Pi_(Delta(A))(eta vr)$],
      euclid,
      (0.175, 0.2, 0.24, 0.29, 0.35, 0.42, 0.48),
      euclid-path,
      5 / 3,
      ((1 / 2, "south", $1\/2$), (5 / 7, "east", $5\/7$), (1, "west", $1$), (5 / 3, "south-east", $eta >= 5\/3$)),
    ),
  ),
)
