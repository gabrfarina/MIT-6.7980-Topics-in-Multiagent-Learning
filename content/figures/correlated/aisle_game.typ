#import "../../meta/notation.typ": sf
#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": game_table

#let U = ((4, 2), (5, 0))
#let V = ((4, 5), (2, 0))

#game_table(U, V, (sf[Wait], sf[Go]), (sf[Wait], sf[Go]), cw: 1.4cm)
