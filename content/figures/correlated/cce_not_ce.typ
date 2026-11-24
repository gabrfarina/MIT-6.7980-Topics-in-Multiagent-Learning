#import "../../meta/notation.typ": sf
#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": game_table
#import "@preview/cetz:0.4.1"

#let U = ((4, 0), (0, 4), (5, 0))
#let V = ((4, 0), (0, 4), (0, 0))

#game_table(U, V, (sf[Red], sf[Blue], sf[Green]), (sf[Circle], sf[Square]), cw: 1.4cm)
