#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 1mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot

// Data: content/notebooks/learning2/last_iterate_figures.ipynb (game U(delta), delta = 0.01).
#let data = json("comparison.json")
#let colors = (rgb(31, 90, 190), rgb(214, 96, 0), rgb(118, 64, 160), rgb(46, 125, 50))
#let t1-color = rgb(200, 30, 30)
#let t2-color = rgb(20, 20, 20)

#let panel(alg, color) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  plot.plot(
    size: (6.2, 5.0),
    axis-style: "scientific",
    x-min: 0.5, x-max: 1.0, y-min: 0, y-max: 1,
    x-tick-step: 0.1, y-tick-step: 0.2,
    x-label: $x_1^((t))$, y-label: $y_1^((t))$,
    {
      plot.add(alg.trajectory.map(p => (p.at(0), p.at(1))), style: (stroke: .7pt + color))
      plot.add(((0.5, 0.5),), mark: "o", mark-size: .16,
        mark-style: (fill: rgb(150, 50, 200), stroke: none), style: (stroke: none))
      plot.add((data.equilibrium,), mark: "o", mark-size: .2,
        mark-style: (fill: black, stroke: white + .8pt), style: (stroke: none))
      if "p1" in alg {
        plot.add((alg.p1,), mark: "x", mark-size: .26,
          mark-style: (stroke: 1.6pt + t1-color), style: (stroke: none))
      }
      if "p2" in alg {
        plot.add((alg.p2,), mark: "square", mark-size: .22,
          mark-style: (fill: t2-color, stroke: none), style: (stroke: none))
      }
    },
  )
  content((3.1, 5.4))[#alg.name]
})

#let key(mark, body) = box(baseline: 1pt, mark) + h(1.2mm) + body

#align(center, stack(
  dir: ttb,
  spacing: 3mm,
  grid(
    columns: 2,
    column-gutter: 6mm,
    row-gutter: 5mm,
    ..data.algorithms.enumerate().map(((i, a)) => panel(a, colors.at(i))),
  ),
  [
    #key(circle(radius: 1.6pt, fill: rgb(150, 50, 200), stroke: none))[start] #h(5mm)
    #key(circle(radius: 2pt, fill: black, stroke: none))[Nash equilibrium] #h(5mm)
    #key(text(fill: t1-color, weight: "bold")[×])[$T_1$] #h(5mm)
    #key(rect(width: 4.5pt, height: 4.5pt, fill: t2-color, stroke: none))[$T_2$]
  ],
))
