// Shared drawing of the running example: a team game tree and its TB-DAG.
// Included by the standalone figures in this directory; not rendered on its own.
// Original rendering of the construction in Zhang, Farina, Sandholm (ICML 2023).
#import "@preview/cetz:0.4.1"

#let team-blue = rgb("245c86")
#let team-violet = rgb("6a4a90")
#let annot-violet = rgb("5c3d80")

// A player decision node drawn as an upward-pointing triangle.
#let tri(pos, label, color) = {
  import cetz.draw: line, content
  let (x, y) = pos
  let w = .34
  let h = .5
  line((x - w, y - h / 2), (x + w, y - h / 2), (x, y + h / 2),
    close: true, stroke: none, fill: color, name: "t-" + label)
  content((x, y - .08), text(fill: white, weight: "bold", size: 9pt, label))
}

#let sq(pos, label, color: white, txt: black) = {
  import cetz.draw: rect, content
  let (x, y) = pos
  let w = .30 + .11 * (label.len() - 1)
  rect((x - w, y - .26), (x + w, y + .26),
    stroke: .6pt + luma(30%), fill: color)
  content((x, y), text(fill: txt, weight: if color == white { "regular" } else { "bold" }, size: 9pt, label))
}

#let edge(a, b, paint: .7pt + luma(25%)) = {
  import cetz.draw: line
  line(a, b, stroke: paint, mark: (end: "stealth", scale: .55, fill: luma(25%)))
}

// Left panel: the team game tree.
#let game-tree() = {
  import cetz.draw: line, circle
  let P = (
    root: (2.75, 4.4),
    A: (1.5, 3.2), B: (4.0, 3.2),
    C: (0.5, 1.8), D: (1.9, 1.8), E: (3.3, 1.8), F: (4.7, 1.8),
    G: (0.1, 0.5), H: (0.9, 0.5), I: (1.5, 0.5), J: (2.3, 0.5),
    K: (2.9, 0.5), L: (3.7, 0.5), M: (4.3, 0.5), N: (5.1, 0.5),
  )
  let shrink(a, b, ra, rb) = {
    let (ax, ay) = a
    let (bx, by) = b
    let d = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
    ((ax + (bx - ax) * ra / d, ay + (by - ay) * ra / d),
     (bx - (bx - ax) * rb / d, by - (by - ay) * rb / d))
  }
  for (a, b) in (("root", "A"), ("root", "B")) {
    let (s, e) = shrink(P.at(a), P.at(b), .24, .40)
    edge(s, e)
  }
  for (a, b) in (("A", "C"), ("A", "E"), ("B", "D"), ("B", "F")) {
    let (s, e) = shrink(P.at(a), P.at(b), .30, .40)
    edge(s, e)
  }
  for (a, b) in (("C", "G"), ("C", "H"), ("D", "I"), ("D", "J"),
                 ("E", "K"), ("E", "L"), ("F", "M"), ("F", "N")) {
    let (s, e) = shrink(P.at(a), P.at(b), .30, .34)
    edge(s, e)
  }
  // Infoset of the second team member: C and D are indistinguishable.
  line((P.C.at(0) + .36, P.C.at(1)), (P.D.at(0) - .36, P.D.at(1)),
    stroke: (paint: team-violet, thickness: 1.4pt, dash: "densely-dotted"))
  circle(P.root, radius: .2, stroke: .8pt + luma(25%), fill: white)
  tri(P.A, "A", team-blue)
  tri(P.B, "B", team-blue)
  for n in ("C", "D", "E", "F") { tri(P.at(n), n, team-violet) }
  for n in ("G", "H", "I", "J", "K", "L", "M", "N") { sq(P.at(n), n) }
}

// Right panel: the corresponding team belief DAG.
#let tb-dag() = {
  let B = (  // decision points (beliefs), filled blue
    AB: (10.5, 4.4),
    C: (7.6, 2.2), CD: (9.0, 2.2), D: (10.4, 2.2), E: (11.8, 2.2), F: (13.2, 2.2),
    G: (7.9, 0.0), H: (8.8, 0.0), I: (9.7, 0.0), J: (10.6, 0.0),
  )
  let O = (  // observation points, white
    CD: (8.0, 3.3), CF: (9.7, 3.3), DE: (11.3, 3.3), EF: (13.0, 3.3),
    G: (7.2, 1.1), H: (7.9, 1.1), GI: (8.65, 1.1), HJ: (9.45, 1.1),
    I: (10.15, 1.1), J: (10.8, 1.1), K: (11.5, 1.1), L: (12.15, 1.1),
    M: (12.8, 1.1), N: (13.5, 1.1),
  )
  let shrink(a, b, r) = {
    let (ax, ay) = a
    let (bx, by) = b
    let d = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
    ((ax + (bx - ax) * r / d, ay + (by - ay) * r / d),
     (bx - (bx - ax) * r / d, by - (by - ay) * r / d))
  }
  let dedges = (
    (B.AB, O.CD), (B.AB, O.CF), (B.AB, O.DE), (B.AB, O.EF),
    (O.CD, B.CD),
    (O.CF, B.C), (O.CF, B.F),
    (O.DE, B.D), (O.DE, B.E),
    (O.EF, B.E), (O.EF, B.F),
    (B.C, O.G), (B.C, O.H),
    (B.CD, O.GI), (B.CD, O.HJ),
    (B.D, O.I), (B.D, O.J),
    (B.E, O.K), (B.E, O.L),
    (B.F, O.M), (B.F, O.N),
    (O.G, B.G), (O.GI, B.G), (O.GI, B.I),
    (O.H, B.H), (O.HJ, B.H), (O.HJ, B.J),
    (O.I, B.I), (O.J, B.J),
  )
  for (a, b) in dedges {
    let (s, e) = shrink(a, b, .40)
    edge(s, e)
  }
  for (n, p) in B { sq(p, n, color: team-blue, txt: white) }
  for (n, p) in O { sq(p, n) }
}

#let base-pair() = {
  game-tree()
  tb-dag()
}
