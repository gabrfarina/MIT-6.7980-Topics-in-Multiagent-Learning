// Convexity is more than Brouwer needs. A dented blob is not convex, yet it is
// a deformed disk and the theorem still applies; an annulus has a hole, and a
// rotation of it has no fixed point.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/fixedpoint.typ": curve

#let shape-stroke = .5mm + luma(25%)

#let panel(caption, body) = block[
  #cetz.canvas(body)
  #v(1.2mm)
  #align(center, text(size: 8.5pt, caption))
]

#stack(
  dir: ltr,
  spacing: 7mm,

  // A dented blob: the chord leaves the set, so it is not convex; but there is
  // no hole, so it is still a deformed disk.
  panel([not convex, but no hole], {
    import cetz.draw: *
    catmull(
      (-1.0, 0.0), (-0.72, 0.76), (0.0, 1.0), (0.62, 0.70),
      (0.34, 0.14), (0.62, -0.52), (0.0, -0.96), (-0.72, -0.76),
      close: true,
      stroke: shape-stroke,
    )
    line((0.62, 0.70), (0.62, -0.52), stroke: (thickness: .3mm, paint: curve, dash: "dashed"))
    circle((0.62, 0.70), radius: .06, fill: curve, stroke: none)
    circle((0.62, -0.52), radius: .06, fill: curve, stroke: none)
  }),

  // An annulus: the hole lets a rotation slide every point around it.
  panel([a hole: rotation escapes], {
    import cetz.draw: *
    circle((0, 0), radius: 1, stroke: shape-stroke)
    circle((0, 0), radius: 0.4, stroke: shape-stroke)
    for i in range(6) {
      let a = i * 60deg + 12deg
      arc(
        (a, 0.7),
        start: a,
        stop: a + 34deg,
        radius: 0.7,
        stroke: .34mm + curve,
        mark: (end: "straight", scale: .45, fill: curve),
      )
    }
  }),
)
