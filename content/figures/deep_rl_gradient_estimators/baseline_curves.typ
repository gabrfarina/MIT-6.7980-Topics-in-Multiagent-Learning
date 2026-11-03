#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

// REINFORCE in matching pennies, as in the lecture notes: the learner wins
// (+1) when the coins match and loses (-1) otherwise, the opponent plays heads
// with probability 0.35, and a constant 10 is added to every payoff. Each run
// starts from uniform logits and takes one sample per step. The simulation is
// deterministic: it uses a linear congruential generator.
#let offset = 10.0
#let y-heads = 0.35
#let eta = 0.1
#let alpha = 0.1 // step size of the learned baseline (critic)
#let steps = 400
#let seeds = range(1, 21)

#let softmax(l) = {
  let m = calc.max(..l)
  let e = l.map(x => calc.exp(x - m))
  let z = e.sum()
  e.map(x => x / z)
}

#let lcg(state) = calc.rem(1103515245 * state + 12345, 2147483648)

// Returns the probability of tails after each step.
#let run(seed, use-baseline) = {
  let state = seed * 7919 + 17
  let l = (0.0, 0.0)
  let b = 0.0
  let out = ((0, 0.5),)
  for t in range(1, steps + 1) {
    let pi = softmax(l)
    state = lcg(state)
    let a = if state / 2147483648 < pi.at(0) { 0 } else { 1 }
    state = lcg(state)
    let o = if state / 2147483648 < y-heads { 0 } else { 1 }
    let u = offset + if a == o { 1 } else { -1 }
    let w = if use-baseline { u - b } else { u }
    l = range(2).map(i => l.at(i) + eta * w * ((if i == a { 1 } else { 0 }) - pi.at(i)))
    if use-baseline { b += alpha * (u - b) }
    out.push((t, softmax(l).at(1)))
  }
  out
}

// Exact gradient ascent on the logits, for reference.
#let exact = {
  let q = (offset + 2 * y-heads - 1, offset + 1 - 2 * y-heads)
  let l = (0.0, 0.0)
  let out = ((0, 0.5),)
  for t in range(1, steps + 1) {
    let pi = softmax(l)
    let v = range(2).map(i => pi.at(i) * q.at(i)).sum()
    l = range(2).map(i => l.at(i) + eta * pi.at(i) * (q.at(i) - v))
    out.push((t, softmax(l).at(1)))
  }
  out
}

#let accent = rgb("#325d8a")

#let panel(use-baseline, title) = cetz.canvas({
  import cetz.draw: content
  import cetz-plot: plot
  plot.plot(
    size: (5.2, 3.2),
    x-label: [step],
    y-label: [$pi(sans("T"))$],
    x-tick-step: 100,
    y-tick-step: 0.25,
    y-min: 0,
    y-max: 1,
    x-min: 0,
    x-max: steps,
    x-grid: true,
    y-grid: true,
    {
      let runs = seeds.map(s => run(s, use-baseline))
      for r in runs {
        plot.add(r, style: (stroke: 0.4pt + luma(60%).transparentize(35%)))
      }
      plot.add(exact, style: (stroke: (paint: black, thickness: 1pt, dash: "dashed")))
    },
  )
  content((2.6, 3.65), title)
  let runs = seeds.map(s => run(s, use-baseline))
  let wrong = runs.filter(r => r.last().at(1) < 0.1).len()
  content((5.1, 0.25), anchor: "south-east",
    box(fill: white, inset: 1mm, text(fill: accent)[#wrong of #seeds.len() runs end below $0.1$]))
})

#grid(
  columns: 2,
  column-gutter: 6mm,
  panel(false, [*REINFORCE*, payoffs shifted by $10$]),
  panel(true, [*With a learned baseline* $b$]),
)
