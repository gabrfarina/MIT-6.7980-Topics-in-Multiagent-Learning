#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 1mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot

// Data: content/notebooks/learning2/last_iterate_figures.ipynb. Rows are
// [log10 t, log10 min gap, log10 max gap] over logarithmic bins of t.
#let data = json("last_vs_average.json")
#let brown = rgb(149, 69, 53)
#let blue = rgb(31, 90, 190)

#let x-ticks = ((0, $1$), (1, $10$), (2, $10^2$), (3, $10^3$), (4, $10^4$))
#let y-ticks = ((0, $1$), (-3, $10^(-3)$), (-6, $10^(-6)$), (-9, $10^(-9)$), (-12, $10^(-12)$))

#let band(rows, color) = {
  let lo = rows.map(r => (r.at(0), r.at(1)))
  let hi = rows.map(r => (r.at(0), r.at(2)))
  plot.add-fill-between(lo, hi, style: (fill: color.transparentize(55%), stroke: .9pt + color))
}
#let mid(rows) = rows.map(r => (r.at(0), (r.at(1) + r.at(2)) / 2))

#let panel(p, title) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  plot.plot(
    size: (6.4, 4.8),
    axis-style: "scientific",
    x-min: 0, x-max: 4, y-min: -12.5, y-max: 0.6,
    x-tick-step: none, y-tick-step: none,
    x-ticks: x-ticks, y-ticks: y-ticks,
    x-label: $t$, y-label: [Saddle-point gap],
    {
      band(p.plain.last, brown)
      band(p.optimistic.last, blue)
      plot.add(mid(p.plain.average), style: (stroke: (paint: brown, thickness: 1.6pt, dash: "dashed")))
      plot.add(mid(p.optimistic.average), style: (stroke: (paint: blue, thickness: 1.6pt, dash: "dashed")))
    },
  )
  content((3.2, 5.2))[#title]
})

#let key(color, dash, body) = box(baseline: -2pt, line(length: 8mm, stroke: (paint: color, thickness: 1.6pt, dash: dash))) + h(1.2mm) + body

#align(center, stack(
  dir: ttb,
  spacing: 2mm,
  stack(
    dir: ltr,
    spacing: 7mm,
    panel(data.panels.at(0), [MWU vs. #text(blue)[*optimistic*] MWU ($eta = 0.25$)]),
    panel(data.panels.at(1), [OGD vs. #text(blue)[*optimistic*] OGD ($eta = 0.1$)]),
  ),
  grid(
    columns: 2,
    align: left,
    column-gutter: 8mm,
    row-gutter: 1.5mm,
    key(brown, "solid")[non-optimistic, last iterate (band)], key(blue, "solid")[optimistic, last iterate (band)],
    key(brown, "dashed")[non-optimistic, average iterate], key(blue, "dashed")[optimistic, average iterate],
  ),
))
