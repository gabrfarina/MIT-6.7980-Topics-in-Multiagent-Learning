// The communication game of the team-games lecture (part 1). Chance draws a
// uniform bit that only P1 sees. P1 sends left or right, which P2 and P3 both see,
// and P2 and P3 then guess the bit. Team ▲ (P1, P2) gets 1 iff P2 is right and the
// adversary ▼ (P3) is wrong. Information sets are dashed lines. Edge labels are the
// behavioral probabilities a, ..., f of the notes, and leaves are numbered
// z_1, ..., z_12 left to right, as in the realization vectors of part 3.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#import "../../meta/typography.typ": course-sans
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#let panel = rgb(247, 249, 252)
#let team-color = rgb(46, 104, 181)
#let mate-color = rgb(118, 82, 166)
#let adv-color = rgb(222, 110, 20)

#let ybar(x) = $overline(#x)$

#box(
  fill: panel,
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let lab(p, body, size: 9pt) = content(p, box(fill: panel, inset: 1.2pt, text(size, body)))
    // Arrow from a to b, shortened by ra at a and rb at b, with a label at fraction t.
    let arrow(a, b, ra, rb, label: none, t: .5) = {
      let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
      let n = calc.sqrt(dx * dx + dy * dy)
      let (ux, uy) = (dx / n, dy / n)
      line(
        (a.at(0) + ra * ux, a.at(1) + ra * uy),
        (b.at(0) - rb * ux, b.at(1) - rb * uy),
        stroke: .3mm,
        mark: (end: "stealth", scale: .7, fill: black),
      )
      if label != none {
        lab((a.at(0) + t * dx, a.at(1) + t * dy), label)
      }
    }
    let node-r = .3
    let tri(p, paint, num, up: true) = {
      let s = if up { 1 } else { -1 }
      line(
        (p.at(0), p.at(1) + s * .36), (p.at(0) - .3, p.at(1) - s * .18), (p.at(0) + .3, p.at(1) - s * .18),
        close: true, fill: paint, stroke: .25mm + paint.darken(30%),
      )
      content(p, course-sans(7pt, white, weight: "bold", num))
    }
    let leaf(p, value, k) = {
      rect((p.at(0) - .08, p.at(1) - .08), (p.at(0) + .08, p.at(1) + .08), fill: white, stroke: .22mm)
      content((p.at(0), p.at(1) - .32), text(8pt, $#value$))
      content((p.at(0), p.at(1) - .68), text(7pt, luma(35%), $z_#k$))
    }
    let infoset(a, b, paint, label, side: left) = {
      line(a, b, stroke: (paint: paint, thickness: .35mm, dash: "dashed"))
    }

    let root = (6, 0)
    let p1 = ((3, -1.5), (9, -1.5)) // bit 0, bit 1
    let y2 = -3.3
    let y3 = -4.9
    let yl = -6.4
    // P2 nodes in tree order: (bit, message, x).
    let p2 = ((0, "L", 1.5), (1, "L", 4.5), (0, "R", 7.5), (1, "R", 10.5))

    // Information sets first, under everything else.
    infoset((1.5 + .3, y2), (4.5 - .3, y2), mate-color, none)
    infoset((7.5 + .3, y2), (10.5 - .3, y2), mate-color, none)
    infoset((.75 + .3, y3), (5.25 - .3, y3), adv-color, none)
    infoset((6.75 + .3, y3), (11.25 - .3, y3), adv-color, none)
    content((3, y2 + .25), text(7.5pt, mate-color.darken(20%), [sees left]))
    content((9, y2 + .25), text(7.5pt, mate-color.darken(20%), [sees right]))
    content((3, y3 + .25), text(7.5pt, adv-color.darken(25%), [sees left]))
    content((9, y3 + .25), text(7.5pt, adv-color.darken(25%), [sees right]))

    // Chance and Player 1.
    arrow(root, p1.at(0), .27, node-r, label: $1\/2$)
    arrow(root, p1.at(1), .27, node-r, label: $1\/2$)
    content((p1.at(0).at(0) - .75, p1.at(0).at(1) + .1), text(8pt, luma(30%), [bit 0]))
    content((p1.at(1).at(0) + .75, p1.at(1).at(1) + .1), text(8pt, luma(30%), [bit 1]))
    arrow(p1.at(0), (1.5, y2), node-r, node-r, label: $a$, t: .45)
    arrow(p1.at(0), (7.5, y2), node-r, node-r, label: ybar($a$), t: .2)
    arrow(p1.at(1), (4.5, y2), node-r, node-r, label: $b$, t: .2)
    arrow(p1.at(1), (10.5, y2), node-r, node-r, label: ybar($b$), t: .45)

    // Player 2, Player 3, and leaves. Leaf numbers run left to right.
    let k = 1
    for (bit, msg, x) in p2 {
      let (g0, g1) = if msg == "L" { ($c$, ybar($c$)) } else { ($d$, ybar($d$)) }
      let (h0, h1) = if msg == "L" { ($e$, ybar($e$)) } else { ($f$, ybar($f$)) }
      // Player 2 guesses 0 (left edge) or 1 (right edge). A right guess leads to
      // Player 3, a wrong one ends the game with payoff 0.
      for (guess, glabel) in ((0, g0), (1, g1)) {
        let q = (x - .75 + 1.5 * guess, y3)
        if guess == bit {
          arrow((x, y2), q, node-r, node-r, label: glabel)
          for (pg, hlabel) in ((0, h0), (1, h1)) {
            let z = (q.at(0) - .45 + .9 * pg, yl)
            arrow(q, z, .2, .1, label: hlabel, t: .45)
            // The team wins iff Player 3 guesses wrong.
            leaf(z, if pg == bit { 0 } else { 1 }, k)
            k += 1
          }
        } else {
          let z = (q.at(0), yl)
          arrow((x, y2), z, node-r, .1, label: glabel, t: .25)
          leaf(z, 0, k)
          k += 1
        }
      }
    }

    // Nodes on top.
    circle(root, radius: .25, fill: white, stroke: .25mm)
    content(root, text(8pt, $C$))
    for p in p1 { tri(p, team-color, "1") }
    for (bit, msg, x) in p2 {
      tri((x, y2), mate-color, "2")
      let q = (x - .75 + 1.5 * bit, y3)
      tri(q, adv-color, "3", up: false)
    }
  }),
)
