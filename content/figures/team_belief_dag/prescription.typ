#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "pair.typ": base-pair, annot-violet

#cetz.canvas({
  import cetz.draw: *
  base-pair()
  content((9.0, 5.5), anchor: "east",
    text(fill: annot-violet, size: 9pt)[
      #align(left)[
        *Answer sheet $=$ prescription:* \
        one predetermined action for each \
        infoset the team might be in \
        --- never a mixed response
      ]
    ])
  bezier((9.2, 5.2), (9.9, 4.05), (10.3, 4.9),
    stroke: 1pt + annot-violet,
    mark: (end: "stealth", scale: .7, fill: annot-violet))
})
