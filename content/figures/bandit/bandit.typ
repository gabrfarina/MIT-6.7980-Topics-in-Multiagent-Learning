#import "../../meta/notation.typ": cX, vx, vy, vg
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
      (11.0, 1.85),
      stroke: (dash: "dashed", paint: blue),
      radius: 1mm,
      fill: blue.transparentize(95%),
    )
    blk((9.5, 0))[Strategy \ sampler]
    blk((5.25, 0))[_Full-info._ \ regr. minim.]
    blk((1, 0))[Gradient \ Estimator]

    // lock (top right of the sampler)
    line(
      (10.22, .62), (10.22, .75), (10.3, .83), (10.42, .83), (10.5, .75), (10.5, .62),
      stroke: red.darken(20%) + .4mm,
    )
    rect((10.15, .35), (10.57, .65), radius: .3mm, fill: red, stroke: red.darken(30%) + .3mm)
    circle((10.36, .5), radius: .04, fill: white, stroke: none)

    // die (bottom right of the sampler)
    rect((10.15, -.5), (10.5, -.15), radius: .5mm, fill: white, stroke: black + .3mm)
    circle((10.23, -.42), radius: .02, fill: black)
    circle((10.325, -.325), radius: .02, fill: black)
    circle((10.42, -.23), radius: .02, fill: black)

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
    line((-1.5, 0), (0., 0))
    line((2, 0), (4.25, 0))
    line((6.25, 0), (8.5, 0))
    line((10.5, 0), (12, 0))

    content((0.7, 1.4))[#set text(blue); _Bandit_ regret \ minimizer]
    content((-1.1, .25))[$w^((t))$]
    content((3.125, .25))[$tilde(vg)^((t))$]
    content((7.375, .25))[$vy^((t))$]
    content((7.375, -.21))[$in cX$]
    content((11.8, .25))[$vx^((t)) in cX$]
  },
)
