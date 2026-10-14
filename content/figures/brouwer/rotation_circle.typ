// Dropping convexity: a quarter-turn rotation of the circle displaces every
// point, so it has no fixed point.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let curve = rgb("#0b6bcb")
#let hint = luma(45%)

#cetz.canvas({
  import cetz.draw: *

  circle((0, 0), radius: 1, stroke: .35mm + luma(60%), fill: none)

  // The motion is the same everywhere: short tangential arrows all around.
  for i in range(8) {
    let a = i * 45deg + 10deg
    arc(
      (a, 1),
      start: a,
      stop: a + 26deg,
      radius: 1,
        stroke: .38mm + luma(20%),
      mark: (end: "straight", scale: .5, fill: luma(20%)),
    )
  }

  // One point and its image, a quarter turn away.
  let za = -30deg
  arc(
    (za + 8deg, 1.28),
    start: za + 8deg,
    stop: za + 82deg,
    radius: 1.28,
    stroke: (thickness: .35mm, paint: curve, dash: "dashed"),
    mark: (end: "straight", scale: .4, fill: curve),
  )
  circle((za, 1), radius: .075, fill: curve, stroke: none)
  circle((za + 90deg, 1), radius: .075, fill: curve, stroke: none)
  content((za, 1.17), anchor: "north-west", text(fill: curve)[$bold(z)$])
  content((za + 90deg, 1.17), anchor: "south-west", text(fill: curve)[$f(bold(z))$])
})
