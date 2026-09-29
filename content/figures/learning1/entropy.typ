#set page(width: auto, height: auto, fill: none, margin: .5mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#cetz.canvas({
  import cetz.draw: content
  import cetz-plot: plot
  plot.plot(
    x-label: $x$,
    y-label: none,
    x-grid: true,
    y-grid: true,
    size: (3.3, 2.8),
    axis-style: "school-book",
    x-tick-step: 0.25,
    x-max: 1.04,
    y-tick-step: 0.25,
    y-min: -.89,
    {
      plot.add(
        domain: (1e-4, 1 - 1e-4),
        style: (stroke: 0.65mm + blue),
        samples: 200,
        x => x * calc.ln(x) + (1 - x) * calc.ln(1 - x),
      )
    },
  )
  content((3.0, 0.6), box(fill: none, inset: .5mm, $H(x,1-x)$))
})
