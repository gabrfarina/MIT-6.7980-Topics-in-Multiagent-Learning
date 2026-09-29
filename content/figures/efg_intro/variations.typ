#import "../../meta/notation.typ": sf
#set page(width: 385.5118pt, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree, kuhn-tree

#align(center, grid(
    columns: (25%, 70%),
    align: (left, left),
    row-gutter: 3mm,
    column-gutter: 3%,
    [#box(
        stroke: (top: .5mm + gray),
        width: 100%,
        inset: (right: 0mm, top: 2.5mm, bottom: 2mm),
      )[#sym.triangle.r.filled *First variation*]

      Player 1 is informed of the private card of Player 2 by the dealer.
    ],
    box(fill: blue.lighten(97%), radius: 2mm, inset: 1mm, height: 4.7cm, scale(85%, reflow: true, kuhn-tree(
      sx: .17pt,
      sy: .16pt,
      payoffs: false,
      action-labels: false,
      infoset-labels: false,
      infoset-thickness: 3.5mm,
      (nodes: ("/JK",), bend: 13mm, name: none),
      (nodes: ("/JQ",), bend: 13mm, name: none),
      (nodes: ("/QK",), bend: 0mm, name: none),
      (nodes: ("/QJ",), bend: 0mm, name: none),
      (nodes: ("/KJ",), bend: 0mm, name: none),
      (nodes: ("/KQ",), bend: 0mm, name: none),
      (nodes: ("/JK/chk", "/QK/chk"), bend: 6.5mm, name: "P"),
      (nodes: ("/JK/bet", "/QK/bet"), bend: -6.5mm, name: "Q"),
      (nodes: ("/QJ/chk", "/KJ/chk"), bend: 6.5mm, name: "R"),
      (nodes: ("/QJ/bet", "/KJ/bet"), bend: -6.5mm, name: "S"),
      (nodes: ("/KQ/chk", "/JQ/chk"), bend: 6.5mm, name: "T"),
      (nodes: ("/KQ/bet", "/JQ/bet"), bend: -6.5mm, name: "U"),
      (nodes: ("/JK/chk/bet",), bend: 0mm, name: none),
      (nodes: ("/JQ/chk/bet",), bend: 0mm, name: none),
      (nodes: ("/QK/chk/bet",), bend: 0mm, name: none),
      (nodes: ("/QJ/chk/bet",), bend: 0mm, name: none),
      (nodes: ("/KJ/chk/bet",), bend: 0mm, name: none),
      (nodes: ("/KQ/chk/bet",), bend: 0mm, name: none),
    ))),

    [#box(
        stroke: (top: .5mm + gray),
        width: 100%,
        inset: (right: 0mm, top: 2.5mm, bottom: 2mm),
      )[#sym.triangle.r.filled *Second variation*]

      Player 2 does not get to observe
      her private card.
    ],
    box(fill: blue.lighten(97%), radius: 2mm, inset: 1mm, height: 4.9cm, scale(85%, reflow: true, kuhn-tree(
      sx: .17pt,
      sy: .16pt,
      payoffs: false,
      action-labels: false,
      infoset-labels: false,
      infoset-thickness: 3.5mm,
      (nodes: ("/JK", "/JQ"), bend: 13mm, name: "A"),
      (nodes: ("/QK", "/QJ"), bend: 0mm, name: "B"),
      (nodes: ("/KJ", "/KQ"), bend: 0mm, name: "C"),
      (nodes: ("/JK/chk", "/QK/chk", "/QJ/chk", "/KJ/chk", "/KQ/chk", "/JQ/chk"), bend: 7mm, name: "P"),
      (nodes: ("/JK/bet", "/QK/bet", "/QJ/bet", "/KJ/bet", "/KQ/bet", "/JQ/bet"), bend: -7mm, name: "Q"),
      (nodes: ("/JK/chk/bet", "/JQ/chk/bet"), bend: -20mm, name: "D"),
      (nodes: ("/QK/chk/bet", "/QJ/chk/bet"), bend: -4mm, name: "E"),
      (nodes: ("/KJ/chk/bet", "/KQ/chk/bet"), bend: -4mm, name: "F"),
    ))),

    [#box(
        stroke: (top: .5mm + gray),
        width: 100%,
        inset: (right: 0mm, top: 2.5mm, bottom: 2mm),
      )[#sym.triangle.r.filled *Third variation*]

      Player 1 is allowed to look at his
      private card only if he decides to
      `check`.
    ],
    box(fill: blue.lighten(97%), radius: 2mm, inset: 1mm, height: 4.9cm, scale(85%, reflow: true, kuhn-tree(
      sx: .17pt,
      sy: .16pt,
      payoffs: false,
      action-labels: false,
      infoset-labels: false,
      infoset-thickness: 3.5mm,
      (nodes: ("/JK", "/JQ"), bend: -2mm, name: "A"),
      (nodes: ("/JK/chk", "/QK/chk"), bend: 6.5mm, name: "P"),
      (nodes: ("/JK/bet", "/QK/bet"), bend: -6.5mm, name: "Q"),
      (nodes: ("/QJ/chk", "/KJ/chk"), bend: 6.5mm, name: "R"),
      (nodes: ("/QJ/bet", "/KJ/bet"), bend: -6.5mm, name: "S"),
      (nodes: ("/KQ/chk", "/JQ/chk"), bend: 6.5mm, name: "T"),
      (nodes: ("/KQ/bet", "/JQ/bet"), bend: -6.5mm, name: "U"),
      (nodes: ("/JK/chk/bet", "/JQ/chk/bet"), bend: -20mm, name: "D"),
      (nodes: ("/QK/chk/bet", "/QJ/chk/bet"), bend: -4mm, name: "E"),
      (nodes: ("/KJ/chk/bet", "/KQ/chk/bet"), bend: -4mm, name: "F"),
    ))),
  ))
