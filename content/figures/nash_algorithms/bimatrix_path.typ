#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/lemke_howson.typ": labeled-simplex, lemke-howson-bimatrix
#import "../../meta/notation.typ": vx, vy

// The 3 x 2 game of the asymmetric example in nash_algorithms.typ, with
// label 2 dropped.
#let R = ((3, 3), (2, 5), (0, 6))
#let C = ((3, 2), (2, 6), (3, 1))
#let CT = range(2).map(j => range(3).map(i => C.at(i).at(j)))
#let run = lemke-howson-bimatrix(R, C, 2)
#let steps = range(run.states.len())

#grid(
  columns: 2,
  column-gutter: 22pt,
  align: bottom,
  stack(
    spacing: 4pt,
    align(center)[Row: $vx in P$],
    cetz.canvas(length: 1cm, {
      labeled-simplex(CT, (4, 5), (1, 2, 3), path: run.states.map(s => s.at(0)), steps: steps, size: 3.2)
    }),
  ),
  stack(
    spacing: 4pt,
    align(center)[Column: $vy in Q$],
    cetz.canvas(length: 1cm, {
      labeled-simplex(R, (1, 2, 3), (4, 5), path: run.states.map(s => s.at(1)), steps: steps, size: 3.2)
    }),
  ),
)
