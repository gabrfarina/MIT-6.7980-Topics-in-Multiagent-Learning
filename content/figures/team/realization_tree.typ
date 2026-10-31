// The realization vector of the one-time pad of L12 (slide 8). The tree is that of
// communication_game.typ. Below each leaf z is x^(mu*)[z], the probability under mu*
// that the team plays all of its actions on the path to z. Green team edges are those
// the team reaches by its own actions with positive probability (1/2 for each).
// Grey team edges have probability 0. Chance and Player 3 edges stay black. Edge
// labels and payoffs are dropped to save clutter. Values checked in python3 from the
// definition and from x(a, b; c, d) of the notes' example.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let p1-color = rgb(46, 104, 181)
#let p2-color = rgb(118, 82, 166)
#let p3-color = rgb(222, 110, 20)
#let plan-color = rgb(0, 150, 110)
#let off-color = luma(62%)

// Node positions (cm), as in communication_game.typ.
#let nodes = (
  root: (5.5, -.45),
  p1l: (2.5, -1.5),
  p1r: (8.5, -1.5),
  p2-1: (1, -3.3),
  p2-2: (4, -3.3),
  p2-3: (7, -3.3),
  p2-4: (10, -3.3),
  z2-1: (1.85, -4.7),
  z2-2: (3.15, -4.7),
  z2-3: (7.85, -4.7),
  z2-4: (9.15, -4.7),
  p3-1: (1, -6.15),
  p3-2: (4, -6.15),
  p3-3: (7, -6.15),
  p3-4: (10, -6.15),
)
// x^(mu*)[z] for z_1, ..., z_12 (1 means 1/2, 0 means 0).
#let half = (1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1)
// (parent, child) for every edge above the Player 3 nodes. Team edges that the team
// reaches with positive probability under mu* are in `on`.
#let edges = (
  ("root", "p1l"), ("root", "p1r"),
  ("p1l", "p2-1"), ("p1l", "p2-3"), ("p1r", "p2-2"), ("p1r", "p2-4"),
  ("p2-1", "p3-1"), ("p2-1", "z2-1"), ("p2-2", "z2-2"), ("p2-2", "p3-2"),
  ("p2-3", "p3-3"), ("p2-3", "z2-3"), ("p2-4", "z2-4"), ("p2-4", "p3-4"),
)
#let on = (
  ("p1l", "p2-1"), ("p1l", "p2-3"), ("p1r", "p2-2"), ("p1r", "p2-4"),
  ("p2-1", "p3-1"), ("p2-2", "p3-2"), ("p2-3", "p3-3"), ("p2-4", "p3-4"),
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
    let tri-r = .34 // distance from a triangle's centre to where an edge stops
    // Rounded band around an information set. hy is its half-height, and dy shifts it
    // toward the wide side of the triangles.
    let band = (padx: .55, hy: .43, dy: .09)
    let radius(key) = if key == "root" { .27 } else if key.starts-with("z") { .1 } else { tri-r }

    let halo(pos, body, fill: black) = {
      for i in range(36) {
        let x = (calc.rem(i, 6) - 2.5) * .12mm
        let y = (calc.floor(i / 6) - 2.5) * .12mm
        content((rel: (x, y), to: pos), text(white, body))
      }
      content(pos, text(fill, body))
    }

    // Arrow from a to b. style is "team-on", "team-off" or "neutral". rb = -1 means:
    // stop at the top edge of the child's information set.
    let edge(a, b, ra, rb, style: "neutral") = {
      let u = unit(a, b)
      let start = add(a, u, s: ra)
      let dy = if b.at(1) < -5 { -band.dy } else { band.dy }
      // A shallow edge into the outer end of a band enters through its side.
      let left-end = b.at(0) in (1, 7)
      let side = if (left-end and u.at(0) > 0) or (not left-end and u.at(0) < 0) {
        band.padx / calc.abs(u.at(0))
      } else { 99 }
      let rb = if rb < 0 { calc.min((band.hy + dy) / -u.at(1), side) } else { rb }
      let stop = add(b, u, s: -(rb + .02))
      let paint = if style == "team-on" { plan-color } else if style == "team-off" { off-color } else { black }
      let width = if style == "team-on" { .7mm } else { .3mm }
      let arrow = (end: "stealth", scale: if style == "team-on" { .65 } else { .8 }, fill: paint, stroke: width + paint)
      line(start, stop, mark: arrow, stroke: width + paint)
    }

    let infoset(a, b, paint) = {
      let dy = if paint == p3-color { -band.dy } else { band.dy }
      rect(
        (a.at(0) - band.padx, a.at(1) + dy - band.hy),
        (b.at(0) + band.padx, b.at(1) + dy + band.hy),
        radius: band.hy,
        fill: paint.lighten(82%),
        stroke: .25mm + paint.lighten(35%),
      )
    }

    let triangle(p, paint, number, up: true) = {
      let s = if up { 1 } else { -1 }
      let (w, h) = (.62, .54)
      line(
        add(p, (0, s * 2 * h / 3)),
        add(p, (-w / 2, -s * h / 3)),
        add(p, (w / 2, -s * h / 3)),
        close: true,
        fill: paint.darken(22%),
        stroke: .25mm + paint.darken(40%),
      )
      content(p, course-sans(7pt, white, weight: "bold", number))
    }

    // Leaf z_name with x^(mu*)[z] below it. Leaves with positive mass are filled green.
    let leaf(p, name) = {
      let pos = half.at(name - 1) == 1
      rect(
        add(p, (-.08, -.08)),
        add(p, (.08, .08)),
        fill: if pos { plan-color } else { white },
        stroke: .22mm + if pos { plan-color.darken(30%) } else { black },
      )
      halo(
        add(p, (0, -.34)),
        text(8pt, if pos { $1\/2$ } else { $0$ }),
        fill: if pos { plan-color.darken(35%) } else { off-color.darken(30%) },
      )
      content(add(p, (0, -.68)), text(7.5pt, gray.darken(70%), $bold(z)_#name$))
    }

    // Information sets of P2 and P3 (P1's two nodes are singletons).
    infoset(nodes.p2-1, nodes.p2-2, p2-color)
    infoset(nodes.p2-3, nodes.p2-4, p2-color)
    infoset(nodes.p3-1, nodes.p3-2, p3-color)
    infoset(nodes.p3-3, nodes.p3-4, p3-color)

    for (parent, child) in edges {
      let into-band = child.starts-with("p2") or child.starts-with("p3")
      let style = if parent == "root" { "neutral" } else if (parent, child) in on { "team-on" } else { "team-off" }
      edge(nodes.at(parent), nodes.at(child), radius(parent), if into-band { -1 } else { radius(child) }, style: style)
    }
    let p3-names = (p3-1: (1, 2), p3-2: (5, 6), p3-3: (7, 8), p3-4: (11, 12))
    for (key, names) in p3-names {
      let p = nodes.at(key)
      for (i, dx) in (-.6, .6).enumerate() {
        let z = add(p, (dx, -1.55))
        edge(p, z, tri-r, .1)
        leaf(z, names.at(i))
      }
    }

    // Row label to the left of the bottom leaves.
    content(
      (-.15, -6.15 - 1.55 - .34),
      anchor: "east",
      text(8pt, $x^(bold(mu)^star) [z]$),
    )

    // Nodes on top of edges and infosets.
    let p = nodes.root
    circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
    line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
    line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
    for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
    for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p2-color, "2") }
    for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "3", up: false) }
    for (key, name) in (("z2-1", 3), ("z2-2", 4), ("z2-3", 9), ("z2-4", 10)) { leaf(nodes.at(key), name) }
  }),
)
