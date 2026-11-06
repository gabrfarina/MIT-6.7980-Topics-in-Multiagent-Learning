#set page(width: auto, height: auto, fill: none, margin: .6mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/nash.typ": brown, payoff_table

#show text: emph

#align(center,
  payoff_table(3, 3, cw: 1.5cm)(
    [],
    [#set text(brown); L],
    [#set text(brown); R],

    [#set text(blue); T],
    [3, 3],
    [0, 0],

    [#set text(blue); B],
    [0, 0],
    [2, 2],
  ),
)