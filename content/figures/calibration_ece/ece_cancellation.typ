// Areas encode weight times gap. Reflection shows exactly what absolute value does.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  content((7.8, 6.0), [Same ten rounds: width = bucket weight; height = observed frequency minus forecast.])
  for (x, title) in ((.55, [1. Keep the signs]), (6.05, [2. Fold negative area upward]), (11.55, [3. Merge the buckets])) {
    content((x + 2, 5.25), text(weight: "bold")[#title])
    line((x, 3), (x + 4, 3), stroke: .7pt + luma(45%))
    for v in (-.2, 0, .2) {
      line((x - .08, 3 + 6*v), (x, 3 + 6*v), stroke: .5pt + luma(60%))
      content((x - .15, 3 + 6*v), anchor: "east", text(size: 8pt)[#str(v)])
    }
  }
  rect((.55, 3), (2.55, 4.2), fill: blue.transparentize(45%), stroke: .5pt + blue)
  rect((2.55, 1.8), (4.55, 3), fill: orange.transparentize(45%), stroke: .5pt + orange)
  content((1.55, 3.6), text(fill: blue)[$+0.1$])
  content((3.55, 2.4), text(fill: orange)[$-0.1$])
  content((1.55, 4.55), [$q=0.2$])
  content((3.55, 1.38), [$q=0.8$])
  content((2.55, .65), [$0.1-0.1=0$])
  content((2.55, .05), [Signed bias])

  rect((6.05, 3), (8.05, 4.2), fill: blue.transparentize(45%), stroke: .5pt + blue)
  rect((8.05, 3), (10.05, 4.2), fill: orange.transparentize(45%), stroke: .5pt + orange)
  rect((8.05, 1.8), (10.05, 3), fill: none,
    stroke: (paint: orange.transparentize(35%), thickness: .5pt, dash: "dashed"))
  content((7.05, 3.6), text(fill: blue)[$0.1$])
  content((9.05, 3.6), text(fill: orange)[$0.1$])
  bezier((9.35, 2.15), (9.35, 4.55), (11.1, 2.1), (11.1, 4.5),
    stroke: .8pt + orange, mark: (end: "stealth", scale: .6))
  content((8.05, .65), [$0.1+0.1=0.2$])
  content((8.05, .05), [ECE = total unsigned area])

  line((11.55, 3), (13.55, 3), stroke: 2pt + blue)
  line((13.55, 3), (15.55, 3), stroke: 2pt + orange)
  content((13.55, 4.15), [Mean forecast = 0.5])
  content((13.55, 3.65), [Mean outcome = 0.5])
  content((13.55, 2.25), [The pooled gap disappears])
  content((13.55, .65), [Coarse-bin gap = 0])
  content((13.55, .05), [Original ECE is still 0.2])
  content((7.8, -.7), [Each original bucket has width 1/2 and gap magnitude 0.2, so its area is 0.1.])
})
