// Dropping continuity: the step leaps over the diagonal at x = 1/2.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/fixedpoint.typ": *

#cetz.canvas({
  import cetz.draw: *
  let m = mkq(-0.22, -0.22, 1.55)
  axes(m, -0.16, 1.3, -0.16, 1.3)
  diagonal(m, 0, 1.2)
  graph(m, (0, 1), (0.5, 1))
  graph(m, (0.5, 0), (1, 0))
  full-dot(m(0, 1)); open-dot(m(0.5, 1))
  full-dot(m(0.5, 0)); full-dot(m(1, 0))
  content(m(0.84, 0.44), anchor: "center", text(fill: diag)[$f(x) = x$])
  content(m(0.25, 1.05), anchor: "south", text(fill: curve)[$f$])
  content(m(0.5, -0.06), anchor: "north")[$1\/2$]
  content(m(1, -0.06), anchor: "north")[$1$]
  content(m(-0.06, 1), anchor: "east")[$1$]
})
