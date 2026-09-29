#set page(width: auto, height: auto, fill: none, margin: 0mm)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#import "../libs/nash.typ": game_table

#game_table(
  (
    ($a_11$, $a_12$, $...$, $a_(1 m)$),
    ($a_21$, $a_22$, $...$, $a_(2 m)$),
    ($dots.v$ + sym.space, $dots.v$ + sym.space, $dots.down$, $dots.v$ + sym.space),
    ($a_(n 1)$, $a_(n 2)$, $...$, $a_(n m)$),
  ),
  (
    ($b_11$, $b_12$, $...$, $b_(1 m)$),
    ($b_21$, $b_22$, $...$, $b_(2 m)$),
    ($dots.v$ + sym.space, $dots.v$ + sym.space, $dots.down$, $dots.v$ + sym.space),
    ($b_(n 1)$, $b_(n 2)$, $...$, $b_(n m)$),
  ),
  ("action 1", "action 2", $dots.v$ + h(5.5mm), $"action" n$),
  ("action 1", "action 2", $dots.c$, $"action" m$),
  // cw: 1.6cm,
  ch: .7cm,
)
