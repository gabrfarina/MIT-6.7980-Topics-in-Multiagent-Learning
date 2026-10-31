// Schematic of the nested sets of the realization-form section of L12:
// V ⊂ tilde(X) ⊂ X = conv(V) ⊂ R. Not a projection and not to scale. Six points of V
// stand in for the 12 realization vectors, and four hollow corners stand in for the
// four vertices of R that no team can play. Heads and tails are two points of V, and
// the midpoint of the dashed segment between them is the one-time pad x^(mu*).
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let plan-color = rgb(0, 150, 110)
#let hull-color = rgb(46, 104, 181)
#let uncor-color = rgb(118, 82, 166)
#let relax-color = luma(55%)

// Points of V (cm). Heads is p2 and tails is p4.
#let p0 = (4.2, 0)
#let p1 = (2.2, 2.2)
#let p2 = (-1.8, 2.3)
#let p3 = (-4.2, .2)
#let p4 = (-2, -2.2)
#let p5 = (2.4, -2.1)
// Vertices of R that are not in V.
#let q1 = (3.6, 1.5)
#let q2 = (.2, 2.85)
#let q3 = (.2, -2.8)
#let q4 = (3.7, -1.3)

#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, y: 3mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let mid(a, b) = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
    let lerp(a, b, t) = (a.at(0) + t * (b.at(0) - a.at(0)), a.at(1) + t * (b.at(1) - a.at(1)))
    // Control point for a side of tilde(X) that bows inward from the chord a-b.
    let pull(a, b, t, toward: (0, 0), s: .25) = lerp(lerp(a, b, t), toward, s)

    let halo(pos, body, anchor: "center") = {
      for i in range(36) {
        let x = (calc.rem(i, 6) - 2.5) * .12mm
        let y = (calc.floor(i / 6) - 2.5) * .12mm
        content((rel: (x, y), to: pos), text(white, body), anchor: anchor)
      }
      content(pos, body, anchor: anchor)
    }

    // R, the flow relaxation.
    line(p0, q1, p1, q2, p2, p3, p4, q3, p5, q4, close: true,
      fill: luma(93%), stroke: (paint: relax-color, thickness: .3mm, dash: (1.4mm, .9mm)))

    // cX = conv(V).
    line(p0, p1, p2, p3, p4, p5, close: true,
      fill: hull-color.lighten(85%), stroke: .35mm + hull-color)

    // tilde(cX). Corners at the points of V, sides bowed inward, and a bay on the left
    // whose mouth faces the side p3-p4 and which contains the midpoint of heads-tails.
    let bay = (-1.15, -.05)
    merge-path(close: true, fill: uncor-color.lighten(72%), stroke: .35mm + uncor-color, {
      bezier(p0, p1, pull(p0, p1, .3), pull(p0, p1, .7))
      bezier(p1, p2, pull(p1, p2, .3), pull(p1, p2, .7))
      // Straight here. tilde(cX) contains the segment between two plans that differ
      // in one teammate's plan only, so not every side of cX is cut off.
      line(p2, p3)
      bezier(p3, bay, (-3.0, .95), (-1.15, 1.05))
      bezier(bay, p4, (-1.15, -.9), (-1.55, -1.7))
      bezier(p4, p5, pull(p4, p5, .3), pull(p4, p5, .7))
      bezier(p5, p0, pull(p5, p0, .3), pull(p5, p0, .7))
    })

    // Heads-tails segment and the one-time pad at its midpoint.
    let m = mid(p2, p4)
    line(p2, p4, stroke: (paint: plan-color.darken(10%), thickness: .45mm, dash: (1.6mm, 1mm)))

    // Points of V, then the vertices of R that no team can play.
    for p in (p0, p1, p3, p5) {
      circle(p, radius: .09, fill: black, stroke: none)
    }
    for p in (p2, p4) {
      circle(p, radius: .12, fill: plan-color, stroke: .25mm + plan-color.darken(40%))
    }
    for q in (q1, q2, q3, q4) {
      circle(q, radius: .1, fill: white, stroke: .3mm + black)
    }
    let d = .13
    line((m.at(0), m.at(1) + d), (m.at(0) + d, m.at(1)), (m.at(0), m.at(1) - d),
      (m.at(0) - d, m.at(1)), close: true, fill: black, stroke: none)

    // Labels.
    halo((m.at(0) - .22, m.at(1) - .05), text(13.5pt, $bold(x)^(bold(mu)^star)$), anchor: "east")
    content((p2.at(0) - .12, p2.at(1) + .22), course-sans(11pt, weight: "bold", plan-color.darken(25%), "Heads"), anchor: "south-east")
    content((p4.at(0) - .12, p4.at(1) - .2), course-sans(11pt, weight: "bold", plan-color.darken(25%), "Tails"), anchor: "north-east")
    content((-2.75, -.6), text(14pt, hull-color.darken(20%), $cal(X)$))
    content((1.0, .1), text(14pt, uncor-color.darken(30%), $accent(cal(X), tilde, size: #130%)$))
    content((q1.at(0) + .35, q1.at(1) + .25), text(14pt, $R$), anchor: "south-west")
    // Legend.
    let ly = -3.55
    let lx = -4.3
    circle((lx, ly), radius: .09, fill: black, stroke: none)
    content((lx + .25, ly), text(11pt)[point of $V$ (a joint plan)], anchor: "west")
    circle((lx + 5.1, ly), radius: .1, fill: white, stroke: .3mm + black)
    content((lx + 5.35, ly), text(11pt)[vertex of $R$ outside $cal(X)$], anchor: "west")
  }),
)
