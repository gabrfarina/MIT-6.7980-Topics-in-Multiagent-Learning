#import "@preview/cetz:0.4.1"
#import "../../meta/linalg.typ": add, mvp, transpose, vvp

#let _arrow(from, to, ..kw) = {
  cetz.draw.mark(to, (2 * to.at(0) - from.at(0), 2 * to.at(1) - from.at(1)), ..kw)
}
#let brown = rgb(149, 69, 53)

#let nash_cmap = gradient.conic((yellow, 0%), (blue, 31.25%), (red, 68.75%), (yellow, 100%))

#let softbr = (x, U, opp) => {
  let grad = mvp(U, opp)
  let ut = vvp(grad, x)
  let gain = ()
  for i in range(grad.len()) {
    gain.push(calc.max(0, grad.at(i) - ut))
  }
  let denom = 1.0 + gain.sum()
  let out = add(x, gain)
  for i in range(out.len()) {
    out.at(i) /= denom
  }
  out
}


#let nashf(
  A1,
  A2,
  quiver_scale: .11,
  colors: false,
  highlight: (),
  x_to_strat: x => (1 - x, x),
  y_to_strat: y => (1 - y, y),
  strat_to_x: x => x.at(1),
  strat_to_y: y => y.at(1),
) = {
  import cetz.draw: *

  line((0, 0), (1, 0), (1, 1), (0, 1), close: true, fill: white)

  let A2T = transpose(A2)
  let f = (p, q) => {
    let x = x_to_strat(p)
    let y = y_to_strat(q)
    let o1 = softbr(x, A1, y)
    let o2 = softbr(y, A2T, x)
    (strat_to_x(o1), strat_to_y(o2))
  }

  let N = 12
  let K = 2 * N
  set-style(mark: (end: "stealth", scale: .2, fill: luma(0%)))
  if (colors) {
    for i in range(K) {
      for j in range(K) {
        let p = (i + .5) / K
        let q = (j + .5) / K
        let (pp, qq) = f(p, q)
        let dp = pp - p
        let dq = qq - q
        rect(
          (i / K, j / K),
          ((i + 1) / K + 1e-3, (j + 1) / K + 1e-3),
          fill: rgb(nash_cmap.sample(calc.atan2(dp, dq) - 45deg).transparentize(20%)),
          stroke: none,
        )
      }
    }
  }
  for i in range(N) {
    for j in range(N) {
      let p = (i + .5) / N
      let q = (j + .5) / N
      let (pp, qq) = f(p, q)
      let dp = (pp - p) * quiver_scale
      let dq = (qq - q) * quiver_scale
      let norm = calc.sqrt(dp * dp + dq * dq)
      // Cap length at 1.25 x size of cell
      if (norm > 1.2 / N) {
        dp /= N * norm
        dq /= N * norm
      }
      line((p - dp / 2, q - dq / 2), (p + dp / 2, q + dq / 2), stroke: .15mm + luma(0%))
      // _arrow(
      //   (p + dp / 2, q + dq / 2),
      //   (p - dp / 2, q - dq / 2),
      //   symbol: "stealth",
      //   fill: black,
      // )
    }
  }

  set-style(mark: none)
  for i in range(11) {
    line((i / 10, 0), (i / 10, -.7mm), stroke: .2mm + luma(30%))
    line((0, i / 10), (-.7mm, i / 10), stroke: .2mm + luma(30%))
  }
  content((0, -3mm))[$0$]
  content((-2.5mm, 0))[$0$]
  content((1, -3mm))[$1$]
  content((-2.5mm, 1))[$1$]
  line((0, 0), (1, 0), (1, 1), (0, 1), close: true, stroke: .4mm + black)

  if highlight.len() > 0 {
    for pt in highlight {
      circle(pt, radius: .9mm, fill: black, stroke: .3mm + white)
      // content(pt, box(baseline: -3pt, text(black, size: 15pt, sym.star.filled)))
      // content(pt, box(baseline: -9pt / 5, text(purple, size: 9pt, sym.star.filled)))
    }
  }
}

#let payoff_table(cw: auto, ch: auto, n, m) = table.with(
  columns: (auto,) + (cw,) * (m - 1),
  rows: (ch,) * n,
  align: (j, i) => (
    if j == 0 {
      right
    } else {
      center
    }
      + if i == 0 {
        bottom
      } else {
        horizon
      }
  ),
  inset: (j, i) => (
    x: 1mm,
    y: if i > 0 {
      1.5mm
    } else {
      1mm
    },
  ),
  stroke: (j, i) => if i >= 1 and j >= 1 {
    .2mm
  } else {
    none
  },
  fill: (j, i) => if i >= 1 and j >= 1 {
    white
  } else {
    none
  },
)

#let game_table(
  A,
  B,
  p1_labels,
  p2_labels,
  cw: auto,
  ch: auto,
) = {
  let p1 = blue
  let p2 = brown
  let rows = ()
  for i in range(A.len()) {
    rows.push(text(p1, p1_labels.at(i)))
    for j in range(A.at(i).len()) {
      rows.push([#text(p1)[$#A.at(i).at(j)$], #text(p2)[$#B.at(i).at(j)$]])
    }
  }
  payoff_table(p1_labels.len() + 1, p2_labels.len() + 1, cw: cw, ch: ch)(
    [],
    ..p2_labels.map(label => text(p2, label)),
    ..rows,
  )
}
