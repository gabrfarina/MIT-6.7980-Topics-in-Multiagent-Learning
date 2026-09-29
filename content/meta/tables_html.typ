// Native HTML preserves table structure but omits column and cell styling.
// Style its td/th elements after Typst has resolved table defaults, functions,
// column arrays, and cell overrides; do not reconstruct the table's children.
#let css-table-length(value) = {
  let value = 0% + value
  let ratio = str(value.ratio / 1%) + "%"
  let length = str(value.length.to-absolute().pt()) + "pt"
  // Typst formats negative numbers with U+2212; CSS requires an ASCII minus.
  let css = if value.ratio == 0% { length } else if value.length == 0pt { ratio } else { "calc(" + ratio + " + " + length + ")" }
  css.replace("−", "-")
}

#let style-table-cell(it) = context {
  if "data-table-cell" in it.attrs or it.body == none or it.body.func() != table.cell {
    return it
  }

  let border(value) = {
    if value == none { return "none" }
    let value = stroke(value)
    let width = if value.thickness == auto { 1pt } else { value.thickness }
    let paint = if value.paint == auto { black } else { value.paint }
    let pattern = if value.dash == auto or value.dash == none or value.dash.array.len() == 0 {
      "solid"
    } else if value.dash.array.first() == "dot" {
      "dotted"
    } else { "dashed" }
    // CSS borders support solid colors and the standard dash families.
    let color = if type(paint) == color { rgb(paint).to-hex() } else { "currentColor" }
    str(width.to-absolute().pt()) + "pt " + pattern + " " + color
  }

  let strokes = it.body.stroke
  let css = ("top", "right", "bottom", "left").map(side => {
    let value = if type(strokes) == dictionary { strokes.at(side) } else { strokes }
    "border-" + side + ": " + border(value) + ";"
  }).join(" ")
  let alignment = it.body.align
  let outer = align.alignment
  let x = if alignment == auto or alignment.x == none { outer.x } else { alignment.x }
  let y = if alignment == auto or alignment.y == none { outer.y } else { alignment.y }
  css += " text-align: " + repr(x) + "; vertical-align: " + if y == horizon { "middle" } else { repr(y) } + ";"
  let fill = it.body.fill
  css += " background: " + if type(fill) == color {
    rgb(fill).to-hex()
  } else if type(fill) == gradient and fill.kind() == gradient.linear {
    let stops = fill.stops().map(((paint, offset)) => rgb(paint).to-hex() + " " + repr(offset)).join(", ")
    "linear-gradient(" + repr(fill.angle() + 90deg).replace("−", "-") + ", " + stops + ")"
  } else { "transparent" } + ";"
  let previous = it.attrs.at("style", default: "")
  html.elem(it.tag, attrs: (
    ..it.attrs,
    "data-table-cell": "",
    style: (if previous == "" { "" } else { previous + "; " }) + css,
  ), it.body)
}

// A table-scoped rule adds colgroup to the native table. Nested Typst tables
// install their own rule; raw HTML tables (without native cells) are untouched.
#let has-native-table-cell(body) = {
  if body == none { false }
  else if body.func() == table.cell { true }
  else if body.func() == table or (body.func() == html.elem and body.tag == "table") { false }
  else if body.has("children") { body.children.any(has-native-table-cell) }
  else if body.has("body") { has-native-table-cell(body.body) }
  else { false }
}

#let render-html-table(it) = context {
  let columns = it.columns
  // Typst treats an empty column list as a single auto column.
  if columns.len() == 0 { columns = (auto,) }
  let fixed = columns.filter(c => c != auto and type(c) != fraction)
  let total = fixed.fold(0% + 0pt, (sum, c) => sum + c)
  let fractions = columns.filter(c => type(c) == fraction).fold(0fr, (sum, c) => sum + c)
  let has-auto = auto in columns
  let layout = if has-auto { "auto" } else { "fixed" }
  let fills-width = fractions > 0fr or (has-auto and total.ratio != 0%)
  let width = if fills-width { "100%" } else if has-auto { "auto" } else { css-table-length(total) }
  let column-width(c) = {
    if c == auto { return "auto" }
    if type(c) == fraction {
      if fractions == 0fr { return "0pt" }
      return css-table-length((100% - total) * (c / fractions))
    }
    // CSS column percentages refer to the table, whereas Typst percentages
    // refer to the containing block. Normalize when the table itself is sized
    // to the sum of its explicit tracks (e.g. two 25% columns make a 50% table).
    if not fills-width and not has-auto and total.ratio != 0% {
      let part = c.ratio / total.ratio
      return css-table-length(part * 100% + c.length - part * total.length)
    }
    css-table-length(c)
  }
  let x = align.alignment.x
  let margins = if x == center {
    "margin-inline: auto;"
  } else if x == right {
    "margin-left: auto; margin-right: 0;"
  } else if x == left {
    "margin-left: 0; margin-right: auto;"
  } else if x == end {
    "margin-inline-start: auto; margin-inline-end: 0;"
  } else { "margin-inline-start: 0; margin-inline-end: auto;" }
  show html.elem.where(tag: "table"): node => {
    if "data-table-columns" in node.attrs or not has-native-table-cell(node.body) { return node }
    let cols = columns.map(c => {
      let dimensions = if c == auto {
        ("data-table-track": "auto")
      } else if type(c) == fraction {
        ("data-table-track": "fraction", "data-table-fraction": str(c / 1fr))
      } else {
        (
          "data-table-track": "relative",
          "data-table-ratio": str(c.ratio / 100%).replace("−", "-"),
          "data-table-pt": str(c.length.to-absolute().pt()).replace("−", "-"),
        )
      }
      let width = column-width(c)
      html.elem("col", attrs: (..dimensions, "data-table-width": width, style: "width: " + width + ";"))
    }).join()
    let previous = node.attrs.at("style", default: "")
    html.elem(node.tag, attrs: (
      ..node.attrs,
      "data-table-columns": "",
      style: previous + "; table-layout: " + layout + "; width: " + width + "; " + margins,
    ), html.elem("colgroup", cols) + node.body)
  }
  html.elem("div", attrs: (class: "lecture-table"))[#it]
}
