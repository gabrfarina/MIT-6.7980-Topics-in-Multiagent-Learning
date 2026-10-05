#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/lemke_howson.typ": lemke-howson-pairings, lh-color

// The two asymmetric games of nash_algorithms.typ, with their equilibria in
// the order E_1, E_2, ... used in the text. E_0 is the artificial equilibrium.
#let games = (
  (
    title: [(a) The $3 times 2$ game],
    R: ((3, 3), (2, 5), (0, 6)),
    C: ((3, 2), (2, 6), (3, 1)),
    equilibria: (
      ((1, 0, 0), (1, 0)),
      (((4, 5), (1, 5), 0), ((2, 3), (1, 3))),
      ((0, (1, 3), (2, 3)), ((1, 3), (2, 3))),
    ),
  ),
  (
    title: [(b) The $3 times 3$ game],
    R: ((8, 1, 8), (9, 4, 0), (5, 3, 7)),
    C: ((5, 1, 8), (9, 1, 7), (5, 8, 6)),
    equilibria: (
      ((1, 0, 0), (0, 0, 1)),
      ((0, 1, 0), (1, 0, 0)),
      (((2, 5), (3, 5), 0), ((8, 9), 0, (1, 9))),
      (((2, 9), 0, (7, 9)), (0, (1, 3), (2, 3))),
      ((0, (1, 4), (3, 4)), (0, (7, 8), (1, 8))),
    ),
  ),
)

// One panel: the endpoints on a circle, E_0 on the left, and the pairs
// joined by the paths of label k.
#let panel(k, pairs, nodes) = {
  let radius = .82
  let pos(i) = {
    let angle = 180deg - i * 360deg / nodes
    (radius * calc.cos(angle), radius * calc.sin(angle))
  }
  stack(
    spacing: 3pt,
    align(center, text(fill: lh-color(k))[*Label #k*]),
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      for (a, b, _) in pairs {
        line(pos(a), pos(b), stroke: 1.6pt + lh-color(k))
      }
      for i in range(nodes) {
        circle(pos(i), radius: .22, fill: if i == 0 { luma(90%) } else { white }, stroke: .7pt + black)
        content(pos(i), text(size: 7.5pt)[$E_#i$])
      }
    }),
  )
}

#stack(
  spacing: 12pt,
  ..games.map(game => {
    let pairings = lemke-howson-pairings(game.R, game.C, game.equilibria)
    let nodes = game.equilibria.len() + 1
    stack(
      spacing: 5pt,
      game.title,
      grid(
        columns: pairings.len(),
        column-gutter: 8pt,
        ..pairings.enumerate().map(((i, pairs)) => panel(i + 1, pairs, nodes)),
      ),
    )
  }),
)
