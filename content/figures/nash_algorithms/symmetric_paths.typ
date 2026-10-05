#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/lemke_howson.typ": labeled-simplex, lemke-howson-symmetric

// The symmetric game of the worked example in nash_algorithms.typ.
#let R = ((4, 8, 1), (2, 7, 3), (9, 4, 5))

#let panel(k) = {
  let run = lemke-howson-symmetric(R, k)
  let T = run.pivots.len()
  stack(
    spacing: 4pt,
    align(center)[Special action $#k$: #T #if T == 1 [pivot] else [pivots]],
    cetz.canvas(length: 1cm, {
      labeled-simplex(R, (1, 2, 3), (1, 2, 3), path: run.states, steps: range(T + 1), label-end: false, size: 2.8)
    }),
  )
}

#grid(columns: 3, column-gutter: 14pt, ..(1, 2, 3).map(panel))
