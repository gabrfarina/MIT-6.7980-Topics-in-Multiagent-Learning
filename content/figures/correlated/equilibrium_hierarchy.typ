#set page(width: auto, height: auto, fill: none, margin: (top: 0mm, bottom: 0mm, left: 0mm, right: 2mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Joint distributions mu = (mu_11, mu_12, mu_21, mu_22) of a 2x2 game, drawn as
// points of the tetrahedron whose corners are the four pure outcomes. With the
// corners below, the product distributions (p, 1-p) x (q, 1-q) form the saddle
// surface z = x y over the square [-1, 1]^2, where x = 2p - 1 and y = 2q - 1.
#let corners = ((1, 1, 1), (1, -1, -1), (-1, 1, -1), (-1, -1, 1))
#let embed(mu) = range(3).map(k => range(4).map(i => mu.at(i) * corners.at(i).at(k)).sum())

// Game: both players get payoff matrix diag(2, 1). Corners of its correlated
// equilibrium polytope, computed exactly from the four incentive constraints.
#let ce-vertices = (
  (1, 0, 0, 0),
  (0, 0, 0, 1),
  (1 / 9, 2 / 9, 2 / 9, 4 / 9),
  (1 / 7, 0, 2 / 7, 4 / 7),
  (1 / 7, 2 / 7, 0, 4 / 7),
)
// Each face is a triangle of tight constraints (indices into ce-vertices).
#let ce-faces = ((1, 3, 0), (1, 4, 0), (0, 2, 4), (2, 3, 1), (0, 2, 3), (2, 4, 1))
// Nash equilibria: the two pure ones and the mixed one with p = q = 1/3.
#let nash = ((1, 0, 0, 0), (0, 0, 0, 1), (1 / 9, 2 / 9, 2 / 9, 4 / 9))

// Orthographic view: rotate about the vertical axis, then tilt.
#let az = -15deg
#let el = 18deg
#let scale = 2.1
#let view(p) = {
  let (x, y, z) = p
  let u = calc.cos(az) * x - calc.sin(az) * y
  let d = calc.sin(az) * x + calc.cos(az) * y
  (scale * u, scale * (calc.cos(el) * z - calc.sin(el) * d))
}
#let at(mu) = view(embed(mu))

// Depth toward the viewer, and vector helpers for back-face tests.
#let toward = (calc.cos(el) * calc.sin(az), calc.cos(el) * calc.cos(az), calc.sin(el))
#let dot3(a, b) = range(3).map(k => a.at(k) * b.at(k)).sum()
#let sub3(a, b) = range(3).map(k => a.at(k) - b.at(k))
#let cross3(a, b) = (
  a.at(1) * b.at(2) - a.at(2) * b.at(1),
  a.at(2) * b.at(0) - a.at(0) * b.at(2),
  a.at(0) * b.at(1) - a.at(1) * b.at(0),
)
// A triangle faces the viewer if its normal, oriented away from the solid's center, points toward the viewer.
#let faces-viewer(tri, center) = {
  let n = cross3(sub3(tri.at(1), tri.at(0)), sub3(tri.at(2), tri.at(0)))
  let n = if dot3(n, sub3(tri.at(0), center)) < 0 { n.map(c => -c) } else { n }
  dot3(n, toward) > 0
}
// Draw edges of a convex solid: dashed if both adjacent faces point away.
#let edge-front(faces, front, i, j) = faces.enumerate().any(((k, f)) => front.at(k) and f.contains(i) and f.contains(j))

#let blue = rgb("#1f5cb8")
#let orange = rgb("#c4621a")
#let hidden = (dash: "dashed", thickness: 0.45pt)

#cetz.canvas(length: 1cm, {
  import cetz.draw: *

  // Tetrahedron of joint distributions.
  let tet-faces = ((0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3))
  let tet-front = tet-faces.map(f => faces-viewer(f.map(i => corners.at(i)), (0, 0, 0)))

  // Correlated equilibria (equal to coarse correlated equilibria in 2x2 games): back faces first.
  let ce-pts = ce-vertices.map(embed)
  let ce-center = range(3).map(k => ce-pts.map(p => p.at(k)).sum() / ce-pts.len())
  let ce-front = ce-faces.map(f => faces-viewer(f.map(i => ce-pts.at(i)), ce-center))
  for (k, f) in ce-faces.enumerate() {
    if not ce-front.at(k) {
      line(..f.map(i => view(ce-pts.at(i))), close: true, fill: orange.transparentize(90%), stroke: none)
    }
  }
  for (i, j) in ((0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (2, 3), (2, 4)) {
    if not edge-front(ce-faces, ce-front, i, j) and ce-faces.any(f => f.contains(i) and f.contains(j)) {
      line(view(ce-pts.at(i)), view(ce-pts.at(j)), stroke: (paint: orange, ..hidden))
    }
  }

  // Product distributions: grid lines p = const and q = const are straight.
  // Segments on the far side of the saddle are drawn fainter.
  let n = 8
  let m = 16
  let grid-seg(a, b) = {
    for r in range(m) {
      let p0 = range(3).map(k => a.at(k) + (b.at(k) - a.at(k)) * r / m)
      let p1 = range(3).map(k => a.at(k) + (b.at(k) - a.at(k)) * (r + 1) / m)
      let mid = range(3).map(k => (p0.at(k) + p1.at(k)) / 2)
      let fade = if dot3(mid, toward) < 0 { 72% } else { 25% }
      line(view(p0), view(p1), stroke: (paint: blue.transparentize(fade), thickness: 0.5pt))
    }
  }
  for k in range(n + 1) {
    let s = 2 * k / n - 1
    grid-seg((s, -1, -s), (s, 1, s))
    grid-seg((-1, s, -s), (1, s, s))
  }

  // Front faces and edges of the correlated equilibrium polytope.
  for (k, f) in ce-faces.enumerate() {
    if ce-front.at(k) {
      line(..f.map(i => view(ce-pts.at(i))), close: true, fill: orange.transparentize(72%), stroke: none)
    }
  }
  for (i, j) in ((0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (2, 3), (2, 4)) {
    if edge-front(ce-faces, ce-front, i, j) {
      line(view(ce-pts.at(i)), view(ce-pts.at(j)), stroke: (paint: orange, thickness: 1pt))
    }
  }

  // Tetrahedron edges on top, so its four corners read as one solid.
  for (i, j) in ((0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)) {
    let style = if edge-front(tet-faces, tet-front, i, j) { (paint: luma(60), thickness: 0.9pt) } else { (paint: luma(60), dash: "dashed", thickness: 0.6pt) }
    line(view(corners.at(i)), view(corners.at(j)), stroke: style)
  }

  // Nash equilibria; the mixed one is labelled.
  for mu in nash {
    circle(at(mu), radius: 0.085, fill: black, stroke: (paint: white, thickness: 0.7pt))
  }
  let mixed = at(nash.at(2))
  let tag = (-2.3, mixed.at(1) - 0.2)
  line(mixed, tag, stroke: (paint: black, thickness: 0.4pt))
  content(tag, anchor: "east", padding: 0.06, [$p = q = 1/3$])

  // Pure outcomes at the corners.
  let labels = ([$(1, 1)$], [$(1, 2)$], [$(2, 1)$], [$(2, 2)$])
  let anchors = ("south-west", "north-west", "north-east", "south-east")
  for i in range(4) {
    content(view(corners.at(i)), anchor: anchors.at(i), padding: 0.12, labels.at(i))
  }

  // Legend.
  let (lx, ly) = (2.2, -2.05)
  line((lx, ly), (lx + 0.5, ly), stroke: (paint: blue, thickness: 0.8pt))
  content((lx + 0.65, ly), anchor: "west", [product distributions])
  rect((lx, ly - 0.55), (lx + 0.5, ly - 0.25), fill: orange.transparentize(72%), stroke: (paint: orange, thickness: 1pt))
  content((lx + 0.65, ly - 0.4), anchor: "west", [correlated equilibria (= CCE here)])
  circle((lx + 0.25, ly - 0.8), radius: 0.085, fill: black, stroke: (paint: white, thickness: 0.7pt))
  content((lx + 0.65, ly - 0.8), anchor: "west", [Nash equilibria])
})
