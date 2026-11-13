#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#show text: emph

#box[
  #cetz.canvas(length: 5cm, {
    import cetz.draw: *

    // Feasible region
    line(
      (0, 0),
      (1/6, 5/6),
      (1, 0),
      close: true,
      fill: luma(230),
      stroke: none,
    )

    // Axes
    line((0, 0), (1.1, 0), mark: (end: ">"))
    line((0, 0), (0, 1.1), mark: (end: ">"))

    // Constraints
    line((0, 0), (1/5, 1), stroke: 0.8pt)
    line((0, 1), (1, 0), stroke: 0.8pt)

    // Optimal point
    circle(
      (1/6, 5/6),
      radius: 0.025,
      fill: black,
      stroke: black,
    )

    // Axis labels
    content((1.08, -0.07), [$p$])
    content((-0.07, 1.08), [$v$])

    // Tick labels
    content((1/6, -0.08), [$frac(1, 6)$])
    content((1, -0.08), [$1$])
    content((-0.08, 5/6), [$frac(5, 6)$])
    content((-0.06, 1), [$1$])

    // Constraint labels
    content((0.12, 0.58), [$v = 5p$])
    content((0.68, 0.43), [$v = 1-p$])

    // Optimum label
    content(
      (0.43, 0.90),
      [$(p^*, v^*) = (frac(1, 6), frac(5, 6))$],
    )
  })
]
