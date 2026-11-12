// Shared drawing of the running example of the team belief DAG section: a team game tree (left) and its
// TB-DAG (right), after the example of Zhang, Farina, Sandholm (ICML 2023). Included by the standalone
// figures in this directory; not rendered on its own.
// The tree uses the glyphs of the other team-game figures (tree.typ): numbered triangles in the team
// colours, a chance node, a shaded band for an information set, small leaves. The TB-DAG uses the glyphs
// of the tree-form decision processes of Lectures 7 and 8: filled squares for decision points, crossed
// squares for observation points, hollow squares where the process ends, solid edges for the team's
// choices and dashed edges for observations.
#import "../team_games_tmecor/tree.typ": p1-color, p2-color, triangle, halo, add
#import "@preview/cetz:0.4.1"

#let panel = rgb(247, 249, 252)
#let plan-color = rgb(0, 150, 110)  // highlighted edges, as in one_time_pad.typ
#let ink = black
#let label-gray = gray.darken(55%)
#let it(name) = eval("$" + name + "$")   // a node name in math italics, as in the notes' text

#let unit((x, y), (u, v)) = {
  let n = calc.sqrt((u - x) * (u - x) + (v - y) * (v - y))
  ((u - x) / n, (v - y) / n)
}

// Arrow from a to b, leaving a at distance ra and stopping at distance rb from b, with an optional label
// at fraction t of the way.
#let arrow(a, b, ra, rb, label: none, t: .5, dashed: false, paint: ink, width: .3mm) = {
  import cetz.draw: line
  let u = unit(a, b)
  let start = add(a, u, s: ra)
  let stop = add(b, u, s: -(rb + .02))
  let st = (paint: paint, thickness: width, dash: if dashed { "dashed" } else { none })
  line(start, stop, stroke: st, mark: (end: "stealth", scale: .7, fill: paint, stroke: width + paint))
  if label != none {
    let c = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
    halo(c, text(8.5pt, label), fill: paint)
  }
}

// ---------------------------------------------------------------- the game tree
#let tree-nodes = (
  root: (2.8, 0),
  A: (1.4, -1.35), B: (4.2, -1.35),
  C: (.45, -3.0), D: (2.15, -3.0), E: (3.45, -3.0), F: (5.15, -3.0),
  G: (.05, -4.55), H: (.85, -4.55), I: (1.75, -4.55), J: (2.55, -4.55),
  K: (3.05, -4.55), L: (3.85, -4.55), M: (4.75, -4.55), N: (5.55, -4.55),
)
#let leaves = ("G", "H", "I", "J", "K", "L", "M", "N")
#let tree-edges = (
  ("A", "C", $ell$), ("A", "E", $r$), ("B", "D", $ell$), ("B", "F", $r$),
  ("C", "G", $ell$), ("C", "H", $r$), ("D", "I", $ell$), ("D", "J", $r$),
  ("E", "K", $ell$), ("E", "L", $r$), ("F", "M", $ell$), ("F", "N", $r$),
)

#let game-tree() = {
  import cetz.draw: rect, circle, line, content
  let P = tree-nodes
  // Member 2 cannot tell C from D: one information set, drawn as a band, as in the other figures.
  let (hy, padx, dy) = (.4, .45, .09)
  rect((P.C.at(0) - padx, P.C.at(1) + dy - hy), (P.D.at(0) + padx, P.D.at(1) + dy + hy),
    radius: hy, fill: p2-color.lighten(82%), stroke: .25mm + p2-color.lighten(35%))
  arrow(P.root, P.A, .27, .36)
  arrow(P.root, P.B, .27, .36)
  for (a, b, lab) in tree-edges {
    let leaf = b in leaves
    arrow(P.at(a), P.at(b), .34, if leaf { .12 } else { .36 }, label: lab, t: if leaf { .5 } else { .42 })
  }
  // the chance node
  let p = P.root
  circle(p, radius: 2.5mm, fill: white, stroke: .25mm)
  line(add(p, (-.177, -.177)), add(p, (.177, .177)), stroke: .25mm)
  line(add(p, (-.177, .177)), add(p, (.177, -.177)), stroke: .25mm)
  for n in ("A", "B") { triangle(P.at(n), p1-color, "1") }
  for n in ("C", "D", "E", "F") { triangle(P.at(n), p2-color, "2") }
  // node names beside the nodes, leaves' names below them
  let name(n, dx, anchor) = content(add(P.at(n), (dx, .02)), text(8.5pt, label-gray, it(n)), anchor: anchor)
  name("A", -.42, "east")
  name("B", .42, "west")
  name("C", -.52, "east")
  name("D", .52, "west")
  name("E", .4, "west")
  name("F", .4, "west")
  for n in leaves {
    rect(add(P.at(n), (-.08, -.08)), add(P.at(n), (.08, .08)), fill: white, stroke: .22mm)
    content(add(P.at(n), (0, -.32)), text(8.5pt, label-gray, it(n)))
  }
}

// ---------------------------------------------------------------- the TB-DAG
#let ox = 7.0
#let at(x, y) = (ox + x, y)
#let dec = (  // decision points: the beliefs
  AB: at(4.5, 0),
  C: at(.45, -2.45), CD: at(2.45, -2.45), D: at(4.4, -2.45), E: at(6.55, -2.45), F: at(8.6, -2.45),
)
#let dec-label = (AB: ${A, B}$, C: ${C}$, CD: ${C, D}$, D: ${D}$, E: ${E}$, F: ${F}$)
#let obs = (  // observation points, named by the nodes where play may be
  CF: at(.95, -1.2), CD: at(2.45, -1.2), DE: at(5.45, -1.2), EF: at(7.6, -1.2),
  G: at(0, -3.65), H: at(.9, -3.65), GI: at(1.95, -3.65), HJ: at(2.95, -3.65),
  I: at(3.95, -3.65), J: at(4.85, -3.65), K: at(6.1, -3.65), L: at(7.0, -3.65),
  M: at(8.15, -3.65), N: at(9.05, -3.65),
)
#let obs-label = (
  CD: $C D$, CF: $C F$, DE: $D E$, EF: $E F$, G: $G$, H: $H$, GI: $G I$, HJ: $H J$,
  I: $I$, J: $J$, K: $K$, L: $L$, M: $M$, N: $N$,
)
#let term = (  // terminal beliefs, where the process ends
  G: at(.55, -4.85), H: at(1.55, -4.85), I: at(2.85, -4.85), J: at(3.85, -4.85),
  K: at(6.1, -4.85), L: at(7.0, -4.85), M: at(8.15, -4.85), N: at(9.05, -4.85),
)
// (decision point, observation point, prescription)
#let choices = (
  ("AB", "CD", $ell ell$), ("AB", "CF", $ell r$), ("AB", "DE", $r ell$), ("AB", "EF", $r r$),
  ("C", "G", $ell$), ("C", "H", $r$), ("CD", "GI", $ell$), ("CD", "HJ", $r$), ("D", "I", $ell$), ("D", "J", $r$),
  ("E", "K", $ell$), ("E", "L", $r$), ("F", "M", $ell$), ("F", "N", $r$),
)
// (observation point, child decision point) and (observation point, terminal belief)
#let splits = (
  ("CD", "CD"), ("CF", "C"), ("CF", "F"), ("DE", "D"), ("DE", "E"), ("EF", "E"), ("EF", "F"),
)
#let ends = (
  ("G", "G"), ("GI", "G"), ("GI", "I"), ("H", "H"), ("HJ", "H"), ("HJ", "J"),
  ("I", "I"), ("J", "J"), ("K", "K"), ("L", "L"), ("M", "M"), ("N", "N"),
)

#let tb-dag(highlight: none) = {
  import cetz.draw: rect, line, content
  let (rd, ro, rt) = (.16, .19, .12)  // where edges stop at decision points, observation points, ends
  for (j, k, lab) in choices {
    let hot = highlight == "prescriptions" and j == "AB"
    arrow(dec.at(j), obs.at(k), rd, ro, label: lab, t: if j == "AB" { .42 } else { .5 },
      paint: if hot { plan-color } else { ink }, width: if hot { .55mm } else { .3mm })
  }
  for (k, j) in splits {
    let hot = highlight == "observations" and k in ("CD", "CF")
    arrow(obs.at(k), dec.at(j), ro, rd, dashed: true,
      paint: if hot { plan-color } else { ink }, width: if hot { .55mm } else { .3mm })
  }
  for (k, z) in ends { arrow(obs.at(k), term.at(z), ro, rt, dashed: true) }
  // decision points: filled squares, labelled by their beliefs
  let d = .11
  for (key, p) in dec {
    let hot = highlight == "prescriptions" and key == "AB"
    rect(add(p, (-d, -d)), add(p, (d, d)), fill: if hot { plan-color } else { ink }, stroke: none)
    let off = if key == "AB" { (.72, .02) } else if key == "F" { (.6, .02) } else if key == "CD" { (-.68, .02) } else { (-.5, .02) }
    halo(add(p, off), text(8.5pt, dec-label.at(key)))
  }
  // observation points: crossed squares, named by the nodes where play may be
  let o = .12
  for (key, p) in obs {
    let hot = highlight == "observations" and key in ("CD", "CF")
    let paint = if hot { plan-color } else { ink }
    rect(add(p, (-o, -o)), add(p, (o, o)), fill: white, stroke: (if hot { .4mm } else { .22mm }) + paint)
    line(add(p, (-o, -o)), add(p, (o, o)), stroke: .22mm + paint)
    line(add(p, (-o, o)), add(p, (o, -o)), stroke: .22mm + paint)
    let off = if key in ("CF", "CD") { (-.45, .02) } else if key in ("DE", "EF") { (.45, .14) } else if key.len() == 2 { (.42, .02) } else { (.3, .02) }
    halo(add(p, off), text(8pt, obs-label.at(key)), fill: label-gray)
  }
  // terminal beliefs: hollow squares
  let t = .08
  for (key, p) in term {
    rect(add(p, (-t, -t)), add(p, (t, t)), fill: white, stroke: .22mm)
    content(add(p, (0, -.32)), text(8.5pt, label-gray, eval("${" + key + "}$")))
  }
}

// The whole figure. highlight: none, "prescriptions" (the edges out of the root belief) or
// "observations" (the public observations after the prescriptions ℓℓ and ℓr).
#let pair(highlight: none) = box(
  fill: panel,
  radius: 2mm,
  inset: (x: 4mm, top: 4mm, bottom: 3mm),
  cetz.canvas(length: 1cm, {
    game-tree()
    tb-dag(highlight: highlight)
  }),
)
