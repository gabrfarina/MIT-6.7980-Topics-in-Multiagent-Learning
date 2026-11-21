// Setup of Example "Three hats" in the team-games lecture. Three teammates stand in a circle, so each
// sees the other two hats (dashed sight lines) but not its own (the "?" on each hat).
// Plan: "on seeing two equal hats, guess the other color, otherwise pass".
// Left panel (red, red, blue): teammate 3 sees two reds and guesses blue, which is
// right, and teammates 1 and 2 see one of each and pass. So the team wins.
// Right panel (red, red, red): everyone sees two reds and guesses blue. The team loses.
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "../../meta/typography.typ": course-sans
#import "@preview/cetz:0.4.1"

#let plan-color = rgb(0, 150, 110)
#let off-color = luma(62%)
#let red-hat = rgb(214, 48, 49)
#let blue-hat = rgb(30, 120, 230)

#let wrong-color = red-hat.darken(15%)
#let spots = ((-1.75, 0), (1.75, 0), (0, 2.75))

// One panel: a title, the three hat colors, and per teammate (label, ink) for its bubble.
#let panel(title, hats, says) = box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, top: 3mm, bottom: 3mm),
  stack(spacing: 2mm,
  align(center, course-sans(8.5pt, luma(30%), weight: "bold", title)),
  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let add((x, y), (u, v), s: 1) = (x + s * u, y + s * v)
    let unit((x, y), (u, v)) = {
      let n = calc.sqrt((u - x) * (u - x) + (v - y) * (v - y))
      ((u - x) / n, (v - y) / n)
    }
    let r = .42 // head radius
    // Fixed invisible frame so both panels have the same size.
    rect((-2.8, -1.2), (2.8, 4.17), stroke: none, fill: none)

    // Sight lines between every pair of teammates, drawn first.
    for (i, j) in ((0, 1), (0, 2), (1, 2)) {
      let a = spots.at(i)
      let b = spots.at(j)
      let u = unit(a, b)
      let arrow = (start: "stealth", end: "stealth", scale: .7, fill: off-color, stroke: .3mm + off-color)
      line(add(a, u, s: r + .45), add(b, u, s: -(r + .45)), mark: arrow,
        stroke: (paint: off-color, thickness: .3mm, dash: (1.2mm, .9mm)))
    }

    // A teammate: head with its number and a cap in its hat color.
    let person(p, number, paint) = {
      circle(p, radius: r, fill: white, stroke: .3mm + luma(30%))
      content(add(p, (0, -.08)), course-sans(9pt, luma(25%), weight: "bold", number))
      // Cap: a dome over the top of the head and a brim.
      let (cx, cy) = add(p, (0, .26))
      let pts = range(0, 19).map(k => {
        let t = calc.pi * k / 18
        (cx + .44 * calc.cos(t), cy + .4 * calc.sin(t))
      })
      line(..pts, close: true, fill: paint, stroke: .25mm + paint.darken(35%))
      rect((cx - .54, cy - .07), (cx + .54, cy + .05), radius: .05,
        fill: paint.darken(15%), stroke: .25mm + paint.darken(35%))
      content((cx, cy + .2), text(8pt, white, weight: "bold", "?"))
    }

    // Speech bubble of half-width w with its tail pointing at the speaker.
    let bubble(p, w, tail, body, paint) = {
      let h = .22
      let u = unit(p, tail)
      let perp = (-u.at(1), u.at(0))
      let base = add(p, u, s: if calc.abs(u.at(0)) > .5 { w } else { h })
      let b1 = add(base, perp, s: .09)
      let b2 = add(base, perp, s: -.09)
      rect(add(p, (-w, -h)), add(p, (w, h)), radius: h, fill: white, stroke: .25mm + paint)
      line(b1, tail, b2, fill: white, stroke: .25mm + paint)
      line(add(b1, u, s: -.08), b1, tail, b2, add(b2, u, s: -.08), close: true, fill: white, stroke: none)
      content(p, body)
    }

    for k in range(3) { person(spots.at(k), str(k + 1), hats.at(k)) }

    let say((kind, w)) = {
      let paint = if kind == "right" { plan-color } else if kind == "wrong" { wrong-color } else { off-color }
      let body = if kind == "pass" { text(8.5pt, off-color.darken(30%), "pass") } else {
        text(8.5pt, paint.darken(20%), [guess #text(blue-hat, weight: "bold")[blue] #if kind == "right" [#sym.checkmark] else [#text(weight: "bold", sym.times)]])
      }
      (body, paint, w)
    }
    let pos = ((-1.75, -.95), (1.75, -.95), (0, 3.92))
    let tails = ((-1.75, -.48), (1.75, -.48), (0, 3.48))
    for k in range(3) {
      let (body, paint, w) = say(says.at(k))
      bubble(pos.at(k), w, tails.at(k), body, paint)
    }
  }),
  ),
)

#let g = ("right", 1.02)
#let x = ("wrong", 1.02)
#let ps = ("pass", .5)
#stack(dir: ltr, spacing: 4mm,
  panel([plan wins (6 of 8)], (red-hat, red-hat, blue-hat), (ps, ps, g)),
  panel([plan loses (all red or all blue)], (red-hat, red-hat, red-hat), (x, x, x)),
)
