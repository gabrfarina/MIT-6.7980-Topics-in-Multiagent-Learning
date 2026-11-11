#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// An encoding diagram, not a game tree: the boxes index last-infosets
// associated with P, which need not all lie inside P itself.
#cetz.canvas({
  import cetz.draw: *
  let blue = rgb("245c86")
  let muted = luma(55%)
  rect((0, 0), (12, 3.5), stroke: .6pt + luma(65%), fill: luma(98%))
  content((6, 3.15), [Last-infosets associated with public state $P$])
  for (i, selected) in (0, 1, 2).enumerate() {
    let x = 2 + 4 * i
    content((x, 2.55), $J_#(i + 1)$)
    for (j, label) in ($⊥$, $L$, $R$).enumerate() {
      let cx = x + (j - 1) * .85
      let active = j == selected
      rect((cx - .34, 1.7), (cx + .34, 2.2),
        stroke: if active { 1.1pt + blue } else { .5pt + muted },
        fill: if active { rgb("e0edf6") } else { white })
      content((cx, 1.95), label)
    }
    let cx = x + (selected - 1) * .85
    line((cx, 1.65), (x, 1.0), stroke: .8pt + blue,
      mark: (end: "stealth", scale: .6, fill: blue))
    content((x, .72), ($⊥$, $L$, $R$).at(selected))
    content((x, .28), text(size: 8.5pt, ("unreachable", "select L", "select R").at(selected)))
  }
  content((6, -.48), [One signature: $(⊥, L, R)$])
  content((6, -1.02), [$3$ choices at each of $3$ coordinates: at most $3^3 = 27$ signatures])
})
