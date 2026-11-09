#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "pair.typ": base-pair

#cetz.canvas({
  import cetz.draw: *
  base-pair()
})
