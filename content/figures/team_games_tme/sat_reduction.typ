// The team game of the satisfiability reduction, for the formula
// (x1 or x2) and (not x1 or x2) and (x1 or not x2). Chance picks a clause, which
// only P1 sees. P1 points to a literal of the clause. P2 sees only the variable of
// that literal and assigns it true (T) or false (F). The team gets 1 iff the literal
// is true. P2 nodes that see the same variable form one information set, drawn as
// a shaded band of that variable's color under the nodes.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../../meta/typography.typ": course-sans

#let p1-color = rgb(46, 104, 181)
#let p2-color = rgb(118, 82, 166)
#let panel = rgb(247, 249, 252)
#let tri-r = .3
#let add((x, y), (u, v)) = (x + u, y + v)
#let lab(p, body) = cetz.draw.content(p, box(fill: panel, inset: 1.2pt, text(9pt, body)))
#let halo(p, body, fill: black) = cetz.draw.content(p, text(fill, body))
// Arrow from a to b, shortened by ra at a and rb at b, with a label at fraction t.
#let edge(a, b, ra, rb, band, label: none, t: .5) = {
  import cetz.draw: line
  let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
  let n = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / n, dy / n)
  line(
    (a.at(0) + ra * ux, a.at(1) + ra * uy),
    (b.at(0) - rb * ux, b.at(1) - rb * uy),
    stroke: .3mm,
    mark: (end: "stealth", scale: .7, fill: black),
  )
  if label != none { lab((a.at(0) + t * dx, a.at(1) + t * dy), label) }
}
#let triangle(p, paint, num) = {
  import cetz.draw: line, content
  line(
    (p.at(0), p.at(1) + .36), (p.at(0) - .3, p.at(1) - .18), (p.at(0) + .3, p.at(1) - .18),
    close: true, fill: paint, stroke: .25mm + paint.darken(30%),
  )
  content(p, course-sans(7pt, white, weight: "bold", num))
}
#let leaf(p, value) = {
  import cetz.draw: rect, content
  rect((p.at(0) - .08, p.at(1) - .08), (p.at(0) + .08, p.at(1) + .08), fill: white, stroke: .22mm)
  content((p.at(0), p.at(1) - .32), text(8pt, $#value$))
}

#let x1-color = p2-color
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

    let band = (padx: .5, hy: .4, dy: 0)
    let root = (6, 0)
    let y1 = -1.7
    let y2 = -3.5
    let y3 = -5.1

    // P2 nodes, in tree order, with their variable.
    let p2 = ()
    for (j, clause) in clauses.enumerate() {
      let p = (2 + 4 * j, y1)
      edge(root, p, .27, tri-r, band, label: $C_#(j + 1)$, t: .5)
      for (k, (v, pos)) in clause.enumerate() {
        let q = (p.at(0) - 1 + 2 * k, y2)
        edge(p, q, tri-r, tri-r, band, label: lit(v, pos), t: .5)
        p2.push((q, v, pos))
      }
    }

    // Faint vertical strips mark the variable seen at each P2 node.
    for (q, v, pos) in p2 {
      let paint = if v == 1 { x1-color } else { x2-color }
      rect(
        add(q, (-.48, -.42)), add(q, (.48, .5)),
        radius: .18,
        fill: paint.lighten(84%),
        stroke: (paint: paint.lighten(30%), thickness: .25mm, dash: "dashed"),
      )
    }

    for (q, v, pos) in p2 {
      for (i, (val, name)) in ((true, $T$), (false, $F$)).enumerate() {
        let z = add(q, (-.5 + i, y3 - y2))
        edge(q, z, tri-r, .1, band, label: name, t: .5)
        leaf(z, if val == pos { 1 } else { 0 })
      }
    }

    // Nodes on top.
    circle(root, radius: 2.5mm, fill: white, stroke: .25mm)
    line(add(root, (-.177, -.177)), add(root, (.177, .177)), stroke: .25mm)
    line(add(root, (-.177, .177)), add(root, (.177, -.177)), stroke: .25mm)
    for j in range(3) { triangle((2 + 4 * j, y1), p1-color, "1") }
    for (q, v, pos) in p2 {
      let paint = if v == 1 { x1-color } else { x2-color }
      triangle(q, paint, "2")
      halo(add(q, (.78, .28)), text(8pt, $x_#v$), fill: paint.darken(25%))
    }
  }),
)
