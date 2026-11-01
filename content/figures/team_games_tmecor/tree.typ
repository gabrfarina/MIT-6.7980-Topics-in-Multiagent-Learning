// Shared drawing code for the communication-game trees of communication_game.typ
// and one_time_pad.typ. Include-only, so it is listed in SUPPORT_SOURCES.
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let p1-color = rgb(46, 104, 181)
#let p2-color = rgb(118, 82, 166)
#let p3-color = rgb(222, 110, 20)

// Node positions (cm). P2_1, P2_2 share an infoset, as do P2_3, P2_4, and
// likewise for P3. P1's left node is reached on the first chance outcome.
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
// Terminal payoffs (team utility) below the P3 nodes, left then right child.
// Leaves are numbered z_1, ..., z_12 left to right (message, then bit, then P2, then P3),
// matching the realization vectors in the notes.
#let p3-leaves = (
  p3-1: (0, 1),
  p3-2: (1, 0),
  p3-3: (0, 1),
  p3-4: (1, 0),
)
#let p3-labels = (
  p3-1: ($e$, $overline(e)$),
  p3-2: ($e$, $overline(e)$),
  p3-3: ($f$, $overline(f)$),
  p3-4: ($f$, $overline(f)$),
)
// Children whose information set the edge enters from its outer (left) end.
#let left-ends = ("p2-1", "p2-3", "p3-1", "p3-3")

#let add((x, y), (u, v), s: 1) = (x + s * u, y + s * v)
#let unit((x, y), (u, v)) = {
  let n = calc.sqrt((u - x) * (u - x) + (v - y) * (v - y))
  ((u - x) / n, (v - y) / n)
}
#let tri-r = .34 // distance from a triangle's centre to where an edge stops
#let radius(key) = if key == "root" { .27 } else if key.starts-with("z") { .1 } else { tri-r }

#let halo(pos, body, fill: black) = {
  import cetz.draw: content
  for i in range(36) {
    let x = (calc.rem(i, 6) - 2.5) * .12mm
    let y = (calc.floor(i / 6) - 2.5) * .12mm
    content((rel: (x, y), to: pos), text(white, body))
  }
  content(pos, text(fill, body))
}

// Arrow from a to b with a gap for a label at fraction t. band is the rounded band
// around an information set: padx is its horizontal padding, hy its half-height, and
// dy shifts it toward the wide side of the triangles. rb = -1 means: stop at the top
// edge of the child's information set, entering through the side of the band if the
// child is its outer end.
#let edge(
  a, b, ra, rb, band,
  label: none, t: .5, left-end: false,
  paint: black, width: .3mm, dash: none, scale: .8, gap: .17, label-fill: black,
) = {
  import cetz.draw: line
  let u = unit(a, b)
  let start = add(a, u, s: ra)
  let dy = if b.at(1) < -5 { -band.dy } else { band.dy }
  let side = if (left-end and u.at(0) > 0) or (not left-end and u.at(0) < 0) {
    band.padx / calc.abs(u.at(0))
  } else { 99 }
  let rb = if rb < 0 { calc.min((band.hy + dy) / -u.at(1), side) } else { rb }
  let stop = add(b, u, s: -(rb + .02))
  let lw = (paint: paint, thickness: width, dash: dash)
  let arrow = (end: "stealth", scale: scale, fill: paint, stroke: width + paint)
  if label == none {
    line(start, stop, mark: arrow, stroke: lw)
  } else {
    let c = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
    line(start, add(c, u, s: -gap), stroke: lw)
    line(add(c, u, s: gap), stop, mark: arrow, stroke: lw)
    halo(c, text(9pt, label), fill: label-fill)
  }
}

#let infoset(a, b, paint, band) = {
  import cetz.draw: rect
  let dy = if paint == p3-color { -band.dy } else { band.dy }
  rect(
    (a.at(0) - band.padx, a.at(1) + dy - band.hy),
    (b.at(0) + band.padx, b.at(1) + dy + band.hy),
    radius: band.hy,
    fill: paint.lighten(82%),
    stroke: .25mm + paint.lighten(35%),
  )
}

// The four information sets of P2 and P3 (P1's two nodes are singletons).
#let infosets(nodes, band) = {
  infoset(nodes.p2-1, nodes.p2-2, p2-color, band)
  infoset(nodes.p2-3, nodes.p2-4, p2-color, band)
  infoset(nodes.p3-1, nodes.p3-2, p3-color, band)
  infoset(nodes.p3-3, nodes.p3-4, p3-color, band)
}

#let triangle(p, paint, number, up: true) = {
  import cetz.draw: line, content
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

// A leaf with its payoff below it.
#let leaf(p, value) = {
  import cetz.draw: rect
  rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: white, stroke: .22mm)
  halo(add(p, (0, -.3)), text(7pt, $#value$))
}

// The chance node and the player nodes, drawn on top of edges and infosets.
#let decision-nodes(nodes) = {
  import cetz.draw: circle, line
  let p = nodes.root
  circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
  line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
  line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
  for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
  for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p2-color, "2") }
  for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "3", up: false) }
}
