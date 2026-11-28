#import "../../meta/notation.typ": vu, vp, cU, cH, cC
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Mirrors figures/phi_regret/gordon.svg (the Gordon-Greenwald-Marks reduction),
// with tests in place of deviations and an EVI in place of the fixed point.
#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let blk(pos, body, col: black, hgt: 1.5, wid: 2.6, bg: white) = {
      rect(
        (pos.at(0) - wid / 2, pos.at(1) - hgt / 2),
        (pos.at(0) + wid / 2, pos.at(1) + hgt / 2),
        radius: .4mm,
        stroke: col + .3mm,
        fill: bg,
      )
      content(pos)[
        #set text(col.darken(10%))
        #set align(center)
        #body
      ]
    }

    set-style(stroke: .3mm)
    rect((-.5, -1.2), (11.9, 1.4), stroke: (dash: "dashed", paint: blue), radius: 3mm, fill: blue.transparentize(95%))
    blk((1.3, 0))[Utility \ construction \ in $cH$ space]
    blk((5.5, 0), hgt: 1.1)[_External_ regret \ minimizer for $cH$]
    blk((9.9, 0), hgt: 1.3, wid: 3.0)[EVI solver #v(-1.5mm) $S^((t)) = h^((t))(c^((t)), dot)$]

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
    line((-2.2, 0), (0., 0))
    line((2.6, 0), (4.2, 0))
    line((6.8, 0), (8.4, 0))
    line((11.4, 0), (14.3, 0))
    line((9.9, -2.0), (9.9, -.65))

    content((1.7, 1.7))[#set text(blue); $cH$-multicalibrated forecaster]
    content((11.2, 1.7))[#set text(blue); $"MC"^((T))$]
    content((5.5, 0.85))[$"Reg"_(cH)^((T))$]
    content((-1.35, .3))[$vu^((t)) in cU$]
    content((3.4, .25))[$g^((t))$]
    content((3.4, -.25))[$cH -> RR$]
    content((7.6, .25))[$h^((t)) in cH$]
    content((13.15, .3))[$D^((t)) in Delta(cU)$]
    content((10.6, -1.75))[$c^((t)) in cC$]
  })
