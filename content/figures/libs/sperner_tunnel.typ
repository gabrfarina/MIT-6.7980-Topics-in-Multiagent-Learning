// Tunnel colorings from the query lower bound for Sperner's lemma
// (content/brouwer.typ, <sec-sperner-query-lower-bound>). The geometry and the
// painting rule mirror makeProofEngine in
// content/interactive/sperner-adversary.html; keep the two in sync.
//
// Points are (x, y) with y pointing up. A coloring of the grid {0, ..., n}^2 is
// a flat array whose entry y * (n + 1) + x is one of tunnel-red, tunnel-yellow,
// or tunnel-blue.

#let tunnel-red = 0
#let tunnel-yellow = 1
#let tunnel-blue = 2

#let tunnel-margin = 2 // blue margin around the bands
#let tunnel-cell = 4 // walls turn only at the centers of these cells
#let tunnel-band = 3 * tunnel-cell // band width w = 12

// Side n of the grid {0, ..., n}^2 with k diagonal squares.
#let tunnel-grid-size(k) = tunnel-band * k + 2 * tunnel-margin
// The wall of a hop runs along the center line c_k = 12 k + 8 of its bands.
#let tunnel-center(k) = tunnel-margin + tunnel-cell * (3 * k + 1) + calc.quo(tunnel-cell, 2)

#let _sgn(v) = if v > 0 { 1 } else if v < 0 { -1 } else { 0 }
#let _cell-point(c) = (
  tunnel-margin + tunnel-cell * c.at(0) + calc.quo(tunnel-cell, 2),
  tunnel-margin + tunnel-cell * c.at(1) + calc.quo(tunnel-cell, 2),
)

// Cells visited by the tunnel door -> chain.at(0) = 0 -> chain.at(1) -> ...,
// before crossings are rewired. A hop u -> v runs sideways along the middle
// cell row of horizontal band u, then up or down along the middle cell column
// of vertical band v.
#let _tunnel-cells(chain) = {
  let cells = ((1, 0), (1, 1))
  for t in range(chain.len() - 1) {
    let (u, v) = (chain.at(t), chain.at(t + 1))
    let row = 3 * u + 1
    let column = 3 * v + 1
    let x = row
    while x != column {
      x += _sgn(column - x)
      cells.push((x, row))
    }
    let y = row
    while y != column {
      y += _sgn(column - y)
      cells.push((column, y))
    }
  }
  cells
}

// Walls of the tunnel coloring: the walk from the door, then any closed loops
// (islands). Each wall is (pts: polyline, closed: bool). Where a sideways leg
// and an up-or-down leg cross, the incoming sideways leg is joined to the
// outgoing up-or-down leg and vice versa, through two corner cells of the
// crossing cell, so the walls never touch and keep their directions.
#let tunnel-walls(chain) = {
  let cells = _tunnel-cells(chain)
  let n = cells.len()
  let succ = range(1, n + 1)
  succ.at(n - 1) = -1
  let seen = (:)
  for i in range(n) {
    let key = str(cells.at(i).at(0)) + "," + str(cells.at(i).at(1))
    if key in seen {
      let j = seen.at(key)
      let (h, v) = if cells.at(j - 1).at(1) == cells.at(j + 1).at(1) { (j, i) } else { (i, j) }
      let (h-in, h-out) = (cells.at(h - 1), cells.at(h + 1))
      let (v-in, v-out) = (cells.at(v - 1), cells.at(v + 1))
      cells.at(h) = (h-in.at(0), v-out.at(1))
      succ.at(h) = v + 1
      cells.at(v) = (h-out.at(0), v-in.at(1))
      succ.at(v) = h + 1
    } else {
      seen.insert(key, i)
    }
  }
  let visited = (false,) * n
  // The door wall enters along row 1 and turns up into diagonal square 0.
  let main = ((0, 1), (tunnel-center(0), 1))
  let i = 0
  while i >= 0 {
    visited.at(i) = true
    main.push(_cell-point(cells.at(i)))
    i = succ.at(i)
  }
  let out = ((pts: main, closed: false),)
  for s in range(n) {
    if not visited.at(s) {
      let loop = ()
      let k = s
      while not visited.at(k) {
        visited.at(k) = true
        loop.push(_cell-point(cells.at(k)))
        k = succ.at(k)
      }
      out.push((pts: loop, closed: true))
    }
  }
  out
}

// Paint walls on {0, ..., n}^2: every wall point is red; the neighbor on the
// right of each step, and the outer corner of each left turn, are yellow;
// every other point is blue. With `boundary: true`, the standard boundary
// coloring is imposed afterwards.
#let tunnel-paint(walls, n, boundary: true) = {
  let side = n + 1
  let at(x, y) = y * side + x
  let col = (tunnel-blue,) * (side * side)
  let on-wall = (false,) * (side * side)
  let right = ()
  for wall in walls {
    let pts = wall.pts
    let m = pts.len()
    let segments = if wall.closed { m } else { m - 1 }
    let segment(s) = {
      let (ax, ay) = pts.at(s)
      let (bx, by) = pts.at(calc.rem(s + 1, m))
      (ax: ax, ay: ay, bx: bx, by: by, dx: _sgn(bx - ax), dy: _sgn(by - ay),
       steps: calc.abs(bx - ax) + calc.abs(by - ay))
    }
    for s in range(segments) {
      let g = segment(s)
      for t in range(g.steps + 1) {
        let (qx, qy) = (g.ax + t * g.dx, g.ay + t * g.dy)
        on-wall.at(at(qx, qy)) = true
        right.push((qx + g.dy, qy - g.dx))
      }
      if wall.closed or s + 1 < segments {
        let next = segment(calc.rem(s + 1, m))
        if next.dx != g.dx or next.dy != g.dy {
          let (px, py) = (g.bx + g.dx - next.dx, g.by + g.dy - next.dy)
          if g.dx * (py - g.by) - g.dy * (px - g.bx) < 0 { right.push((px, py)) }
        }
      }
    }
  }
  for (x, y) in right {
    if x >= 0 and y >= 0 and x <= n and y <= n and not on-wall.at(at(x, y)) {
      col.at(at(x, y)) = tunnel-yellow
    }
  }
  for i in range(side * side) {
    if on-wall.at(i) { col.at(i) = tunnel-red }
  }
  if boundary {
    let standard(x, y) = if x == 0 {
      if y >= 1 { tunnel-red } else { tunnel-yellow }
    } else if y == 0 {
      if x < n { tunnel-yellow } else { tunnel-blue }
    } else { tunnel-blue }
    for a in range(side) {
      for b in (0, n) {
        col.at(at(a, b)) = standard(a, b)
        col.at(at(b, a)) = standard(b, a)
      }
    }
  }
  col
}

// The tunnel coloring of {0, ..., tunnel-grid-size(k)}^2 for a chain of
// diagonal squares starting at 0.
#let tunnel-coloring(chain, k) = tunnel-paint(tunnel-walls(chain), tunnel-grid-size(k))

// Trichromatic triangles when each unit square is cut by its diagonal from
// (x, y) to (x + 1, y + 1), as in the proof and the game.
#let tunnel-trichromatic(col, n) = {
  let side = n + 1
  let c(x, y) = col.at(y * side + x)
  let rainbow(a, b, d) = a != b and b != d and a != d
  let out = ()
  for y in range(n) {
    for x in range(n) {
      let (a, b, e, d) = (c(x, y), c(x + 1, y), c(x + 1, y + 1), c(x, y + 1))
      if rainbow(a, b, e) { out.push(((x, y), (x + 1, y), (x + 1, y + 1))) }
      if rainbow(a, d, e) { out.push(((x, y), (x, y + 1), (x + 1, y + 1))) }
    }
  }
  out
}
