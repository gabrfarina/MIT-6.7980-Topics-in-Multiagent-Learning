#set page(width: auto, height: auto, fill: none, margin: .6mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/nash.typ": brown, payoff_table
#import "@preview/cetz:0.4.1"

#show text: emph

#align(center, stack(
  dir: ltr,
  spacing: 1cm,
  stack(
    dir: ttb,
    spacing: 3mm,
    payoff_table(3, 3, cw: 1.5cm)(
      [],
      [#set text(brown); left],
      [#set text(brown); right],
      [#set text(blue); top],
      [3, 0, 2],
      [0, 2, 0],
      [#set text(blue);#box(width: 1.2cm)[bottom]],
      [0, 1, 0],
      [1, 0, 0],
    ),
    [#set text(orange.darken(20%));#h(1.5cm);(action X)],
  ),
  stack(
    dir: ttb,
    spacing: 3mm,
    payoff_table(3, 3, cw: 1.5cm)(
      [],
      [#set text(brown); left],
      [#set text(brown); right],
      [#set text(blue); top],
      [1, 0, 0],
      [0, 1, 0],
      [#set text(blue);#box(width: 1.2cm)[bottom]],
      [0, 3, 0],
      [2, 0, 3],
    ),
    [#set text(orange.darken(20%));#h(1.5cm);(action Y)],
  ),
))
