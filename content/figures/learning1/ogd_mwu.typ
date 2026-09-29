#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 0mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../../meta/dyns.typ": dynplot, entropy-prox, euc-prox
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#let A = ((2, 1), (0, 2))
#let B = ((-2, -1), (0, -2))
#let NE = (0.5 / (1 + 0.5), (1 + 2 * 0.5) / (2 + 2 * 0.5))

#show text: emph

#align(
  center,
  grid(
    columns: (auto, auto),
    column-gutter: 6mm,
    cetz.canvas(
      length: 3.5cm,
      {
        import cetz.draw: *
        dynplot(A, B, euc-prox, eta: 0.1, quiver_scale: 0.6, highlight: (NE,))
        content((.5, 1.1))[OGD ($eta=0.1$)]
        content((.5, -5mm))[$x^((t))_2$]
        content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
      },
    ),
    cetz.canvas(
      length: 3.5cm,
      {
        import cetz.draw: *

        dynplot(A, B, entropy-prox, eta: 0.25, quiver_scale: 0.6, highlight: (NE,))
        content((.5, 1.1))[MWU ($eta=0.25$)]
        content((.5, -5mm))[$x^((t))_2$]
        content((-5mm, .5), angle: 90deg)[$y^((t))_2$]
      },
    ),
  ),
)
