#set page(width: auto, height: auto, fill: none, margin: 1mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style

#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2": plot

#let loss = rgb("#a75039")
#let gain = rgb("#176b69")
#let zero = luma(42%)
#let payoff(x, y) = 3 * x * y - x * x - y * y + (calc.pow(x, 4) + calc.pow(y, 4)) / 2
#let actions = (-1, 1)

#let contours(levels, stroke) = plot.add-contour(
  payoff,
  z: levels,
  x-domain: actions,
  y-domain: actions,
  x-samples: 80,
  y-samples: 80,
  style: (stroke: stroke),
)

#let arrow(to, color, dash: "solid") = cetz.draw.line(
  (0, 0), to,
  stroke: (paint: color, thickness: 1.25pt, dash: dash),
  mark: (end: "stealth", fill: color, scale: .7),
)

#let key(color, body, dash: "solid") = {
  box(
    baseline: -2.5pt,
    line(length: 6mm, stroke: (paint: color, thickness: .85pt, dash: dash)),
  )
  h(1.4mm)
  body
}

#grid(
  columns: (auto, auto),
  column-gutter: 4mm,
  align: horizon + left,
  cetz.canvas(length: 1cm, {
    plot.plot(
      size: (4.1, 4.1),
      axis-style: "scientific",
      x-min: -1, x-max: 1, x-tick-step: 1,
      y-min: -1, y-max: 1, y-tick-step: 1,
      x-label: [Player 1 action $x$],
      y-label: [Player 2 action $y$],
      {
        contours((-3, -2, -1, -.5, -.2), (paint: loss.lighten(22%), thickness: .65pt, dash: "dashed"))
        contours((0,), .9pt + zero)
        contours((.2, .5, 1, 1.5), .65pt + gain.lighten(24%))
        plot.annotate(resize: false, {
          cetz.draw.rect((-1, -1), (1, 1), stroke: .9pt + luma(35%), fill: none)
          arrow((.76, 0), loss, dash: "dashed")
          arrow((0, .76), loss, dash: "dashed")
          arrow((.76, .76), gain)
          cetz.draw.circle((0, 0), radius: .035, fill: black, stroke: none)
        })
      },
    )
  }),
  grid(
    columns: 1,
    row-gutter: 2.2mm,
    [*Payoff contours*],
    key(gain)[$u > 0$],
    key(zero)[$u = 0$],
    key(loss, dash: "dashed")[$u < 0$],
  ),
)
