#set page(width: auto, height: auto, margin: 1mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// S6.3.4: two-state Attacker/Defender Markov game.
// Edge labels give Player 1's reward, then the joint action (Player 1, Player 2).

#cetz.canvas(
  length: 1cm,
  {
    import cetz.draw: *

    let node(pos, body) = {
      rect(
        (pos.at(0) - 1, pos.at(1) - .5),
        (pos.at(0) + 1, pos.at(1) + .5),
        radius: .4mm,
        stroke: black + .3mm,
        fill: white,
      )
      content(pos)[
        #set align(center)
        #body
      ]
    }

    let s1 = (0, 0)
    let s2 = (7, 0)

    node(s1)[Secure \ $(s_1)$]
    node(s2)[Infiltrated \ $(s_2)$]

    set-style(mark: (end: "stealth", fill: black, scale: .6), stroke: .35mm)

    // Transitions between the states.
    line((1, .2), (6, .2))
    line((6, -.2), (1, -.2))
    content((3.5, .45))[$+3 space (E, M)$]
    content((3.5, -.45))[$-1 space (X, R)$ / $-2 space (H, S)$]

    // Self-loops: leave the top edge on the right, re-enter on the left.
    for x in (s1.at(0), s2.at(0)) {
      bezier((x + .3, .5), (x - .3, .5), (x + .75, 1.6), (x - .75, 1.6))
    }
    content((s1.at(0) - .75, 1.15), anchor: "east")[
      #set align(right)
      $-2 space (E, P)$ \
      $-1 space (W, M)$ \
      $+1 space (W, P)$
    ]
    content((s2.at(0) + .75, 1.3), anchor: "west")[
      #set align(left)
      $+4 space (X, S)$ \
      $+2 space (H, R)$
    ]
  },
)
