#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10.2pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let dia(lbl, num) = box(
  cetz.canvas({
    import cetz.draw: *

    circle((0, 0), radius: .3, fill: luma(40%), stroke: none)
    content((0, 0.03))[#set text(white);#lbl]
    set-style(mark: (end: "stealth", fill: black, scale: .7))
    line((.3, 0), (1, 0))
    content((1.1, 0), anchor: "west")[$y$]

    if num == 1 {
      line((-1, 0), (-.3, 0))
      content((-1.1, 0), anchor: "east")[$x_1$]
    } else if num == 2 {
      line((-1, .3), (-.3, .1))
      line((-1, -.3), (-.3, -.1))
      content((-1.1, .4), anchor: "east")[$x_1$]
      content((-1.1, -.3), anchor: "east")[$x_2$]
    } else {
      content((-1.45, 0), anchor: "east")[]
    }
  }),
)

#let gate = sys.inputs.at("gate", default: "assignment")
#let spec = (
  assignment: ($:=$, 1),
  constant: ($a$, 0),
  addition: ($+$, 2),
  subtraction: ($-$, 2),
  multiplication: ([$times #h(-.3mm) a$], 1),
  comparison: ($>$, 2),
).at(gate)
#dia(..spec)
