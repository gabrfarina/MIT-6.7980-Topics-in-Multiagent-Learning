#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10.2pt)
#show: figure-style
#import "@preview/fletcher:0.5.8": diagram, edge, node

#diagram(
  node-stroke: .4mm,
  edge-stroke: .3mm,
  node-fill: white,
  cell-size: 2mm,
  spacing: (8mm, 5mm),
  node((0, 1), fill: luma(40%), text(white, $1 / 2$)),
  edge("dr", "-stealth"),
  node((2, 1), fill: luma(40%), text(white, $>$)),
  edge("ur", "-stealth"),
  node((4, 1), fill: luma(40%), text(white, $:=$)),
  edge("dl", "-stealth"),
  node((3, 2), shape: "rect")[$a$],
  edge("ul", "-stealth"),
  node((1, 2), shape: "rect")[$c$],
  edge("ur", "-stealth"),
  node((3, 0), shape: "rect")[$b$],
  edge("dr", "-stealth"),
)
