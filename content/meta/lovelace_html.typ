// HTML renderer for the course's Lovelace pseudocode. Share the line data
// constructors with the paged library, but never invoke its grid renderer.
#import "lovelace.typ": normalize-line, indent, no-number, with-line-label, line-label, identify-algorithm

#let _html-pseudo-is-not-empty(it) = {
  (
    type(it) != content
      or not (
        it.fields() == (:)
          or (it.has("children") and it.children == ())
          or (
            it.has("children") and it.children.all(c => not _html-pseudo-is-not-empty(c))
          )
          or (it.has("text") and it.text.match(regex("^\\s*$")) != none)
      )
  )
}

#let _html-pseudo-unwrap-singleton(a) = {
  while type(a) == array and a.len() == 1 {
    a = a.first()
  }
  a
}

#let _html-pseudo-transform-list(it, numbered) = {
  if not it.has("children") {
    if numbered {
      return (it,)
    } else {
      return (no-number(it),)
    }
  }

  let transformed = ()
  let non-item-child = []
  let non-item-label = none
  let items = ()

  for child in it.children {
    let f = child.func()
    if f in (enum.item, list.item) {
      items += _html-pseudo-transform-list(child.body, f == enum.item)
    } else if (
      child.func() == metadata
        and child.value.at(
          "identifier",
          default: "",
        )
          == "lovelace line label"
        and "label" in child.value
    ) {
      non-item-label = child.value.label
    } else {
      non-item-child += child
    }
  }

  if _html-pseudo-is-not-empty(non-item-child) {
    if numbered {
      transformed.push(with-line-label(non-item-label, non-item-child))
    } else {
      transformed.push(no-number(non-item-child))
    }
  }
  if items.len() > 0 {
    transformed.push(indent(..items))
  }
  transformed
}

#let _html-pseudo-number-lines(children, next-number: 1) = {
  let numbered = ()
  for child in children {
    if type(child) == dictionary {
      if child.numbered {
        child.insert("number", next-number)
        next-number += 1
      }
    } else if type(child) == array {
      let nested = _html-pseudo-number-lines(child, next-number: next-number)
      child = nested.children
      next-number = nested.next-number
    }
    numbered.push(child)
  }
  (children: numbered, next-number: next-number)
}

#let _html-pseudo-render-lines(children, level: 0, closing-guides: (), line-numbering: "1") = {
  for idx in range(children.len()) {
    let child = children.at(idx)
    let is-last = idx == children.len() - 1
    if type(child) == dictionary {
      let end-guides = ()
      if is-last {
        end-guides = closing-guides
        if level > 0 {
          end-guides.push(level)
        }
      }
      html.elem("div", attrs: (
        class: "pseudo-line",
        style: "--indent:" + str(level),
      ), {
        // Code-mode content avoids whitespace spans becoming extra grid items.
        for i in range(level) {
          let guide = i + 1
          let class = "pseudo-guide"
          if guide in end-guides {
            class += " pseudo-guide-end"
          }
          html.elem("span", attrs: (
            class: class,
            style: "--guide:" + str(guide),
            "aria-hidden": "true",
          ))[]
        }
        // Keep the gutter outside the indented body, including wrapped lines.
        if line-numbering != none and child.numbered {
          html.elem("span", attrs: (class: "pseudo-number"))[
            #numbering(line-numbering, child.number)
          ]
        }
        html.elem("div", attrs: (class: "pseudo-text"), child.body)
      })
    } else if type(child) == array {
      let child-closing-guides = ()
      if is-last {
        child-closing-guides = closing-guides
        if level > 0 {
          child-closing-guides.push(level)
        }
      }
      _html-pseudo-render-lines(
        child,
        level: level + 1,
        closing-guides: child-closing-guides,
        line-numbering: line-numbering,
      )
    }
  }
}

// Both entry points use native HTML. Visual spacing is owned by notes.css;
// the booktabs appearance follows the course's algorithm style. As in the
// paged renderer, callers attach labels and captions to the pseudocode call.
#let pseudocode(caption: none, ..children) = {
  let named = children.named()
  let title = named.at("title", default: none)
  let numbered-title = named.at("numbered-title", default: none)
  if numbered-title != none {
    title = if numbered-title == [] {
      strong(identify-algorithm)
    } else {
      [*#identify-algorithm:* #numbered-title]
    }
  }
  let line-numbering = named.at("line-numbering", default: "1.")
  let transformed = _html-pseudo-number-lines(children.pos().map(normalize-line)).children

  figure(
    kind: "algorithm",
    supplement: [Algorithm],
    caption: caption,
    html.elem("section", attrs: (class: "env algorithm"))[
      #if title != none {
        html.elem("div", attrs: (class: "env-title"))[#title]
      }
      #html.elem("div", attrs: (
        class: "pseudocode" + if line-numbering == none { " pseudo-unnumbered" } else { "" },
      ))[
        #_html-pseudo-render-lines(transformed, line-numbering: line-numbering)
      ]
    ],
  )
}

#let pseudocode-list(..config, body) = {
  let transformed = _html-pseudo-unwrap-singleton(_html-pseudo-transform-list(body, false))
  if type(transformed) != array {
    transformed = (transformed,)
  }
  pseudocode(..config.named(), ..transformed)
}
