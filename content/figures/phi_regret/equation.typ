#import "../../meta/notation.typ": vp
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style

#let boxd(i) = box(
  baseline: 6mm,
  width: 4.5mm,
  height: 1.5cm,
  radius: 0.3mm,
  stroke: .3pt + black,
  // fill: luma(90%), //.2mm + black,
  text(9pt, align(center + horizon, stack(dir: ttb, spacing: 2mm)[|][#v(-.5mm)$vp_#i$][#sym.arrow.b])),
)
$
  Phi := {P = mat(boxd(1), boxd(2), dots.c, boxd(n)): vp_1, ..., vp_n in Delta^n}.
$
