#import "../../meta/notation.typ": cH, cU, cX
#set page(width: auto, height: auto, margin: 2mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#import "../../meta/typography.typ": course-sans-font
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue_background = rgb("#F2F5F7")
  let orange_background = rgb("#F9F1E8")
  let gray_background = rgb("#F5F4F2")
  let main_text_color = rgb("#656D72")
  let descriptor_text_color = rgb("#6B635B")
  let interior_border_color = rgb("#9EAEBC")
  let exterior_border = (paint: interior_border_color.transparentize(40%), thickness: .4pt, dash: "dashed")
  let exterior_radius = .8mm
  let exterior_opacity = 35%

  let w = 5.0 // box width
  let left-x = 0
  let right-x = 9.6
  let top-y = (3.1, 4.3)
  let bot-y = (0.5, 1.7)

  // Route panels
  for (x, title, fill) in (
    (left-x, [Forecasting route], blue_background),
    (right-x, [Gordon--Greenwald--Marks (2008)], gray_background),
  ) {
    rect((x - 0.3, bot-y.at(0) - 0.35), (x + w + 0.3, top-y.at(1) + 0.75),
      radius: exterior_radius, fill: fill.transparentize(exterior_opacity), stroke: exterior_border)
    content((x + w / 2, top-y.at(1) + 0.4),
      text(font: course-sans-font, fill: descriptor_text_color)[*#title*])
  }

  // Shared bottom band, inset within both panels
  rect((left-x - 0.15, bot-y.at(0) - 0.2), (right-x + w + 0.15, bot-y.at(1) + 0.2),
    radius: exterior_radius, fill: orange_background.transparentize(exterior_opacity), stroke: exterior_border)

  // The four learners
  let box(x, y, body) = {
    rect((x, y.at(0)), (x + w, y.at(1)), fill: white, stroke: .6pt + interior_border_color)
    content((x + w / 2, (y.at(0) + y.at(1)) / 2), align(center, text(fill: main_text_color, body)))
  }
  box(left-x, top-y)[External-regret learner \ over $cH$]
  box(left-x, bot-y)[$cH$-multicalibrated \ forecaster over $cU$]
  box(right-x, top-y)[External-regret learner \ over $Phi$]
  box(right-x, bot-y)[$Phi$-regret learner \ on $cX$, utilities in $cU$]

  let connector(from, to) = line(from, to, stroke: .6pt + interior_border_color,
    mark: (end: "triangle", fill: interior_border_color, stroke: 0pt + interior_border_color, scale: .7))

  let mid-y = (top-y.at(0) + bot-y.at(1)) / 2
  for (x, label) in (
    (left-x, [Expected \ VI]),
    (right-x, [Fixed \ point]),
  ) {
    connector((x + w / 2, top-y.at(0)), (x + w / 2, bot-y.at(1)))
    content((x + w / 2 + 0.15, mid-y), anchor: "west",
      align(left, text(size: 8pt, fill: descriptor_text_color)[#label]))
  }

  let bridge-y = (bot-y.at(0) + bot-y.at(1)) / 2
  connector((left-x + w, bridge-y), (right-x, bridge-y))
  content(((left-x + w + right-x) / 2, bridge-y - 0.15), anchor: "north", text(fill: descriptor_text_color)[Best response])
})
