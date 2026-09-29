#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": brown, game_table, nash_cmap, nashf
#import "@preview/cetz:0.4.1"

#show text: emph

#game_table(
  ((0, 5), (1, 0)),
  ((0, 1), (5, 0)),
  ("insist", "accept"),
  ("insist", "accept"),
  cw: 1.4cm,
)
