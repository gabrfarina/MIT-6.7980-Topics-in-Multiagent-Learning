#set page(width: auto, height: auto, fill: none, margin: .1mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/nash.typ": brown, game_table, nash_cmap, nashf
#import "@preview/cetz:0.4.1"

#show text: emph

#cetz.canvas({
  import cetz.draw: *
  // circle((0, 3), radius: 1)
  let N = 128
  let dl = 360deg / (2 * N)
  // for i in range(N) {
  //   let start = (i / N) * 360deg - dl * 1.1
  //   let stop = start + 2.2 * dl

  //   // let col = nash_cmap.sample(-45deg + (start + stop) / 2).saturate(10%)
  //   // if stop <= 90deg {
  //   //   col = red
  //   // }

  //   arc(
  //     (start, 1),
  //     start: start,
  //     stop: stop,
  //     radius: 1,
  //     close: true,
  //     mode: "PIE",
  //     fill: col,
  //     stroke: none,
  //   )
  // }
  arc((0deg, 1), start: 0deg, stop: 90deg, radius: 1, close: true, mode: "PIE", fill: yellow, stroke: none)
  arc((90deg, 1), start: 90deg, stop: 225deg, radius: 1, close: true, mode: "PIE", fill: blue, stroke: none)
  arc((225deg, 1), start: 225deg, stop: 360deg, radius: 1, close: true, mode: "PIE", fill: red, stroke: none)
  circle((0, 0), radius: 1)
  line((0deg, 0), (0deg, 1), stroke: (thickness: .2mm, paint: black, dash: "dashed"))
  line((0deg, 1), (0deg, 1.15), stroke: .5mm + black)
  line((90deg, 0), (90deg, 1), stroke: (thickness: .2mm, paint: black, dash: "dashed"))
  line((90deg, 1), (90deg, 1.15), stroke: .5mm + black)
  line((225deg, 0), (225deg, 1), stroke: (thickness: .2mm, paint: black, dash: "dashed"))
  line((225deg, 1), (225deg, 1.15), stroke: .5mm + black)
  content((45deg, 1.2), anchor: "south-west")[yellow]
  content((157.5deg, 1.1), anchor: "south-east")[blue]
  content((292.5deg, 1.1), anchor: "north-west")[red]
})
