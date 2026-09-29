#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": brown, game_table, nash_cmap, nashf
#import "@preview/cetz:0.4.1"

#game_table(
  ch: 7mm,
  ((-1, -3), (0, -2)),
  ((-1, 0), (-3, -2)),
  ("Deny", "Confess"),
  ("Deny", "Confess"),
)
