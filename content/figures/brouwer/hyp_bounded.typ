// Dropping boundedness: a translation runs parallel to the diagonal forever.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/fixedpoint.typ": *

#cetz.canvas({
  import cetz.draw: *
  let m = mkq(-1.35, -1.35, 3.2)
  axes(m, -1.3, 1.78, -1.3, 1.78)
  diagonal(m, -1.25, 1.7)
  graph(m, (-1.25, -0.25), (0.72, 1.72))
  content(m(1.32, 1.26), anchor: "north-west", text(fill: diag)[$f(x) = x$])
  content(m(0.44, 1.52), anchor: "south-east", text(fill: curve)[$f$])
})
