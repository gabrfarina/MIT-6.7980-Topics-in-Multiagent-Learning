// One round of the forecast-then-best-respond learner.
// Recreates slide 21 ("Best respond to the forecast", #cal-best-response) of L15.
#import "../../meta/notation.typ": vx, vu
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *

  let blk(pos, body, w: 2.8, h: 1.1) = {
    rect(
      (pos.at(0) - w / 2, pos.at(1) - h / 2),
      (pos.at(0) + w / 2, pos.at(1) + h / 2),
      radius: .4mm,
      stroke: .3mm,
      fill: white,
    )
    content(pos)[#set align(center); #body]
  }

  blk((0, 0))[Draw a forecast \ $p ~ D^((t))$]
  blk((4.6, 0), w: 3.6)[Play the best response \ $vx^((t)) = sigma(p)$]
  blk((9.2, 0))[Observe the utility \ $vu^((t))$]

  set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)
  line((1.4, 0), (2.8, 0))
  line((6.4, 0), (7.8, 0))
})
