#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// An encoding diagram, not a game tree: the boxes index last-infosets associated with P, which need not
// all lie inside P itself. Panel, highlight colour and action names follow the other figures of the
// lecture (team_belief_dag/pair.typ): actions are ℓ and r, and the chosen entries are highlighted.
#let panel = rgb(247, 249, 252)
#let plan-color = rgb(0, 150, 110)
#let muted = luma(55%)

#box(
  fill: panel,
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 3mm),
  cetz.canvas({
    import cetz.draw: *
    content((6, 3.15), [Last-infosets associated with the public state $P$])
    let actions = ($⊥$, $ell$, $r$)
    for (i, selected) in (0, 1, 2).enumerate() {
      let x = 2 + 4 * i
      content((x, 2.55), $J_#(i + 1)$)
      for (j, label) in actions.enumerate() {
        let cx = x + (j - 1) * .85
        let active = j == selected
        rect((cx - .34, 1.7), (cx + .34, 2.2),
          stroke: if active { .4mm + plan-color } else { .22mm + muted },
          fill: if active { plan-color.lighten(85%) } else { white })
        content((cx, 1.95), label)
      }
      let cx = x + (selected - 1) * .85
      line((cx, 1.65), (x, 1.0), stroke: .3mm + plan-color,
        mark: (end: "stealth", scale: .6, fill: plan-color, stroke: .3mm + plan-color))
      content((x, .72), actions.at(selected))
      content((x, .28), text(size: 8.5pt, muted.darken(30%), (
        [not reached],
        [prescribes $ell$],
        [prescribes $r$],
      ).at(selected)))
    }
    content((6, -.42), [One signature: $(⊥, ell, r)$])
    content((6, -.98), [$3$ choices at each of $3$ coordinates: at most $3^3 = 27$ signatures])
  }),
)
