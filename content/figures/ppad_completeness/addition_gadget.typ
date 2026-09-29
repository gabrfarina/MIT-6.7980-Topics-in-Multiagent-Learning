#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10.2pt)
#show: figure-style
#import "@preview/fletcher:0.5.8": diagram, edge, node

#diagram(
  node-stroke: .3mm,
  edge-stroke: .3mm,
  node-fill: white,
  spacing: (3mm, 1.1cm),
  node((-1, 0))[$x$],
  edge("u", "stealth--", stroke: blue),
  edge("rd", "-stealth"),
  node((1, 0))[$y$],
  edge("u", "stealth--", stroke: blue),
  edge("ld", "-stealth"),
  node((0, 1))[$w$],
  edge("d", "stealth-stealth"),
  node((0, 2))[$z$],
  edge("d", "--stealth", stroke: blue),
  node(
    enclose: ((-1, 0), (1, 0), (0, 2)),
    snap: false,
    stroke: blue,
    corner-radius: 2mm,
    inset: 5mm,
    fill: blue.transparentize(90%),
  ),
)
