#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../libs/sperner.typ": *
#import "../../meta/linalg.typ": transpose
#import "../libs/nash.typ": nash_cmap, softbr


#figure[
  #cetz.canvas(length: .82cm, {
    import cetz.draw: *
    rect(
      (0, 0),
      (rel: (sperner_w * 8, sperner_h * 8)),
      stroke: .6mm + black,
    )
    // line(
    //   (-sperner_w, 0),
    //   (rel: (sperner_w, 0)),
    //   (rel: (0, sperner_h)),
    //   close: true,
    //   stroke: none,
    //   fill: trichromatic_col,
    // )
    // line((-sperner_w, 0), (rel: (sperner_w, 0)), stroke: .25mm + grid_col)
    // line((-sperner_w, 0), (rel: (sperner_w, sperner_h)), stroke: .2mm + grid_col)
    // circle((-sperner_w, 0), radius: sperner_radius, fill: blue, stroke: blue.darken(30%) + .3mm)
    let rows = (
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
    _sperner_grid(bottom_left: purple.lighten(60%), ..rows)
    // rect((0, 0), (8 * sperner_w, 8 * sperner_h), fill: white.transparentize(60%), stroke: none)

    for x in range(8) {
      for y in range(8) {
        if rows.at(7 - y).at(x) == "r" and rows.at(8 - y).at(x + 1) == "y" {
          sperner_path((x, y), "lower", dne)
        } else if rows.at(7 - y).at(x) == "y" and rows.at(8 - y).at(x) == "r" {
          sperner_path((x, y), "lower", dw)
        } else if rows.at(8 - y).at(x) == "y" and rows.at(8 - y).at(x + 1) == "r" {
          sperner_path((x, y), "lower", ds)
        } else {
          sperner_path((x, y), "lower")
        }

        if rows.at(7 - y).at(x) == "r" and rows.at(7 - y).at(x + 1) == "y" {
          sperner_path((x, y), "upper", dn)
        } else if rows.at(7 - y).at(x + 1) == "r" and rows.at(8 - y).at(x + 1) == "y" {
          sperner_path((x, y), "upper", de)
        } else if rows.at(7 - y).at(x) == "y" and rows.at(8 - y).at(x + 1) == "r" {
          sperner_path((x, y), "upper", dsw)
        } else {
          sperner_path((x, y), "upper")
        }
      }
    }
    // sperner_path((0, 0), "lower", dne, dn, dne, de, dne, dn, dne, de)
    // sperner_path((1, 3), "upper", dsw, dw, dn, dne, dn, dne, de, dne, de)
    // sperner_path((5, 5), "upper", dn, dne, de, ds, dsw, dw)
    // sperner_path((4, 1), "lower", dne, dn, dne, de, ds, de)
    // sperner_path((3, 5), "lower")
    // sperner_path((7, 2), "lower")
  })
]
