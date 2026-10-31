// The one-time pad of L12 (slides 6-7). The TMECor of the communication game mixes
// two joint plans with probability 1/2 each. Each panel is the tree of
// communication_game.typ, drawn narrower, with the actions of one joint plan
// highlighted at every team node. Heads is (a, b; c, d) = (1, 0; 1, 0) and tails is
// (0, 1; 0, 1). Leaf names are dropped to save width.
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

// Node positions (cm), those of communication_game.typ with x scaled by sx.
#let sx = .6
#let nodes = (
  root: (5.5, 0),
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
#let nodes = {
  let out = (:)
  for (k, (x, y)) in nodes { out.insert(k, (sx * x, y)) }
  out
}
// Team payoffs below the P3 nodes, left then right child.
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
  ("p1l", "p2-3", $overline(a)$, .24),
  ("p1r", "p2-2", $b$, .24),
  ("p1r", "p2-4", $overline(b)$, .45),
  ("p2-1", "p3-1", $c$, .42),
  ("p2-1", "z2-1", $overline(c)$, .55),
  ("p2-2", "z2-2", $c$, .55),
  ("p2-2", "p3-2", $overline(c)$, .42),
  ("p2-3", "p3-3", $d$, .42),
  ("p2-3", "z2-3", $overline(d)$, .55),
  ("p2-4", "z2-4", $d$, .55),
  ("p2-4", "p3-4", $overline(d)$, .42),
)
// The team's action at each of its six nodes under a joint plan, as (parent, child).
#let heads = (
  ("p1l", "p2-1"), ("p1r", "p2-4"),
  ("p2-1", "p3-1"), ("p2-2", "z2-2"),
  ("p2-3", "z2-3"), ("p2-4", "p3-4"),
)
#let tails = (
  ("p1l", "p2-3"), ("p1r", "p2-2"),
  ("p2-1", "z2-1"), ("p2-2", "p3-2"),
  ("p2-3", "p3-3"), ("p2-4", "z2-4"),
)
// Prescribed actions at Player 2 nodes the plan never reaches. Drawn dashed.
#let off-path = (
  ("p2-2", "z2-2"), ("p2-3", "z2-3"),
  ("p2-1", "z2-1"), ("p2-4", "z2-4"),
)

#let panel(plan) = box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 3mm, top: 3mm, bottom: 2mm),
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
    let band = (padx: .5, hy: .43, dy: .09)
    let radius(key) = if key == "root" { .27 } else if key.starts-with("z") { .1 } else { tri-r }

    let halo(pos, body, fill: black) = {
      for i in range(36) {
        let x = (calc.rem(i, 6) - 2.5) * .12mm
        let y = (calc.floor(i / 6) - 2.5) * .12mm
        content((rel: (x, y), to: pos), text(white, body))
      }
      content(pos, text(fill, body))
    }

    // Arrow from a to b with a gap for a label at fraction t. rb = -1 means: stop at
    // the top edge of the child's information set, entering through the side of the
    // band if the child is its outer end (left-end says which side that is).
    let edge(a, b, ra, rb, label: none, t: .5, hl: false, dashed: false, left-end: false) = {
      let u = unit(a, b)
      let start = add(a, u, s: ra)
      let dy = if b.at(1) < -5 { -band.dy } else { band.dy }
      let side = if (left-end and u.at(0) > 0) or (not left-end and u.at(0) < 0) {
        band.padx / calc.abs(u.at(0))
      } else { 99 }
      let rb = if rb < 0 { calc.min((band.hy + dy) / -u.at(1), side) } else { rb }
      let stop = add(b, u, s: -(rb + .02))
      let paint = if hl { plan-color } else { off-color }
      let width = if hl { .7mm } else { .3mm }
      let lw = (paint: paint, thickness: width, dash: if dashed { (1.2mm, .9mm) } else { none })
      let arrow = (end: "stealth", scale: if hl { .65 } else { .8 }, fill: paint, stroke: width + paint)
      if label == none {
        line(start, stop, mark: arrow, stroke: lw)
      } else {
        let c = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
        let gap = if hl { .2 } else { .17 }
        line(start, add(c, u, s: -gap), stroke: lw)
        line(add(c, u, s: gap), stop, mark: arrow, stroke: lw)
        halo(c, text(9pt, label), fill: if hl { black } else { off-color.darken(30%) })
      }
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

    let leaf(p, value) = {
      rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: white, stroke: .22mm)
      halo(add(p, (0, -.3)), text(7pt, $#value$))
    }

    infoset(nodes.p2-1, nodes.p2-2, p2-color)
    infoset(nodes.p2-3, nodes.p2-4, p2-color)
    infoset(nodes.p3-1, nodes.p3-2, p3-color)
    infoset(nodes.p3-3, nodes.p3-4, p3-color)

    for (parent, child, label, t) in edges {
      let into-band = child.starts-with("p2") or child.starts-with("p3")
      edge(
        nodes.at(parent),
        nodes.at(child),
        radius(parent),
        if into-band { -1 } else { radius(child) },
        label: label,
        t: t,
        hl: (parent, child) in plan,
        dashed: (parent, child) in plan and (parent, child) in off-path,
        left-end: child in ("p2-1", "p2-3"),
      )
    }
    let p3-labels = (
      p3-1: ($e$, $overline(e)$),
      p3-2: ($e$, $overline(e)$),
      p3-3: ($f$, $overline(f)$),
      p3-4: ($f$, $overline(f)$),
    )
    for (key, values) in p3-leaves {
      let p = nodes.at(key)
      for (i, dx) in (-.45, .45).enumerate() {
        let z = add(p, (dx, -1.55))
        edge(p, z, tri-r, .1, label: p3-labels.at(key).at(i), t: .55)
        leaf(z, values.at(i))
      }
    }

    // Nodes on top of edges and infosets.
    let p = nodes.root
    circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
    line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
    line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
    for key in ("p1l", "p1r") { triangle(nodes.at(key), p1-color, "1") }
    for key in ("p2-1", "p2-2", "p2-3", "p2-4") { triangle(nodes.at(key), p2-color, "2") }
    for key in ("p3-1", "p3-2", "p3-3", "p3-4") { triangle(nodes.at(key), p3-color, "3", up: false) }
    for key in ("z2-1", "z2-2", "z2-3", "z2-4") { leaf(nodes.at(key), 0) }
  }),
)

#let plan-label(name, plan) = box(inset: (bottom: .8mm))[#course-sans(weight: "bold", name)#h(.6em)$(a, b; c, d) = #plan$]

#grid(
  columns: 2,
  column-gutter: 5mm,
  row-gutter: 2.5mm,
  align: center,
  panel(heads), panel(tails),
  plan-label("Heads", $(1, 0; 1, 0)$), plan-label("Tails", $(0, 1; 0, 1)$),
)
