// Known inclusions among total-search classes. An arrow points to the larger class.
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10.2pt)
#show: figure-style
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let class(pos, name) = node(pos, name, shape: "rect", corner-radius: 1.5mm, width: 14mm, height: 7mm)

#diagram(
  node-stroke: .3mm,
  edge-stroke: .3mm,
  node-fill: white,
  spacing: (9mm, 9mm),
  class((1, 0))[TFNP],
  class((0, 1))[PPA],
  class((1, 1))[PPP],
  class((2, 1))[PLS],
  class((.5, 2))[PPAD],
  class((1, 3))[FP],
  edge((1, 3), (.5, 2), "-stealth"),
  edge((1, 3), (2, 1), "-stealth"),
  edge((.5, 2), (0, 1), "-stealth"),
  edge((.5, 2), (1, 1), "-stealth"),
  edge((0, 1), (1, 0), "-stealth"),
  edge((1, 1), (1, 0), "-stealth"),
  edge((2, 1), (1, 0), "-stealth"),
)
