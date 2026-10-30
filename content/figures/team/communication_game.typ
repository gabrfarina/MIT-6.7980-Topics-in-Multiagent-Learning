// The communication game of L12 (slides 2-7). Chance draws a uniform bit seen
// only by P1; P1's action is seen by P2 and P3, who then guess the bit. The team
// (P1, P2: ▲) gets 1 iff P2 guesses right and the adversary (P3: ▼) guesses
// wrong. Edges carry the slides' behavioral probabilities a, ..., f and their
// complements; leaves show the team's utility.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let p1-color = rgb(46, 104, 181)
#let p2-color = rgb(118, 82, 166)
#let p3-color = rgb(222, 110, 20)

// Node positions (cm). P2_1, P2_2 share an infoset, as do P2_3, P2_4, and
// likewise for P3. P1's left node is reached on the first chance outcome.
#let nodes = (
  root: (5.5, 0),
  p1l: (2.5, -1.5),
  p1r: (8.5, -1.5),
  p2-1: (1, -3.3),
  p2-2: (4, -3.3),
  p2-3: (7, -3.3),
  p2-4: (10, -3.3),
  z2-1: (1.85, -4.45),
  z2-2: (3.15, -4.45),
  z2-3: (7.85, -4.45),
  z2-4: (9.15, -4.45),
  p3-1: (1, -5.4),
  p3-2: (4, -5.4),
  p3-3: (7, -5.4),
  p3-4: (10, -5.4),
)
// Terminal payoffs (team utility) below the P3 nodes, left then right child.
// Leaves are numbered z_1, ..., z_12 left to right (message, then bit, then P2, then P3),
// matching the realization vectors in the notes.
#let p3-leaves = (
  p3-1: (0, 1),
  p3-2: (1, 0),
  p3-3: (0, 1),
  p3-4: (1, 0),
)
// (parent, child, label, position of label along the edge)
#let edges = (
  ("root", "p1l", $1\/2$, .5),
  ("root", "p1r", $1\/2$, .5),
  ("p1l", "p2-1", $a$, .45),
  ("p1l", "p2-3", $overline(a)$, .22),
  ("p1r", "p2-2", $b$, .22),
  ("p1r", "p2-4", $overline(b)$, .45),
  ("p2-1", "p3-1", $c$, .42),
  ("p2-1", "z2-1", $overline(c)$, .53),
  ("p2-2", "z2-2", $c$, .53),
  ("p2-2", "p3-2", $overline(c)$, .42),
  ("p2-3", "p3-3", $d$, .42),
  ("p2-3", "z2-3", $overline(d)$, .53),
  ("p2-4", "z2-4", $d$, .53),
  ("p2-4", "p3-4", $overline(d)$, .42),
)

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let add((x, y), (u, v), s: 1) = (x + s * u, y + s * v)
    let unit((x, y), (u, v)) = {
      let n = calc.sqrt((u - x) * (u - x) + (v - y) * (v - y))
      ((u - x) / n, (v - y) / n)
    }
    let tri-r = .25 // distance from a triangle's centre to where an edge stops
    let radius(key) = if key == "root" { .17 } else if key.starts-with("z") { .1 } else { tri-r }

    let halo(pos, body) = {
      for i in range(36) {
        let x = (calc.rem(i, 6) - 2.5) * .12mm
        let y = (calc.floor(i / 6) - 2.5) * .12mm
        content((rel: (x, y), to: pos), text(white, body))
      }
      content(pos, body)
    }

    // Arrow from a to b with a gap for a label at fraction t.
    let edge(a, b, ra, rb, label: none, t: .5) = {
      let u = unit(a, b)
      let start = add(a, u, s: ra)
      let stop = add(b, u, s: -(rb + .02))
      let arrow = (end: "stealth", scale: .8, fill: black, stroke: .3mm)
      let lw = .3mm + black
      if label == none {
        line(start, stop, mark: arrow, stroke: lw)
      } else {
        let c = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
        let gap = .17
        line(start, add(c, u, s: -gap), stroke: lw)
        line(add(c, u, s: gap), stop, mark: arrow, stroke: lw)
        halo(c, text(9pt, label))
      }
    }

    let infoset(a, b, paint) = {
      line(a, b, stroke: (thickness: 6.2mm, paint: paint.lighten(35%), cap: "round"))
      line(a, b, stroke: (thickness: 5.7mm, paint: paint.lighten(82%), cap: "round"))
    }

    let triangle(p, paint, number, up: true) = {
      let s = if up { 1 } else { -1 }
      let (w, h) = (.44, .38)
      line(
        add(p, (0, s * 2 * h / 3)),
        add(p, (-w / 2, -s * h / 3)),
        add(p, (w / 2, -s * h / 3)),
        close: true,
        fill: paint,
        stroke: .25mm + paint.darken(40%),
      )
      content(add(p, (0, -s * .015)), course-sans(6pt, white, weight: "bold", number))
    }

    let leaf(p, value, name) = {
      rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: white, stroke: .22mm)
      halo(add(p, (0, -.3)), text(7pt, $#value$))
      content(add(p, (0, -.58)), text(6.5pt, gray.darken(55%), $z_#name$))
    }

    // Information sets of P2 and P3 (P1's two nodes are singletons).
    infoset(nodes.p2-1, nodes.p2-2, p2-color)
    infoset(nodes.p2-3, nodes.p2-4, p2-color)
    infoset(nodes.p3-1, nodes.p3-2, p3-color)
    infoset(nodes.p3-3, nodes.p3-4, p3-color)

    for (parent, child, label, t) in edges {
      edge(nodes.at(parent), nodes.at(child), radius(parent), radius(child), label: label, t: t)
    }
    let p3-labels = (
      p3-1: ($e$, $overline(e)$),
      p3-2: ($e$, $overline(e)$),
      p3-3: ($f$, $overline(f)$),
      p3-4: ($f$, $overline(f)$),
    )
    let p3-names = (p3-1: (1, 2), p3-2: (5, 6), p3-3: (7, 8), p3-4: (11, 12))
    for (key, values) in p3-leaves {
      let p = nodes.at(key)
      for (i, dx) in (-.6, .6).enumerate() {
        let z = add(p, (dx, -1.3))
        edge(p, z, tri-r, .1, label: p3-labels.at(key).at(i), t: .48)
        leaf(z, values.at(i), p3-names.at(key).at(i))
      }
    }

    // Nodes on top of edges and infosets.
    let p = nodes.root
    circle(p, radius: 1.5mm, fill: white, stroke: .22mm)
    line(add(p, (-.1, -.1)), add(p, (.1, .1)), stroke: .22mm)
    line(add(p, (-.1, .1)), add(p, (.1, -.1)), stroke: .22mm)
    for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
    for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p2-color, "2") }
    for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "3", up: false) }
    for (key, name) in (("z2-1", 3), ("z2-2", 4), ("z2-3", 9), ("z2-4", 10)) { leaf(nodes.at(key), 0, name) }
  }),
)
