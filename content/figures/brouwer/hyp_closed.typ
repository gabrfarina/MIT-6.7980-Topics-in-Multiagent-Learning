// Dropping closedness: the only crossing sits at the omitted endpoint.
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
  graph(m, (0, 0), (1, 0.5))
  open-dot(m(0, 0)); full-dot(m(1, 0.5))
  content(m(0.72, 0.78), anchor: "south-east", text(fill: diag)[$f(x) = x$])
  content(m(0.88, 0.40), anchor: "north-west", text(fill: curve)[$f$])
  content(m(1, -0.06), anchor: "north")[$1$]
})
