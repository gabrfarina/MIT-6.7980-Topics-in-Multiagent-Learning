#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../libs/sperner.typ": *

#sperner_grid(
  w: 1,
  "rbbrrrr",
  "rrrbryr",
  "yybbrrr",
  "ybbbrbr",
  "rrrrrrb",
  "rybryrr",
  "yybbyyb",
)
