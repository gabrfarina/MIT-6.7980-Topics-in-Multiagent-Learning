#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../libs/sperner.typ": *
#import "../../meta/linalg.typ": transpose
#import "../libs/nash.typ": nash_cmap, softbr

#cetz.canvas(length: .75cm, {
  import cetz.draw: *

  _sperner_grid(
    "rbbbbbbbb",
    "rrbbrrrrb",
    "rrrrbryrb",
    "ryybbrrrb",
    "rybbbrbrb",
    "rrrrrrrbb",
    "rrybryrrb",
    "ryybbyybb",
    "yyyyyyyyb",
  )

  rect(
    (.5 * sperner_w, .5 * sperner_h),
    (7.5 * sperner_w, 7.5 * sperner_h),
    stroke: (thickness: .5mm, paint: black, dash: (2mm, 2mm)),
    radius: 0mm,
    fill: white.transparentize(30%),
  )
})
