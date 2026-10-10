#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": game_table

#game_table(
  ch: 7mm,
  ((1, -1), (-1, 1)),
  ((-1, 1), (1, -1)),
  ($H$, $T$),
  ($H$, $T$),
)
