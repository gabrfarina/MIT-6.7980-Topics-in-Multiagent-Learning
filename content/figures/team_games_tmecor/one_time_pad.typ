// The one-time pad of the team-games lecture. The TMECor of the communication game mixes
// two joint plans with probability 1/2 each. Each panel is the tree of
// communication_game.typ, drawn narrower, with the actions of one joint plan
// highlighted at every team node. Heads is (a, b; c, d) = (1, 0; 1, 0) and tails is
// (0, 1; 0, 1). Leaf names are dropped to save width.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"
#import "tree.typ": *

#let plan-color = rgb(0, 150, 110)
#let off-color = luma(62%)

// Node positions (cm), those of communication_game.typ with x scaled by sx.
#let sx = .6
#let nodes = {
  let out = (:)
  for (k, (x, y)) in nodes { out.insert(k, (sx * x, y)) }
  out
}
// (parent, child, label, position of label along the edge)
#let edges = (
  ("root", "p1l", $1\/2$, .5),
  ("root", "p1r", $1\/2$, .5),
  ("p1l", "p2-1", $a$, .45),
  ("p1l", "p2-3", $overline(a)$, .24),
  ("p1r", "p2-2", $b$, .24),
  ("p1r", "p2-4", $overline(b)$, .45),
  ("p2-1", "p3-1", $c$, .42),
  ("p2-1", "z2-1", $overline(c)$, .55),
  ("p2-2", "z2-2", $c$, .55),
  ("p2-2", "p3-2", $overline(c)$, .42),
  ("p2-3", "p3-3", $d$, .42),
  ("p2-3", "z2-3", $overline(d)$, .55),
  ("p2-4", "z2-4", $d$, .55),
  ("p2-4", "p3-4", $overline(d)$, .42),
)
// The team's action at each of its six nodes under a joint plan, as (parent, child).
#let heads = (
  ("p1l", "p2-1"), ("p1r", "p2-4"),
  ("p2-1", "p3-1"), ("p2-2", "z2-2"),
  ("p2-3", "z2-3"), ("p2-4", "p3-4"),
)
#let tails = (
  ("p1l", "p2-3"), ("p1r", "p2-2"),
  ("p2-1", "z2-1"), ("p2-2", "p3-2"),
  ("p2-3", "p3-3"), ("p2-4", "z2-4"),
)
// Prescribed actions at Player 2 nodes the plan never reaches. Drawn dashed.
#let off-path = (
  ("p2-2", "z2-2"), ("p2-3", "z2-3"),
  ("p2-1", "z2-1"), ("p2-4", "z2-4"),
)

#let panel(plan) = box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 3mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let band = (padx: .5, hy: .43, dy: .09)

    infosets(nodes, band)

    for (parent, child, label, t) in edges {
      let into-band = child.starts-with("p2") or child.starts-with("p3")
      let hl = (parent, child) in plan
      edge(
        nodes.at(parent),
        nodes.at(child),
        radius(parent),
        if into-band { -1 } else { radius(child) },
        band,
        label: label,
        t: t,
        left-end: child in left-ends,
        paint: if hl { plan-color } else { off-color },
        width: if hl { .7mm } else { .3mm },
        dash: if hl and (parent, child) in off-path { (1.2mm, .9mm) } else { none },
        scale: if hl { .65 } else { .8 },
        gap: if hl { .2 } else { .17 },
        label-fill: if hl { black } else { off-color.darken(30%) },
      )
    }
    for (key, values) in p3-leaves {
      let p = nodes.at(key)
      for (i, dx) in (-.45, .45).enumerate() {
        let z = add(p, (dx, -1.55))
        edge(p, z, tri-r, .1, band, label: p3-labels.at(key).at(i), t: .55, paint: off-color, label-fill: off-color.darken(30%))
        leaf(z, values.at(i))
      }
    }

    decision-nodes(nodes)
    for key in ("z2-1", "z2-2", "z2-3", "z2-4") { leaf(nodes.at(key), 0) }
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
