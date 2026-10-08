#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#align(center)[
  #cetz.canvas({
    import cetz-plot: plot
    plot.plot(
      x-label: none,
      y-label: [probability of action 1],
      x-min: -1,
      x-max: 1,
      x-tick-step: .5,
      y-min: 0,
      y-max: 1,
      y-tick-step: .25,
      x-grid: true,
      y-grid: true,
      size: (6.4, 3.1),
      axis-style: "school-book",
      {
        // FTL: the response jumps at a tie.
        plot.add(domain: (-1, -.001), style: (stroke: .55mm + purple), x => 0)
        plot.add(domain: (.001, 1), style: (stroke: .55mm + purple), x => 1)

        // For two positive regrets r=(1+d, 1-d), RM is linear in d.
        plot.add(domain: (-1, 1), style: (stroke: .55mm + green), x => .5 + .5 * x)

        // Entropic FTRL is MWU: a softmax response.
        plot.add(domain: (-1, 1), samples: 200, style: (stroke: .55mm + blue), x => 1 / (1 + calc.exp(-4 * x)))

        // Quadratic FTRL: a clipped linear response for this two-action slice.
        plot.add(domain: (-1, 1), style: (stroke: .55mm + red), x => calc.min(1, calc.max(0, .5 + .65 * x)))
      },
    )
  })
  #v(1mm)
  #align(left)[
    #grid(
      columns: (auto,),
      row-gutter: 1mm,
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: purple) #h(1mm) FTL],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: green) #h(1mm) RM],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: blue) #h(1mm) MWU],
      [#box(width: 4mm, height: .8mm, radius: .4mm, fill: red) #h(1mm) quadratic FTRL],
    )
  ]
]
