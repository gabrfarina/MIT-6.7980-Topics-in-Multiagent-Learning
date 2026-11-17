#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "pair.typ": base-pair, annot-violet

#cetz.canvas({
  import cetz.draw: *
  base-pair()
  content((8.9, 5.6), anchor: "east",
    text(fill: annot-violet, size: 9pt)[
      #align(left)[
        *Public observation:* \
        what every member knows. \
        Nodes that even one member cannot \
        tell apart stay grouped, ex: ${C, D}$
      ]
    ])
  bezier((8.3, 5.0), (8.9, 2.55), (7.9, 3.6),
    stroke: 1pt + annot-violet,
    mark: (end: "stealth", scale: .7, fill: annot-violet))
})
