#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree

// Bayesian persuasion (slides: car on sale for $5k). Nature draws the car's quality; the seller
// (black nodes), who has committed to a signaling scheme, recommends Buy or Pass; the buyer
// (white nodes) sees only the recommendation. Payoffs are (u_S, u_B) in $k.
// Bold edges: the optimal scheme's recommendations and the buyer's direct (obedient) strategy.
#let pay = (
  "/good/Bg/buy": $(5, 1)$,
  "/good/Pg/buy": $(5, 1)$,
  "/bad/Bb/buy": $(5, -1)$,
  "/bad/Pb/buy": $(5, -1)$,
)

#box(fill: blue.lighten(97%), radius: 2mm, inset: (x: 14mm, top: 2mm, bottom: 3mm))[
  #efg-tree(
    sx: 0.3pt,
    sy: 0.3pt,
    infoset-thickness: 2.6mm,
    nodes: (
      "/": (0, 0),
      "/good": (-220, 130),
      "/bad": (220, 130),
      "/good/Bg": (-330, 270),
      "/bad/Bb": (-110, 270),
      "/good/Pg": (110, 270),
      "/bad/Pb": (330, 270),
      "/good/Bg/buy": (-380, 400),
      "/good/Bg/pass": (-280, 400),
      "/bad/Bb/buy": (-160, 400),
      "/bad/Bb/pass": (-60, 400),
      "/good/Pg/buy": (60, 400),
      "/good/Pg/pass": (160, 400),
      "/bad/Pb/buy": (280, 400),
      "/bad/Pb/pass": (380, 400),
    ),
    payoff: key => pay.at(key, default: $(0, 0)$),
    highlight-edges: (
      "/good/Bg", "/bad/Bb", "/bad/Pb",
      "/good/Bg/buy", "/bad/Bb/buy", "/good/Pg/pass", "/bad/Pb/pass",
    ),
    action-name: a => if a == "good" [
      #set align(center)
      good (\$6k) \ $1 \/ 3$
    ] else if a == "bad" [
      #set align(center)
      bad (\$4k) \ $2 \/ 3$
    ] else if a == "Bg" [
      #set align(center)
      "buy" \ $1$
    ] else if a == "Pg" [
      #set align(center)
      "pass" \ $0$
    ] else if a == "Bb" [
      #set align(center)
      "buy" \ $1 \/ 2$
    ] else if a == "Pb" [
      #set align(center)
      "pass" \ $1 \/ 2$
    ] else if a == "buy" [B] else [P],
    (nodes: ("/good/Bg", "/bad/Bb"), name: move(dx: -8mm)[Buyer: "buy"], bend: 0mm),
    (nodes: ("/good/Pg", "/bad/Pb"), name: move(dx: 8mm)[Buyer: "pass"], bend: 0mm, right: true),
  )
]
