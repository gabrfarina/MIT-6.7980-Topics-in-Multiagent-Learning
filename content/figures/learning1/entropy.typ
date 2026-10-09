#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#let xlogx(x) = if x <= 0 { 0 } else { x * calc.ln(x) }
#let H(x) = x.map(xlogx).sum()
#let edge-color = blue
#let low = rgb(88, 52, 150)
#let high = rgb(226, 216, 242)

// Left panel: two actions, x |-> H(x, 1 - x).
#let two-actions = cetz.canvas({
  import cetz.draw: content
  import cetz-plot: plot
  plot.plot(
    x-label: $x$,
    y-label: none,
    x-grid: true,
    y-grid: true,
    size: (3.3, 2.8),
    axis-style: "school-book",
    x-tick-step: 0.25,
    x-max: 1.04,
    y-tick-step: 0.25,
    y-min: -.89,
    {
      plot.add(
        domain: (1e-4, 1 - 1e-4),
        style: (stroke: 0.65mm + edge-color),
        samples: 200,
        x => xlogx(x) + xlogx(1 - x),
      )
    },
  )
  content((3.0, 0.6), box(fill: none, inset: .5mm, $H(x,1-x)$))
})

// Right panel: three actions. The simplex lies in a horizontal plane at
// height 0 and the surface hangs below it at height H(x) <= 0.
#let side = 3.6
#let zscale = 1.7
#let corners = ((0, 0), (side, 0), (side / 2, side * calc.sqrt(3) / 2))
#let mid = (side / 2, side * calc.sqrt(3) / 6)
#let base(x) = (0, 1).map(i => range(3).map(k => x.at(k) * corners.at(k).at(i)).sum())
// Orthographic camera: rotate the plane by `azimuth`, then tilt it towards the
// viewer by `elevation`. Returns (screen x, screen y, depth towards the viewer).
#let azimuth = -8deg
#let elevation = 42deg
#let project(x) = {
  let (bx, by) = base(x)
  let (px, py) = (bx - mid.at(0), by - mid.at(1))
  let u = px * calc.cos(azimuth) - py * calc.sin(azimuth)
  let d = px * calc.sin(azimuth) + py * calc.cos(azimuth)
  let z = zscale * H(x)
  (u, z * calc.cos(elevation) + d * calc.sin(elevation), z * calc.sin(elevation) - d * calc.cos(elevation))
}
#let plane(x) = {
  let (u, v, s) = project(x)
  (u, v - zscale * H(x) * calc.cos(elevation))
}

#let N = 24
#let pt(i, j) = (i / N, j / N, (N - i - j) / N)
#let triangles = {
  let tris = ()
  for i in range(N) {
    for j in range(N - i) {
      tris.push((pt(i, j), pt(i + 1, j), pt(i, j + 1)))
      if i + j < N - 1 { tris.push((pt(i + 1, j), pt(i + 1, j + 1), pt(i, j + 1))) }
    }
  }
  tris
}

#let three-actions = cetz.canvas({
  import cetz.draw: *
  let hmin = -calc.ln(3)
  // The simplex at height 0, drawn first because it lies above the surface
  // only at the corners, where they meet.
  line(..range(3).map(k => plane(range(3).map(i => if i == k { 1 } else { 0 }))), close: true, fill: luma(96%), stroke: (paint: luma(55%), thickness: .25mm, dash: "dashed"))
  // Painter's algorithm: draw the farthest triangles first.
  let faces = triangles.map(tri => {
    let ps = tri.map(project)
    let depth = ps.map(p => p.at(2)).sum() / 3
    let level = tri.map(H).sum() / 3 / hmin
    // Lambertian shading with a light above the viewer's left shoulder.
    let (a, b, c) = tri.map(x => (..base(x), zscale * H(x)))
    let e1 = range(3).map(i => b.at(i) - a.at(i))
    let e2 = range(3).map(i => c.at(i) - a.at(i))
    let n = (
      e1.at(1) * e2.at(2) - e1.at(2) * e2.at(1),
      e1.at(2) * e2.at(0) - e1.at(0) * e2.at(2),
      e1.at(0) * e2.at(1) - e1.at(1) * e2.at(0),
    )
    let norm = calc.sqrt(n.map(v => v * v).sum())
    let light = (-.35, -.45, .82)
    let lambert = calc.abs(range(3).map(i => n.at(i) * light.at(i)).sum()) / norm
    (depth, ps, level, lambert)
  })
  for (depth, ps, level, lambert) in faces.sorted(key: f => f.at(0)) {
    let fill = color.mix((low, level * 100%), (high, (1 - level) * 100%), space: rgb)
    let fill = rgb(fill.darken((1 - lambert) * 35%))
    line(..ps.map(p => (p.at(0), p.at(1))), close: true, fill: fill, stroke: .1mm + fill)
  }
  // Each edge of the surface is a copy of the two-action curve on the left.
  for k in range(3) {
    let pts = range(41).map(s => {
      let x = (0, 0, 0)
      x.at(k) = s / 40
      x.at(calc.rem(k + 1, 3)) = 1 - s / 40
      let p = project(x)
      (p.at(0), p.at(1))
    })
    line(..pts, stroke: .45mm + edge-color)
  }
  // The minimum, at the uniform strategy.
  let u = (1 / 3, 1 / 3, 1 / 3)
  let bottom = project(u)
  line(plane(u), (bottom.at(0), bottom.at(1)), stroke: (paint: luma(25%), thickness: .25mm, dash: "dotted"))
  circle(plane(u), radius: .04, fill: luma(40%), stroke: none)
  circle((bottom.at(0), bottom.at(1)), radius: .06, fill: white, stroke: .3mm + luma(15%))
  let tag = (side * .62, bottom.at(1) - .62)
  line((bottom.at(0) + .05, bottom.at(1) - .05), (tag.at(0) - .08, tag.at(1)), stroke: .2mm + luma(25%))
  content(tag, anchor: "west", text(fill: luma(15%))[$H(1/3, 1/3, 1/3) = -log 3$])
  let labels = (("north-east", $(1, 0, 0)$), ("north-west", $(0, 1, 0)$), ("south", $(0, 0, 1)$))
  for k in range(3) {
    let x = range(3).map(i => if i == k { 1 } else { 0 })
    let (anchor, body) = labels.at(k)
    content(plane(x), anchor: anchor, padding: .1, body)
  }
  content((plane((0, .5, .5)).at(0) + .35, plane((0, .5, .5)).at(1) + .1), text(fill: luma(45%))[$Delta(A)$])
})

#align(
  center,
  grid(
    columns: 2,
    column-gutter: 9mm,
    align: horizon,
    two-actions, three-actions,
  ),
)
