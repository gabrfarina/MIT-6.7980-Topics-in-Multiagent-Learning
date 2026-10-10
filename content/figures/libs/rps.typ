// Rock-paper-scissors timelines comparing played actions with a comparator.
#import "../../meta/typography.typ": course-sans-font

// Colors and proportions follow the Lecture 4 slides.
#let ink = rgb("#171411")
#let label-color = rgb("#39434d")
#let time-color = rgb("#6b635b")
#let unchanged-color = rgb("#68727a")
#let unchanged-arrow-color = rgb("#aab1b7")
#let comparator-color = rgb("#325d8a")
#let comparator-fill = rgb("#e9f1f9")
#let icon-size = 20pt
#let label-width = 72pt
#let time-width = 40pt
// One unit of the slides' 56-unit icon box.
#let unit = icon-size / 56

#let sans(body, ..args) = text(font: course-sans-font, weight: "bold", ..args, body)

// The slide icons are drawn in the played colors; recolor them on load.
#let icon(action, fill: white, stroke: label-color) = {
  let svg = read("icons/" + action + ".svg")
    .replace("fill=\"#fff\"", "fill=\"" + fill.to-hex() + "\"")
    .replace("stroke=\"#39434d\"", "stroke=\"" + stroke.to-hex() + "\"")
  image(bytes(svg), height: icon-size)
}

#let action-names = ("rock", "paper", "scissors")
#let actions = action-names.map(action => (action, icon(action))).to-dict()
// Comparator actions changed by the deviation.
#let changed-actions = action-names.map(action => (
  action,
  icon(action, fill: comparator-fill, stroke: comparator-color),
)).to-dict()

#let arrow(color) = curve(
  stroke: (paint: color, thickness: 2 * unit, cap: "round", join: "round"),
  curve.move((5 * unit, 0pt)),
  curve.line((5 * unit, 16 * unit)),
  curve.move((0pt, 11 * unit)),
  curve.line((5 * unit, 16 * unit)),
  curve.line((10 * unit, 11 * unit)),
)

#let more(color) = text(fill: color, $dots.c$)

// `played` lists action names; `comparator` lists (action, changed) pairs.
// An action of `none` marks a trailing column that continues the sequence.
#let rps-figure(subtitle, played, comparator, formula) = {
  let rounds = played.len()
  let comparator-cell((action, changed)) = {
    let color = if changed { comparator-color } else { unchanged-color }
    if action == none { return more(color) }
    let label = if changed { sans(fill: color, size: 7.5pt, action) } else {
      text(font: course-sans-font, fill: color, size: 7.5pt, action)
    }
    stack(
      spacing: 3pt,
      (if changed { changed-actions } else { actions }).at(action),
      label,
    )
  }

  grid(
    columns: (label-width,) + (time-width,) * rounds,
    align: (left + horizon,) + (center + horizon,) * rounds,
    row-gutter: 7pt,
    grid.cell(colspan: rounds + 1, inset: (bottom: 4pt), subtitle),
    [], ..range(1, rounds + 1).map(t => text(fill: time-color, size: 8pt, $t = #t$)),
    sans(fill: label-color)[Actually played],
    ..played.map(action => if action == none { more(unchanged-color) } else { actions.at(action) }),
    [],
    ..comparator.map(((_, changed)) => arrow(
      if changed { comparator-color } else { unchanged-arrow-color },
    )),
    sans(fill: label-color)[Comparator], ..comparator.map(comparator-cell),
  )

  v(8pt)
  align(center, rect(stroke: 0.6pt + ink, inset: 6pt, text(size: 10pt, formula)))
}
