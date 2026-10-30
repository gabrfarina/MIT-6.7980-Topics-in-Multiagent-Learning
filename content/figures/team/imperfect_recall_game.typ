// The communication game of L12 redrawn as a two-player zero-sum game (slide 7).
// Team ▲ is one player (1) that observes the bit, sends a message, and then forgets
// the bit when it acts again at the second level. Player 3 becomes player 2.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let p1-color = rgb(46, 104, 181)
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
// Terminal payoffs (team utility) below the adversary's nodes, left then right child.
#let p3-leaves = (
  p3-1: (0, 1),
  p3-2: (1, 0),
  p3-3: (0, 1),
  p3-4: (1, 0),
)
// (parent, child)
#let edges = (
  ("root", "p1l"),
  ("root", "p1r"),
  ("p1l", "p2-1"),
  ("p1l", "p2-3"),
  ("p1r", "p2-2"),
  ("p1r", "p2-4"),
  ("p2-1", "p3-1"),
  ("p2-1", "z2-1"),
  ("p2-2", "z2-2"),
  ("p2-2", "p3-2"),
  ("p2-3", "p3-3"),
  ("p2-3", "z2-3"),
  ("p2-4", "z2-4"),
  ("p2-4", "p3-4"),
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

    let edge(a, b, ra, rb) = {
      let u = unit(a, b)
      let arrow = (end: "stealth", scale: .8, fill: black, stroke: .3mm)
      line(add(a, u, s: ra), add(b, u, s: -(rb + .02)), mark: arrow, stroke: .3mm + black)
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

    let leaf(p, value) = {
      rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: white, stroke: .22mm)
      halo(add(p, (0, -.3)), text(7pt, $#value$))
    }

    // Information sets of the team player at the second level, and of the adversary.
    infoset(nodes.p2-1, nodes.p2-2, p1-color)
    infoset(nodes.p2-3, nodes.p2-4, p1-color)
    infoset(nodes.p3-1, nodes.p3-2, p3-color)
    infoset(nodes.p3-3, nodes.p3-4, p3-color)

    for (parent, child) in edges {
      edge(nodes.at(parent), nodes.at(child), radius(parent), radius(child))
    }
    for (key, values) in p3-leaves {
      let p = nodes.at(key)
      for (i, dx) in (-.6, .6).enumerate() {
        let z = add(p, (dx, -1.3))
        edge(p, z, tri-r, .1)
        leaf(z, values.at(i))
      }
    }

    // Nodes on top of edges and infosets.
    let p = nodes.root
    circle(p, radius: 1.5mm, fill: white, stroke: .22mm)
    line(add(p, (-.1, -.1)), add(p, (.1, .1)), stroke: .22mm)
    line(add(p, (-.1, .1)), add(p, (.1, -.1)), stroke: .22mm)
    for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
    for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p1-color, "1") }
    for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "2", up: false) }
    for key in ("z2-1", "z2-2", "z2-3", "z2-4") { leaf(nodes.at(key), 0) }
  }),
)
