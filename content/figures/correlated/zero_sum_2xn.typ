#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Player 1's payoffs: rows are Player 1's actions, columns Player 2's.
#let U = ((5, 0, 3, 4, 2), (0, 4, 1, 3, 2))
// Payoff to Player 1 from x = (t, 1 - t) against Player 2's action j.
#let pay(j, t) = t * U.at(0).at(j) + (1 - t) * U.at(1).at(j)

#let sx = 6.0 // cm per unit of t
#let sy = 0.8 // cm per unit of payoff
#let pt(t, v) = (t * sx, v * sy)

#cetz.canvas(length: 1cm, {
  import cetz.draw: *

  // Axes and ticks.
  line(pt(0, 0), pt(1.06, 0), mark: (end: "stealth", fill: black), stroke: 0.6pt)
  line(pt(0, 0), pt(0, 5.6), mark: (end: "stealth", fill: black), stroke: 0.6pt)
  for (t, label) in ((0, $0$), (1 / 3, $1/3$), (1 / 2, $1/2$), (1, $1$)) {
    line(pt(t, 0), (t * sx, -0.08), stroke: 0.6pt)
    content((t * sx, -0.35), label)
  }
  for v in range(1, 6) {
    line(pt(0, v), (-0.08, v * sy), stroke: 0.6pt)
    content((-0.3, v * sy), $#v$)
  }
  content((1.06 * sx, -0.35), anchor: "west", [$t$])
  content((0, 5.6 * sy + 0.25), [payoff to Player 1])

  // One line per action of Player 2.
  let colors = (rgb("#1f5cb8"), rgb("#b3323b"), rgb("#2c7a4b"), rgb("#888888"), rgb("#7a4fb0"))
  for j in range(5) {
    let dash = if j == 3 { "dashed" } else if j == 4 { "dotted" } else { none }
    line(pt(0, pay(j, 0)), pt(1, pay(j, 1)), stroke: (paint: colors.at(j), thickness: 0.8pt, dash: dash))
    let ly = if j == 1 { 0.3 } else { pay(j, 1) * sy }
    content((sx + 0.12, ly), anchor: "west", text(fill: colors.at(j))[$ell_#(j + 1)$])
  }

  // Lower envelope: the payoff Player 1 can guarantee with x = (t, 1 - t).
  line(pt(0, 0), pt(1 / 3, 5 / 3), pt(1 / 2, 2), pt(1, 0), stroke: (paint: black, thickness: 2.2pt, cap: "round", join: "round"))

  // Maxmin point.
  line(pt(1 / 2, 0), pt(1 / 2, 2), stroke: (paint: black, thickness: 0.5pt, dash: "dotted"))
  circle(pt(1 / 2, 2), radius: 0.07, fill: black, stroke: none)
  content((0.5 * sx - 0.12, 2 * sy - 0.35), anchor: "north-east", [$v^* = 2$])
})
