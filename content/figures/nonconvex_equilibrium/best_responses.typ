#set page(width: auto, height: auto, fill: none, margin: 2mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#let blue = rgb("245990")
#let orange = rgb("c35b24")
#cetz.canvas(length: 6cm, {
  import cetz.draw: *
  for t in (0, .5, 1) {
    line((t,0),(t,1),stroke: .3pt + luma(85%))
    line((0,t),(1,t),stroke: .3pt + luma(85%))
    content((t,-.06),str(t))
    content((-.06,t),str(t))
  }
  line((0,0),(1,1),stroke: 1.5pt + orange)
  line((1,0),(1,.5),stroke: 2pt + blue)
  line((0,.5),(0,1),stroke: 2pt + blue)
  circle((1,.5),radius: .015,fill: blue,stroke: none)
  circle((0,.5),radius: .015,fill: blue,stroke: none)
  content((.5,-.16))[Player 1 action $x$]
  content((-.2,.5),angle:90deg)[Player 2 action $y$]
  content((.5,1.14))[#text(blue)[Player 1 best responses]]
  content((.5,1.06))[#text(orange)[Player 2 best responses]]
})
