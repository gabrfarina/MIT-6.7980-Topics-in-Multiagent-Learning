#import "../../meta/notation.typ": vx, vp
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let blk(pos, body, col: black, hgt: 1.1, w: 2.6, bg: white) = {
      rect(
        (pos.at(0) - w / 2, pos.at(1) - hgt / 2),
        (pos.at(0) + w / 2, pos.at(1) + hgt / 2),
        radius: .4mm,
        stroke: col + .3mm,
        fill: bg,
      )
      content(pos)[
        // #set text(font: "New Computer Modern Sans 08")
        #set text(col.darken(10%))
        #set align(center)
        #body
      ]
    }

    set-style(stroke: .3mm)
    rect((-.3, -2.8), (11.0, 2.3), stroke: (dash: "dashed", paint: blue), radius: 3mm, fill: blue.transparentize(95%))
    blk((3, 0))[_External_ regret \ minim. for $Delta^n$ ]
    blk((6.4, 0), w: 2.2)[Assemble $P^((t))$ \ $\(vp_1^((t))#h(.5mm)|#h(.7mm)dots.c#h(.7mm)|#h(.7mm)vp_n^((t))\)$ ]
    blk((3, 1.4))[_External_ regret \ minim. for $Delta^n$ ]
    blk((3, -1.9))[_External_ regret \ minim. for $Delta^n$ ]
    blk((9.5, 0))[Fixed point #v(0mm) $vx^((t)) = P^((t)) vx^((t))$]
    circle((0.06, 0), radius: .6mm, fill: black)

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
    line((-1.7, 0), (0., 0))
    line((0.06, 0), (1.7, 0))
    set-style(mark: (end: none))
    bezier((0.06, 0), (0.7, 1.4), (0.7, 0), (-0, 1.4))
    bezier((0.06, 0), (0.7, -1.9), (0.7, 0), (-0, -1.9))
    line((4.3, 1.4), (5.9, 1.4))
    line((4.3, -1.9), (5.9, -1.9))
    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)

    line((0.7, 1.4), (1.7, 1.4))
    line((0.7, -1.9), (1.7, -1.9))
    // line((0.06, 0), (0.06, -1.9), (1.7, -1.9))
    line((10.8, 0), (12.3, 0))

    line((4.3, 0), (5.3, 0))
    line((7.5, 0), (8.2, 0))
    bezier((5.9, 1.4), (6.4, .55), (6.4, 1.4), (6.4, 1.4))
    bezier((5.9, -1.9), (6.4, -.55), (6.4, -1.9), (6.4, -1.9))


    content((2.6, 2.6))[#set text(blue); Blum-Mansour's swap regret minimizer]
    content((-0.9, .25))[$u^((t))$]
    content((-1.0, -.25))[$Delta^n -> RR$]
    content((3, -.9))[$dots.v$]
    content((1.1, 1.7))[$x_1^((t)) u^((t))$]
    content((4.75, 1.7))[$vp_1^((t))$]
    content((1.1, .3))[$x_2^((t)) u^((t))$]
    content((4.75, .3))[$vp_2^((t))$]
    // content((7.9, .25))[$P^((t))$]
    content((1.1, -2.2))[$x_n^((t)) u^((t))$]
    content((4.75, -1.6))[$vp_n^((t))$]

    content((11.9, .3))[$vx^((t)) in Delta^n$]
  })
