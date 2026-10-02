// What a retraction would have to do: sweep every interior point out to the
// rim while leaving the rim itself untouched.
#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let rim = rgb("#0b6bcb")
#let flow = luma(38%)

#cetz.canvas({
  import cetz.draw: *
  scale(1.55)

  for (a, r0) in ((32deg, 0.44), (104deg, 0.30), (172deg, 0.56),
                  (248deg, 0.40), (316deg, 0.60)) {
    line((a, r0), (a, 1.0), stroke: .32mm + flow,
         mark: (end: "straight", scale: .42, fill: flow))
    circle((a, r0), radius: .055, fill: flow, stroke: none)
  }

  circle((0, 0), radius: 1, stroke: .6mm + rim)
  // The centre is clear of every arrow, so the set label sits there.
  content((0, 0), anchor: "center", text(fill: luma(25%))[$D$])
  content((90deg, 1.16), anchor: "south", text(fill: rim)[$partial D$ fixed])
})
