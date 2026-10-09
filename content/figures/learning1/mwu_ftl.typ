#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

// The follow-the-leader counterexample: g(1) = (0, 1/2), then (1, 0) and (0, 1) alternate.
#let T = 10
#let gradient(t) = if t == 1 { (0, 0.5) } else if calc.even(t) { (1, 0) } else { (0, 1) }

// Run T rounds on the counterexample. `choose` maps the regret vector to a strategy.
// Returns the probability of the first action at each round.
#let play(choose) = {
  let r = (0, 0)
  let xs = ()
  for t in range(1, T + 1) {
    let x = choose(r)
    xs.push(x.first())
    let g = gradient(t)
    let u = g.zip(x).map(((gi, xi)) => gi * xi).sum()
    r = r.zip(g).map(((ri, gi)) => ri + gi - u)
  }
  xs
}

#let mwu(eta) = play(r => {
  // shift by the max so exp never overflows; the softmax is unchanged
  let top = calc.max(..r)
  let w = r.map(v => calc.exp(eta * (v - top)))
  w.map(v => v / w.sum())
})

#let ftl() = play(r => if r.first() >= r.last() { (1, 0) } else { (0, 1) })

#let etas = (1, 4, 16)
#let colors = (blue.lighten(60%), blue.lighten(30%), blue)
#let points(ys) = ys.enumerate().map(((i, y)) => (i + 1, y))

// Probability that MWU puts on the action FTL plays at round T.
#let x-ftl = ftl().last()
#let on-leader(eta) = {
  let x = mwu(eta).last()
  if x-ftl == 1 { x } else { 1 - x }
}
#let eta-grid = range(31).map(k => calc.pow(10, k / 10 - 1))

#let iterates = cetz.canvas({
  import cetz-plot: plot
  plot.plot(
    size: (5, 3),
    x-label: $t$,
    y-label: $x^((t))_1$,
    x-min: 0.5,
    x-max: T + 0.5,
    x-tick-step: 1,
    y-min: -0.05,
    y-max: 1.05,
    y-tick-step: 0.25,
    legend: "north",
    legend-style: (orientation: ltr, item: (spacing: 0.3)),
    {
      for (v, color) in etas.zip(colors) {
        plot.add(
          points(mwu(v)),
          style: (stroke: 0.4mm + color),
          mark: "o",
          mark-size: 0.08,
          mark-style: (fill: color, stroke: none),
          label: $eta = #v$,
        )
      }
      plot.add(
        points(ftl()),
        style: (stroke: (paint: black, thickness: 0.4mm, dash: "dashed")),
        label: [FTL],
      )
    },
  )
})

#let concentration = cetz.canvas({
  import cetz-plot: plot
  plot.plot(
    size: (5, 3),
    x-label: $eta$,
    y-label: [mass on FTL's action],
    x-mode: "log",
    x-min: 0.1,
    x-max: 100,
    x-ticks: (0.1, 1, 10, 100),
    x-tick-step: none,
    y-min: 0.45,
    y-max: 1.02,
    y-tick-step: 0.25,
    {
      plot.add-hline(1, style: (stroke: (paint: gray, dash: "dashed")))
      plot.add(eta-grid.map(eta => (eta, on-leader(eta))), style: (stroke: 0.5mm + blue))
    },
  )
})

#align(center, grid(columns: (auto, auto), column-gutter: 8mm, iterates, concentration))
