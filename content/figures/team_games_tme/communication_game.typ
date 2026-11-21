// The communication game of the team-games lecture (part 1). Chance draws a
// uniform bit that only P1 sees. P1 sends left or right, which P2 and P3 both see,
// and P2 and P3 then guess the bit. Team ▲ (P1, P2) gets 1 iff P2 is right and the
// adversary ▼ (P3) is wrong. Information sets are shaded bands, as in the other
// lectures. Edge labels are the behavioral probabilities a, ..., f of the notes, and
// the leaves z_1, ..., z_12 sit in one row, left to right, as in the realization
// vectors of part 3.
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
#let bar(x) = $overline(#x)$

#box(
  fill: panel,
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 2mm),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let (y0, y1, y2, y3, yl) = (0, -1.4, -3.0, -4.8, -6.4)
    let hy = .42 // half-height of an information-set band
    let node-r = .3
    // A triangle's visual middle is .09 above (▲) or below (▼) its node point, so
    // the bands are centred there rather than on the node point.
    let (b2, b3) = (y2 + .09, y3 - .09)

    let lab(p, body) = content(p, box(fill: panel, inset: 1.2pt, text(9pt, body)))
    // Arrow from a to b. It leaves a at distance ra and stops at distance rb from b,
    // or where it reaches the height stop-y (a band's top) or the abscissa stop-x
    // (a band's side).
    let arrow(a, b, ra, rb, label: none, t: .5, stop-y: none, stop-x: none) = {
      let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
      let n = calc.sqrt(dx * dx + dy * dy)
      let (ux, uy) = (dx / n, dy / n)
      let end = if stop-x != none {
        let s = (stop-x - a.at(0)) / dx
        (stop-x, a.at(1) + s * dy)
      } else if stop-y == none {
        (b.at(0) - rb * ux, b.at(1) - rb * uy)
      } else {
        let s = (stop-y - a.at(1)) / dy
        (a.at(0) + s * dx, stop-y)
      }
      line((a.at(0) + ra * ux, a.at(1) + ra * uy), end, stroke: .3mm,
        mark: (end: "stealth", scale: .7, fill: black))
      if label != none { lab((a.at(0) + t * dx, a.at(1) + t * dy), label) }
    }
    let band(x0, x1, y, paint, label) = {
      rect((x0 - .55, y - hy), (x1 + .55, y + hy), radius: hy,
        fill: paint.lighten(82%), stroke: .3mm + paint.lighten(30%))
      content(((x0 + x1) / 2, y), text(9pt, paint.darken(15%), label))
    }
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
      content((p.at(0), p.at(1) - .68), text(8pt, luma(30%), $z_#k$))
    }

    // Leaves z_1, ..., z_12 in one row.
    let lx(k) = .6 + (k - 1) * 1.0
    let root = (6.1, y0)
    let p1 = ((2.6, y1), (9.6, y1)) // bit 0, bit 1
    // P2 nodes in tree order (bit, message): each sits above its three leaves.
    let p2 = ((0, "L", lx(2)), (1, "L", lx(5)), (0, "R", lx(8)), (1, "R", lx(11)))

    // Information sets, under everything else.
    band(lx(2), lx(5), b2, mate-color, [sees left])
    band(lx(8), lx(11), b2, mate-color, [sees right])
    band((lx(1) + lx(2)) / 2, (lx(5) + lx(6)) / 2, b3, adv-color, [sees left])
    band((lx(7) + lx(8)) / 2, (lx(11) + lx(12)) / 2, b3, adv-color, [sees right])

    // Chance and Player 1.
    arrow(root, p1.at(0), .27, node-r, label: $1\/2$)
    arrow(root, p1.at(1), .27, node-r, label: $1\/2$)
    content((p1.at(0).at(0) - .8, y1 + .05), text(9pt, luma(30%), [bit 0]))
    content((p1.at(1).at(0) + .8, y1 + .05), text(9pt, luma(30%), [bit 1]))
    arrow(p1.at(0), (lx(2), y2), node-r, 0, label: $a$, t: .45, stop-y: b2 + hy)
    arrow(p1.at(0), (lx(8), y2), node-r, 0, label: bar($a$), t: .22, stop-x: lx(8) - .55)
    arrow(p1.at(1), (lx(5), y2), node-r, 0, label: $b$, t: .22, stop-x: lx(5) + .55)
    arrow(p1.at(1), (lx(11), y2), node-r, 0, label: bar($b$), t: .45, stop-y: b2 + hy)

    // Player 2, Player 3, and leaves. A right guess by Player 2 leads to Player 3,
    // and a wrong one ends the game with payoff 0.
    let k = 1
    for (bit, msg, x) in p2 {
      let (g0, g1) = if msg == "L" { ($c$, bar($c$)) } else { ($d$, bar($d$)) }
      let (h0, h1) = if msg == "L" { ($e$, bar($e$)) } else { ($f$, bar($f$)) }
      for (guess, glabel) in ((0, g0), (1, g1)) {
        if guess == bit {
          // Player 3 sits above the two leaves that follow.
          let q = ((lx(k) + lx(k + 1)) / 2, y3)
          arrow((x, y2), q, node-r, 0, label: glabel, t: .5, stop-y: b3 + hy)
          for (pg, hlabel) in ((0, h0), (1, h1)) {
            let z = (lx(k), yl)
            arrow(q, z, .2, .12, label: hlabel, t: .45)
            // The team wins iff Player 3 guesses wrong.
            leaf(z, if pg == bit { 0 } else { 1 }, k)
            k += 1
          }
        } else {
          let z = (lx(k), yl)
          arrow((x, y2), z, node-r, .12, label: glabel, t: .27)
          leaf(z, 0, k)
          k += 1
        }
      }
    }

    // Nodes on top.
    circle(root, radius: .25, fill: white, stroke: .25mm)
    line((root.at(0) - .177, -.177), (root.at(0) + .177, .177), stroke: .25mm)
    line((root.at(0) - .177, .177), (root.at(0) + .177, -.177), stroke: .25mm)
    for p in p1 { tri(p, team-color, "1") }
    for (bit, msg, x) in p2 { tri((x, y2), mate-color, "2") }
    for (a, b) in ((1, 2), (5, 6), (7, 8), (11, 12)) {
      tri(((lx(a) + lx(b)) / 2, y3), adv-color, "3", up: false)
    }
  }),
)
