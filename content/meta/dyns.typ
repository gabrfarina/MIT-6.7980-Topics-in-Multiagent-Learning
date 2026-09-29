#import "@preview/cetz:0.4.1"
#import "linalg.typ": mvp, vvp
#let brown = rgb(149, 69, 53)

#let entropy-prox(x0, g, eta) = {
  x0 * calc.exp(eta * g) / (x0 * calc.exp(eta * g) + (1 - x0))
}

#let euc-prox(x0, g, eta) = {
  let k = x0 + (eta * g) * 0.5
  calc.min(1, calc.max(0, k))
}

#let dynplot(
  A1,
  A2,
  prox,
  optimistic: false,
  eta: 0.1,
  quiver_scale: .11,
  highlight: (),
) = {
  import cetz.draw: *

  // Let the containing document show through the plot area.
  line((0, 0), (1, 0), (1, 1), (0, 1), close: true, fill: none)

  let f = (p, q) => (
    prox(p, vvp((-1, 1), mvp(A1, (1 - q, q))), eta),
    prox(q, vvp((1 - p, p), mvp(A2, (-1, 1))), eta),
  )

  let N = 18
  set-style(mark: (end: "stealth", scale: .25, fill: luma(0%)))
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
      line((p - dp / 2, q - dq / 2), (p + dp / 2, q + dq / 2), stroke: .14mm + luma(30%))
    }
  }

  set-style(mark: none)
  for i in range(11) {
    line((i / 10, 0), (i / 10, -.9mm), stroke: .2mm + luma(30%))
    line((0, i / 10), (-.9mm, i / 10), stroke: .2mm + luma(30%))
  }
  content((0, -3mm))[#set text(10pt);$0$]
  content((-2.5mm, 0))[#set text(10pt);$0$]
  content((1, -3mm))[#set text(10pt);$1$]
  content((-2.5mm, 1))[#set text(10pt);$1$]
  line((0, 0), (1, 0), (1, 1), (0, 1), close: true, fill: none, stroke: .4mm + black)

  // Trajectory
  let x = (0.5, 0.5)
  let _x = x // Old x

  // Extrapolated iterate
  let z = x

  // Average
  let ax = x

  let col = if not optimistic {
    brown
  } else {
    red
  }
  let px = x // Previous plotted x
  let pax = x // Previous plotted x
  let dist(a, b) = calc.sqrt(calc.pow(a.at(0) - b.at(0), 2) + calc.pow(a.at(1) - b.at(1), 2))
  for j in range(1, 200) {
    // Here:
    // z = z^t
    // x = x^t has not been computed yet
    if not optimistic {
      x = z
    } else {
      let (p, q) = _x
      x = (
        prox(z.at(0), vvp((-1, 1), mvp(A1, (1 - q, q))), eta),
        prox(z.at(1), vvp((1 - p, p), mvp(A2, (-1, 1))), eta),
      )
    }

    if dist(px, x) > 0.03 {
      line(px, x, stroke: .3mm + col)
      line(pax, ax, stroke: (thickness: .4mm, paint: luma(50%), dash: "dotted"))
      circle(x, radius: .5mm, fill: col, stroke: none)
      px = x
      pax = ax
    }
    _x = x
    {
      let (p, q) = x
      z = (
        prox(z.at(0), vvp((-1, 1), mvp(A1, (1 - q, q))), eta),
        prox(z.at(1), vvp((1 - p, p), mvp(A2, (-1, 1))), eta),
      )
    }
    ax.at(0) = ax.at(0) * (1 - 1 / (j + 1)) + x.at(0) / (j + 1)
    ax.at(1) = ax.at(1) * (1 - 1 / (j + 1)) + x.at(1) / (j + 1)
  }

  circle((.5, .5), radius: .7mm, fill: purple, stroke: none)
  if highlight.len() > 0 {
    for pt in highlight {
      circle(pt, radius: .9mm, fill: black, stroke: .3mm + white)
    }
  }
}
