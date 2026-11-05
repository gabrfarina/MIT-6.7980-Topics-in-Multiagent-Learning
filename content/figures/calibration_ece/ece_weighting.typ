// Counting picture and unit-area picture encode the same 100-round example.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  content((2.25, 5.65), text(weight: "bold")[1. Count 100 rounds])
  content((10.7, 5.65), text(weight: "bold")[2. Turn weight and gap into area])
  for col in range(10) {
    for row in range(10) {
      let color = if col < 9 { blue } else { orange }
      let positive = col < 9 and row < 5
      circle((.35 + col*.42, 4.95 - row*.36), radius: .115,
        fill: if positive { color } else { white }, stroke: .7pt + color)
    }
  }
  content((2.25, 1.02), text(fill: blue)[$q=0.5$: 45 of 90 positive])
  content((2.25, .49), text(fill: orange)[$q=1$: 0 of 10 positive])
  content((2.25, -.12), [Filled = 1; hollow = 0])
  line((5.0, 3.25), (6.8, 3.25), stroke: .9pt + luma(45%),
    mark: (end: "stealth", scale: .7))
  content((5.9, 3.75), [Same rounds])

  let x = 8.3
  let y = 1.25
  let s = 3.6
  // A unit square: x is fraction of rounds, y is absolute calibration gap.
  rect((x + .9*s, y), (x + s, y + s), fill: orange.transparentize(25%), stroke: none)
  for k in range(11) {
    line((x + s*k/10, y), (x + s*k/10, y + s), stroke: .25pt + luma(86%))
    line((x, y + s*k/10), (x + s, y + s*k/10), stroke: .25pt + luma(86%))
  }
  line((x, y + s), (x + s, y + s), stroke: .5pt + luma(70%))
  line((x + s, y), (x + s, y + s), stroke: .5pt + luma(70%))
  line((x, y), (x + s, y), stroke: 2pt + blue)
  line((x + .9*s, y), (x + s, y), stroke: 2pt + orange)
  line((x, y), (x, y + s), stroke: .6pt + luma(45%))
  for v in (0, .5, 1) { content((x - .22, y + s*v), anchor: "east", str(v)) }
  content((x - .87, y + s/2), angle: 90deg, [Absolute gap])
  content((x + .45*s, y + s/2), text(fill: blue)[90 rounds; gap 0])
  content((x + .45*s, y + s/2 - .5), text(fill: blue)[Zero area])
  content((x + .45*s, y - .35), text(fill: blue)[$90/100$])
  content((x + .95*s, y - .35), text(fill: orange)[$10/100$])
  line((x + .95*s, y + .75*s), (14.45, y + .75*s), stroke: .6pt + orange)
  content((14.45, y + .75*s + .5), text(fill: orange)[Area 0.1])
  content((10.1, .12), [Width = share of all rounds])
  content((7.4, -.8), text(size: 11pt)[$"ECE" = 0.9 times 0 + 0.1 times 1 = 0.1$])
})
