#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../libs/sperner.typ": *
#import "../../meta/linalg.typ": transpose
#import "../libs/nash.typ": nash_cmap, softbr

#show text: emph



#let triangulation(title, show_sperner, A1, A2, highlight: ()) = box(cetz.canvas(length: .5cm, {
  import cetz.draw: *
  // let A1 = ((0, 5), (1, 0))
  // let A2 = ((0, 1), (5, 0))

  let quiver_scale = .5
  let sperner_N = 8

  let A2T = transpose(A2)
  let f = (p, q) => {
    let x = (1 - p, p)
    let y = (1 - q, q)
    let o1 = softbr(x, A1, y)
    let o2 = softbr(y, A2T, x)
    (o1.at(1), o2.at(1))
  }

  let N = 16 // !!
  let K = 3 * N
  let W = sperner_N * sperner_w
  let H = sperner_N * sperner_h
  line((0, 0), (W, 0), (W, H), (0, H), stroke: .5mm, close: true)
  set-style(mark: (end: "stealth", scale: .25, fill: luma(0%)))
  if true or not show_sperner {
    for i in range(K) {
      for j in range(K) {
        let p = (i + .5) / K
        let q = (j + .5) / K
        let (pp, qq) = f(p, q)
        let dp = pp - p
        let dq = qq - q
        rect(
          (i / K * W, j / K * H),
          ((i + 1) / K * W + 1e-3, (j + 1) / K * H + 1e-3),
          fill: rgb(nash_cmap
            .sample(calc.atan2(dp, dq) - 45deg)
            .transparentize(if show_sperner {
              70%
            } else {
              15%
            })),
          stroke: none,
        )
      }
    }
  }
  if not show_sperner {
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
        line(((p - dp / 2) * W, (q - dq / 2) * H), ((p + dp / 2) * W, (q + dq / 2) * H), stroke: .2mm + luma(10%))
      }
    }

    for pt in highlight {
      circle((pt.at(0) * W, pt.at(1) * H), radius: 1.1mm, fill: black, stroke: .4mm + white)
    }
  }
  set-style(mark: (end: none))

  if show_sperner {
    let rows = ()
    for i in range(sperner_N + 1) {
      rows.push("")
      for j in range(sperner_N + 1) {
        let p = j / sperner_N
        let q = (sperner_N - i) / sperner_N
        let (pp, qq) = f(p, q)
        let (dp, dq) = (pp - p, qq - q)

        let ch = if dp >= 0 and dq >= 0 {
          "y"
        } else if dp >= dq {
          "r"
        } else {
          "b"
        }
        if j == sperner_N and ch == "y" {
          ch = "b"
        } else if i == 0 and ch == "y" {
          ch = "r"
        } else if j == 0 and ch == "b" {
          ch = "y"
        } else if i == sperner_N and ch == "r" {
          ch = "y"
        }
        rows.at(-1) += ch
      }
    }

    _sperner_grid(
      bg: none,
      highlight: true,
      radius: 0.9mm,
      ..rows,
    )
  }

  if title != "" {
    content((W / 2, H * 1.1), title)
  }
}))

#let tof_A1 = ((0, 5), (1, 0))
#let tof_A2 = ((0, 1), (5, 0))
#let psg_A1 = ((-1, 1), (1, -1))
#let psg_A2 = ((1, -1), (-1, 1))
#let pdi_A1 = ((-1, -3), (0, -2))
#let pdi_A2 = ((-1, 0), (-3, -2))


#grid(columns: 4, column-gutter: 2mm, row-gutter: 2mm, align: top + center)[#v(4mm)#rotate(
    -90deg,
    reflow: true,
  )[Nash improvement\ function (Brouwer)]][
  #triangulation("Theater or football", false, tof_A1, tof_A2, highlight: ((1, 0), (0, 1), (1 / 6, 1 / 6)))
][
  #pad(left: 1mm, triangulation("Prisoner's dilemma", false, pdi_A1, pdi_A2, highlight: ((1, 1),)))
][
  #triangulation("Penalty shot game", false, psg_A1, psg_A2, highlight: ((.5, .5),))
][][#rotate(90deg, reflow: true, $->$)][#rotate(90deg, reflow: true, $->$)][#rotate(
  90deg,
  reflow: true,
  $->$,
)][
  #v(-1mm)#rotate(-90deg, reflow: true)[Sperner discretization]
][
  #triangulation("", true, tof_A1, tof_A2)
][
  #triangulation("", true, pdi_A1, pdi_A2)
][
  #triangulation("", true, psg_A1, psg_A2)
]
