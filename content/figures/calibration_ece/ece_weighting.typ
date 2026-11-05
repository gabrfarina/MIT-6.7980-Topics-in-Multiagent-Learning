// Bucket weights are proportions of rounds, not equal votes per bucket.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  for (x, color, title, values, gap) in (
    (0, blue, [Bucket A: 90 rounds], [$q=0.5$, $overline(y)_q=45/90=0.5$], [Calibration gap: 0; weight: 0.9]),
    (7.8, orange, [Bucket B: 10 rounds], [$q=1$, $overline(y)_q=0/10=0$], [Calibration gap: 1; weight: 0.1]),
  ) {
    rect((x, 3.1), (x + 7.2, 5.1), radius: 1.5mm,
      fill: color.transparentize(96%), stroke: .6pt + color)
    content((x + 3.6, 4.65), text(weight: "bold")[#title])
    content((x + 3.6, 4.1), values)
    content((x + 3.6, 3.55), gap)
  }

  // Exactly 90% of the bar belongs to A, and 10% belongs to B.
  rect((0.5, 1.95), (13.1, 2.55), fill: blue.transparentize(82%), stroke: .5pt + blue)
  rect((13.1, 1.95), (14.5, 2.55), fill: orange.transparentize(25%), stroke: .5pt + orange)
  content((6.8, 2.25), [90% of the rounds])
  content((13.8, 2.25), [10%])
  content((7.5, 1.45), [A randomly selected round sees bucket B only one time in ten.])
  content((7.5, 0.7), text(size: 12pt)[$"ECE"=0.9 times 0+0.1 times 1=0.1$])
  content((7.5, 0), [Giving both buckets equal weight would instead give $(0+1)/2=0.5$.])
})
