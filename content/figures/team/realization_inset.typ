// Inset beside the lemma "Utility in realization form" of L12 (slide 8). A fragment of
// the tree of communication_game.typ: bit 0, the left message (a), Player 2 guessing
// 0 (c), and Player 3's two guesses, e to z_1 and 1 - e to z_2. Grey stubs mark the
// branches left out. Below each leaf are the team's weight x^(mu*)[z] = 1/2 (heads plan
// gives ac = 1, tails gives 0), Player 3's weight y[z], and the reach probability
// p_chance(z) x[z] y[z]. Style as in realization_tree.typ. The row labels sit to the
// right so they fill the space under the stubs.
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

// Node positions (cm).
#let nodes = (
  root: (1.75, 0),
  p1: (1.35, -.95),
  p2: (.95, -1.9),
  p3: (.55, -2.9),
  z1: (0, -3.95),
  z2: (1.1, -3.95),
)

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 3mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let add((x, y), (u, v), s: 1) = (x + s * u, y + s * v)
    let unit((x, y), (u, v)) = {
      let n = calc.sqrt((u - x) * (u - x) + (v - y) * (v - y))
      ((u - x) / n, (v - y) / n)
    }
    let tri-r = .34

    let halo(pos, body, fill: black, anchor: "center") = {
      for i in range(36) {
        let x = (calc.rem(i, 6) - 2.5) * .12mm
        let y = (calc.floor(i / 6) - 2.5) * .12mm
        content((rel: (x, y), to: pos), anchor: anchor, text(white, body))
      }
      content(pos, anchor: anchor, text(fill, body))
    }

    // Arrow from a to b, with an optional label at fraction t. style is "team-on",
    // "neutral" or "stub" (a short grey line for a branch that is left out).
    let edge(a, b, ra, rb, style: "neutral", label: none, t: .5) = {
      let u = unit(a, b)
      let start = add(a, u, s: ra)
      let stop = add(b, u, s: -(rb + .02))
      let paint = if style == "team-on" { plan-color } else if style == "stub" { off-color } else { black }
      let width = if style == "team-on" { .7mm } else { .3mm }
      let lw = (paint: paint, thickness: width, dash: if style == "stub" { (1.2mm, .9mm) } else { none })
      let arrow = (end: "stealth", scale: if style == "team-on" { .65 } else { .8 }, fill: paint, stroke: width + paint)
      if label == none {
        line(start, stop, mark: if style == "stub" { none } else { arrow }, stroke: lw)
      } else {
        let c = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
        line(start, add(c, u, s: -.17), stroke: lw)
        line(add(c, u, s: .17), stop, mark: arrow, stroke: lw)
        halo(c, text(9pt, label))
      }
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

    // Stubs for the branches outside the fragment (bit 1, right message, Player 2
    // guessing 1).
    edge(nodes.root, add(nodes.root, (.5, -.7)), .27, 0, style: "stub")
    edge(nodes.p1, add(nodes.p1, (.5, -.7)), tri-r, 0, style: "stub")
    edge(nodes.p2, add(nodes.p2, (.5, -.7)), tri-r, 0, style: "stub")

    edge(nodes.root, nodes.p1, .27, tri-r)
    content((rel: (-.2, .02), to: (1.55, -.47)), anchor: "east", text(9pt, $1\/2$))
    edge(nodes.p1, nodes.p2, tri-r, tri-r, style: "team-on")
    edge(nodes.p2, nodes.p3, tri-r, tri-r, style: "team-on")
    edge(nodes.p3, nodes.z1, tri-r, .1, label: $e$, t: .5)
    edge(nodes.p3, nodes.z2, tri-r, .1, label: $overline(e)$, t: .5)

    // Leaves and the three rows below them.
    let rows = (
      ($p_"chance" (z)$, ($1\/2$, $1\/2$), black),
      ($x^(bold(mu)^star) [z]$, ($1\/2$, $1\/2$), plan-color.darken(35%)),
      ($y[z]$, ($e$, $overline(e)$), p3-color.darken(25%)),
      ($Pr[z "is reached"]$, ($e\/4$, $overline(e)\/4$), black),
    )
    for (key, name) in (("z1", 1), ("z2", 2)) {
      let p = nodes.at(key)
      rect(add(p, (-.08, -.08)), add(p, (.08, .08)), fill: plan-color, stroke: .22mm + plan-color.darken(30%))
      content(add(p, (0, -.36)), text(7.5pt, gray.darken(70%), $bold(z)_#name$))
    }
    let y0 = nodes.z1.at(1) - .85
    let row-y(i) = y0 - .45 * i - if i == 3 { .12 } else { 0 }
    for (i, (label, values, paint)) in rows.enumerate() {
      let y = row-y(i)
      content((nodes.z2.at(0) + .5, y), anchor: "west", text(8pt, paint, label))
      for (j, key) in ("z1", "z2").enumerate() {
        content((nodes.at(key).at(0), y), text(8pt, paint, values.at(j)))
      }
    }
    // Rule above the product row.
    line(
      (nodes.z1.at(0) - .35, row-y(3) + .28),
      (nodes.z2.at(0) + .35, row-y(3) + .28),
      stroke: .2mm + gray,
    )

    // Nodes on top of edges.
    let p = nodes.root
    circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
    line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
    line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
    triangle(nodes.p1, p1-color, "1")
    triangle(nodes.p2, p2-color, "2")
    triangle(nodes.p3, p3-color, "3", up: false)
  }),
)
