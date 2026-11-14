// Both rules are empirically calibrated; only one uses the observed context.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue = rgb("#2864a5")
  let orange = rgb("#bd5c1d")
  let xs = 5.2
  let ys = 3.5
  let y0 = 1.8
  content((7.7, 7.0), [Contexts A and B are equally common: A always yields 0, B always yields 1.])
  for (x0, title) in ((1.0, [Always report 0.5]), (9.2, [Use the observed context])) {
    content((x0 + xs/2, 6.25), text(weight: "bold")[#title])
    for v in (0, 0.5, 1) {
      line((x0 + v*xs, y0), (x0 + v*xs, y0 + ys), stroke: .2pt + luma(90%))
      line((x0, y0 + v*ys), (x0 + xs, y0 + v*ys), stroke: .2pt + luma(90%))
      content((x0 + v*xs, y0 - .22), str(v))
      content((x0 - .25, y0 + v*ys), str(v))
    }
    line((x0, y0), (x0 + xs + .12, y0), stroke: .6pt)
    line((x0, y0), (x0, y0 + ys + .12), stroke: .6pt)
    line((x0, y0), (x0 + xs, y0 + ys), stroke: (paint: luma(50%), thickness: .7pt, dash: "dashed"))
    content((x0 + xs/2, 1.05), [Forecast probability $q$])
    content((x0 - .8, y0 + ys/2), angle: 90deg, [Observed frequency $overline(y)_q$])
  }
  circle((3.6, 3.55), radius: .13, fill: blue, stroke: blue)
  content((3.6, 4.12), box(fill: white, inset: 1pt)[$(q,overline(y)_q)=(0.5,0.5)$])
  content((3.6, 3.05), box(fill: white, inset: 1pt)[One bucket: all rounds])
  circle((9.2, 1.8), radius: .11, fill: blue, stroke: blue)
  circle((14.4, 5.3), radius: .11, fill: blue, stroke: blue)
  content((9.65, 2.3), anchor: "west", box(fill: white, inset: 1pt)[A: $(0,0)$])
  content((13.95, 4.78), anchor: "east", box(fill: white, inset: 1pt)[B: $(1,1)$])
  for (x, loss) in ((0, [$1/4$]), (8.2, [$0$])) {
    content((x + 3.6, .4), text(fill: blue)[$"ECE"=0$])
    content((x + 3.6, 0), [Mean squared prediction loss: #loss])
  }
})
