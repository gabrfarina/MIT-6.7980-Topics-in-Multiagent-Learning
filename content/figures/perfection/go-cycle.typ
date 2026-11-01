#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// Who beats whom in Go, after Wang et al. (2023, Figure 2).
#cetz.canvas({
  import cetz.draw: *
  let blue = blue.darken(20%)
  let red = rgb("#c0392b")
  let names = ([Adversary], [KataGo], [Human\ professional], [Human\ amateur])
  let xs = (0, 3.3, 6.6, 9.9)
  for (i, name) in names.enumerate() {
    let fill = if i == 0 { red.transparentize(82%) } else { blue.transparentize(85%) }
    rect((xs.at(i) - 1.15, -0.55), (xs.at(i) + 1.15, 0.55), radius: 2mm, fill: fill, stroke: none, name: "n" + str(i))
    content("n" + str(i), align(center, name))
  }
  for i in range(3) {
    line((xs.at(i) + 1.25, 0), (xs.at(i + 1) - 1.25, 0), mark: (end: ">", fill: black, scale: .7), stroke: .7pt)
    content(((xs.at(i) + xs.at(i + 1)) / 2, 0.28), text(size: 8pt, style: "italic")[beats])
  }
  bezier((xs.at(3), -0.65), (xs.at(0), -0.65), (7.5, -2.1), (2.4, -2.1),
    mark: (end: ">", fill: red, scale: .7), stroke: (paint: red, thickness: .9pt))
  content((4.95, -1.98), anchor: "north", text(size: 8pt, style: "italic", fill: red)[beats])
})
