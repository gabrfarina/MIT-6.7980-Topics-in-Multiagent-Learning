#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// The setting of the Sperner query lower bound, for m = 3 (N = 7): the grid,
// its triangulation (diagonals from (i, j) to (i + 1, j + 1)), the standard
// boundary with the door, and one call to the Sperner circuit. Interior points
// are unknown until they are queried.
#let m = 3
#let n = calc.pow(2, m) - 1
#let call = (5, 3) // the queried point, (101, 011) in binary
#let call-color = blue

#let boundary(i, j) = if i == 0 {
  if j >= 1 { red } else { yellow }
} else if j == 0 {
  if i < n { yellow } else { blue }
} else if i == n or j == n { blue } else { none }
#let bits(k) = {
  let s = ""
  for b in range(m) { s = str(calc.rem(calc.quo(k, calc.pow(2, b)), 2)) + s }
  s
}

#cetz.canvas(length: 7mm, {
  import cetz.draw: *
  let grid-stroke = .2mm + luma(60%)

  // Triangulation.
  for k in range(n + 1) {
    line((k, 0), (k, n), stroke: grid-stroke)
    line((0, k), (n, k), stroke: grid-stroke)
  }
  for i in range(n) {
    for j in range(n) {
      line((i, j), (i + 1, j + 1), stroke: .15mm + luma(70%))
    }
  }

  // The door: the red-yellow boundary edge from (0, 0) to (0, 1).
  line((0, 0), (0, 1), stroke: 1.2mm + purple.lighten(40%))
  content((.18, .62), anchor: "west", text(7.5pt)[door])

  // The call's arrow runs under the points it passes.
  let (ci, cj) = call
  let box-left = n + 1.3
  line((ci + .35, cj), (box-left, cj), stroke: .3mm + black, mark: (end: ">", fill: black, scale: .6))

  // Points: boundary colors are known; interior points are unknown (hollow).
  for i in range(n + 1) {
    for j in range(n + 1) {
      let c = boundary(i, j)
      if (i, j) == call { c = call-color }
      if c == none {
        circle((i, j), radius: .13, fill: white, stroke: .25mm + luma(55%))
      } else {
        circle((i, j), radius: .17, fill: c, stroke: .25mm + c.darken(30%))
      }
    }
  }

  // Coordinates as m-bit numbers.
  for k in range(n + 1) {
    content((k, -.45), anchor: "north", text(7pt, raw(bits(k))))
    content((-.45, k), anchor: "east", text(7pt, raw(bits(k))))
  }
  content((n / 2, -1.25), anchor: "north")[$i$]
  content((-1.55, n / 2), anchor: "east")[$j$]

  // One call: the circuit returns the color of the queried point.
  circle(call, radius: .32, stroke: .35mm + black)
  rect((box-left, cj - .55), (box-left + 3.6, cj + .55), radius: .15, stroke: .3mm + black, fill: white)
  content((box-left + 1.8, cj), align(center, text(8pt)[Sperner circuit]))
  content((box-left + 1.8, cj + .75), anchor: "south", text(7.5pt)[call: #raw("(" + bits(ci) + ", " + bits(cj) + ")")])
  line((box-left + 1.8, cj - .55), (box-left + 1.8, cj - 1.45), stroke: .3mm + black, mark: (end: ">", fill: black, scale: .6))
  circle((box-left + 1.8, cj - 1.75), radius: .17, fill: call-color, stroke: .25mm + call-color.darken(30%))
  content((box-left + 2.1, cj - 1.75), anchor: "west", text(7.5pt)[answer: blue])
})
