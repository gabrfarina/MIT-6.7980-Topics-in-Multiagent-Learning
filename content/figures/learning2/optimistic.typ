#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 0mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../../meta/dyns.typ": dynplot, entropy-prox, euc-prox
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#show text: emph

#let A = ((2, 1), (0, 2))
#let B = ((-2, -1), (0, -2))
#let NE = (0.5 / (1 + 0.5), (1 + 2 * 0.5) / (2 + 2 * 0.5))

#grid(
  columns: (auto, auto),
  row-gutter: 2mm,
  column-gutter: 1mm,
  cetz.canvas(length: 2.8cm, {
    import cetz.draw: *
    dynplot(A, B, entropy-prox, eta: 0.25, optimistic: false, quiver_scale: 0.8, highlight: (NE,))
    content((.5, 1.085))[#set text(9pt);Non-optimistic MWU]
    content((.5, -5mm))[$x^((t))_2$]
    content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
  }),
  cetz.canvas(length: 2.8cm, {
    import cetz.draw: *

    dynplot(A, B, entropy-prox, optimistic: true, eta: 0.25, quiver_scale: 0.8, highlight: (NE,))
    content((.5, 1.085))[#set text(9pt);#text(blue)[*Optimistic*] MWU]
    content((.5, -5mm))[$x^((t))_2$]
    content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
  }),

  cetz.canvas(length: 2.8cm, {
    import cetz.draw: *
    dynplot(A, B, euc-prox, eta: 0.1, optimistic: false, quiver_scale: 0.8, highlight: (NE,))
    content((.5, 1.085))[#set text(9pt);Non-optimistic OGD]
    content((.5, -5mm))[$x^((t))_2$]
    content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
  }),
  cetz.canvas(length: 2.8cm, {
    import cetz.draw: *

    dynplot(A, B, euc-prox, optimistic: true, eta: 0.1, quiver_scale: 0.8, highlight: (NE,))
    content((.5, 1.085))[#set text(9pt);#text(blue)[*Optimistic*] OGD]
    content((.5, -5mm))[$x^((t))_2$]
    content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
  }),
)
