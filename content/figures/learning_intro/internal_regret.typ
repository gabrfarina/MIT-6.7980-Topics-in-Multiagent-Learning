#import "../../meta/notation.typ": vx
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/rps.typ": rps-figure, sans

// The switch from a = scissors to b = rock changes only the scissors rounds.
#let (a, b) = ("scissors", "rock")
#let played = ("rock", "scissors", "paper", "scissors", "rock", "paper", none)

#rps-figure(
  [#sans[One action-to-action switch:] move all mass from $a$ to $b$; leave the rest unchanged.],
  played,
  played.map(action => if action == a { (b, true) } else { (action, false) }),
  $
    (phi.alt_(a -> b)(vx))_s = cases(
      0 & quad s = a",",
      x_b + x_a & quad s = b",",
      x_s & quad "otherwise,"
    ) quad quad a != b
  $,
)
