#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
// _sperner_grid is drawn with the cetz version that libs/sperner.typ imports.
#import "../libs/sperner.typ": cetz, _sperner_grid, sperner_w, sperner_h
#import "../libs/sperner_tunnel.typ": *

// Close-ups of the walls of a tunnel coloring, for the proof that its only
// trichromatic triangles sit at the dead end. Each wall is walked in the
// direction of the arrow: red on the wall, yellow on its right, including the
// outer corner of a left turn. Panel (e) is the rewired crossing in block
// (2, 1) of sperner_bands.typ.

#let panel(label, rows, walls: (), length: 5.2mm, radius: 1.2mm) = {
  let canvas = cetz.canvas(length: length, {
    import cetz.draw: *
    _sperner_grid(radius: radius, ..rows)
    set-style(mark: (end: ">", fill: black, scale: .6))
    for wall in walls {
      line(..wall.map(((x, y)) => (x * sperner_w, y * sperner_h)), stroke: .45mm + black)
    }
  })
  box(align(center, stack(dir: ttb, spacing: 2mm, canvas, label)))
}

// A wall on a small window, painted without the Sperner boundary.
#let piece(label, wall, n) = {
  let col = tunnel-paint(((pts: wall, closed: false),), n, boundary: false)
  panel(label, tunnel-rows(col, n, 0, 0, n, n), walls: (wall,))
}

// The pieces of the walls of `walls` inside the window [x0, x1] x [y0, y1],
// in window coordinates.
#let clip-walls(walls, x0, y0, x1, y1) = {
  let runs = ()
  for wall in walls {
    let pts = if wall.closed { wall.pts + (wall.pts.first(),) } else { wall.pts }
    let run = ()
    for s in range(pts.len() - 1) {
      let ((ax, ay), (bx, by)) = (pts.at(s), pts.at(s + 1))
      let steps = calc.abs(bx - ax) + calc.abs(by - ay)
      for t in range(if s == 0 { 0 } else { 1 }, steps + 1) {
        let (x, y) = (ax + t * (bx - ax) / steps, ay + t * (by - ay) / steps)
        if x0 <= x and x <= x1 and y0 <= y and y <= y1 {
          run.push((x - x0, y - y0))
        } else if run.len() > 1 {
          runs.push(run)
          run = ()
        } else {
          run = ()
        }
      }
    }
    if run.len() > 1 { runs.push(run) }
  }
  runs
}

#let crossing = {
  let chain = (0, 2, 1, 3)
  let n = tunnel-grid-size(4)
  let (x0, y0) = (tunnel-margin + 2 * tunnel-band, tunnel-margin + tunnel-band)
  let (x1, y1) = (x0 + tunnel-band - 1, y0 + tunnel-band - 1)
  panel(
    [(e) rewired crossing],
    tunnel-rows(tunnel-coloring(chain, 4), n, x0, y0, x1, y1),
    walls: clip-walls(tunnel-walls(chain), x0, y0, x1, y1),
    length: 4mm,
    radius: .9mm,
  )
}

#grid(
  columns: 4,
  column-gutter: 5mm,
  align: bottom,
  piece([(a) straight], ((0, 2), (4, 2)), 4),
  piece([(b) left turn], ((0, 1), (2, 1), (2, 4)), 4),
  piece([(c) right turn], ((0, 3), (2, 3), (2, 0)), 4),
  piece([(d) dead end], ((2, 0), (2, 2)), 4),
)
#v(4mm)
#align(center, crossing)
