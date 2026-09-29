#import "../../meta/notation.typ": sf, eps
#set page(width: 372.3973pt, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree, kuhn-tree

#align(center, stack(dir: ltr, spacing: 1fr)[
      #box(
        fill: blue.lighten(97%), //luma(97%),
        radius: 2mm,
        inset: (x: 1mm, top: 1mm, bottom: 3mm),
      )[#efg-tree(
          sx: 0.2pt,
          nodes: (
            "/": (0, 0),
            "/a": (-240, 120),
            "/b": (240, 120),
            "/b/r": (120, 240),
            "/b/r/c": (60, 360),
            "/b/r/d": (180, 360),
            "/b/s": (360, 240),
            "/b/s/p": (300, 360),
            "/b/s/q": (420, 360),
          ),
          payoff: key => {
            if key == "/a" [
              $(2, -2)$
            ] else if key == "/b/r/c" [
              $(1,-1)$
            ] else if key == "/b/r/d" [
              $(-2,2)$
            ] else [
              $(0,0)$
            ]
          },
          root-is-chance: false,
          (nodes: ("/",), name: "A", bend: 0mm),
          (nodes: ("/b",), name: "B", bend: 0mm, right: true),
          (nodes: ("/b/r",), name: "C", bend: 0mm),
          (nodes: ("/b/s",), name: "D", bend: 0mm, right: true),
        )]][
      #table(
        columns: 3,
        align: (left, left, right),
        stroke: (j, i) => if i == 0 {
          (top: black, bottom: black)
        } else if i == 5 {
          (bottom: black)
        },
        fill: (j, i) => if calc.rem(i, 2) == 0 {
          white
        } else {
          // luma(85%)
          none
        },
        table.header()[*Player*][*Action*][*Probability*],
        [Player 1 $(#text(size: 13pt, sym.circle.filled))$], [#sf[a]], [$1 - 4 eps$],
        [Player 1], [#sf[b]], [$4 eps$],
        [Player 1], [#sf[c, d, p, q]], [$1\/2$],
        [Player 2 $(#text(size: 13pt, sym.circle.stroked.small))$], [#sf[r]], [$1 - eps$],
        [Player 2], [#sf[s]], [$eps$],
      )
    ])
