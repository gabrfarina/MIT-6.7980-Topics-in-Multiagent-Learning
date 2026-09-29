#set page(width: auto, height: auto, margin: 2mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas({
  import cetz.draw: *
  set-style(stroke: .3mm)
  let A = (0, 0)
  let B = (1.8, -1.3)
  let C = (.7, -2.6)
  let D = (2.9, -2.6)
  let leaves = ((-2, -1.3), (.1, -3.9), (1.3, -3.9), (2.3, -3.9), (3.5, -3.9))
  for (u, v, label, pos) in (
    (A, leaves.at(0), [a], (-1.2, -.4)),
    (A, B, [b], (1.2, -.4)),
    (B, C, [r], (.9, -1.8)),
    (B, D, [s], (2.7, -1.8)),
    (C, leaves.at(1), [c], (.15, -3.1)),
    (C, leaves.at(2), [d], (1.3, -3.1)),
    (D, leaves.at(3), [p], (2.3, -3.1)),
    (D, leaves.at(4), [q], (3.5, -3.1)),
  ) {
    line(u, v)
    content(pos, label)
  }
  for (pos, label, fill) in ((A, [A], black), (B, [B], white), (C, [C], black), (D, [D], black)) {
    circle(pos, radius: .085, fill: fill)
    content((pos.at(0), pos.at(1) + .3), text(fill: blue, label))
  }
  for (i, pos) in leaves.enumerate() {
    rect((pos.at(0) - .05, pos.at(1) - .05), (pos.at(0) + .05, pos.at(1) + .05), fill: white)
    content((pos.at(0), pos.at(1) - .35), ($(2,-2)$, $(1,-1)$, $(-2,2)$, $(0,0)$, $(0,0)$).at(i))
  }
})
