#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 1mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot

// Data: content/notebooks/learning2/last_iterate_figures.ipynb (game U(delta), delta = 0.01).
// Rows are [log10 t, log10 min, log10 max] over logarithmic bins of t.
#let data = json("comparison.json")
#let colors = (rgb(31, 90, 190), rgb(214, 96, 0), rgb(118, 64, 160), rgb(46, 125, 50))
#let x-ticks = ((0, $1$), (1, $10$), (2, $10^2$), (3, $10^3$), (4, $10^4$), (5, $10^5$))

#let band(rows, color) = {
  let lo = rows.map(r => (r.at(0), r.at(1)))
  let hi = rows.map(r => (r.at(0), r.at(2)))
  plot.add-fill-between(lo, hi, style: (fill: color.transparentize(65%), stroke: .7pt + color))
}

#let gap-panel = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  plot.plot(
    size: (6.6, 4.8),
    axis-style: "scientific",
    x-min: 0, x-max: 5, y-min: -12.5, y-max: 0.6,
    x-tick-step: none, y-tick-step: none,
    x-ticks: x-ticks,
    y-ticks: ((0, $1$), (-3, $10^(-3)$), (-6, $10^(-6)$), (-9, $10^(-9)$), (-12, $10^(-12)$)),
    x-label: $t$, y-label: [Saddle-point gap],
    {
      for (i, a) in data.algorithms.enumerate() { band(a.gap, colors.at(i)) }
    },
  )
  content((3.3, 5.2))[Saddle-point gap of $(x^((t)), y^((t)))$]
})

#let boundary-panel = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  plot.plot(
    size: (6.6, 4.8),
    axis-style: "scientific",
    x-min: 0, x-max: 5, y-min: -41, y-max: 0.6,
    x-tick-step: none, y-tick-step: none,
    x-ticks: x-ticks,
    y-ticks: ((0, $1$), (-10, $10^(-10)$), (-20, $10^(-20)$), (-30, $10^(-30)$), (-40, $<= 10^(-40)$)),
    x-label: $t$, y-label: $x_2^((t))$,
    {
      plot.add-hline(calc.log(data.delta / (1 + data.delta)),
        style: (stroke: (paint: luma(30%), thickness: .6pt, dash: "dashed")))
      for (i, a) in data.algorithms.enumerate() { band(a.x2, colors.at(i)) }
    },
  )
  content((3.3, 5.2))[Distance from the boundary: $x_2^((t)) = 1 - x_1^((t))$]
})

#let key(color, body) = box(baseline: -2pt, line(length: 6mm, stroke: 1.6pt + color)) + h(1.2mm) + body

#align(center, stack(
  dir: ttb,
  spacing: 3mm,
  stack(dir: ltr, spacing: 7mm, gap-panel, boundary-panel),
  grid(
    columns: 3,
    column-gutter: 7mm,
    row-gutter: 1.8mm,
    align: left,
    ..data.algorithms.enumerate().map(((i, a)) => key(colors.at(i))[#a.name]),
    box(baseline: -2pt, line(length: 6mm, stroke: (paint: luma(30%), thickness: .6pt, dash: "dashed"))) + h(1.2mm) + [equilibrium value $x_2^* = delta\/(1 + delta)$],
  ),
))
