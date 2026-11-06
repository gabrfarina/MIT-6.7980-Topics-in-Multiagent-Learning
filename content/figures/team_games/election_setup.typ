// Three-player election: seats and indistinguishable role cards.
#set page(width: auto, height: auto, margin: .6mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 8pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let good = rgb("3d6ea8")
#let bad = rgb("b45a55")
#let p1 = rgb("d07a3a")
#let p2 = rgb("7a6aa8")
#let p3 = rgb("4f9aa8")

#cetz.canvas(length: .95cm, {
  import cetz.draw: *

  let seat(pos, name, fill) = {
    circle(pos, radius: 0.46, fill: fill, stroke: 0.65pt + luma(25%))
    content(pos, text(white, size: 8pt, weight: "bold", name))
  }

  let card(origin, name, fill) = {
    rect(
      origin,
      (origin.at(0) + 1.05, origin.at(1) + 1.35),
      radius: 1.6pt,
      fill: fill,
      stroke: 0.5pt + luma(35%),
    )
    content(
      (origin.at(0) + 0.525, origin.at(1) + 0.67),
      text(white, size: 7.2pt, weight: "bold", name),
    )
  }

  seat((1.7, 2.55), [P1], p1)
  seat((0.45, 0.7), [P3], p3)
  seat((2.95, 0.7), [P2], p2)

  line((1.7, 2.05), (0.75, 1.1), stroke: 0.45pt + luma(65%))
  line((1.7, 2.05), (2.65, 1.1), stroke: 0.45pt + luma(65%))
  line((0.85, 0.7), (2.55, 0.7), stroke: 0.45pt + luma(65%))

  card((3.85, 1.35), [Good], good)
  card((5.05, 1.35), [Good], good)
  card((6.25, 1.35), [Bad], bad)

  content((5.575, 0.95), text(size: 7pt, fill: luma(35%))[dealt privately])
})
