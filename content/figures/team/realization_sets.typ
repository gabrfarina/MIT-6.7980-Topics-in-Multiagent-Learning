// Schematic of the nested sets of the realization-form section of L12:
// V ⊂ tilde(X) ⊂ X = conv(V) ⊂ R. Not a projection and not to scale. Six points of V
// stand in for the 12 realization vectors, and four hollow corners stand in for the
// four vertices of R that no team can play. Heads and tails span an edge of X (checked
// by LP), and the midpoint of that edge is the one-time pad x^(mu*).
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

// Points of V (cm). Heads and tails span the left edge of cX, and the two plans under
// which Player 2 is always wrong span the right edge. Both edges are real edges of cX.
#let ph = (-3.6, 1.5)
#let pt = (-3.6, -1.5)
#let pw1 = (3.6, 1.5)
#let pw2 = (3.6, -1.5)
#let ptop = (0, 2.7)
#let pbot = (0, -2.7)
// Vertices of R that are not in V, in two mirrored pairs beyond those edges.
#let q1 = (-4.65, .75)
#let q2 = (-4.65, -.75)
#let q3 = (4.65, -.75)
#let q4 = (4.65, .75)

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
    line(ph, q1, q2, pt, pbot, pw2, q3, q4, pw1, ptop, close: true,
      fill: luma(93%), stroke: (paint: relax-color, thickness: .3mm, dash: (1.4mm, .9mm)))

    // cX = conv(V).
    line(ph, ptop, pw1, pw2, pbot, pt, close: true,
      fill: hull-color.lighten(85%), stroke: .35mm + hull-color)

    // tilde(cX). Corners at the points of V. It bows inward from the heads-tails edge and
    // from the opposite edge, whose midpoints are not uncorrelated. The two left sides are
    // straight, since a segment between plans that differ in one teammate's plan only lies
    // in tilde(cX).
    merge-path(close: true, fill: uncor-color.lighten(72%), stroke: .35mm + uncor-color, {
      line(ph, ptop)
      bezier(ptop, pw1, pull(ptop, pw1, .3, s: .12), pull(ptop, pw1, .7, s: .12))
      bezier(pw1, pw2, (1.9, .9), (1.9, -.9))
      bezier(pw2, pbot, pull(pw2, pbot, .3, s: .12), pull(pw2, pbot, .7, s: .12))
      line(pbot, pt)
      bezier(pt, ph, (-1.9, -.9), (-1.9, .9))
    })

    // The one-time pad at the midpoint of the heads-tails edge.
    let m = mid(ph, pt)
    line(ph, pt, stroke: (paint: plan-color.darken(10%), thickness: .45mm, dash: (1.6mm, 1mm)))

    // Points of V, then the vertices of R that no team can play.
    for p in (ptop, pbot, pw1, pw2) {
      circle(p, radius: .09, fill: black, stroke: none)
    }
    for p in (ph, pt) {
      circle(p, radius: .12, fill: plan-color, stroke: .25mm + plan-color.darken(40%))
    }
    for q in (q1, q2, q3, q4) {
      circle(q, radius: .1, fill: white, stroke: .3mm + black)
    }
    let d = .13
    line((m.at(0), m.at(1) + d), (m.at(0) + d, m.at(1)), (m.at(0), m.at(1) - d),
      (m.at(0) - d, m.at(1)), close: true, fill: black, stroke: none)

    // Labels.
    halo((m.at(0) + .25, m.at(1)), text(13.5pt, $bold(x)^(bold(mu)^star)$), anchor: "west")
    content((ph.at(0) - .1, ph.at(1) + .22), course-sans(11pt, weight: "bold", plan-color.darken(25%), "Heads"), anchor: "south-east")
    content((pt.at(0) - .1, pt.at(1) - .2), course-sans(11pt, weight: "bold", plan-color.darken(25%), "Tails"), anchor: "north-east")
    content((0, .1), text(14pt, uncor-color.darken(30%), $accent(cal(X), tilde, size: #130%)$))
    // cX labelled at its boundary, so it does not read as the region between the curves.
    let xpos = (2.6, 2.75)
    content(xpos, text(14pt, hull-color.darken(20%), $cal(X)$), anchor: "south-west")
    line((xpos.at(0) + .05, xpos.at(1) + .05), lerp(ptop, pw1, .62), stroke: .2mm + hull-color.darken(20%))
    content((q4.at(0) + .2, q4.at(1) + .25), text(14pt, $R$), anchor: "south-west")
    // Legend.
    let ly = -3.65
    let lx = -4.3
    circle((lx, ly), radius: .09, fill: black, stroke: none)
    content((lx + .25, ly), text(11pt)[point of $V$ (a joint plan)], anchor: "west")
    circle((lx + 5.1, ly), radius: .1, fill: white, stroke: .3mm + black)
    content((lx + 5.35, ly), text(11pt)[vertex of $R$ outside $cal(X)$], anchor: "west")
  }),
)
