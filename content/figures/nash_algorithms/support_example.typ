#import "../../meta/notation.typ": ve, vy
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/nash.typ": brown, game_table

#let table-part = game_table(
  ((3, 3), (2, 5), (0, 6)),
  ((3, 2), (2, 6), (3, 1)),
  ($1$, $2$, $3$),
  ($1$, $2$),
  cw: 1.2cm,
  ch: .75cm,
)

// Row's expected payoff from each action as Column moves y_2 from 0 to 1.
#let plot-part = cetz.canvas(length: 1cm, {
  import cetz.draw: *

  let W = 5.2
  let H = .55
  let pt(t, v) = (t * W, v * H)
  let rows = (
    (t => 3, blue.lighten(10%), $ve_1^T R vy$),
    (t => 2 + 3 * t, orange.darken(10%), $ve_2^T R vy$),
    (t => 6 * t, green.darken(30%), $ve_3^T R vy$),
  )

  // Axes and ticks.
  line(pt(0, 0), pt(1.06, 0), mark: (end: "stealth", fill: black, scale: .5), stroke: .25mm)
  line(pt(0, 0), pt(0, 6.6), mark: (end: "stealth", fill: black, scale: .5), stroke: .25mm)
  for (t, label) in ((0, $0$), (1 / 3, $1/3$), (1 / 2, $1/2$), (2 / 3, $2/3$), (1, $1$)) {
    line(pt(t, 0), (t * W, -.08), stroke: .2mm)
    content((t * W, -.35), label)
  }
  for v in (0, 2, 3, 4, 6) {
    line(pt(0, v), (-.08, v * H), stroke: .2mm)
    content((-.3, v * H), $#v$)
  }
  content((W + .55, -.02), $y_2$)

  // Each action's payoff, with the upper envelope (best responses) drawn bold.
  for (f, col, label) in rows {
    line(pt(0, f(0)), pt(1, f(1)), stroke: .3mm + col.transparentize(55%))
  }
  let env = ((0, 3), (1 / 3, 3), (2 / 3, 4), (1, 6))
  line(..env.map(((t, v)) => pt(t, v)), stroke: .75mm + black.transparentize(80%))
  for (f, col, label) in rows {
    let pieces = ((0, 1 / 3), (1 / 3, 2 / 3), (2 / 3, 1))
    for (a, b) in pieces {
      let mid = (a + b) / 2
      let best = calc.max(..rows.map(r => r.at(0)(mid)))
      if calc.abs(f(mid) - best) < 1e-9 {
        line(pt(a, f(a)), pt(b, f(b)), stroke: .55mm + col)
      }
    }
  }
  content((W + .2, 3 * H), anchor: "west", text(blue.lighten(10%), rows.at(0).at(2)))
  content((W + .2, 5 * H), anchor: "west", text(orange.darken(10%), rows.at(1).at(2)))
  content((W + .2, 6 * H), anchor: "west", text(green.darken(30%), rows.at(2).at(2)))

  // Feasible support guesses for Row: kinks of the upper envelope.
  for (t, v) in ((1 / 3, 3), (2 / 3, 4)) {
    line(pt(t, 0), pt(t, v), stroke: (paint: luma(45%), thickness: .2mm, dash: "dashed"))
    circle(pt(t, v), radius: .07, fill: black, stroke: none)
  }
  // The guess S_R = {1, 3}: actions 1 and 3 tie only below action 2.
  line(pt(1 / 2, 0), pt(1 / 2, 3.5), stroke: (paint: red.darken(20%), thickness: .2mm, dash: "dotted"))
  // Label it in the empty region below the envelope, with a leader to the marker.
  line(pt(1 / 2, 3), pt(.72, 1.75), stroke: .2mm + red.darken(20%))
  circle(pt(1 / 2, 3), radius: .07, fill: white, stroke: .25mm + red.darken(20%))
  content(
    pt(.72, 1.75),
    anchor: "north-west",
    padding: .05,
    text(red.darken(20%), size: 8pt)[$1$ and $3$ tie, \ but $2$ is better],
  )
})

#align(center, stack(
  dir: ltr,
  spacing: 1.2cm,
  align(horizon, table-part),
  align(horizon, plot-part),
))
