#import "../../meta/notation.typ": sf, spade
#set page(width: 413.63703pt, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../libs/efgs.typ": efg-tree, kuhn-tree

#stack(
      dir: ltr,
      spacing: 1fr,
      box(
        fill: blue.lighten(97%), //luma(97%),
        radius: 2mm,
        inset: (x: 1.75mm, top: 1mm, bottom: 3mm),
      )[#efg-tree(
          sx: 0.255pt,
          nodes: (
            "/": (0, 0),
            "/AT": (-240, 120),
            "/ANT": (240, 120),
            "/AT/quit": (-340, 240),
            "/AT/bet": (-140, 240),
            "/AT/bet/BNAT": (-230, 360),
            "/AT/bet/BAT": (-50, 360),
            "/ANT/quit": (340, 240),
            "/ANT/bet": (140, 240),
            "/ANT/bet/BNAT": (50, 360),
            "/ANT/bet/BAT": (230, 360),
          ),
          highlight-edges: ("/AT/quit", "/ANT/quit", "/AT/bet/BNAT", "/ANT/bet/BNAT"),
          payoff: key => if key.contains("bet") [$(-\$, \$)$] else [$(0,0)$],
          action-name: action => if action == "BNAT" [
            #{ sym.not }A#spade
          ] else if action == "BAT" [
            A#spade
          ] else if action == "AT" [
            #set align(center)
            A#spade on top \
            // ($1 / 52$)
          ] else if action == "ANT" [
            #set align(center)
            A#spade _not_ on top \
            // ($51 / 52$)
          ] else [
            #action
          ],
          (nodes: ("/AT", "/ANT"), name: "A", bend: 0mm),
          (nodes: ("/AT/bet", "/ANT/bet"), name: "B", bend: 0mm),
        )

        #set align(center)
        "Sensible" Nash equilibrium
      ],
      box(
        fill: blue.lighten(97%), //luma(97%),
        radius: 2mm,
        inset: (x: 1.75mm, top: 1mm, bottom: 3mm),
      )[#efg-tree(
          sx: 0.255pt,
          nodes: (
            "/": (0, 0),
            "/AT": (-240, 120),
            "/ANT": (240, 120),
            "/AT/quit": (-340, 240),
            "/AT/bet": (-140, 240),
            "/AT/bet/BNAT": (-230, 360),
            "/AT/bet/BAT": (-50, 360),
            "/ANT/quit": (340, 240),
            "/ANT/bet": (140, 240),
            "/ANT/bet/BNAT": (50, 360),
            "/ANT/bet/BAT": (230, 360),
          ),
          payoff: key => if key.contains("bet") [$(-\$, \$)$] else [$(0,0)$],
          highlight-edges: ("/AT/quit", "/ANT/quit", "/AT/bet/BAT", "/ANT/bet/BAT"),
          action-name: action => if action == "BNAT" [
            #{ sym.not }A#spade
          ] else if action == "BAT" [
            A#spade
          ] else if action == "AT" [
            #set align(center)
            A#spade on top \
            // ($1 / 52$)
          ] else if action == "ANT" [
            #set align(center)
            A#spade _not_ on top \
            // ($51 / 52$)
          ] else [
            #action
          ],
          (nodes: ("/AT", "/ANT"), name: "A", bend: 0mm),
          (nodes: ("/AT/bet", "/ANT/bet"), name: "B", bend: 0mm),
        )

        #set align(center)
        "Questionable" Nash equilibrium
      ],
    )
