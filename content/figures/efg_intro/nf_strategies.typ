#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#import "../../meta/typography.typ": course-sans
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../kernelized/vertices.typ": draw-tree

#let makevec(s, num) = {
  v(1mm)
  box(width: 4.3cm, height: 2.7cm, radius: 2mm, fill: blue.lighten(97%), scale(65%, reflow: true, draw-tree(s)))
  // v(2mm)

  if (
    false
  ) [$pi_#num :=$ #h(0.1mm) ( #h(-1.5mm) #box(grid(
      columns: (3.3mm,) * 9,
      row-gutter: 0mm,
      align: center,
      ..range(9).map(i => course-sans(fill: gray, size: 7pt)[#{ i + 1 }]),
      ..range(9).map(i => s.at(i)),
    )) #h(-1.5mm) )]
}

#align(center, table(
    columns: (auto, auto, auto),
    inset: (x: 3mm, top: 1.2mm, bottom: 1.2mm),
    // column-gutter: .2cm,
    // row-gutter: .5cm,
    align: center + horizon,
    stroke: (x, y) => {
      (
        bottom: if y <= 1 { (thickness: .2mm, paint: luma(40%), dash: "dashed") } else { none },
        left: if x > 0 and not (x == 2 and y == 2) { (thickness: .2mm, paint: luma(40%), dash: "dashed") } else {
          none
        },
      )
    },
    ..(
      "101010000",
      "101001000",
      "100110000",
      "100101000",
      "010000100",
      "010000010",
      "010000001",
    )
      .enumerate()
      .map((x => makevec(x.at(1), x.at(0) + 1))),
  ))
