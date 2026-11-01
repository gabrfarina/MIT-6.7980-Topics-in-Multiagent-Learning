#import "../libs/typography.typ": figure-font, figure-style
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#set text(font: figure-font, size: 8pt)
#show: figure-style

// Exact-feedback simultaneous MMD for the matching-pennies example in L09.
#let alpha = 0.3
#let eta = 0.1
#let logit(x) = calc.ln(x / (1 - x))
#let sigmoid(x) = 1 / (1 + calc.exp(-x))
#let trace = {
  let p = 0.8
  let q = 0.35
  let points = ()
  for t in range(1001) {
    let gap = calc.abs(2*p - 1) + calc.abs(2*q - 1)
    let residual = calc.max(
      calc.abs(4*q - 2 - alpha*(logit(p) - calc.ln(4))),
      calc.abs(2 - 4*p - alpha*(logit(q) - calc.ln(4))),
    )
    points.push((t, p, q, gap, residual))
    let pn = sigmoid((logit(p) + eta*(4*q - 2) + eta*alpha*calc.ln(4)) / (1 + eta*alpha))
    let qn = sigmoid((logit(q) + eta*(2 - 4*p) + eta*alpha*calc.ln(4)) / (1 + eta*alpha))
    p = pn
    q = qn
  }
  points
}
#metadata(trace.last()) <mmd-final>

#let blue = rgb("#2466A0")
#let brown = rgb("#AD5A26")
#let grid-color = luma(88%)
#let ink = luma(25%)
#let left-x = 0.8
#let right-x = 7.5
#let plot-top = 0.65
#let plot-height = 4.3
#let left-width = 4.3
#let right-width = 5.5
#let xy(p, q) = (left-x + left-width*(p - 0.4)/0.5, plot-top + plot-height*(0.7 - q)/0.5)
#let ty(t, value) = (right-x + right-width*t/1000, plot-top - plot-height*calc.log(calc.max(value, 1e-12))/12)
#let segment(a, b, stroke: 0.45pt + ink) = place(top + left,
  curve(stroke: stroke, curve.move((a.at(0)*1cm, a.at(1)*1cm)), curve.line((b.at(0)*1cm, b.at(1)*1cm))),
)
#let path(points, stroke) = place(top + left, curve(
  stroke: stroke,
  curve.move((points.at(0).at(0)*1cm, points.at(0).at(1)*1cm)),
  ..points.slice(1).map(v => curve.line((v.at(0)*1cm, v.at(1)*1cm))),
))
#let label(x, y, body, width: 2cm, alignment: center) = place(top + left,
  dx: x*1cm, dy: y*1cm, box(width: width, align(alignment, body)),
)
#let dot(p, color, hollow: false) = place(top + left,
  dx: p.at(0)*1cm - 2.2pt, dy: p.at(1)*1cm - 2.2pt,
  circle(radius: 2.2pt, fill: if hollow { white } else { color }, stroke: 0.8pt + color),
)
#let cross(p) = {
  let s = 0.07
  segment((p.at(0)-s, p.at(1)-s), (p.at(0)+s, p.at(1)+s), stroke: 1pt + ink)
  segment((p.at(0)-s, p.at(1)+s), (p.at(0)+s, p.at(1)-s), stroke: 1pt + ink)
}

#block(width: 13.35cm, height: 6.2cm)[
  #label(0.8, 0.02, [*Strategy trajectory*], width: 4.3cm)
  #label(7.5, 0.02, [*Original gap and regularized residual*], width: 5.5cm)

  #for v in (0.4, 0.6, 0.8) {
    let x = xy(v, 0.2).at(0)
    segment((x, plot-top), (x, plot-top+plot-height), stroke: 0.35pt + grid-color)
    label(x - 0.3, 5.08, str(v), width: 0.6cm)
  }
  #for v in (0.2, 0.4, 0.6) {
    let y = xy(0.4, v).at(1)
    segment((left-x, y), (left-x+left-width, y), stroke: 0.35pt + grid-color)
    label(0.14, y - 0.12, str(v), width: 0.5cm)
  }
  #segment((left-x, plot-top), (left-x, plot-top+plot-height))
  #segment((left-x, plot-top+plot-height), (left-x+left-width, plot-top+plot-height))
  #path(trace.map(v => xy(v.at(1), v.at(2))), 0.9pt + blue)
  #cross(xy(0.5, 0.5))
  #dot(xy(0.8, 0.35), blue, hollow: true)
  #dot(xy(trace.last().at(1), trace.last().at(2)), brown)
  #label(0.13, 0.28, $q$, width: 0.5cm)
  #label(2.1, 5.35, $p$, width: 1.5cm)

  #for t in (0, 500, 1000) {
    let x = ty(t, 1).at(0)
    segment((x, plot-top), (x, plot-top+plot-height), stroke: 0.35pt + grid-color)
    label(x - 0.45, 5.08, str(t), width: 0.9cm)
  }
  #for k in (0, -3, -6, -9, -12) {
    let y = plot-top - plot-height*k/12
    segment((right-x, y), (right-x+right-width, y), stroke: 0.35pt + grid-color)
    label(6.35, y - 0.14, if k == 0 { $1$ } else { $10^#k$ }, width: 0.95cm)
  }
  #segment((right-x, plot-top), (right-x, plot-top+plot-height))
  #segment((right-x, plot-top+plot-height), (right-x+right-width, plot-top+plot-height))
  #path(trace.map(v => ty(v.at(0), v.at(3))), 0.95pt + blue)
  #path(trace.map(v => ty(v.at(0), v.at(4))), (paint: brown, thickness: 0.95pt, dash: "dashed"))
  #label(8.9, 5.35, [Iteration], width: 2.6cm)

  #cross((0.9, 5.9))
  #label(1.05, 5.77, [Nash], width: 0.8cm, alignment: left)
  #dot((2.08, 5.9), brown)
  #label(2.23, 5.77, [Regularized limit], width: 2.2cm, alignment: left)
  #dot((4.6, 5.9), blue, hollow: true)
  #label(4.75, 5.77, [Start], width: 0.9cm, alignment: left)
  #segment((7.5, 5.9), (7.95, 5.9), stroke: 0.95pt + blue)
  #label(8.08, 5.77, [Nash gap], width: 1.45cm, alignment: left)
  #segment((9.9, 5.9), (10.35, 5.9), stroke: (paint: brown, thickness: 0.95pt, dash: "dashed"))
  #label(10.48, 5.77, [Residual], width: 2.0cm, alignment: left)
]
