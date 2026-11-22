#set page(width: 390pt, height: 245pt, margin: 0pt, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style

#let edge(x1, y1, x2, y2, ..opts) = place(
  top + left,
  line(start: (x1 * 1pt, y1 * 1pt), end: (x2 * 1pt, y2 * 1pt), ..opts),
)
#let node(x, y, fill) = place(
  top + left, dx: (x - 2.5) * 1pt, dy: (y - 2.5) * 1pt,
  circle(radius: 2.5pt, fill: fill, stroke: .6pt),
)
#let label-at(x, y, width, body) = place(
  top + left, dx: (x - width / 2) * 1pt, dy: y * 1pt,
  box(width: width * 1pt, align(center, body)),
)

#edge(210, 25, 65, 130)
#edge(210, 25, 290, 72)
#edge(290, 72, 235, 130)
#edge(290, 72, 350, 130)
#edge(65, 130, 65, 146)
#edge(235, 130, 235, 146)
#edge(350, 130, 350, 146)
#edge(65, 130, 350, 130, stroke: (paint: gray, thickness: .7pt, dash: "dashed"))

#for x in (65, 235, 350) {
  place(top + left, dx: (x - 36) * 1pt, dy: 146pt,
    polygon((36pt, 0pt), (0pt, 56pt), (72pt, 56pt),
      fill: luma(96%), stroke: .6pt))
  label-at(x, 166, 60, $Gamma$)
}

#node(210, 25, black)
#node(290, 72, white)
#for x in (65, 235, 350) { node(x, 130, black) }

#label-at(210, 0, 115, [Deviator (Min)])
#label-at(113, 67, 45, $i = 0$)
#label-at(263, 35, 65, $i in [n]$)
#label-at(331, 65, 64, [Chance])
#label-at(244, 93, 36, $1/2$)
#label-at(341, 93, 36, $1/2$)
#label-at(162, 112, 130, text(size: 7.5pt)[Same mediator information])
#for x in (65, 235, 350) { label-at(x - 10, 125, 12, $M$) }
#label-at(65, 185, 70, text(size: 8pt)[All direct])
#label-at(235, 185, 70, text(size: 8pt)[All direct])
#label-at(350, 185, 70, text(size: 8pt)[$i$ may deviate])
#label-at(65, 210, 110, $u_M (z) - tau$)
#label-at(235, 210, 100, $2u_i (z)$)
#label-at(350, 210, 80, $-2u_i (z)$)
#label-at(208, 232, 325, text(size: 8pt)[The mediator maximizes; the deviator receives the negative payoff.])
