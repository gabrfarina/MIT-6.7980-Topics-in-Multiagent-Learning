#import "../../meta/notation.typ": upsans
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Example "Competing drug makers" with beta = 1.5. One panel per state y.
// Coordinates: (utility of prescribing J, utility of prescribing P).

#let alice-col = rgb("#1f5fa8")
#let bob-col = rgb("#b03a2e")

#cetz.canvas(length: 1.05cm, {
  import cetz.draw: *

  let panel(dx, state, alice, bj, bp, title) = {
    let P(q) = (q.at(0) + dx, q.at(1))
    let mid = ((bj.at(0) + bp.at(0)) / 2, (bj.at(1) + bp.at(1)) / 2)

    // Preference regions, split by the indifference line u(J) = u(P).
    line(P((0, 0)), P((0, 3)), P((3, 3)), close: true, fill: luma(242), stroke: none)
    line(P((0, 0)), P((3, 3)), stroke: (paint: gray, dash: "dashed", thickness: .3mm))
    content(P((1.0, 2.75)), text(fill: gray.darken(30%), size: 8pt)[prefers #upsans("P")])
    content(P((2.55, 1.6)), text(fill: gray.darken(30%), size: 8pt)[prefers #upsans("J")])

    // Axes.
    let arrow = (end: "stealth", fill: black, scale: .5)
    line(P((0, 0)), P((3.1, 0)), stroke: .3mm, mark: arrow)
    line(P((0, 0)), P((0, 3.1)), stroke: .3mm, mark: arrow)
    content(P((1.5, -0.62)), anchor: "north")[$u(upsans(J), y)$]
    content(P((0, 3.2)), anchor: "south")[$u(upsans(P), y)$]
    content(P((1.5, 3.65)), anchor: "south")[*State* $y = upsans(#state)$ #h(.2em) #title]

    // Providers and the segment between them.
    line(P(bj), P(bp), stroke: bob-col.lighten(30%) + .35mm)
    circle(P(bj), radius: .075, fill: bob-col, stroke: none)
    circle(P(bp), radius: .075, fill: bob-col, stroke: none)

    // Alice and the shift along (1, 1) to the midpoint.
    // Stop the arrow short of the hollow midpoint marker so its head stays visible.
    let tip = (alice.at(0) + .88 * (mid.at(0) - alice.at(0)), alice.at(1) + .88 * (mid.at(1) - alice.at(1)))
    line(P(alice), P(tip), stroke: (paint: black, dash: "dotted", thickness: .35mm),
      mark: (end: "stealth", fill: black, scale: .45))
    circle(P(mid), radius: .075, fill: white, stroke: black + .3mm)
    circle(P(alice), radius: .075, fill: alice-col, stroke: none)
  }

  let lbl(pos, anchor, body) = content(pos, anchor: anchor, padding: .1, body)

  // State y = J: (u(J), u(P)) for Alice = (1, 0), J-provider = (2.5, 0), P-provider = (1, 1.5).
  panel(0, "J", (1, 0), (2.5, 0), (1, 1.5), [(#upsans("J") is better)])
  lbl((1, 0), "north", text(fill: alice-col)[$u_A$])
  lbl((2.5, 0), "north", text(fill: bob-col)[$u_(upsans(J))$])
  lbl((1, 1.5), "east", text(fill: bob-col)[$u_(upsans(P))$])
  lbl((1.8, 0.8), "south-west", [midpoint])
  lbl((1.47, 0.36), "north-west", text(size: 8pt)[$+beta\/2$])

  // State y = P: Alice = (0, 1), J-provider = (1.5, 1), P-provider = (0, 2.5).
  let dx = 4.9
  panel(dx, "P", (0, 1), (1.5, 1), (0, 2.5), [(#upsans("P") is better)])
  lbl((dx + 0, 1), "east", text(fill: alice-col)[$u_A$])
  lbl((dx + 1.5, 1), "west", text(fill: bob-col)[$u_(upsans(J))$])
  lbl((dx + 0, 2.5), "east", text(fill: bob-col)[$u_(upsans(P))$])
  lbl((dx + 0.8, 1.8), "south-west", [midpoint])
  lbl((dx + 0.45, 1.3), "north-west", text(size: 8pt)[$+beta\/2$])
})
