// Extensive-form tree with nine sequence coordinates for Player 1.
#import "../libs/typography.typ": figure-font
#import "@preview/cetz:0.4.1"

#let draw-tree(s) = {
  let bg = blue.lighten(97%)
  cetz.canvas({
    import cetz.draw: *

    let node(coord, player) = {
      circle(
        coord,
        radius: if player == 1 {
          0.9mm
        } else {
          1.0mm
        },
        stroke: black + .2mm,
        fill: if player == 1 {
          black
        } else {
          white
        },
      )
    }
    let leaf(coord) = {
      rect(
        (coord.at(0) - .08, coord.at(1) - .08),
        (coord.at(0) + .08, coord.at(1) + .08),
        stroke: .2mm,
        fill: white,
      )
    }
    let info1(coord) = {
      circle(coord, radius: 2.2mm, stroke: .18mm + blue.lighten(30%), fill: blue.lighten(80%))
    }
    let info2(A, B) = {
      arc(
        (A.at(0), A.at(1) + 0.22),
        radius: 2.2mm,
        start: 90deg,
        stop: 270deg,
        stroke: .18mm + blue.lighten(30%),
        fill: blue.lighten(80%),
      )
      arc(
        (B.at(0), B.at(1) - 0.22),
        radius: 2.2mm,
        start: -90deg,
        stop: 90deg,
        stroke: .18mm + blue.lighten(30%),
        fill: blue.lighten(80%),
      )
      rect(
        (A.at(0), A.at(1) - 0.22),
        (B.at(0), B.at(1) + 0.22),
        fill: blue.lighten(80%),
        stroke: none,
      )

      line(
        (A.at(0), A.at(1) + 0.22),
        (B.at(0), B.at(1) + 0.22),
        stroke: .18mm + blue.lighten(30%),
      )
      line(
        (A.at(0), A.at(1) - 0.22),
        (B.at(0), B.at(1) - 0.22),
        stroke: .18mm + blue.lighten(30%),
      )
    }

    info1((0, 0))
    content((.4, 0))[#text(blue, font: figure-font)[A]]
    info1((-1.44, -.96))
    content((-1.44 - .4, -.96))[#text(blue, font: figure-font)[P]]
    info1((1.44, -.96))
    content((1.44 + .4, -.96))[#text(blue, font: figure-font)[Q]]
    info1((-1.44 - .72, -1.92))
    content((-1.44 - .72 - .4, -1.92))[#text(blue, font: figure-font)[B]]
    info1((-1.44 + .72, -1.92))
    content((-1.44 + .72 - .4, -1.92))[#text(blue, font: figure-font)[C]]
    info2((1.44 - .72, -1.92), (1.44 + .72, -1.92))
    content((1.44 + .72 + .4, -1.92))[#text(blue, font: figure-font)[D]]

    node((0, 0), 1)
    node((-1.44, -.96), 2)
    node((1.44, -.96), 2)
    node((-1.44 - .72, -1.92), 1)
    node((-1.44 + .72, -1.92), 1)
    leaf((-1.44 - .72 - 0.4, -2.88))
    leaf((-1.44 - .72 + 0.4, -2.88))
    leaf((-1.44 + .72 - 0.4, -2.88))
    leaf((-1.44 + .72 + 0.4, -2.88))
    node((1.44 - .72, -1.92), 1)
    node((1.44 + .72, -1.92), 1)
    leaf((1.44 - .72 - 0.4, -2.88))
    leaf((1.44 - .72 + 0.0, -2.88))
    leaf((1.44 - .72 + 0.4, -2.88))
    leaf((1.44 + .72 - 0.4, -2.88))
    leaf((1.44 + .72 + 0.0, -2.88))
    leaf((1.44 + .72 + 0.4, -2.88))

    let arr(start, end, lbl: none, hl: false) = {
      let len = calc.sqrt(calc.pow(end.at(0) - start.at(0), 2) + calc.pow(end.at(1) - start.at(1), 2))
      let ns = (
        start.at(0) + 0.1 * (end.at(0) - start.at(0)) / len,
        start.at(1) + 0.1 * (end.at(1) - start.at(1)) / len,
      )
      let ne = (
        end.at(0) - 0.1 * (end.at(0) - start.at(0)) / len,
        end.at(1) - 0.1 * (end.at(1) - start.at(1)) / len,
      )
      let nne = (
        end.at(0) - 0.25 * (end.at(0) - start.at(0)) / len,
        end.at(1) - 0.25 * (end.at(1) - start.at(1)) / len,
      )
      let mp = (
        (start.at(0) * .55 + end.at(0) * .45),
        (start.at(1) * .55 + end.at(1) * .45),
      )

      line(ns, nne, stroke: .8mm + white)

      if not hl {
        line(ns, nne, stroke: .3mm)
        mark(ne, cetz.vector.sub(cetz.vector.add(ne, ne), ns), symbol: "stealth", fill: black, stroke: .3mm, scale: .7)
      } else {
        line(ns, nne, stroke: 1.2mm + blue.darken(20%))
        mark(
          ne,
          cetz.vector.sub(cetz.vector.add(ne, ne), ns),
          symbol: "stealth",
          fill: blue.darken(20%),
          stroke: blue.darken(20%),
          scale: 1,
        )
      }

      if lbl != none {
        content(mp)[#text(
          if not hl {
            luma(20%)
          } else {
            blue.darken(30%)
          },
          font: figure-font,
          size: 9pt,
          box(fill: bg, inset: (y: .3mm, x: .15mm))[#lbl],
        )]
      }
    }
    arr((0, 0), (-1.44, -.96), lbl: 1, hl: s.at(0) == "1")
    arr((0, 0), (1.44, -.96), lbl: 2, hl: s.at(1) == "1")
    arr((-1.44, -.96), (-1.44 - .72, -1.92))
    arr((-1.44, -.96), (-1.44 + .72, -1.92))
    arr((1.44, -.96), (1.44 - .72, -1.92))
    arr((1.44, -.96), (1.44 + .72, -1.92))
    arr(
      (-1.44 - .72, -1.92),
      (-1.44 - .72 - 0.4, -2.88),
      lbl: 3,
      hl: s.at(2) == "1",
    )
    arr(
      (-1.44 - .72, -1.92),
      (-1.44 - .72 + 0.4, -2.88),
      lbl: 4,
      hl: s.at(3) == "1",
    )
    arr(
      (-1.44 + .72, -1.92),
      (-1.44 + .72 - 0.4, -2.88),
      lbl: 5,
      hl: s.at(4) == "1",
    )
    arr(
      (-1.44 + .72, -1.92),
      (-1.44 + .72 + 0.4, -2.88),
      lbl: 6,
      hl: s.at(5) == "1",
    )
    arr(
      (1.44 - .72, -1.92),
      (1.44 - .72 - 0.4, -2.88),
      lbl: 7,
      hl: s.at(6) == "1",
    )
    arr(
      (1.44 - .72, -1.92),
      (1.44 - .72 + 0.4, -2.88),
      lbl: 9,
      hl: s.at(8) == "1",
    )
    arr(
      (1.44 - .72, -1.92),
      (1.44 - .72 + 0.0, -2.88),
      lbl: 8,
      hl: s.at(7) == "1",
    )
    arr(
      (1.44 + .72, -1.92),
      (1.44 + .72 - 0.4, -2.88),
      lbl: 7,
      hl: s.at(6) == "1",
    )
    arr(
      (1.44 + .72, -1.92),
      (1.44 + .72 + 0.4, -2.88),
      lbl: 9,
      hl: s.at(8) == "1",
    )
    arr(
      (1.44 + .72, -1.92),
      (1.44 + .72 + 0.0, -2.88),
      lbl: 8,
      hl: s.at(7) == "1",
    )
  })
}
