#import "@preview/cetz:0.3.4"
#import "../libs/typography.typ": figure-font, figure-style
#set page(width: auto, height: auto, margin: 2mm, fill: none)
#set text(font: figure-font, size: 8pt)
#show: figure-style

#cetz.canvas({
  import cetz.draw: *
  let ink = rgb("384252")
  let green = rgb("267344")
  let blue = rgb("28618c")
  let label-at(pos, body) = content(pos, box(fill: white, inset: 1pt, body))
  let edge(a, b, label, at, obey: false) = {
    line(a, b, stroke: (paint: if obey { green } else { ink }, thickness: if obey { 1.1pt } else { .65pt }))
    label-at(at, label)
  }
  let node(pos, who) = {
    circle(pos, radius: .13, fill: white, stroke: blue + .8pt)
    content(pos, text(size: 6.5pt, fill: blue, who))
  }
  content((6, 6), [Mediator's committed randomization])
  edge((6, 5.55), (3, 3.6), [recommend $(S,G)$ \ probability $p$], (3.35, 4.7))
  edge((6, 5.55), (9, 3.6), [recommend $(G,S)$ \ probability $1-p$], (8.65, 4.7))
  circle((6, 5.55), radius: .10, fill: ink, stroke: none)
  for (branch, rx) in (3, 9).enumerate() {
    let rec-row = if branch == 0 { $S$ } else { $G$ }
    let rec-col = if branch == 0 { $G$ } else { $S$ }
    label-at((rx, 3.95), [$R$ receives #rec-row])
    line((rx - 1.4, 2), (rx + 1.4, 2), stroke: (paint: blue, dash: "dashed", thickness: .7pt))
    label-at((rx, 2.25), [$C$ receives #rec-col])
    for (row-action, cx) in (rx - 1.4, rx + 1.4).enumerate() {
      edge((rx, 3.6), (cx, 2), if row-action == 0 { $S$ } else { $G$ }, ((rx+cx)/2, 2.85), obey: row-action == branch)
      for (col-action, lx) in (cx - .7, cx + .7).enumerate() {
        edge((cx, 2), (lx, .6), if col-action == 0 { $S$ } else { $G$ }, ((cx+lx)/2, 1.3), obey: col-action == 1-branch)
        let payoff = if row-action == 0 {
          if col-action == 0 { $(0,0)$ } else { $(0,1)$ }
        } else {
          if col-action == 0 { $(1,0)$ } else { $(-5,-5)$ }
        }
        circle((lx, .6), radius: .04, fill: ink, stroke: none)
        content((lx, .2), payoff)
      }
      node((cx, 2), [C])
    }
    node((rx, 3.6), [R])
  }
})
