// Dropping the self-map condition: the graph leaves the box before it can cross.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/fixedpoint.typ": *

#cetz.canvas({
  import cetz.draw: *
  let m = mkq(-0.32, -0.32, 2.75)
  axes(m, -0.24, 2.32, -0.24, 2.32)
  rect(m(0, 0), m(1, 1), stroke: (thickness: .22mm, paint: luma(55%), dash: "dotted"))
  diagonal(m, 0, 2.2)
  graph(m, (0, 1), (1, 2))
  full-dot(m(0, 1)); full-dot(m(1, 2))
  content(m(1.74, 1.68), anchor: "north-west", text(fill: diag)[$f(x) = x$])
  content(m(0.62, 1.70), anchor: "south-east", text(fill: curve)[$f$])
  content(m(0.92, 0.10), anchor: "south-east", text(size: 7pt, fill: luma(40%))[$K$])
  content(m(1, -0.06), anchor: "north")[$1$]
})
