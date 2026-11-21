// Distinguishable Good / Good' cards, and Bad's three announcements.
#set page(width: auto, height: auto, margin: .6mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 8pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let good = rgb("3d6ea8")
#let goodp = rgb("2a8a84")
#let bad = rgb("b45a55")
#let p1 = rgb("d07a3a")
#let p2 = rgb("7a6aa8")
#let p3 = rgb("4f9aa8")
#let elect = rgb("2f7d4a")

#cetz.canvas(length: .82cm, {
  import cetz.draw: *

  let seat(pos, name, fill) = {
    circle(pos, radius: 0.4, fill: fill, stroke: 0.6pt + luma(25%))
    content(pos, text(white, size: 7.5pt, weight: "bold", name))
  }

  let chip(origin, name, fill, width: 1.55) = {
    rect(
      origin,
      (origin.at(0) + width, origin.at(1) + 0.52),
      radius: 1.2pt,
      fill: fill,
      stroke: none,
    )
    content(
      (origin.at(0) + width / 2, origin.at(1) + 0.26),
      text(white, size: 6.6pt, weight: "bold", name),
    )
  }

  let panel(x, title, p1-say, elected, elected-name) = {
    rect((x, 0), (x + 4.55, 4.35), radius: 2pt, fill: luma(98%), stroke: 0.4pt + luma(80%))
    content((x + 2.275, 4.05), text(size: 7pt, weight: "bold", title))

    seat((x + 2.275, 3.15), [P1], p1)
    seat((x + 0.85, 1.55), [P3], p3)
    seat((x + 3.7, 1.55), [P2], p2)

    chip((x + 1.5, 2.45), p1-say, bad, width: 1.55)
    chip((x + 0.12, 0.85), [Good], good, width: 1.45)
    chip((x + 2.98, 0.85), [Good'], goodp, width: 1.45)

    content(
      (x + 2.275, 0.32),
      text(fill: elect, size: 7pt, weight: "bold")[elect #elected-name],
    )
    for pos in elected {
      circle(pos, radius: 0.48, stroke: 1.15pt + elect, fill: none)
    }
  }

  panel(0.0, [Bad copies Good], [Good], ((0.0 + 3.7, 1.55),), [P2 (Good')])
  panel(4.85, [Bad copies Good'], [Good'], ((4.85 + 0.85, 1.55),), [P3 (Good)])
  panel(
    9.7,
    [Bad says something else],
    [other],
    ((9.7 + 0.85, 1.55), (9.7 + 3.7, 1.55)),
    [P2 or P3],
  )
})
