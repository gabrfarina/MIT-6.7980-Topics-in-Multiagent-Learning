#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree

// Two buyers with i.i.d. values in {2, 6} (in $k), each with probability 1/2.
// Nature draws (v_1, v_2); buyer 1 reports knowing only v_1; buyer 2 reports knowing only v_2
// and not buyer 1's report. The auctioneer has committed to the second-price auction with
// reserve 6 (random tie-breaking), so its mechanism is folded into the payoffs
// (u_A, u_1, u_2). Bold edges: truthful (direct) reports.
#let pay = (
  "/LL/L/L": $(0, 0, 0)$,
  "/LL/L/H": $(6, 0, -4)$,
  "/LL/H/L": $(6, -4, 0)$,
  "/LL/H/H": $(6, -2, -2)$,
  "/LH/L/L": $(0, 0, 0)$,
  "/LH/L/H": $(6, 0, 0)$,
  "/LH/H/L": $(6, -4, 0)$,
  "/LH/H/H": $(6, -2, 0)$,
  "/HL/L/L": $(0, 0, 0)$,
  "/HL/L/H": $(6, 0, -4)$,
  "/HL/H/L": $(6, 0, 0)$,
  "/HL/H/H": $(6, 0, -2)$,
  "/HH/L/L": $(0, 0, 0)$,
  "/HH/L/H": $(6, 0, 0)$,
  "/HH/H/L": $(6, 0, 0)$,
  "/HH/H/H": $(6, 0, 0)$,
)

#box(fill: blue.lighten(97%), radius: 2mm, inset: (x: 13mm, top: 2mm, bottom: 3mm))[
  #efg-tree(
    sx: 0.3pt,
    sy: 0.3pt,
    infoset-thickness: 2.6mm,
    nodes: (
      "/": (0, 0),
      "/LL": (-600, 140),
      "/LL/L": (-700, 280),
      "/LL/L/L": (-750, 420),
      "/LL/L/H": (-650, 420),
      "/LL/H": (-500, 280),
      "/LL/H/L": (-550, 420),
      "/LL/H/H": (-450, 420),
      "/LH": (-200, 140),
      "/LH/L": (-300, 280),
      "/LH/L/L": (-350, 420),
      "/LH/L/H": (-250, 420),
      "/LH/H": (-100, 280),
      "/LH/H/L": (-150, 420),
      "/LH/H/H": (-50, 420),
      "/HL": (200, 140),
      "/HL/L": (100, 280),
      "/HL/L/L": (50, 420),
      "/HL/L/H": (150, 420),
      "/HL/H": (300, 280),
      "/HL/H/L": (250, 420),
      "/HL/H/H": (350, 420),
      "/HH": (600, 140),
      "/HH/L": (500, 280),
      "/HH/L/L": (450, 420),
      "/HH/L/H": (550, 420),
      "/HH/H": (700, 280),
      "/HH/H/L": (650, 420),
      "/HH/H/H": (750, 420),
    ),
    payoff: key => pay.at(key),
    highlight-edges: ("/LL/L", "/LL/L/L", "/LL/H/L", "/LH/L", "/LH/L/H", "/LH/H/H", "/HL/H", "/HL/L/L", "/HL/H/L", "/HH/H", "/HH/L/H", "/HH/H/H"),
    action-name: a => if a.len() == 2 [
      #set align(center)
      $(#(if a.at(0) == "L" {2} else {6}), #(if a.at(1) == "L" {2} else {6}))$ \ $1 \/ 4$
    ] else if a == "L" [2] else [6],
    (nodes: ("/LL", "/LH"), name: move(dx: -6mm)[1: $v_1 = 2$], bend: 0mm),
    (nodes: ("/HL", "/HH"), name: move(dx: 6mm)[1: $v_1 = 6$], bend: 0mm, right: true),
    // Buyer 2's information sets are not contiguous: the arcs jump over the other subtree.
    (nodes: ("/LL/L", "/LL/H"), name: move(dx: -6mm)[2: $v_2 = 2$], bend: 0mm),
    (nodes: ("/LL/H", "/HL/L"), name: none, bend: 9mm),
    (nodes: ("/HL/L", "/HL/H"), name: none, bend: 0mm),
    (nodes: ("/LH/L", "/LH/H"), name: none, bend: 0mm),
    (nodes: ("/LH/H", "/HH/L"), name: none, bend: -9mm),
    (nodes: ("/HH/L", "/HH/H"), name: move(dx: 6mm)[2: $v_2 = 6$], bend: 0mm, right: true),
  )
]
