#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#align(center)[
  #grid(
    columns: (auto, auto),
    column-gutter: 5mm,
    align: horizon + left,
    [
  #cetz.canvas({
    import cetz-plot: plot
    plot.plot(
      x-label: none,
      y-label: text(size: 6pt)[$P$(action 1)],
      x-min: -2,
      x-max: 2,
      x-tick-step: 1,
      y-min: 0,
      y-max: 1,
      y-tick-step: .25,
      x-grid: true,
      y-grid: true,
      size: (6.4, 2.6),
      axis-style: "school-book",
      {
        // FTL: the response jumps at a tie.
        plot.add(domain: (-2, -.001), style: (stroke: .55mm + purple), x => 0)
        plot.add(domain: (.001, 2), style: (stroke: .55mm + purple), x => 1)

        // Hold r_1+r_2=2.  For RM, p_1 = r_1/(r_1+r_2).
        plot.add(domain: (-2, 2), style: (stroke: .55mm + green), x => .5 + .25 * x)

        // Entropic FTRL is MWU.  Here eta=2.
        plot.add(domain: (-2, 2), samples: 200, style: (stroke: .55mm + blue), x => 1 / (1 + calc.exp(-2 * x)))

        // Quadratic FTRL: a clipped linear response.  Here eta=.65.
        plot.add(domain: (-2, 2), style: (stroke: .55mm + red), x => calc.min(1, calc.max(0, .5 + .325 * x)))
      },
    )
  })
  #align(right)[#text(size: 8pt)[$r_1-r_2$]]
    ],
    [
    #grid(
      columns: (auto,),
      row-gutter: 1mm,
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: purple) #h(1mm) FTL],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: green) #h(1mm) RM],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: blue) #h(1mm) MWU ($eta=2$)],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: red) #h(1mm) quadratic FTRL ($eta=0.65$)],
    )
    ],
  )
]
