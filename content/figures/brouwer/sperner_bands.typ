#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/sperner.typ": trichromatic_col
#import "../libs/sperner_tunnel.typ": *

// One coloring used by the adversary of the Sperner query lower bound, with
// K = 4 diagonal squares. The tunnel was built as 0 -> 2 -> 1 -> 3. The hop
// 1 -> 3 crosses the hop 0 -> 2 in block (2, 1), where the walls are rewired;
// this splits off an island through squares 1 and 2.
#let K = 4
#let chain = (0, 2, 1, 3)
#let n = tunnel-grid-size(K)
#let col = tunnel-coloring(chain, K)
#let color-at(x, y) = col.at(y * (n + 1) + x)
#let triangles = tunnel-trichromatic(col, n)
#assert.eq(triangles.len(), 1, message: "a tunnel coloring has one trichromatic triangle")

#cetz.canvas(length: 1.6mm, {
  import cetz.draw: *
  let band = (paint: luma(55%), thickness: .2mm, dash: "dashed")
  let first = tunnel-margin
  let last = tunnel-margin + tunnel-band * K

  // Diagonal squares (shaded), under everything else.
  for k in range(K) {
    let a = first + tunnel-band * k
    rect((a, a), (a + tunnel-band, a + tunnel-band), fill: luma(95%), stroke: none)
  }

  // The door cell (as in sperner_paths.typ) and the trichromatic triangle.
  line((0, 0), (1, 0), (0, 1), close: true, fill: purple.lighten(60%), stroke: none)
  let t = triangles.first()
  line(..t, close: true, fill: trichromatic_col, stroke: .25mm + black)
  let centroid = (
    (t.at(0).at(0) + t.at(1).at(0) + t.at(2).at(0)) / 3,
    (t.at(0).at(1) + t.at(1).at(1) + t.at(2).at(1)) / 3,
  )

  // Blue points, small and faint: one dotted line per row keeps the SVG small.
  let dots = (paint: blue.lighten(45%), thickness: .48mm, cap: "round", dash: (array: (0mm, 1.6mm), phase: 0mm))
  for y in range(n + 1) {
    line((0, y), (n, y), stroke: dots)
  }
  // Bands (dashed) and diagonal squares (outlined).
  for k in range(K + 1) {
    let a = first + tunnel-band * k
    line((a, first), (a, last), stroke: band)
    line((first, a), (last, a), stroke: band)
  }
  for k in range(K) {
    let a = first + tunnel-band * k
    rect((a, a), (a + tunnel-band, a + tunnel-band), stroke: .35mm + black)
  }
  // Red and yellow points as in libs/sperner.typ.
  for y in range(n + 1) {
    for x in range(n + 1) {
      let c = color-at(x, y)
      if c != tunnel-blue {
        let p = (red, yellow).at(c)
        circle((x, y), radius: .33, fill: p, stroke: .12mm + p.darken(30%))
      }
    }
  }
  circle(centroid, radius: 1.6, stroke: .35mm + black)
  rect((0, 0), (n, n), stroke: .5mm + black)

  // Labels.
  for k in range(K) {
    let a = first + tunnel-band * k
    content((a + .6, a + tunnel-band - .6), anchor: "north-west", text(8pt)[*#k*])
  }
  content((0, -.9), anchor: "north-west")[door]
  line((centroid.at(0), centroid.at(1) + 1.6), (centroid.at(0), n + 1), stroke: .2mm + black)
  content((centroid.at(0), n + 1.2), anchor: "south")[dead end]
})
