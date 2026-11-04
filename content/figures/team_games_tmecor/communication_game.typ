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

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    let band = (padx: .55, hy: .43, dy: .09)
    infosets(nodes, band)
    tree-edges(nodes, band)
    infoset-labels(nodes, band)
    decision-nodes(nodes)
    leaves(nodes)
  }),
)
