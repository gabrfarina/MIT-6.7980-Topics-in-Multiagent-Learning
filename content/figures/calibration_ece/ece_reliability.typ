// Reliability diagram for calibration_ece.typ: two buckets, each with five rounds.
// The .typ source is the editable figure; the SVG is generated from it.
#set page(width: auto, height: auto, margin: 2mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let xscale = 6
  let yscale = 4.8
  let point-color = rgb("#2864a5")
  let gap-color = rgb("#bd5c1d")

  for k in range(0, 6) {
    let v = k / 5
    line((v*xscale, 0), (v*xscale, yscale), stroke: .2pt + luma(90%))
    line((0, v*yscale), (xscale, v*yscale), stroke: .2pt + luma(90%))
    line((v*xscale, 0), (v*xscale, -0.08), stroke: .5pt)
    line((0, v*yscale), (-0.08, v*yscale), stroke: .5pt)
    content((v*xscale, -0.17), anchor: "north", str(v))
    content((-0.16, v*yscale), anchor: "east", str(v))
  }

  line((0, 0), (xscale + .18, 0), stroke: .65pt)
  line((0, 0), (0, yscale + .18), stroke: .65pt)
  line((0, 0), (xscale, yscale), stroke: (paint: luma(45%), thickness: .7pt, dash: "dashed"))

  for (q, rate) in ((0.2, 0.4), (0.8, 0.6)) {
    line((q*xscale, q*yscale), (q*xscale, rate*yscale), stroke: gap-color + 1.4pt)
    circle((q*xscale, q*yscale), radius: .055, fill: white, stroke: luma(45%) + .7pt)
    circle((q*xscale, rate*yscale), radius: .085, fill: point-color, stroke: point-color)
  }

  content((1.45, 2.13), anchor: "west", box(fill: white, inset: 1.5pt)[$q=0.2$, $overline(y)_q=0.4$])
  content((4.55, 2.57), anchor: "east", box(fill: white, inset: 1.5pt)[$q=0.8$, $overline(y)_q=0.6$])
  content((0.96, 1.44), anchor: "east", text(fill: gap-color)[$0.2$])
  content((5.05, 3.36), anchor: "west", text(fill: gap-color)[$0.2$])
  content((3, -0.66), [Forecast probability $q$])
  content((-0.88, 2.4), angle: 90deg, [Observed event frequency $overline(y)_q$])
  content((3, 5.25), [Each point represents 5 of 10 forecasts])
})
