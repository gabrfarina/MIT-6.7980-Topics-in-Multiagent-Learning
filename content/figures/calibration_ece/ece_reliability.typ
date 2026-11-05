// Editable observations-to-reliability figure for calibration_ece.typ.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let xscale = 6
  let yscale = 4.8
  let shift = 9.1
  let point-color = rgb("#2864a5")
  let gap-color = rgb("#bd5c1d")

  content((3.6, 5.4), [1. Group individual outcomes])
  for (q, positives, rate, row-y) in ((0.2, 2, 0.4, 3.7), (0.8, 3, 0.6, 1.2)) {
    content((0.25, row-y + 0.72), anchor: "west", [Same forecast: #str(q) on all 5 rounds])
    for i in range(5) {
      let positive = i < positives
      let pos = (0.55 + i*0.58, row-y)
      circle(pos, radius: .19, fill: if positive { point-color } else { white }, stroke: .7pt + point-color)
      content(pos, text(fill: if positive { white } else { black }, size: 8pt)[#if positive { [1] } else { [0] }])
    }
    content((3.35, row-y), anchor: "west", [Observed: #positives/5 = #str(rate)])
    content((0.25, row-y - 0.55), anchor: "west", [Weight: 5/10; absolute gap: 0.2])
  }
  content((3.6, -0.28), [One circle = one round; 1 = event, 0 = no event])

  content((shift + 3, 5.4), [2. Plot each bucket mean])
  for k in range(0, 6) {
    let v = k / 5
    line((shift + v*xscale, 0), (shift + v*xscale, yscale), stroke: .2pt + luma(90%))
    line((shift, v*yscale), (shift + xscale, v*yscale), stroke: .2pt + luma(90%))
    line((shift + v*xscale, 0), (shift + v*xscale, -0.08), stroke: .5pt)
    line((shift, v*yscale), (shift - 0.08, v*yscale), stroke: .5pt)
    content((shift + v*xscale, -0.17), anchor: "north", str(v))
    content((shift - 0.16, v*yscale), anchor: "east", str(v))
  }

  line((shift, 0), (shift + xscale + .18, 0), stroke: .65pt)
  line((shift, 0), (shift, yscale + .18), stroke: .65pt)
  line((shift, 0), (shift + xscale, yscale), stroke: (paint: luma(45%), thickness: .7pt, dash: "dashed"))

  for (q, rate) in ((0.2, 0.4), (0.8, 0.6)) {
    line((shift + q*xscale, q*yscale), (shift + q*xscale, rate*yscale), stroke: gap-color + 1.4pt)
    circle((shift + q*xscale, q*yscale), radius: .055, fill: white, stroke: luma(45%) + .7pt)
    circle((shift + q*xscale, rate*yscale), radius: .085, fill: point-color, stroke: point-color)
  }

  content((shift + 1.45, 2.13), anchor: "west", box(fill: white, inset: 1.5pt)[$q=0.2$, $overline(y)_q=0.4$])
  content((shift + 4.55, 2.57), anchor: "east", box(fill: white, inset: 1.5pt)[$q=0.8$, $overline(y)_q=0.6$])
  content((shift + 0.96, 1.44), anchor: "east", text(fill: gap-color)[$0.2$])
  content((shift + 5.05, 3.36), anchor: "west", text(fill: gap-color)[$0.2$])
  content((shift + 3, -0.66), [Forecast probability $q$])
  content((shift - 0.88, 2.4), angle: 90deg, [Observed event frequency $overline(y)_q$])
})
