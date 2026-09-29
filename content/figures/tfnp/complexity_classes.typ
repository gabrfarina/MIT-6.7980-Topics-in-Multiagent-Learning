// Schematic inclusions among search complexity classes.
#set page(width: auto, height: auto, margin: .5mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"



#let brown = rgb("a07150")

#cetz.canvas(length: .95cm, {
  import cetz.draw: *

  let rbox(a, b, inc: .5, fill: black) = {
    rect(a, (b.at(0), b.at(1)), stroke: none, fill: fill)
    if inc > 0 {
      arc-through(b, (a.at(0) * .5 + b.at(0) * .5, b.at(1) + inc), (a.at(0), b.at(1)), stroke: black, fill: fill)
    }
    line(a, (a.at(0), b.at(1) + 1.2e-2))
    line((b.at(0), a.at(1)), (b.at(0), b.at(1) + 1.2e-2))
  }

  rbox((0, 0), (5, 4.5), fill: gray.lighten(10%))
  rbox((0, 0), (5, 3.5), inc: 0, fill: orange.lighten(20%))
  rbox((.5, 0), (4.5, 2.0), inc: .8, fill: blue.lighten(50%))
  rbox((1, 0), (4.0, 1.0), inc: .6, fill: brown.lighten(60%))

  content((2.5, 4.1))[FNP-complete]
  content((4.6, 5.0))[FNP]
  content((2.5, 2.2))[PPAD]
  content((2.5, .7))[FP (total)]
  content((2.5, 3.1))[TFNP]

  line((-1.8e-2, 0), (5 + 1.8e-2, 0))
  line((0, 3.5), (5, 3.5), stroke: (dash: "dashed"))
})
