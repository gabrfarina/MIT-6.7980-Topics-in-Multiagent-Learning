#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": brown, game_table, nash_cmap, nashf
#import "@preview/cetz:0.4.1"

#let nash_plot(
  A1,
  A2,
  highlight: (),
  title: "",
  x_label: "action B",
  y_label: "action R",
  draft: false,
  p1_labels: ("T", "B"),
  p2_labels: ("L", "R"),
) = {
  set text(8pt)
  box(stroke: none, width: 3.5cm)[
    #cetz.canvas(length: 2.7cm, {
      import cetz.draw: *
      if not draft {
        nashf(A1, A2, colors: true, quiver_scale: .2, highlight: highlight)
      }
      content((.5, -3.4mm))[$PP[#text(blue, x_label)]$]
      content((-2.4mm, .5), angle: 90deg)[$PP[#text(brown, y_label)]$]
      content((.5, 1.09))[#title]
      content((.41, -.62), game_table(A1, A2, p1_labels, p2_labels, cw: 1.1cm))
    })
  ]
}

#pad(x: 0mm, grid(
  columns: 4,
  align: center,
  inset: 0mm,
  stroke: (j, i) => if j > 0 {
    (left: (dash: "dashed", paint: gray, thickness: .2mm))
  } else {
    none
  },
  nash_plot(
    ((-1, 1), (1, -1)),
    ((1, -1), (-1, 1)),
    highlight: ((.5, .5),),
    title: "Penalty shot game",
    // x_label: "kick right",
    // y_label: "dive right",
    // p1_labels: ("kick L", "kick R"),
    // p2_labels: ("dive L", "dive R"),
  ),
  nash_plot(
    ((-1, -3), (0, -2)),
    ((-1, 0), (-3, -2)),
    highlight: ((1, 1),),
    title: "Prisoner's dilemma",
    // x_label: "confess",
    // y_label: "confess",
    // p1_labels: ("deny", "confess"),
    // p2_labels: ("deny", "confess"),
  ),
  nash_plot(
    ((0, 5), (1, 0)),
    ((0, 1), (5, 0)),
    highlight: ((1 / 6, 1 / 6), (1, 0), (0, 1)),
    title: "Theater or football",
    // x_label: "accept",
    // y_label: "accept",
    // p1_labels: ("insist", "accept"),
    // p2_labels: ("insist", "accept"),
  ),
  nash_plot(
    ((0, 2), (-2, 4)),
    ((4, 2), (-2, 0)),
    highlight: ((.5, .5), (0, 0), (1, 1)),
    title: "Hawk-dove game",
    // x_label: "hawk",
    // y_label: "dove",
    // p1_labels: ("dove", "hawk"),
    // p2_labels: ("hawk", "dove"),
  ),
))
