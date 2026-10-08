#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../../meta/dyns.typ": brown
#import "../../meta/notation.typ": *

// Rock-paper-scissors against an opponent who plays Rock, Paper, Scissors in
// rounds 1, 2, 3. Entry a of g^(t) is the payoff of our action a (R, P, S).
#let gs = ((0, 1, -1), (-1, 0, 1), (1, -1, 0))
#let dot3(u, v) = u.zip(v).map(((a, b)) => a * b).sum()

// Each run returns the strategies x^(1), ..., x^(4).
#let run-ftl() = {
  let cum = (0, 0, 0)
  let xs = ()
  for t in range(4) {
    // Highest cumulated utility, ties broken lexicographically.
    let best = range(3).fold(0, (b, a) => if cum.at(a) > cum.at(b) { a } else { b })
    xs.push(range(3).map(a => if a == best { 1 } else { 0 }))
    if t < 3 { cum = cum.zip(gs.at(t)).map(((c, g)) => c + g) }
  }
  xs
}
#let run-rm() = {
  let r = (0, 0, 0)
  let xs = ()
  for t in range(4) {
    let pos = r.map(v => calc.max(v, 0))
    let s = pos.sum()
    let x = if s > 0 { pos.map(p => p / s) } else { (1 / 3, 1 / 3, 1 / 3) }
    xs.push(x)
    if t < 3 {
      let g = gs.at(t)
      let u = dot3(g, x)
      r = r.zip(g).map(((ri, gi)) => ri + gi - u)
    }
  }
  xs
}
#let run-mwu(eta) = {
  let cum = (0, 0, 0)
  let xs = ()
  for t in range(4) {
    // softmax(eta r) = softmax(eta * cumulated utility): the shift cancels.
    let w = cum.map(c => calc.exp(eta * c))
    xs.push(w.map(wi => wi / w.sum()))
    if t < 3 { cum = cum.zip(gs.at(t)).map(((c, g)) => c + g) }
  }
  xs
}

// Barycentric coordinates (R, P, S) -> plane, with Paper on top.
#let side = 2.6
#let corner-r = (0, 0)
#let corner-p = (side / 2, side * calc.sqrt(3) / 2)
#let corner-s = (side, 0)
#let pt(x) = (
  x.at(0) * corner-r.at(0) + x.at(1) * corner-p.at(0) + x.at(2) * corner-s.at(0),
  x.at(0) * corner-r.at(1) + x.at(1) * corner-p.at(1) + x.at(2) * corner-s.at(1),
)

// labels: one (anchor, body) pair per iterate; none hides a repeated point's label.
// offset shifts each arrow to its right, separating a move from its reversal.
#let panel(title, xs, color, labels, offset: .06) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  line(corner-r, corner-p, corner-s, close: true, fill: luma(97%), stroke: .25mm + luma(55%))
  circle(pt((1 / 3, 1 / 3, 1 / 3)), radius: .03, fill: luma(55%), stroke: none)
  content(corner-r, anchor: "north-east", padding: .08)[R]
  content(corner-p, anchor: "south", padding: .08)[P]
  content(corner-s, anchor: "north-west", padding: .08)[S]
  set-style(mark: (end: "stealth", scale: .45, fill: color))
  for t in range(3) {
    let a = pt(xs.at(t))
    let b = pt(xs.at(t + 1))
    let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let len = calc.sqrt(dx * dx + dy * dy)
    if len > 1e-6 {
      // Stop short of both dots so the arrowheads stay visible.
      let gap = .13 / len
      let (nx, ny) = (offset * dy / len, -offset * dx / len)
      line(
        (a.at(0) + gap * dx + nx, a.at(1) + gap * dy + ny),
        (b.at(0) - gap * dx + nx, b.at(1) - gap * dy + ny),
        stroke: .45mm + color,
      )
    }
  }
  set-style(mark: none)
  for t in range(4) {
    circle(pt(xs.at(t)), radius: .065, fill: color, stroke: .2mm + white)
  }
  for (t, lab) in labels.enumerate() {
    if lab != none {
      let (anchor, body) = lab
      content(pt(xs.at(t)), anchor: anchor, padding: .16, body)
    }
  }
  content((side / 2, -.5), strong(title))
})

#let blue = rgb(31, 90, 170)
#let purple = rgb(110, 60, 160)

#align(
  center,
  grid(
    columns: 3,
    column-gutter: 5mm,
    panel(
      [Follow-the-leader],
      run-ftl(),
      brown,
      (
        ("south-east", $vx^((1)), vx^((4))$),
        ("west", $vx^((2)), vx^((3))$),
        none,
        none,
      ),
    ),
    panel(
      [Regret Matching],
      run-rm(),
      blue,
      (
        ("north", $vx^((1)), vx^((4))$),
        ("west", $vx^((2)), vx^((3))$),
        none,
        none,
      ),
    ),
    panel(
      [MWU ($eta = log 2$)],
      run-mwu(calc.ln(2)),
      purple,
      (
        ("north", $vx^((1)), vx^((4))$),
        ("east", $vx^((2))$),
        ("west", $vx^((3))$),
        none,
      ),
      offset: 0,
    ),
  ),
)
