#set page(width: auto, height: auto, fill: none, margin: 2mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#let blue = rgb("245990")
#cetz.canvas(length: 6cm, {
  import cetz.draw: *
  for t in (0,.5,1) {
    line((t,0),(t,1),stroke: .3pt + luma(85%))
    line((0,t),(1,t),stroke: .3pt + luma(85%))
    content((t,-.06),str(t))
    content((-.07,t),str(t/2))
  }
  let actual = range(0,101).map(i => {let y = i / 100; (y, 2 * ((y - 0.5) * (y - 0.5) + 0.25))})
  let mean = range(0,101).map(i => {let y = i / 100; (y, 2 * (y - 0.5) * (y - 0.5))})
  line(..actual,stroke: 1.5pt + blue)
  line(..mean,stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
  circle((.5,.5),radius:.012,fill:blue,stroke:none)
  content((.5,-.16))[Player 2 action $y$]
  content((-.2,.5),angle:90deg)[Squared distance]
  content((.5,1.16))[#text(blue)[Randomize: $(y-1/2)^2+1/4$]]
  content((.5,1.07))[#text(gray)[Choose the mean: $(y-1/2)^2$]]
})
