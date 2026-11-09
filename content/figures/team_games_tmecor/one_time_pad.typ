// The one-time pad of the team-games lecture. The TMECor of the communication game mixes
// two joint plans with probability 1/2 each. Each panel is the tree of
// communication_game.typ in the compact layout of tree.typ, drawn narrower, with the actions of one joint plan
// highlighted at every team node. Heads is (a, b; c, d) = (1, 0; 1, 0) and tails is
// (0, 1; 0, 1). Leaf names, bit labels and band labels are dropped to save width.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"
#import "tree.typ": *

#let plan-color = rgb(0, 150, 110)
#let off-color = luma(62%)

// Node positions (cm), the compact layout of tree.typ with x scaled by sx.
#let sx = .6
#let nodes = {
  let out = (:)
  for (k, (x, y)) in compact-nodes { out.insert(k, (sx * x, y)) }
  out
}
// The team's action at each of its six nodes under a joint plan, as (parent, child).
#let heads = (
  ("p1l", "p2-1"), ("p1r", "p2-4"),
  ("p2-1", "p3-1"), ("p2-2", "z4"),
  ("p2-3", "z9"), ("p2-4", "p3-4"),
)
#let tails = (
  ("p1l", "p2-3"), ("p1r", "p2-2"),
  ("p2-1", "z3"), ("p2-2", "p3-2"),
  ("p2-3", "p3-3"), ("p2-4", "z10"),
)
// Prescribed actions at Player 2 nodes the plan never reaches. Drawn dashed.
#let off-path = (
  ("p2-2", "z4"), ("p2-3", "z9"),
  ("p2-1", "z3"), ("p2-4", "z10"),
)

#let panel(plan) = box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 3mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let band = (padx: .5, hy: .43, dy: .09)

    infosets(nodes, band)
    tree-edges(nodes, band, t-of: compact-t, style: (parent, child) => {
      let hl = (parent, child) in plan
      (
        paint: if hl { plan-color } else { off-color },
        width: if hl { .7mm } else { .3mm },
        dash: if hl and (parent, child) in off-path { (1.2mm, .9mm) } else { none },
        scale: if hl { .65 } else { .8 },
        gap: if hl { .2 } else { .17 },
        label-fill: if hl { black } else { off-color.darken(30%) },
      )
    })
    decision-nodes(nodes, bits: false)
    leaves(nodes, names: false)
  }),
)

#let plan-label(name, plan) = box(inset: (bottom: .8mm))[#course-sans(weight: "bold", name)#h(.6em)$(a, b; c, d) = #plan$]

#grid(
  columns: 2,
  column-gutter: 5mm,
  row-gutter: 2.5mm,
  align: center,
  panel(heads), panel(tails),
  plan-label("Heads", $(1, 0; 1, 0)$), plan-label("Tails", $(0, 1; 0, 1)$),
)
