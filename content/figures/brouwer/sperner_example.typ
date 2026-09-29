#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"
#import "../libs/sperner.typ": *

#cetz.canvas(length: 6.3mm, {
  import cetz.draw: *
  // _sperner_grid(
  //   "rbbrrrr",
  //   "rooooor",
  //   "yooooor",
  //   "yooooor",
  //   "rooooob",
  //   "rooooor",
  //   "yybbyyb",
  // )
  rect((0, 0), (6 * sperner_w, 6 * sperner_h), stroke: .5mm + black)
  _sperner_grid(
    highlight: false,
    "rbbrrrr",
    "rrrbryr",
    "yybbrrr",
    "ybbbrbr",
    "rrrrrrb",
    "rybryrr",
    "yybbyyb",
  )

  cetz.decorations.flat-brace((-3mm, 0), (-3mm, 6 * sperner_h), pointiness: 0deg, outer-curves: 0.5, debug: false)
  cetz.decorations.flat-brace(
    (0, -2.5mm),
    (6 * sperner_w, -2.5mm),
    flip: true,
    pointiness: 0deg,
    outer-curves: 0.5,
    debug: false,
  )
  cetz.decorations.flat-brace(
    (0, 6.4 * sperner_h),
    (6 * sperner_w, 6.4 * sperner_h),
    flip: false,
    pointiness: 0deg,
    outer-curves: 0.5,
    debug: false,
  )
  cetz.decorations.flat-brace(
    (6.3 * sperner_w, 0),
    (6.3 * sperner_w, 6.0 * sperner_h),
    flip: true,
    pointiness: 0deg,
    outer-curves: 0.5,
    debug: false,
  )


  content((-7mm, 3.1 * sperner_h), anchor: "south", angle: 90deg)[No #strike[#text(blue, weight: "bold")[blue]]]
  content((3 * sperner_w, -6mm), anchor: "north")[No #strike[#text(red, weight: "bold")[red]]]
  // content((6.8 * sperner_w, 3 * sperner_h), anchor: "west")[No yellow]
  content(
    (7 * sperner_w, 7.0 * sperner_h),
    anchor: "south",
  )[No #strike[#text(yellow.darken(10%), weight: "bold")[yellow]]]
  line((sperner_w * 6.8, sperner_h * 3), (sperner_w * 7.6, sperner_h * 7.0), stroke: .25mm + black)
  line((sperner_w * 3, sperner_h * 7), (sperner_w * 5.4, sperner_h * 7.4), stroke: .25mm + black)
})
