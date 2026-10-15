#import "../../meta/notation.typ": vx, vone
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/rps.typ": rps-figure, sans

// A permutation is one stochastic map that replaces every action.
#let swap = (rock: "paper", scissors: "rock", paper: "scissors")
#let played = ("rock", "scissors", "paper", "scissors", "rock", "paper", none)

#rps-figure(
  [#sans[A replacement for every action:] allow all stochastic maps of the simplex.],
  played,
  played.map(action => if action == none { (none, false) } else { (swap.at(action), true) }),
  $
    Phi^"swap" = {vx |-> Q vx : Q >= 0, thin vone^top Q = vone^top}
  $,
)
