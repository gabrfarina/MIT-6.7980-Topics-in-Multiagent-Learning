// Two-player game tree whose normal form is computed in the Lecture 7 practice problems.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree

// Leaf payoffs (u_1, u_2), drawn with Player 1's payoff on top.
#let payoffs = (
  "/1/a/3": (3, 10),
  "/1/a/4": (6, 3),
  "/1/b/3": (6, 6),
  "/1/b/4": (4, 12),
  "/2/c/5": (5, 5),
  "/2/c/6": (10, 7),
  "/2/c/7": (1, 7),
  "/2/d/5": (-2, 3),
  "/2/d/6": (8, 12),
  "/2/d/7": (9, 5),
)

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 2mm, bottom: 6mm),
  efg-tree(
    root-is-chance: false,
    sx: .25pt,
    sy: .25pt,
    nodes: (
      "/": (0, 0),
      "/1": (-260, 120),
      "/2": (260, 120),
      "/1/a": (-370, 250),
      "/1/b": (-150, 250),
      "/2/c": (150, 250),
      "/2/d": (370, 250),
      "/1/a/3": (-415, 380),
      "/1/a/4": (-325, 380),
      "/1/b/3": (-195, 380),
      "/1/b/4": (-105, 380),
      "/2/c/5": (85, 380),
      "/2/c/6": (150, 380),
      "/2/c/7": (215, 380),
      "/2/d/5": (305, 380),
      "/2/d/6": (370, 380),
      "/2/d/7": (435, 380),
    ),
    payoff: key => {
      let (u1, u2) = payoffs.at(key)
      move(dy: 1.6mm, stack(spacing: 1.2mm, $#u1$, $#u2$))
    },
    (nodes: ("/",), name: "A", bend: 0mm, right: true),
    (nodes: ("/1",), name: "X", bend: 0mm),
    (nodes: ("/2",), name: "Y", bend: 0mm, right: true),
    (nodes: ("/1/a", "/1/b"), name: "B", bend: 0mm, right: true),
    (nodes: ("/2/c", "/2/d"), name: "C", bend: 0mm, right: true),
  ),
)
