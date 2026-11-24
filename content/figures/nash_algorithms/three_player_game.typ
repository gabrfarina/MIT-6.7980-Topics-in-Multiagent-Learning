#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/nash.typ": brown, payoff_table

// Payoff triples (u_1, u_2, u_3); player 3 selects the table.
#let p1 = blue
#let p2 = brown
#let p3 = orange.darken(20%)
#let cell(a, b, c) = [#text(p1)[$#a$], #text(p2)[$#b$], #text(p3)[$#c$]]

#let slice(title, entries) = stack(
  dir: ttb,
  spacing: 2.5mm,
  payoff_table(3, 3, cw: 1.7cm, ch: .7cm)(
    [],
    text(p2)[$1$],
    text(p2)[$2$],
    text(p1)[$1$],
    ..entries.slice(0, 2),
    text(p1)[$2$],
    ..entries.slice(2, 4),
  ),
  align(center, text(p3, title)),
)

#align(center, stack(
  dir: ltr,
  spacing: 1cm,
  slice([player 3 plays $1$], (cell(1, -2, -1), cell(3, 0, 3), cell(0, 1, -3), cell(0, 0, -3))),
  slice([player 3 plays $2$], (cell(-3, 1, 0), cell(-3, 0, 0), cell(0, 3, 0), cell(0, 0, 0))),
))
