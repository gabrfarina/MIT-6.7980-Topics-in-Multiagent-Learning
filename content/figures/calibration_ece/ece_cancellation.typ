// The existing ten-round example, viewed before/after aggregation.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  content((7.5, 5.45), [Each bar is a bucket's weighted signed contribution: $(N_q/T)(overline(y)_q-q)$.])
  line((3.3, 4.65), (11.8, 4.65), stroke: .6pt + luma(50%))
  line((7.5, 2.0), (7.5, 4.85), stroke: .7pt + luma(50%))
  for (x, label) in ((3.5, [$-0.1$]), (7.5, [$0$]), (11.5, [$+0.1$])) {
    line((x, 4.58), (x, 4.72), stroke: .6pt)
    content((x, 4.98), label)
  }
  content((0.4, 3.95), anchor: "west", [$q=0.2$])
  content((0.4, 3.5), anchor: "west", [Frequency 0.4])
  rect((7.5, 3.55), (11.5, 4.05), fill: blue.transparentize(15%), stroke: none)
  content((11.75, 3.8), anchor: "west", text(fill: blue)[$+0.1$])
  content((0.4, 2.65), anchor: "west", [$q=0.8$])
  content((0.4, 2.2), anchor: "west", [Frequency 0.6])
  rect((3.5, 2.25), (7.5, 2.75), fill: orange.transparentize(15%), stroke: none)
  content((3.25, 2.5), anchor: "east", text(fill: orange)[$-0.1$])

  for (x, title, middle, bottom) in (
    (0, [Signed bias], [$+0.1-0.1=0$], [Opposite signs cancel]),
    (5.1, [Exact-bucket ECE], [$abs(0.1)+abs(-0.1)=0.2$], [Absolute gaps add]),
    (10.2, [One merged bin], [Both means are 0.5], [Coarse-bin gap: 0]),
  ) {
    rect((x, -0.1), (x + 4.8, 1.5), radius: 1.5mm,
      fill: luma(98%), stroke: .5pt + luma(78%))
    content((x + 2.4, 1.15), text(weight: "bold")[#title])
    content((x + 2.4, 0.65), middle)
    content((x + 2.4, 0.15), bottom)
  }
})
