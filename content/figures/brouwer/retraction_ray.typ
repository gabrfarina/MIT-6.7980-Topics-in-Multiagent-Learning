// The converse construction. A fixed-point-free f keeps f(z) away from z, so
// the ray from f(z) through z is well defined; r(z) is where it leaves the
// disk. A boundary point is reached at itself, so r fixes the rim.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let rim = rgb("#0b6bcb")
#let move = luma(25%)

#cetz.canvas({
  import cetz.draw: *
  scale(1.55)

  circle((0, 0), radius: 1, stroke: .5mm + rim)

  // f(z) and z are interior; the ray from f(z) through z exits at r(z).
  let fz = (-0.45, -0.25)
  let z = (0.15, 0.10)
  let rz = (0.858, 0.513)
  line(fz, rz, stroke: .32mm + move,
       mark: (end: "straight", scale: .45, fill: move))

  circle(fz, radius: .055, fill: move, stroke: none)
  circle(z, radius: .055, fill: move, stroke: none)
  circle(rz, radius: .07, fill: rim, stroke: none)

  content((-0.45, -0.34), anchor: "north", text(fill: move)[$f(bold(z))$])
  content((0.10, 0.18), anchor: "south-east", text(fill: move)[$bold(z)$])
  content((0.93, 0.58), anchor: "south-west", text(fill: rim)[$r(bold(z))$])
})
