#import "../../meta/notation.typ": vx, vy, cX, cY
#import "../../meta/notation.typ": cR
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#align(center, cetz.canvas({
  import cetz.draw: *

  set-style(stroke: .25mm)
  rect((0, 0), (1.2, .8), stroke: .3mm)
  content((.6, .4), $cR_cX$)
  rect((0, -1), (1.2, -0.2), stroke: .3mm)
  content((.6, -.6), $cR_cY$)
  set-style(mark: (end: "stealth", scale: .7, fill: luma(0%)))
  line((-1.2, .4), (0, .4))
  content((-.5, .7), $u_(cX)^((t-1))$)
  line((-1.2, -.6), (0, -.6))
  content((-.5, -.3), $u_(cY)^((t-1))$)
  line((1.2, .4), (2.0, .4))
  content((1.7, .7), $vx^((t))$)
  line((1.2, -.6), (2.0, -.6))
  content((1.7, -.3), $vy^((t))$)

  set-style(mark: (end: none))
  rect((2.0, .2), (2.4, .6), stroke: .3mm)
  line((2.0, .2), (2.4, .6), stroke: .3mm)
  rect((2.0, -.8), (2.4, -.4), stroke: .3mm)
  line((2.0, -.8), (2.4, -.4), stroke: .3mm)

  set-style(mark: (end: "stealth", scale: .7, fill: luma(0%)))
  line((2.4, .4), (2.6, .4), (3.2, -.6), (4, -.6))
  content((3.7, -.25), $u_(cY)^((t))$)
  line((2.4, -.6), (2.6, -.6), (3.2, .4), (4, .4))
  content((3.7, .75), $u_(cX)^((t))$)

  rect((4, 0), (5.2, .8), stroke: .3mm)
  content((4.6, .4), $cR_cX$)
  rect((4, -1), (5.2, -0.2), stroke: .3mm)
  content((4.6, -.6), $cR_cY$)

  line((5.2, .4), (6.4, .4))
  content((6.2, .7), $vx^((t+1))$)
  line((5.2, -.6), (6.4, -.6))
  content((6.2, -.3), $vy^((t+1))$)
}))
