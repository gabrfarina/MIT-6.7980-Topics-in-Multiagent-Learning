// Rock-paper-scissors as an extensive-form game: Player 2 cannot observe Player 1's move.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree

// Payoff (u_1, u_2) when Player 1 plays `a` and Player 2 plays `b`.
#let beats = (R: "S", P: "R", S: "P")
#let rps-payoff(key) = {
  let (_, a, b) = key.split("/")
  if a == b { $(0, 0)$ } else if beats.at(a) == b { $(+1, -1)$ } else { $(-1, +1)$ }
}

#let nodes = (
  "/": (0, 0),
)
#for (i, a) in ("R", "P", "S").enumerate() {
  let x = (i - 1) * 380
  nodes.insert("/" + a, (x, 140))
  for (j, b) in ("R", "P", "S").enumerate() {
    nodes.insert("/" + a + "/" + b, (x + (j - 1) * 125, 300))
  }
}

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 2mm, bottom: 3mm),
  efg-tree(
    root-is-chance: false,
    sx: .25pt,
    sy: .25pt,
    nodes: nodes,
    payoff: rps-payoff,
    (nodes: ("/",), name: "A", bend: 0mm),
    (nodes: ("/R", "/P", "/S"), name: "B", bend: 0mm),
  ),
)
