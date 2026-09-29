#import "../../meta/notation.typ": sf
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree, kuhn-tree

#set text(8pt)
#let draft = true
#box(
  fill: blue.lighten(97%), //luma(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 1mm, bottom: 2mm),
  scale(85%, reflow: true, kuhn-tree(
    sx: .24pt,
    sy: .24pt,
    infoset-thickness: 4mm,
    (nodes: ("/JK", "/JQ"), bend: 13mm, name: "A"),
    (nodes: ("/QK", "/QJ"), bend: 0mm, name: "B"),
    (nodes: ("/KJ", "/KQ"), bend: 0mm, name: "C"),
    (nodes: ("/JK/chk", "/QK/chk"), bend: 8mm, name: "P"),
    (nodes: ("/JK/bet", "/QK/bet"), bend: -8mm, name: "Q"),
    (nodes: ("/QJ/chk", "/KJ/chk"), bend: 8mm, name: "R"),
    (nodes: ("/QJ/bet", "/KJ/bet"), bend: -8mm, name: "S"),
    (nodes: ("/KQ/chk", "/JQ/chk"), bend: 8mm, name: "T"),
    (nodes: ("/KQ/bet", "/JQ/bet"), bend: -8mm, name: "U"),
    (nodes: ("/JK/chk/bet", "/JQ/chk/bet"), bend: -20mm, name: "D"),
    (nodes: ("/QK/chk/bet", "/QJ/chk/bet"), bend: -4mm, name: "E"),
    (nodes: ("/KJ/chk/bet", "/KQ/chk/bet"), bend: -4mm, name: "F"),
  )),
)
