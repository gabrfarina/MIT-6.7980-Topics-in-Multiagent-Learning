// The team game of the satisfiability reduction, for the formula
// (x1 or x2) and (not x1 or x2) and (x1 or not x2). Chance picks a clause, which
// only P1 sees. P1 points to a literal of the clause. P2 sees only the variable of
// that literal and assigns it true (T) or false (F). The team gets 1 iff the literal
// is true. The P2 nodes that see the same variable form one information set, drawn
// as a shaded band; the two bands sit at different heights because their nodes
// alternate along the tree. Same style as communication_game.typ.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#import "../../meta/typography.typ": course-sans
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let panel = rgb(247, 249, 252)
#let team-color = rgb(46, 104, 181)
#let x1-color = rgb(118, 82, 166)
#let x2-color = rgb(30, 140, 110)

// Clauses as lists of (variable, positive?) pairs.
#let clauses = (
  ((1, true), (2, true)),
  ((1, false), (2, true)),
  ((1, true), (2, false)),
)
#let lit(v, pos) = if pos { $x_#v$ } else { $not x_#v$ }

#box(
  fill: panel,
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let (y0, y1, yl) = (0, -1.5, -6.2)
    let yv = (-3.1, -4.4) // heights of the x_1 and x_2 information sets
    let hy = .4
    let node-r = .3

    let lab(p, body) = content(p, box(fill: panel, inset: 1.2pt, text(9pt, body)))
    // Arrow from a to b, leaving a at distance ra and stopping at distance rb from b,
    // with a label at the point of height label-y (or at fraction t).
    let arrow(a, b, ra, rb, label: none, t: .5, label-y: none) = {
      let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
      let n = calc.sqrt(dx * dx + dy * dy)
      let (ux, uy) = (dx / n, dy / n)
      line((a.at(0) + ra * ux, a.at(1) + ra * uy), (b.at(0) - rb * ux, b.at(1) - rb * uy),
        stroke: .3mm, mark: (end: "stealth", scale: .7, fill: black))
      let t = if label-y == none { t } else { (label-y - a.at(1)) / dy }
      if label != none { lab((a.at(0) + t * dx, a.at(1) + t * dy), label) }
    }
    let tri(p, paint, num) = {
      line((p.at(0), p.at(1) + .36), (p.at(0) - .3, p.at(1) - .18), (p.at(0) + .3, p.at(1) - .18),
        close: true, fill: paint, stroke: .25mm + paint.darken(30%))
      content(p, course-sans(7pt, white, weight: "bold", num))
    }
    let leaf(p, value) = {
      rect((p.at(0) - .08, p.at(1) - .08), (p.at(0) + .08, p.at(1) + .08), fill: white, stroke: .22mm)
      content((p.at(0), p.at(1) - .32), text(8pt, $#value$))
    }

    // P2 nodes in tree order, two per clause; leaves in one row below them.
    let root = (6, y0)
    let p2 = ()
    for (j, clause) in clauses.enumerate() {
      for (k, (v, pos)) in clause.enumerate() {
        p2.push((1 + 4 * j + 2 * k, v, pos, j))
      }
    }

    // Information sets: one band per variable, spanning its nodes.
    for (v, paint) in ((1, x1-color), (2, x2-color)) {
      let xs = p2.filter(n => n.at(1) == v).map(n => n.at(0))
      // Centre the band on the triangles' visual middle, .09 above the node point.
      let y = yv.at(v - 1) + .09
      rect((xs.first() - .55, y - hy), (xs.last() + .55, y + hy), radius: hy,
        fill: paint.lighten(84%).transparentize(25%), stroke: .3mm + paint.lighten(30%))
      content((xs.last() + 1.05, y), text(9pt, paint.darken(15%), [sees $x_#v$]))
    }

    for j in range(3) {
      let p = (2 + 4 * j, y1)
      arrow(root, p, .27, node-r, label: $C_#(j + 1)$)
    }
    for (x, v, pos, j) in p2 {
      let q = (x, yv.at(v - 1))
      // Label every P1 edge just below the P1 nodes, above both bands.
      arrow((2 + 4 * j, y1), q, node-r, node-r, label: lit(v, pos), label-y: -2.25)
      for (i, (val, name)) in ((true, $T$), (false, $F$)).enumerate() {
        let z = (x - .45 + .9 * i, yl)
        arrow(q, z, node-r, .12, label: name, label-y: -5.35)
        leaf(z, if val == pos { 1 } else { 0 })
      }
    }

    // Nodes on top.
    circle(root, radius: .25, fill: white, stroke: .25mm)
    line((root.at(0) - .177, -.177), (root.at(0) + .177, .177), stroke: .25mm)
    line((root.at(0) - .177, .177), (root.at(0) + .177, -.177), stroke: .25mm)
    for j in range(3) { tri((2 + 4 * j, y1), team-color, "1") }
    for (x, v, pos, j) in p2 {
      tri((x, yv.at(v - 1)), if v == 1 { x1-color } else { x2-color }, "2")
    }
  }),
)
