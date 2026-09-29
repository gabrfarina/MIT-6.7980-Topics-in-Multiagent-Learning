#import "../../meta/notation.typ": cX, vx, vy, vp, vg, vxi
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(
  length: 1cm,
  {
    import cetz.draw: *

    let blk(pos, body, col: black) = {
      rect(
        (pos.at(0) - 1, pos.at(1) - .5),
        (pos.at(0) + 1, pos.at(1) + .5),
        radius: .4mm,
        stroke: col + .3mm,
        fill: white,
      )
      content(pos)[
        #set text(col.darken(10%))
        #set align(center)
        #body
      ]
    }

    set-style(stroke: .3mm)
    rect(
      (-.5, -.7),
      (11.0, 2.55),
      stroke: (dash: "dashed", paint: blue),
      radius: 1mm,
      fill: blue.transparentize(95%),
    )
    blk((7, 1.8), col: luma(40%))[Exploration \ term]
    blk((9.5, 0))[Strategy \ sampler]
    blk((4.5, 0))[_Full-info._ \ regr. minim.]
    blk((1, 0))[Gradient \ Estimator]
    circle((7, 0), radius: .25, fill: white)
    line((6.87, 0), (7.13, 0), stroke: .2mm)
    line((7, -.13), (7, .13), stroke: .2mm)

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
    line((-1.5, 0), (0., 0))
    line((2, 0), (3.5, 0))
    line((5.5, 0), (6.75, 0))
    line((7, 1.3), (7, .25), stroke: luma(40%))
    line((7.25, 0), (8.5, 0))
    line((10.5, 0), (12, 0))

    content((0.7, 1.95))[#set text(blue); _Bandit_ regret \ minimizer]
    content((-1.1, .25))[$w^((t))$]
    content((2.8, .25))[$tilde(vg)^((t))$]
    content((6.2, .25))[$vy^((t))$]
    content((6.1, -.21))[$in cX$]
    content((7.8, .25))[$vp^((t))$]
    content((7.7, -.21))[$in cX$]
    content((7.7, .95))[#set text(luma(30%));$vxi^((t)) in cX$]
    content((11.8, .25))[$vx^((t)) in cX$]

    content((9.5, 1.9))[#set text(9pt);($<-$ for high-prob. \ regret bounds only)]
  },
)
