#import "../../meta/notation.typ": vx, cX
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let blk(pos, body, col: black, hgt: 1.5, bg: white) = {
      rect(
        (pos.at(0) - 1.3, pos.at(1) - hgt / 2),
        (pos.at(0) + 1.3, pos.at(1) + hgt / 2),
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
    rect((-.5, -1.2), (11.5, 1.4), stroke: (dash: "dashed", paint: blue), radius: 3mm, fill: blue.transparentize(95%))
    blk((1.3, 0))[Utility \ construction \ in $Phi$ space]
    blk((5.5, 0), hgt: 1.1)[_External_ regret \ minimizer for $Phi$ ]
    blk((9.7, 0), hgt: 1.3)[Fixed point #v(-1.5mm) $vx^((t)) = phi.alt^((t))(vx^((t)))$]

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
    line((-1.7, 0), (0., 0))
    line((2.6, 0), (4.2, 0))
    line((6.8, 0), (8.4, 0))
    line((11.0, 0), (12.5, 0))

    content((1.2, 1.7))[#set text(blue); $Phi$-regret minimizer]
    content((10.8, 1.7))[#set text(blue); $Phi"-Reg"^((T))$]
    content((5.5, 0.85))[$"Reg"_Phi^((T))$]
    content((-1.1, .25))[$u^((t))$]
    content((-1.2, -.25))[$cX -> RR$]
    content((3.5, .25))[$U^((t))$]
    content((3.4, -.25))[$Phi -> RR$]
    content((7.6, .25))[$phi.alt^((t)) in Phi$]
    content((12.2, .25))[$vx^((t)) in cX$]
  })
