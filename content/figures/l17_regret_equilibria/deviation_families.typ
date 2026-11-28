#import "../libs/typography.typ": figure-font, figure-style
#set page(width: auto, height: auto, margin: 1pt, fill: none)
#set text(font: figure-font, size: 8pt)
#show: figure-style
#let accent = rgb("#325d8a")
#let rule = rgb("#d7d0c6")
#let panel(title, formula, f) = block(width: 145pt)[
  #align(center)[*#title* #linebreak() #formula]
  #box(width: 145pt, height: 123pt)[
    #place(top + left, dx: 25pt, dy: 8pt)[
      #for t in (0, 0.5, 1) {
        place(top + left, dx: t * 100pt)[#line(start: (0pt, 0pt), end: (0pt, 100pt), stroke: .35pt + rule)]
        place(top + left, dy: (1 - t) * 100pt)[#line(start: (0pt, 0pt), end: (100pt, 0pt), stroke: .35pt + rule)]
        place(top + left, dx: t * 100pt - 5pt, dy: 103pt)[#box(width: 10pt, align(center, str(t)))]
        place(top + left, dx: -17pt, dy: (1 - t) * 100pt - 4pt)[#box(width: 13pt, align(right, str(t)))]
      }
      #place(top + left)[#line(start: (0pt, 0pt), end: (0pt, 100pt), stroke: .5pt)]
      #place(top + left, dy: 100pt)[#line(length: 100pt, stroke: .5pt)]
      #place(top + left)[#curve(stroke: 1.2pt + accent,
        ..range(101).map(i => {
          let point = (i * 1pt, (1 - f(i / 100)) * 100pt)
          if i == 0 { curve.move(point) } else { curve.line(point) }
        }),
      )]
      #for x in (0.2, 0.5, 0.8) {
        place(top + left, dx: x * 100pt - 1.7pt, dy: (1 - f(x)) * 100pt - 1.7pt)[#circle(radius: 1.7pt, fill: accent, stroke: none)]
      }
      #place(top + left, dx: 111pt, dy: 97pt)[$x$]
      #place(top + left, dx: -22pt, dy: -13pt)[$phi.alt(x)$]
    ]
  ]
]
#grid(columns: (145pt, 145pt, 145pt), gutter: 5pt,
  panel([Constant], $phi.alt(x) = 0.65$, x => 0.65),
  panel([Affine], $phi.alt(x) = 0.2 + 0.6x$, x => 0.2 + 0.6*x),
  panel([Swap: nonlinear example], $phi.alt(x) = x^2$, x => x*x),
)
