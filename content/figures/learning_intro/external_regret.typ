#import "../../meta/notation.typ": vx, xhat
#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../libs/rps.typ": rps-figure, sans

#let played = ("rock", "scissors", "paper", "scissors", "rock", "paper", none)

#rps-figure(
  [#sans[Constant replacement:] discard the input strategy. Here, always rock.],
  played,
  played.map(action => (if action == none { none } else { "rock" }, true)),
  $
    Phi^"const" = {phi.alt_xhat : vx |-> xhat mid(|) xhat in Delta(A)}
  $,
)
