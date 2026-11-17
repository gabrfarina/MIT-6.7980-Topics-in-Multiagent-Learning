#import "@preview/cetz:0.3.4"
#import "../libs/typography.typ": figure-font, figure-style
#set page(width: auto, height: auto, margin: 2mm, fill: none)
#set text(font: figure-font, size: 9pt)
#show: figure-style

#cetz.canvas({
  import cetz.draw: *
  let ink = rgb("384252")
  let green = rgb("267344")
  let blue = rgb("28618c")
  let label-at(pos, body) = content(pos, box(fill: white, inset: 1.5pt, body))
  let edge(a, b, label, at, obey: false) = {
    line(a, b, stroke: (paint: if obey { green } else { ink }, thickness: if obey { 1.1pt } else { .65pt }))
    label-at(at, label)
  }
  content((6, 5.1), [Leader's committed randomization])
  edge((6, 4.65), (3, 2.5), [play $X$, recommend $Y$ \ probability $p$], (3.45, 3.8))
  edge((6, 4.65), (9, 2.5), [play $Y$, recommend $Y$ \ probability $1-p$], (8.55, 3.8))
  line((3, 2.5), (9, 2.5), stroke: (paint: blue, dash: "dashed", thickness: .7pt))
  label-at((6, 2.8), [Follower knows $p$; realized action is hidden])
  let leaf-x = (1.5, 4.5, 7.5, 10.5)
  let values = ($(1,1)$, $(11,0)$, $(0,0)$, $(10,1)$)
  for (i, x) in leaf-x.enumerate() {
    let px = if i < 2 { 3 } else { 9 }
    let obey = calc.odd(i)
    edge((px, 2.5), (x, .6), if obey { $Y$ } else { $X$ }, ((px+x)/2, 1.55), obey: obey)
    circle((x, .6), radius: .045, fill: ink, stroke: none)
    content((x, .2), values.at(i))
  }
  circle((6, 4.65), radius: .10, fill: ink, stroke: none)
  for x in (3, 9) {
    circle((x, 2.5), radius: .12, fill: white, stroke: blue + .8pt)
    content((x, 2.5), text(size: 6pt, fill: blue)[F])
  }
})
