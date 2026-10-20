#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Where the samples go in a depth-4 binary tree of the learner's own decisions.
// Edge width and leaf shading are proportional to the probability with which
// the sampling distribution traverses them; `p` is the probability of "left".
#let depth = 4
#let dx = 0.27
#let dy = 0.62

#let reach(k, idx, p) = {
  let r = 1.0
  for level in range(k) {
    let bit = calc.rem(calc.quo(idx, calc.pow(2, k - 1 - level)), 2)
    r *= if bit == 0 { p } else { 1 - p }
  }
  r
}

#let pos(k, idx) = ((idx + 0.5) * calc.pow(2, depth - k) * dx, -k * dy)

#let sampling-tree(p, caption) = cetz.canvas({
  import cetz.draw: *
  for k in range(1, depth + 1) {
    for idx in range(calc.pow(2, k)) {
      let r = reach(k, idx, p)
      line(pos(k - 1, calc.quo(idx, 2)), pos(k, idx),
        stroke: (paint: rgb("#325d8a"), thickness: 0.25pt + 3.2pt * r, cap: "round"))
    }
  }
  for idx in range(calc.pow(2, depth)) {
    let r = reach(depth, idx, p)
    circle(pos(depth, idx), radius: 0.085,
      fill: rgb("#325d8a").transparentize(100% - calc.min(100%, r * 190%)),
      stroke: 0.4pt + rgb("#325d8a"))
  }
  circle(pos(0, 0), radius: 0.07, fill: black, stroke: none)
  content((pos(0, 0).at(0), 0.42), caption)
})

#grid(
  columns: 2,
  column-gutter: 8mm,
  sampling-tree(0.5, [*Uniform exploration*: each leaf gets $1\/16$]),
  sampling-tree(0.85, [*On policy*: the policy path gets $0.85^4 approx 52%$]),
)
