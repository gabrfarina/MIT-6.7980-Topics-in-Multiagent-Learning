#import "../../meta/notation.typ": sf, eps
#set page(width: 413.63703pt, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

// The two-player zero-sum perfect-information game that separates the
// equilibrium refinements of the Venn diagram, drawn once per witness profile.
// Prescribed actions are drawn in the profile color; gray annotations show the
// trembles that the argument for each panel relies on.
#let profile-color = orange.darken(10%)
#let note-color = luma(45%)

#let lerp(u, v, s) = (u.at(0) + (v.at(0) - u.at(0)) * s, u.at(1) + (v.at(1) - u.at(1)) * s)

// t: value of the payoff t after r, shown beside that leaf. profile: highlighted actions. notes: action -> gray
// annotation after the action label.
#let tree(t, profile: (), notes: (:)) = [
  #set text(8pt)
  #cetz.canvas(length: 0.9cm, {
  import cetz.draw: *
  set-style(stroke: .3mm)
  let A = (0, 0)
  let B = (1.1, -1.1)
  let C = (1.9, -2.2)
  let leaf-a = (-1.1, -1.1)
  let leaf-r = (0.1, -2.2)
  let leaf-c = (1.1, -3.3)
  let leaf-d = (2.7, -3.3)

  let edge(u, v, key, pos) = {
    let hl = key in profile
    let col = if hl { profile-color } else { black }
    let th = if hl { .9mm } else { .3mm }
    line(u, lerp(u, v, 0.92), stroke: (paint: col, thickness: th), mark: (end: "stealth", fill: col, stroke: .3mm + col, scale: .8))
    let lbl = if key in notes [#text(fill: col, sf(key)) #text(7pt, fill: note-color)[(#notes.at(key))]] else [#text(fill: col, sf(key))]
    content(pos, lbl)
  }
  edge(A, leaf-a, "a", (-0.8, -0.35))
  edge(A, B, "b", (0.8, -0.35))
  edge(B, leaf-r, "r", (0.3, -1.5))
  edge(B, C, "s", (2.0, -1.45))
  edge(C, leaf-c, "c", (0.85, -2.8))
  edge(C, leaf-d, "d", (2.7, -2.75))

  for (pos, lbl, fill, lbl-pos) in ((A, [A], black, (-0.33, 0.12)), (B, [B], white, (1.43, -0.98)), (C, [C], black, (2.23, -2.08))) {
    circle(pos, radius: .09, fill: fill)
    content(lbl-pos, text(fill: blue, sf(lbl)))
  }
  for (pos, payoff) in ((leaf-a, $(1, -1)$), (leaf-r, $(t, -t)$), (leaf-c, $(1, -1)$), (leaf-d, $(-1, 1)$)) {
    rect((pos.at(0) - .06, pos.at(1) - .06), (pos.at(0) + .06, pos.at(1) + .06), fill: white)
    content((pos.at(0), pos.at(1) - .32), payoff)
  }
  // The value of t in this panel, next to the leaf whose payoff it sets.
  content((leaf-r.at(0) - .2, leaf-r.at(1)), anchor: "east", text(7pt, fill: note-color)[$t = #t$])
  })
]

#let panel(body, title) = box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 2mm, top: 2mm, bottom: 2.5mm),
)[
  #body
  #v(1mm)
  #set align(center)
  #set text(8pt)
  #title
]

#stack(
  dir: ltr,
  spacing: 1fr,
  panel(
    tree($2$, profile: ("a", "c", "s"), notes: (r: $eps$, s: $1 - eps$, c: $1 - eps$, d: $eps$)),
    [*(a)* $t = 2$, $sigma = (a c; s)$ \ EFPE, not normal-form perfect],
  ),
  panel(
    tree($1$, profile: ("a", "d", "s")),
    [*(b)* $t = 1$, $sigma' = (a d; s)$ \ normal-form perfect, not sequential],
  ),
  panel(
    tree($1$, profile: ("b", "c", "s"), notes: (r: $eta$, s: $1 - eta$, c: $1$, d: $0$)),
    [*(c)* $t = 1$, $sigma'' = (b c; s)$ \ QPE, not EFPE],
  ),
)
