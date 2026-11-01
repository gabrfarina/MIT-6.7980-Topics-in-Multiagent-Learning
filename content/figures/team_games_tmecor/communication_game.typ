// The communication game of the team-games lecture. Chance draws a uniform bit seen
// only by P1; P1's action is seen by P2 and P3, who then guess the bit. The team
// (P1, P2: ▲) gets 1 iff P2 guesses right and the adversary (P3: ▼) guesses
// wrong. Edges carry the slides' behavioral probabilities a, ..., f and their
// complements; leaves show the team's utility.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "tree.typ": *

// (parent, child, label, position of label along the edge)
#let edges = (
  ("root", "p1l", $1\/2$, .5),
  ("root", "p1r", $1\/2$, .5),
  ("p1l", "p2-1", $a$, .45),
  ("p1l", "p2-3", $overline(a)$, .22),
  ("p1r", "p2-2", $b$, .22),
  ("p1r", "p2-4", $overline(b)$, .45),
  ("p2-1", "p3-1", $c$, .42),
  ("p2-1", "z2-1", $overline(c)$, .55),
  ("p2-2", "z2-2", $c$, .55),
  ("p2-2", "p3-2", $overline(c)$, .42),
  ("p2-3", "p3-3", $d$, .42),
  ("p2-3", "z2-3", $overline(d)$, .6),
  ("p2-4", "z2-4", $d$, .6),
  ("p2-4", "p3-4", $overline(d)$, .42),
)

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let band = (padx: .55, hy: .43, dy: .09)
    let leaf-name(p, name) = content(add(p, (0, -.6)), text(7.5pt, gray.darken(70%), $z_#name$))

    infosets(nodes, band)

    for (parent, child, label, t) in edges {
      let into-band = child.starts-with("p2") or child.starts-with("p3")
      edge(
        nodes.at(parent),
        nodes.at(child),
        radius(parent),
        if into-band { -1 } else { radius(child) },
        band,
        label: label,
        t: t,
        left-end: child in left-ends,
      )
    }
    let p3-names = (p3-1: (1, 2), p3-2: (5, 6), p3-3: (7, 8), p3-4: (11, 12))
    for (key, values) in p3-leaves {
      let p = nodes.at(key)
      for (i, dx) in (-.6, .6).enumerate() {
        let z = add(p, (dx, -1.55))
        edge(p, z, tri-r, .1, band, label: p3-labels.at(key).at(i), t: .55)
        leaf(z, values.at(i))
        leaf-name(z, p3-names.at(key).at(i))
      }
    }

    decision-nodes(nodes)
    for (key, name) in (("z2-1", 3), ("z2-2", 4), ("z2-3", 9), ("z2-4", 10)) {
      leaf(nodes.at(key), 0)
      leaf-name(nodes.at(key), name)
    }
  }),
)
