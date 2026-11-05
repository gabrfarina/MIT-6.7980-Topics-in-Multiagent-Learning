// The timing changes which current-round information Nature may use.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  let gray = luma(50%)
  content((7.6, 6.25), text(weight: "bold")[1. Nature sees the actual forecast before choosing the outcome])
  line((2.3, 4.75), (7.15, 4.75), stroke: .9pt + blue,
    mark: (end: "stealth", scale: .7))
  line((8.55, 4.75), (13.1, 4.75), stroke: .8pt + gray,
    mark: (end: "stealth", scale: .7))
  circle((1.8, 4.75), radius: .4, fill: blue, stroke: none)
  content((1.8, 4.75), text(fill: white)[$p_t$])
  // An eye: the current sampled value is visible before Nature acts.
  bezier((7.2, 4.75), (8.4, 4.75), (7.55, 5.35), (8.05, 5.35), stroke: .8pt + orange)
  bezier((7.2, 4.75), (8.4, 4.75), (7.55, 4.15), (8.05, 4.15), stroke: .8pt + orange)
  circle((7.8, 4.75), radius: .18, fill: orange, stroke: none)
  content((4.7, 5.3), text(fill: blue)[Actual value is visible])
  circle((13.8, 4.75), radius: .4, fill: gray, stroke: none)
  content((13.8, 4.75), text(fill: white)[$y_t$])
  for (x, role, body) in ((1.8, [Forecaster], [Report $p_t$]), (7.8, [Nature], [See $p_t$; choose $y_t$]), (13.8, [Outcome], [Reveal $y_t$])) {
    content((x, 3.95), text(weight: "bold")[#role])
    content((x, 3.4), body)
  }

  content((7.6, 2.45), text(weight: "bold")[2. Nature sees the distribution, but not the current private draw])
  // The three stems represent a generic public distribution, not a proposed algorithm.
  for (x, h) in ((1.15, .45), (1.75, 1.0), (2.35, .7)) {
    line((x, .45), (x, .45 + h), stroke: 1.3pt + blue)
    circle((x, .45 + h), radius: .08, fill: blue, stroke: none)
  }
  line((.9, .45), (2.6, .45), stroke: .6pt + gray)
  for (x1, x2) in ((2.85, 4.8), (6.0, 8.45), (10.5, 13.05)) {
    line((x1, .9), (x2, .9), stroke: .7pt + gray, mark: (end: "stealth", scale: .6))
  }
  circle((5.4, .9), radius: .4, fill: orange, stroke: none)
  content((5.4, .9), text(fill: white)[$y_t$])
  // Private sampling branches: Nature's outcome has already been committed.
  line((8.8, .9), (9.8, 1.48), stroke: .8pt + blue)
  line((8.8, .9), (9.8, .32), stroke: .8pt + blue)
  circle((9.8, 1.48), radius: .12, fill: blue, stroke: none)
  circle((9.8, .32), radius: .12, fill: white, stroke: .8pt + blue)
  content((10.25, 1.48), [$p_i$])
  content((10.25, .32), [$p_j$])
  circle((13.8, .9), radius: .4, fill: gray, stroke: none)
  content((13.8, .9), text(fill: white)[$y_t$])
  for (x, role, body) in ((1.75, [Public distribution], [Announce $D_t$]), (5.4, [Nature commits], [Keep $y_t$ hidden]), (9.5, [Private draw], [Sample $p_t ~ D_t$]), (13.8, [Reveal], [Show $y_t$; update])) {
    content((x, -.25), text(weight: "bold")[#role])
    content((x, -.8), body)
  }
  content((7.6, -1.55), [Nature commits before seeing $p_t$; the forecaster learns $y_t$ only after its draw.])
})
