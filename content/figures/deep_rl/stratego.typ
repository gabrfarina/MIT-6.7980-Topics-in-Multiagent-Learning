// Stratego positions adapted from Figure 2 of Sokota et al. (2025), arXiv:2511.07312.
#import "@preview/cetz:0.4.1"
#import "../../meta/typography.typ": course-sans
#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style

#let red-piece = rgb("#8c2a2a")
#let blue-piece = rgb("#2c3e5c")
#let light-square = rgb("#e4dfd2")
#let dark-square = rgb("#c4bba5")
#let lake = rgb("#9dbfd8")
#let move-arrow = rgb("#2e7d32")

// Display rank (or icon) and abbreviation of each piece type.
#let pieces = (
  F: ("flag", [Flag]),
  B: ("bomb", [Bomb]),
  "1": ([1], [Spy]),
  "2": ([2], [Sct]),
  "3": ([3], [Min]),
  "4": ([4], [Sgt]),
  "5": ([5], [Lt]),
  "6": ([6], [Capt]),
  "7": ([7], [Maj]),
  "8": ([8], [Col]),
  "9": ([9], [Gen]),
  "10": ([10], [Mar]),
)

// Rows from top to bottom, columns a to j. `?` is a concealed piece, `.` is empty.
#let parse(rows) = rows.map(row => row.split(" "))

#let red-setup = (
  "B 9 B B 2 2 8 7 5 2",
  "7 4 5 4 3 2 6 2 2 6",
  "B 3 5 10 6 4 3 1 6 4",
  "F B 3 8 7 2 B 2 3 5",
)

#let start = (
  blue: parse(range(4).map(_ => "? ? ? ? ? ? ? ? ? ?") + range(6).map(_ => ". . . . . . . . . .")),
  red: parse(range(6).map(_ => ". . . . . . . . . .") + red-setup),
)

#let midgame = (
  blue: parse((
    "? ? ? ? ? ? ? ? ? ?",
    "? ? ? ? 4 ? ? ? . 6",
    ". . 8 . . 7 . ? . .",
    ". 5 . . . 9 ? . . 8",
    ". . . . . . . . . .",
    "? ? . . . . . . . .",
    ". . . . . . . . ? .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
  )),
  red: parse((
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . 9 . . . . .",
    "B . B B . . 8 . . .",
    "7 . . . . . 7 . . 2",
    "B 3 5 10 6 4 3 1 6 .",
    "F B 3 8 7 2 B 2 3 5",
  )),
)

#let board(position, arrow: none) = cetz.canvas(length: 6.5mm, {
  import cetz.draw: *

  for col in range(10) {
    for row in range(10) {
      let fill = if calc.even(col + row) { dark-square } else { light-square }
      rect((col, row), (col + 1, row + 1), fill: fill, stroke: none)
    }
  }
  for col in (2, 6) {
    rect((col, 4), (col + 2, 6), fill: lake, stroke: 0.4pt + lake.darken(25%))
  }

  let piece(col, row, color, kind) = {
    let (x, y) = (col + 0.5, row + 0.5)
    rect((x - 0.43, y - 0.43), (x + 0.43, y + 0.43), radius: 0.12, fill: color, stroke: none)
    if kind == "?" {
      rect((x - 0.3, y - 0.3), (x + 0.3, y + 0.3), radius: 0.08, stroke: 0.7pt + white.transparentize(30%))
    } else {
      let (rank, name) = pieces.at(kind)
      let top = y + 0.16
      if rank == "bomb" {
        circle((x - 0.03, top - 0.03), radius: 0.12, fill: white, stroke: none)
        line((x + 0.05, top + 0.06), (x + 0.12, top + 0.15), stroke: 0.8pt + white)
        circle((x + 0.15, top + 0.18), radius: 0.035, fill: white, stroke: none)
      } else if rank == "flag" {
        line((x - 0.12, top - 0.17), (x - 0.12, top + 0.15), stroke: 0.8pt + white)
        line((x - 0.12, top + 0.15), (x + 0.15, top + 0.06), (x - 0.12, top - 0.03), close: true, fill: white, stroke: none)
      } else {
        content((x, top), text(fill: white, size: 8pt, course-sans(strong(rank))))
      }
      content((x, y - 0.2), text(fill: white, size: 5.4pt, course-sans(name)))
    }
  }

  for (color, side) in ((blue-piece, "blue"), (red-piece, "red")) {
    for (i, row) in position.at(side).enumerate() {
      for (col, kind) in row.enumerate() {
        if kind != "." { piece(col, 9 - i, color, kind) }
      }
    }
  }

  if arrow != none {
    let ((c1, r1), (c2, r2)) = arrow
    let (from, to) = ((c1 + 0.5, r1 - 0.2), (c2 + 0.5, r2 - 0.5 + 0.3))
    // A white halo keeps the arrow visible over the dark pieces.
    line(from, to, stroke: 4pt + white, mark: (end: ">", fill: white, stroke: 1.5pt + white, scale: 0.6))
    line(from, to, stroke: 2.2pt + move-arrow, mark: (end: ">", fill: move-arrow, scale: 0.6))
  }

  for col in range(10) {
    content((col + 0.5, -0.35), text(size: 7pt, "abcdefghij".at(col)))
  }
  for row in range(10) {
    content((-0.35, row + 0.5), text(size: 7pt, str(row + 1)))
  }
})

#set text(8pt)
#box(
  fill: blue.lighten(97%),
  radius: 2mm,
  inset: (x: 4mm, y: 3mm),
  grid(
    columns: 2,
    column-gutter: 8mm,
    row-gutter: 2mm,
    align: center,
    board(start), board(midgame, arrow: ((0, 5), (0, 4))),
    [(a) Starting position, seen by Red], [(b) Blue attacks a4],
  ),
)
