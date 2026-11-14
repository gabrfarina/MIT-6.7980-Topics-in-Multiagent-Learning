// Shared drawing code for the communication-game trees of communication_game.typ
// and one_time_pad.typ. Include-only, so it is listed in SUPPORT_SOURCES.
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let p1-color = rgb(46, 104, 181)
#let p2-color = rgb(118, 82, 166)
#let p3-color = rgb(222, 110, 20)

// All twelve leaves sit in one bottom row, numbered z_1, ..., z_12 left to right
// (message, then bit, then P2, then P3), matching the realization vectors in the notes.
#let leaf-dx = .93
#let leaf-y = -7.7
#let leaf-x(k) = .4 + (k - 1) * leaf-dx
#let mid(i, j) = (leaf-x(i) + leaf-x(j)) / 2

// Node positions (cm), symmetric about the root. P2_1, P2_2 share an infoset (both see
// the left message), as do P2_3, P2_4 (right message), and likewise for P3.
#let nodes = {
  let out = (
    root: (mid(1, 12), -.45),
    p1l: (2.6, -1.5),
    p1r: (2 * mid(1, 12) - 2.6, -1.5),
    p2-1: (1.35, -3.3),
    p2-2: (2 * mid(1, 12) - 7.08, -3.3),
    p2-3: (7.08, -3.3),
    p2-4: (2 * mid(1, 12) - 1.35, -3.3),
    p3-1: (mid(1, 2), -6.15),
    p3-2: (mid(5, 6), -6.15),
    p3-3: (mid(7, 8), -6.15),
    p3-4: (mid(11, 12), -6.15),
  )
  for k in range(1, 13) { out.insert("z" + str(k), (leaf-x(k), leaf-y)) }
  out
}
// A compact layout for one_time_pad.typ: each P3 node sits under its P2 node, and the
// leaves after a wrong guess by Player 2 sit just below that P2 node, so the edges the
// pad never uses stay short.
#let compact-nodes = {
  let out = (
    root: (5.5, -.45),
    p1l: (2.5, -1.5),
    p1r: (8.5, -1.5),
    p2-1: (1, -3.3),
    p2-2: (4, -3.3),
    p2-3: (7, -3.3),
    p2-4: (10, -3.3),
    p3-1: (1, -6.15),
    p3-2: (4, -6.15),
    p3-3: (7, -6.15),
    p3-4: (10, -6.15),
    z3: (1.85, -4.7),
    z4: (3.15, -4.7),
    z9: (7.85, -4.7),
    z10: (9.15, -4.7),
  )
  for (k, p3) in ((1, "p3-1"), (5, "p3-2"), (7, "p3-3"), (11, "p3-4")) {
    let (x, y) = out.at(p3)
    out.insert("z" + str(k), (x - .45, y - 1.55))
    out.insert("z" + str(k + 1), (x + .45, y - 1.55))
  }
  out
}
// Label positions along the edges in the compact layout, by the kind of edge.
#let compact-t(parent, child, t) = {
  if parent.starts-with("p1") and t < .3 { .24 }
  else if parent.starts-with("p2") and child.starts-with("p3") { .42 }
  else if child.starts-with("z") { .55 }
  else { t }
}
// Team payoff at each leaf: 1 iff Player 2 guesses right and Player 3 guesses wrong.
#let payoffs = (0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0)

// (parent, child, label, position of label along the edge)
#let edges = (
  ("root", "p1l", $1\/2$, .5),
  ("root", "p1r", $1\/2$, .5),
  ("p1l", "p2-1", $a$, .45),
  ("p1l", "p2-3", $overline(a)$, .22),
  ("p1r", "p2-2", $b$, .22),
  ("p1r", "p2-4", $overline(b)$, .45),
  ("p2-1", "p3-1", $c$, .45),
  ("p2-1", "z3", $overline(c)$, .3),
  ("p2-2", "z4", $c$, .3),
  ("p2-2", "p3-2", $overline(c)$, .45),
  ("p2-3", "p3-3", $d$, .45),
  ("p2-3", "z9", $overline(d)$, .3),
  ("p2-4", "z10", $d$, .3),
  ("p2-4", "p3-4", $overline(d)$, .45),
  ("p3-1", "z1", $e$, .5),
  ("p3-1", "z2", $overline(e)$, .5),
  ("p3-2", "z5", $e$, .5),
  ("p3-2", "z6", $overline(e)$, .5),
  ("p3-3", "z7", $f$, .5),
  ("p3-3", "z8", $overline(f)$, .5),
  ("p3-4", "z11", $f$, .5),
  ("p3-4", "z12", $overline(f)$, .5),
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
// dy shifts it toward the tips of the triangles, so each triangle sits in its vertical middle. rb = -1 means: stop at the top
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

// Draws every edge of the tree. style(parent, child) returns extra named arguments for
// edge, such as the paint of a highlighted plan. t-of(parent, child, t) can move a label.
#let tree-edges(nodes, band, style: (parent, child) => (:), t-of: (parent, child, t) => t) = {
  for (parent, child, label, t) in edges {
    let into-band = child.starts-with("p2") or child.starts-with("p3")
    edge(
      nodes.at(parent),
      nodes.at(child),
      radius(parent),
      if into-band { -1 } else { radius(child) },
      band,
      label: label,
      t: t-of(parent, child, t),
      left-end: child in left-ends,
      ..style(parent, child),
    )
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

// A label in the middle of a band, on a patch of the band's fill so that it stays
// readable where an edge crosses the band. Drawn after the edges.
#let band-label(a, b, paint, band, body) = {
  import cetz.draw: content
  let dy = if paint == p3-color { -band.dy } else { band.dy }
  let pos = ((a.at(0) + b.at(0)) / 2, a.at(1) + dy)
  content(
    pos,
    text(7.5pt, paint.darken(25%), body),
    frame: "rect",
    fill: paint.lighten(82%),
    stroke: none,
    padding: (x: .06, y: .02),
  )
}

// The four information sets of P2 and P3 (P1's two nodes are singletons). Each joins the
// two nodes reached after the same message, so the player cannot tell the bit.
#let infosets(nodes, band) = {
  infoset(nodes.p2-1, nodes.p2-2, p2-color, band)
  infoset(nodes.p2-3, nodes.p2-4, p2-color, band)
  infoset(nodes.p3-1, nodes.p3-2, p3-color, band)
  infoset(nodes.p3-3, nodes.p3-4, p3-color, band)
}

#let infoset-labels(nodes, band) = {
  band-label(nodes.p2-1, nodes.p2-2, p2-color, band, [sees left])
  band-label(nodes.p2-3, nodes.p2-4, p2-color, band, [sees right])
  band-label(nodes.p3-1, nodes.p3-2, p3-color, band, [sees left])
  band-label(nodes.p3-3, nodes.p3-4, p3-color, band, [sees right])
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

// A leaf with its payoff below it, and optionally its name below that.
#let leaf(p, value, name: none) = {
  import cetz.draw: rect, content
  rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: white, stroke: .22mm)
  halo(add(p, (0, -.3)), text(7pt, $#value$))
  if name != none {
    content(add(p, (0, -.6)), text(7.5pt, gray.darken(70%), $z_#name$))
  }
}

#let leaves(nodes, names: true) = {
  for k in range(1, 13) {
    leaf(nodes.at("z" + str(k)), payoffs.at(k - 1), name: if names { k })
  }
}

// The chance node and the player nodes, drawn on top of edges and infosets. With bits,
// the two Player 1 nodes are labelled by the bit they see.
#let decision-nodes(nodes, bits: true) = {
  import cetz.draw: circle, line, content
  let p = nodes.root
  circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
  line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
  line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
  for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
  for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p2-color, "2") }
  for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "3", up: false) }
  if bits {
    content(add(nodes.p1l, (-.55, 0)), text(8pt, gray.darken(50%), [bit 0]), anchor: "east")
    content(add(nodes.p1r, (.55, 0)), text(8pt, gray.darken(50%), [bit 1]), anchor: "west")
  }
}
