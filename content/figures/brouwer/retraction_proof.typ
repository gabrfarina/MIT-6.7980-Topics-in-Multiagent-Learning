// The contradiction in the proof. Step 4 puts the fixed point of f on the
// boundary; there r is the identity, so f sends it to the antipode. A point
// equal to its own negation would have to be the centre, which is not on the
// boundary.
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

  let a = 38deg
  // f carries the boundary point straight through the centre to the far side.
  line((a, 1), (a + 180deg, 1), stroke: .32mm + move,
       mark: (end: "straight", scale: .45, fill: move))

  circle((a, 1), radius: .07, fill: rim, stroke: none)
  circle((a + 180deg, 1), radius: .07, fill: rim, stroke: none)
  circle((0, 0), radius: .045, fill: move, stroke: none)

  content((a, 1.14), anchor: "south-west", text(fill: rim)[$bold(z)^*$])
  content((a + 180deg, 1.14), anchor: "north-east", text(fill: rim)[$-bold(z)^*$])
  content((0.06, -0.07), anchor: "north-west", text(size: 8.5pt, fill: move)[$0$])
  // Sit the label just off the arrow, partway along it.
  content((0.28, 0.45), anchor: "center", text(size: 8.5pt, fill: move)[$f$])
})
