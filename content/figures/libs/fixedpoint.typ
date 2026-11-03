// Shared drawing helpers for the fixed-point panels in the Brouwer notes.
// A fixed point is a crossing of the graph with the diagonal, so every panel
// pairs a dashed diagonal with a graph that avoids it. Panels use square data
// windows so the diagonal is drawn at a true 45 degrees.
#import "@preview/cetz:0.4.1"

#let W = 3.0
#let curve = rgb("#0b6bcb")
#let diag = luma(45%)

// Square window of the given side, so x and y share one scale.
#let mkq(x0, y0, side) = (x, y) => ((x - x0) / side * W, (y - y0) / side * W)

#let axes(m, x0, x1, y0, y1) = {
  import cetz.draw: *
  line(m(x0, 0), m(x1, 0), stroke: .25mm + luma(30%), mark: (end: "straight", scale: .35))
  line(m(0, y0), m(0, y1), stroke: .25mm + luma(30%), mark: (end: "straight", scale: .35))
}
#let diagonal(m, a, b) = {
  import cetz.draw: *
  line(m(a, a), m(b, b), stroke: (thickness: .25mm, paint: diag, dash: "dashed"))
}
#let graph(m, a, b) = {
  import cetz.draw: *
  line(m(a.at(0), a.at(1)), m(b.at(0), b.at(1)), stroke: .55mm + curve)
}
#let open-dot(p) = {
  import cetz.draw: *
  circle(p, radius: .07, fill: white, stroke: .3mm + curve)
}
#let full-dot(p) = {
  import cetz.draw: *
  circle(p, radius: .07, fill: curve, stroke: none)
}
