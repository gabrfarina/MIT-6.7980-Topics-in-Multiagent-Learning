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
  content((7.6, 5.15), text(weight: "bold")[1. Nature sees the actual forecast before choosing the outcome])
  for (x, role, body, color) in (
    (0, [Forecaster], [Report $p_t$], blue),
    (5.4, [Nature], [See $p_t$; choose $y_t$], orange),
    (10.8, [Outcome], [Reveal $y_t$], gray),
  ) {
    rect((x, 3.2), (x + 4.4, 4.55), radius: 1.5mm,
      fill: color.transparentize(96%), stroke: .6pt + color)
    content((x + 2.2, 4.17), text(weight: "bold")[#role])
    content((x + 2.2, 3.6), body)
  }
  for x in (4.5, 9.9) {
    line((x, 3.88), (x + 0.8, 3.88), stroke: .8pt + gray,
      mark: (end: "stealth", fill: gray, scale: .6))
  }

  content((7.6, 2.55), text(weight: "bold")[2. Nature sees the distribution, but not the current private draw])
  for (x, role, body, color) in (
    (0, [Forecaster], [Announce $D_t$], blue),
    (4.0, [Nature], [Commit to hidden $y_t$], orange),
    (8.0, [Private draw], [Sample $p_t ~ D_t$], blue),
    (12.0, [Reveal], [Show $y_t$; update], gray),
  ) {
    rect((x, 0.55), (x + 3.2, 1.9), radius: 1.5mm,
      fill: color.transparentize(96%), stroke: .6pt + color)
    content((x + 1.6, 1.52), text(weight: "bold")[#role])
    content((x + 1.6, 0.95), body)
  }
  for x in (3.3, 7.3, 11.3) {
    line((x, 1.22), (x + 0.6, 1.22), stroke: .8pt + gray,
      mark: (end: "stealth", fill: gray, scale: .6))
  }
  content((7.6, -0.05), [Nature commits before seeing $p_t$; the forecaster learns $y_t$ only after its draw.])
})
