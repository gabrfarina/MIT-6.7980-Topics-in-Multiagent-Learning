#import "../../meta/notation.typ": sf, spade
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree, kuhn-tree

#box(
  fill: blue.lighten(97%), //luma(97%),
  radius: 2mm,
  inset: (x: 3mm, top: 1mm, bottom: 3mm),
)[#scale(90%, reflow: true, efg-tree(
    sx: 0.22pt,
    sy: 0.25pt,
    nodes: (
      "/": (0, 0),
      "/AT": (-240, 120),
      "/ANT": (240, 120),
      "/AT/quit": (-340, 240),
      "/AT/bet": (-140, 240),
      "/AT/bet/BNAT": (-230, 360),
      "/AT/bet/BNAT/gift": (-310, 480),
      "/AT/bet/BNAT/no gift": (-150, 480),
      "/AT/bet/BAT": (-50, 360),
      "/ANT/quit": (340, 240),
      "/ANT/bet": (140, 240),
      "/ANT/bet/BNAT": (50, 360),
      "/ANT/bet/BAT": (230, 360),
      "/ANT/bet/BAT/no gift": (310, 480),
      "/ANT/bet/BAT/gift": (150, 480),
    ),
    highlight-edges: ("/AT/quit", "/ANT/quit", "/AT/bet/BNAT", "/ANT/bet/BNAT"),
    payoff: key => if key.contains("bet") [$(-\$, \$)$] else [$(0,0)$],
    action-name: action => if action == "BNAT" [
      #{ sym.not }A#spade
    ] else if action == "BAT" [
      A#spade
    ] else if action == "AT" [
      #set align(center)
      A#spade on top \
      // ($1 / 52$)
    ] else if action == "ANT" [
      #set align(center)
      A#spade _not_ on top \
      // ($51 / 52$)
    ] else if action == "no gift" [
      #{ sym.not }gift
    ] else [
      #action
    ],
    (nodes: ("/AT", "/ANT"), name: "A", bend: 0mm),
    (nodes: ("/AT/bet", "/ANT/bet"), name: "B", bend: 0mm),
    (nodes: ("/AT/bet/BNAT",), name: "C", bend: 0mm),
    (nodes: ("/ANT/bet/BAT",), name: "D", bend: 0mm),
  ))]
