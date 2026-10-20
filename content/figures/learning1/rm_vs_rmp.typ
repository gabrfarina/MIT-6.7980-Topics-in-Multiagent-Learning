#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../../meta/dyns.typ": brown

// Two actions. Up to round T0, the second pays 1 and the first pays 0; then they swap.
#let T0 = 50
#let T = 150
#let utility(t) = if t <= T0 { (0, 1) } else { (1, 0) }

// Runs RM (plus: false) or RM+ (plus: true) for T rounds. Returns (xs, rs), where
// xs.at(t - 1) is the probability of the first action at round t and rs.at(t - 1)
// is its cumulated regret after observing round t.
#let run(plus: false) = {
  let xs = ()
  let rs = ()
  let r = (0, 0)
  for t in range(1, T + 1) {
    let pos = r.map(ri => calc.max(ri, 0))
    let s = pos.sum()
    let x = if s > 0 { pos.map(p => p / s) } else { (0.5, 0.5) }
    let g = utility(t)
    let gx = g.zip(x).map(((gi, xi)) => gi * xi).sum()
    r = r.zip(g).map(((ri, gi)) => ri + gi - gx)
    if plus { r = r.map(ri => calc.max(ri, 0)) }
    xs.push(x.at(0))
    rs.push(r.at(0))
  }
  (xs, rs)
}

#let (x-rm, r-rm) = run()
#let (x-rmp, r-rmp) = run(plus: true)
#let points(ys) = ys.enumerate().map(((i, y)) => (i + 1, y))

#let panel(y-label, y-min, y-max, y-tick-step, legend, rm, rmp) = cetz.canvas({
  import cetz-plot: plot
  plot.plot(
    size: (5, 3),
    x-label: $t$,
    y-label: y-label,
    x-min: 0,
    x-max: T,
    x-tick-step: 50,
    y-min: y-min,
    y-max: y-max,
    y-tick-step: y-tick-step,
    legend: legend,
    {
      plot.add-vline(T0, style: (stroke: (paint: gray, dash: "dashed")))
      plot.add(points(rm), style: (stroke: 0.5mm + blue), label: [RM])
      plot.add(points(rmp), style: (stroke: 0.5mm + brown), label: [RM#super[+]])
    },
  )
})

#align(
  center,
  grid(
    columns: (auto, auto),
    column-gutter: 8mm,
    panel($x^((t))_1$, -0.05, 1.05, 0.25, "inner-north-west", x-rm, x-rmp),
    panel($r^((t))_1$, -T0 - 5, 10, 25, "inner-south-east", r-rm, r-rmp),
  ),
)
