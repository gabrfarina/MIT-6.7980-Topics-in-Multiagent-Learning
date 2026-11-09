#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 1mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot

// Data: content/notebooks/learning2/last_iterate_figures.ipynb. Rows are
// [log10 t, log10 min gap, log10 max gap] over logarithmic bins of t.
#let data = json("forgetful.json")
#let omwu-color = rgb(31, 90, 190)
#let ogda-color = rgb(46, 125, 50)
#let t1-color = rgb(200, 30, 30)
#let t2-color = rgb(20, 20, 20)

#let x-ticks = ((0, $1$), (1, $10$), (2, $10^2$), (3, $10^3$), (4, $10^4$))
#let y-ticks = ((0, $1$), (-3, $10^(-3)$), (-6, $10^(-6)$), (-9, $10^(-9)$), (-12, $10^(-12)$))

#let band(rows, color) = {
  let lo = rows.map(r => (r.at(0), r.at(1)))
  let hi = rows.map(r => (r.at(0), r.at(2)))
  plot.add-fill-between(lo, hi, style: (fill: color.transparentize(60%), stroke: .7pt + color))
}

#let panel(p, first) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let (a, b) = (calc.log(p.t1), calc.log(p.t2))
  plot.plot(
    size: (4.4, 4.6),
    axis-style: "scientific",
    x-min: 0, x-max: calc.log(data.T), y-min: -12.5, y-max: 2.8,
    x-tick-step: none, y-tick-step: none,
    x-ticks: x-ticks, y-ticks: if first { y-ticks } else { y-ticks.map(((v, _)) => (v, [])) },
    x-label: $t$, y-label: if first [Saddle-point gap] else [],
    {
      // Plateau of the analysis of Cai et al. (2024): from T_1 to T_2.
      plot.add-fill-between(((a, -12.5), (b, -12.5)), ((a, 2.8), (b, 2.8)),
        style: (fill: luma(90%), stroke: none))
      band(p.ogda, ogda-color)
      band(p.omwu, omwu-color)
      plot.add(((a, p.gap1),), mark: "x", mark-size: .3,
        mark-style: (stroke: 1.8pt + t1-color), style: (stroke: none))
      plot.add(((b, p.gap2),), mark: "square", mark-size: .24,
        mark-style: (fill: t2-color, stroke: white + .5pt), style: (stroke: none))
      plot.annotate({
        content(((a + b) / 2, -10.6), angle: 90deg, anchor: "west")[#text(9pt, fill: luma(25%))[plateau]]
        content((b + 0.06, 2.0), anchor: "west")[#text(9pt, fill: omwu-color)[rebound]]
        line((b + 0.12, 1.45), (b + 0.12, 0.25), stroke: .7pt + omwu-color, mark: (end: "stealth", fill: omwu-color, scale: .7))
      })
    },
  )
  content((2.2, 5.05))[$delta = #p.delta$: #h(1mm) $T_1 = #p.t1$, $T_2 = #p.t2$]
})

#let key(mark, body) = box(baseline: 1pt, mark) + h(1.2mm) + body

#align(center, stack(
  dir: ttb,
  spacing: 3mm,
  stack(
    dir: ltr,
    spacing: 3.5mm,
    ..data.panels.enumerate().map(((i, p)) => panel(p, i == 0)),
  ),
  [
    #key(line(length: 6mm, stroke: 1.6pt + omwu-color))[optimistic MWU] #h(4mm)
    #key(line(length: 6mm, stroke: 1.6pt + ogda-color))[optimistic OGD] #h(4mm)
    #key(rect(width: 4mm, height: 2.5mm, fill: luma(90%), stroke: none))[plateau] #h(4mm)
    #key(text(fill: t1-color, weight: "bold")[×])[$T_1$] #h(4mm)
    #key(rect(width: 4.5pt, height: 4.5pt, fill: t2-color, stroke: none))[$T_2$]
  ],
))
