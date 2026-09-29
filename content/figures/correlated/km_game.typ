#import "../../meta/notation.typ": sf
#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": brown, game_table, nash_cmap, nashf
#import "@preview/cetz:0.4.1"

#let U = ((1, 0, -1), (-1, 0, -1), (1, 0, -2))
#let V = ((1, -1, 1), (0, 0, 0), (-1, -1, -2))

#game_table(U, V, (sf[A], sf[B], sf[C]), (sf[A], sf[B], sf[C]), cw: 1.4cm)
