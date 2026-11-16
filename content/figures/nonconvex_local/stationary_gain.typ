#set page(width: auto, height: auto, fill: none, margin: 2mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#let blue = rgb("245990")
#let orange = rgb("c95b18")
#cetz.canvas(length: 6cm, {
  import cetz.draw: *
  rect((.3,0),(.7,1),fill:rgb("eaf1f8"),stroke:none)
  for t in (0,.5,1) {
    line((t,0),(t,1),stroke:.3pt + luma(85%))
    content((t,-.06),str(t))
  }
  for (y,label) in ((0,"0"),(.16,"0.04"),(.5,"0.125"),(1,"0.25")) {
    line((0,y),(1,y),stroke:.3pt + luma(85%))
    content((-.09,y),label)
  }
  let curve = range(0,101).map(i => {
    let x = i / 100
    (x,4 * (x - .5) * (x - .5))
  })
  line(..curve,stroke:1.5pt + blue)
  line((0,0),(1,0),stroke:(paint:orange,thickness:1.3pt,dash:"dashed"))
  for x in (.3,.7) {
    line((x,0),(x,.16),stroke:(paint:blue,thickness:.7pt,dash:"dashed"))
    circle((x,.16),radius:.012,fill:blue,stroke:none)
  }
  circle((.5,0),radius:.012,fill:orange,stroke:none)
  content((.5,1.16))[#text(blue)[Actual utility: $(x-1/2)^2$]]
  content((.5,1.07))[#text(orange)[Gradient prediction at $x=1/2$: $0$]]
  content((.5,.8))[Allowed interval: $[0.3,0.7]$]
  content((.5,-.16))[Player 1 action $x$]
  content((-.23,.5),angle:90deg)[Player 1 utility]
})
