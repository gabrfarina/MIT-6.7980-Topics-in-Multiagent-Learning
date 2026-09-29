#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../kernelized/vertices.typ": draw-tree

#box(radius: 2mm, fill: blue.lighten(97%), inset: 2mm, draw-tree("000000000"))
