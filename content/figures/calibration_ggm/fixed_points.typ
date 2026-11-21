#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../../meta/notation.typ": *

// Displacement fields phi(x) - x of two deviations on the simplex over
// (rock, paper, scissors), with the fixed point returned by the oracle.
// Drawn with native Typst shapes; coordinates are absolute inside each panel.

#let blue = rgb(31, 90, 170)
#let purple = rgb(110, 60, 160)

// Barycentric coordinates (R, P, S) -> plane, with Paper on top.
#let side = 4.2cm
#let height = side * calc.sqrt(3) / 2
#let corner-r = (0cm, height)
#let corner-p = (side / 2, 0cm)
#let corner-s = (side, height)
#let pt(x) = (
  x.at(0) * corner-r.at(0) + x.at(1) * corner-p.at(0) + x.at(2) * corner-s.at(0),
  x.at(0) * corner-r.at(1) + x.at(1) * corner-p.at(1) + x.at(2) * corner-s.at(1),
)
#let norm-cm(d) = calc.sqrt(calc.pow(d.at(0) / 1cm, 2) + calc.pow(d.at(1) / 1cm, 2))

// One filled polygon per arrow: a thin shaft followed by a triangular head.
#let arrow(a, b, color) = {
  let d = (b.at(0) - a.at(0), b.at(1) - a.at(1))
  let len = norm-cm(d)
  if len < 0.05 { return }
  let (ux, uy) = (d.at(0) / (len * 1cm), d.at(1) / (len * 1cm))
  let head = calc.min(0.1, 0.45 * len) * 1cm
  let (half, shaft) = (0.5 * head, 0.15mm)
  let base = (b.at(0) - ux * head, b.at(1) - uy * head)
  let side-pt(p, w) = (p.at(0) - uy * w, p.at(1) + ux * w)
  place(top + left, polygon(
    fill: color,
    stroke: none,
    side-pt(a, shaft),
    side-pt(base, shaft),
    side-pt(base, half),
    b,
    side-pt(base, -half),
    side-pt(base, -shaft),
    side-pt(a, -shaft),
  ))
}

// `field` maps a strategy to phi(x); arrows are scaled so the longest one
// spans 80% of the grid spacing.
#let panel(field, fixed, fixed-label, label-dx, label-dy) = {
  let n = 7
  let grid-pts = ()
  for i in range(n + 1) {
    for j in range(n + 1 - i) {
      grid-pts.push((i / n, j / n, (n - i - j) / n))
    }
  }
  let disp = grid-pts.map(x => {
    let (a, b) = (pt(x), pt(field(x)))
    (b.at(0) - a.at(0), b.at(1) - a.at(1))
  })
  let longest = calc.max(..disp.map(norm-cm))
  let scale = 0.8 * (side / n / 1cm) / longest
  let star = pt(fixed)
  let body = box(width: side, height: height, {
    place(top + left, polygon(fill: luma(97%), stroke: .25mm + luma(55%), corner-r, corner-p, corner-s))
    for (x, d) in grid-pts.zip(disp) {
      let a = pt(x)
      arrow(a, (a.at(0) + scale * d.at(0), a.at(1) + scale * d.at(1)), blue)
    }
    let r = 0.085cm
    place(top + left, dx: star.at(0) - r, dy: star.at(1) - r, circle(radius: r, fill: purple, stroke: .3mm + white))
    place(top + left, dx: star.at(0) + label-dx, dy: star.at(1) + label-dy, box(
      fill: white.transparentize(15%),
      inset: 1.5pt,
      radius: 1pt,
      text(fill: purple, fixed-label),
    ))
    place(top + left, dx: corner-r.at(0) - 0.32cm, dy: corner-r.at(1) - 0.05cm)[R]
    place(top + left, dx: corner-p.at(0) - 0.07cm, dy: corner-p.at(1) - 0.45cm)[P]
    place(top + left, dx: corner-s.at(0) + 0.12cm, dy: corner-s.at(1) - 0.05cm)[S]
  })
  pad(top: 5mm, bottom: 4mm, x: 4mm, body)
}

#let xhat = (3 / 5, 1 / 5, 1 / 5)
#let constant(x) = xhat
#let swap(x) = (
  0.4 * x.at(0) + 0.1 * x.at(1) + 0.2 * x.at(2),
  0.5 * x.at(0) + 0.8 * x.at(1) + 0.3 * x.at(2),
  0.1 * x.at(0) + 0.1 * x.at(1) + 0.5 * x.at(2),
)

#grid(
  columns: 2,
  column-gutter: 8mm,
  panel(constant, xhat, $hat(vx)$, 0.12cm, -0.42cm),
  panel(swap, (1 / 6, 2 / 3, 1 / 6), $vx^star$, 0.14cm, -0.16cm),
)
