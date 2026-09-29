// HTML-oriented companion for @preview/equate.
// Portions of the line parsing and reference logic are adapted from equate
// 0.3.3, Copyright (c) 2024-2026 Eric Biedert, MIT licensed.

#let sequence = $a b$.body.func()
#let equate-state = state("equate/enabled", 0)
#let sub-numbering-state = state("equate/sub-numbering", false)
#let nested-state = state("equate/nested-depth", 0)
#let share-align-state = state("equate/share-align", (stack: (), max: 0))

#let equate-ref(it) = {
  if it.element == none { return it }
  if it.element.func() != figure { return it }
  if it.element.kind != math.equation { return it }
  if it.element.body == none { return it }
  if it.element.body.func() != metadata { return it }

  let nums = if sub-numbering-state.at(it.element.location()) {
    it.element.body.value
  } else {
    (it.element.body.value.first() + it.element.body.value.slice(1).sum(default: 1) - 1,)
  }

  assert(
    it.element.numbering != none,
    message: "cannot reference equation without numbering."
  )

  let num = numbering(
    if type(it.element.numbering) == str {
      let counting-symbols = (
        "1", "a", "A", "i", "I", "一", "壹", "あ", "い", "ア", "イ",
        "א", "가", "ㄱ", "*", "①", "⓵",
      )
      let prefix-end = it.element.numbering.codepoints().position(c => c in counting-symbols)
      let suffix-start = it.element.numbering.codepoints().rev().position(c => c in counting-symbols)
      it.element.numbering.slice(prefix-end, if suffix-start == 0 { none } else { -suffix-start })
    } else {
      it.element.numbering
    },
    ..nums
  )

  let supplement = if it.supplement == auto {
    it.element.supplement
  } else if type(it.supplement) == function {
    (it.supplement)(it.element)
  } else {
    it.supplement
  }

  link(it.element.location(), if supplement not in ([], none) [#supplement~#num] else [#num])
}

#let unpack-nested(eq) = {
  let unpack-single(child) = {
    if type(child) == content and child.func() == math.equation {
      unpack-nested(child).body
    } else {
      child
    }
  }

  if eq.body.func() == sequence {
    math.equation(eq.body.children.map(unpack-single).join())
  } else {
    math.equation(unpack-single(eq.body))
  }
}

#let trim-line(line) = {
  if line == () { return line }
  if line.first() == [ ] and line.last() == [ ] {
    line.slice(1, -1)
  } else if line.first() == [ ] {
    line.slice(1)
  } else if line.last() == [ ] {
    line.slice(0, -1)
  } else {
    line
  }
}

#let to-lines(equation) = {
  equation = unpack-nested(equation)

  let lines = if equation.body.func() == sequence {
    equation.body.children.split(linebreak())
  } else {
    ((equation.body,),)
  }

  lines.filter(line => line != ()).map(trim-line)
}

#let line-label(line) = {
  if line.len() == 0 { return none }
  let last = line.last()
  if type(last) != content { return none }
  if last.func() != raw { return none }
  if last.lang != "typc" { return none }
  if last.text.match(regex("^<.+>$")) == none { return none }
  last.text.slice(1, -1)
}

#let strip-label(line) = {
  if line-label(line) == none { return line }
  let out = line
  let _ = out.remove(-1)
  let _ = if out.at(-1, default: none) == [ ] { out.remove(-1) }
  out
}

#let label-indices(lines) = {
  lines
    .enumerate()
    .filter(((i, line)) => line-label(line) not in (none, "equate:revoke"))
    .map(((i, _)) => i)
}

#let revoked-indices(lines) = {
  lines
    .enumerate()
    .filter(((i, line)) => line-label(line) == "equate:revoke")
    .map(((i, _)) => i)
}

#let html-frame-math(body) = {
  html.frame({
    show math.equation: eq => eq
    math.equation(block: true, numbering: none, body)
  })
}

#let html-math-mode = sys.inputs.at("html-math", default: "svg")
#let math-data-attrs(body, display, katex: none) = {
  let body = if body == none { [] } else { body }
  let attrs = (
    "data-typst-math": repr(body),
    "data-math-display": display,
  )
  if katex != none {
    attrs.insert("data-katex", katex)
  }
  attrs
}

#let is-align-point(child) = {
  type(child) == content and repr(child) == "align-point()"
}

#let split-alignment(line) = {
  let parts = ()
  let current = ()

  for child in line {
    if is-align-point(child) {
      parts.push(trim-line(current))
      current = ()
    } else {
      current.push(child)
    }
  }

  parts.push(trim-line(current))
  parts
}

#let render-math-fragment(items) = {
  if items.len() > 0 {
    html-frame-math(items.join())
  }
}

#let render-equation-anchor(label-name, nums, numbering, supplement) = {
  if label-name == none or label-name == "equate:revoke" {
    return []
  }

  [
    #figure(
      metadata(nums),
      kind: math.equation,
      numbering: numbering,
      supplement: supplement,
    )#label(label-name)
  ]
}

#let render-equation-line(line, index, number: none, anchor: [], label-name: none, numbered: false, alignment-columns: 0) = {
  let has-alignment = line.any(is-align-point)
  let class = "equation-line" + if numbered { " is-numbered" } else { " is-unnumbered" } + if has-alignment { " has-alignment" } else { "" }
  let line-body = line.join()
  html.elem("div", attrs: (
    class: class,
    "data-line": str(index + 1),
    ..if label-name != none { ("data-label": label-name) } else { (:) },
    ..math-data-attrs(line-body, "block"),
  ))[
    #if alignment-columns > 0 {
      if has-alignment {
        let parts = split-alignment(line)
        // Each ampersand starts a new column. Typst alternates right and
        // left alignment; a third column commonly holds step justifications.
        // Keep empty cells so shorter rows do not shift the following row.
        for column in range(alignment-columns) {
          let part = parts.at(column, default: ())
          let legacy-class = if column == 0 { " equation-align-left" } else if column == 1 { " equation-align-right" } else { "" }
          html.elem("span", attrs: (
            class: "equation-align-cell" + legacy-class,
            "data-align-column": str(column),
            style: "grid-column: " + str(column + 2) + "; justify-self: " + if calc.even(column) { "end;" } else { "start;" },
            ..math-data-attrs(part.join(), "inline"),
          ))[
            #render-math-fragment(part)
          ]
        }
      } else {
        html.elem("span", attrs: (
          class: "equation-align-full",
          ..math-data-attrs(line-body, "inline"),
        ))[
          #render-math-fragment(line)
        ]
      }
    } else {
      html.elem("span", attrs: (
        class: "equation-math",
        ..math-data-attrs(line-body, "block"),
      ))[#html-frame-math(line-body)]
    }
    #if number != none {
      html.elem("span", attrs: (class: "eqno"))[#number]
    }
    #anchor
  ]
}

#let share-align(body) = {
  context assert(
    equate-state.get() > 0,
    message: "shared alignment block requires equate to be enabled."
  )

  share-align-state.update(((stack, max)) => (
    stack: stack + (max + 1,),
    max: max + 1,
  ))

  body

  share-align-state.update(((stack, max)) => (
    stack: stack.slice(0, -1),
    max: max,
  ))
}

#let equate(
  breakable: auto,
  sub-numbering: false,
  number-mode: "line",
  debug: false,
  body,
) = {
  assert(
    breakable == auto or type(breakable) == bool,
    message: "expected boolean or auto for breakable, found " + repr(breakable),
  )
  assert(
    type(sub-numbering) == bool,
    message: "expected boolean for sub-numbering, found " + repr(sub-numbering),
  )
  assert(
    number-mode in ("line", "label"),
    message: "expected \"line\" or \"label\" for number-mode, found " + repr(number-mode),
  )
  assert(
    type(debug) == bool,
    message: "expected boolean for debug, found " + repr(debug),
  )

  if type(body) == label {
    return {
      show ref: equate-ref
      ref(body)
    }
  } else if body.func() == ref {
    return {
      show ref: equate-ref
      body
    }
  }

  show math.equation.where(block: true): it => {
    if nested-state.get() > 0 {
      return it
    }

    if it.has("label") and it.label == <equate:revoke> {
      return it
    }

    show figure.where(kind: math.equation): it => {
      if it.body == none { return it }
      if it.body.func() != metadata { return it }
      html.elem("span", attrs: (class: "equation-anchor", hidden: ""))[]
    }

    let has-numbering = it.numbering != none and numbering(it.numbering, 1) != none
    let main-number = counter(math.equation).get().first()
    let main-counter = counter(math.equation).get()
    let lines = to-lines(it)
    let labelled = label-indices(lines)
    let revoked = revoked-indices(lines)
    let numbered = if not has-numbering {
      ()
    } else if number-mode == "line" {
      range(lines.len()).filter(i => i not in revoked)
    } else if labelled.len() == 0 and it.has("label") {
      range(lines.len()).filter(i => i not in revoked)
    } else {
      labelled
    }

    let has-alignment = lines.any(line => strip-label(line).any(is-align-point))
    let alignment-columns = if has-alignment {
      calc.max(..lines.map(line => split-alignment(strip-label(line)).len()))
    } else { 0 }
    let class = "equation" + if lines.len() > 1 { " equation-multiline" } else { "" } + if has-alignment { " equation-aligned" } else { "" }

    sub-numbering-state.update(_ => sub-numbering)

    html.elem("figure", attrs: (
      class: class,
      role: "math",
      ..if has-alignment { (style:
        "--equation-alignment-columns: " + str(alignment-columns) + "; --equation-number-column: " + str(alignment-columns + 3) + ";",
      ) } else { (:) },
    ))[
      #for (i, line) in lines.enumerate() {
        let sub-number = numbered.position(n => n == i)
        let label-name = line-label(line)
        let line = strip-label(line)
        let number = if sub-number == none {
          none
        } else if sub-numbering {
          numbering(it.numbering, main-number, sub-number + 1)
        } else {
          numbering(it.numbering, main-number + sub-number)
        }
        let nums = if sub-number == none {
          main-counter
        } else {
          main-counter + (sub-number + 1,)
        }
        let anchor = render-equation-anchor(label-name, nums, it.numbering, it.supplement)
        render-equation-line(
          line,
          i,
          number: number,
          anchor: anchor,
          label-name: if label-name != none { label-name } else if i == 0 and it.has("label") { str(it.label) } else { none },
          numbered: sub-number != none,
          alignment-columns: alignment-columns,
        )
      }
    ]

    if has-numbering {
      if numbered.len() == 0 {
        counter(math.equation).update(n => n - 1)
      } else if not sub-numbering and numbered.len() > 1 {
        counter(math.equation).update(n => n + numbered.len() - 1)
      }
    }
  }

  show math.equation.where(block: true): it => {
    set math.equation(numbering: none)
    nested-state.update(n => n + 1)
    it
    nested-state.update(n => n - 1)
  }

  show ref: equate-ref

  equate-state.update(n => n + 1)
  body
  equate-state.update(n => n - 1)
}
