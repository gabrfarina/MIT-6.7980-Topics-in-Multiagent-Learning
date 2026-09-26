// HTML components selected explicitly by the exporter.
#assert(not ("web" in sys.inputs or "combined" in sys.inputs or "html" in sys.inputs),
  message: "Legacy web/combined/html inputs are unsupported. The exporter selects the HTML target explicitly.")
#import "linalg.typ": *
#import "lovelace_html.typ": *
#import "equate_html.typ": equate, share-align
#import "tables_html.typ": style-table-cell, render-html-table

#import "citations.typ": *
#import "notation.typ": *
#import "notation.typ": html-cal as cal, html-bb as bb, html-bold as bold, html-sans as sans
#import "notation.typ": html-italic as italic, html-upright as upright, html-argmin as argmin, html-argmax as argmax
#import "notation.typ": html-P as P, html-PPAD as PPAD, html-NP as NP, html-coNP as coNP
#import "notation.typ": html-span as span, html-colspan as colspan, html-div as div, html-divt as divt
#import "notation.typ": html-matA as matA, html-matI as matI, html-matK as matK, html-matM as matM
#import "notation.typ": html-matU as matU, html-va as va, html-vb as vb, html-vc as vc
#import "notation.typ": html-vp as vp, html-vq as vq, html-vs as vs, html-vu as vu
#import "notation.typ": html-vx as vx, html-vy as vy, html-vz as vz, html-cA as cA
#import "notation.typ": html-cC as cC, html-cH as cH, html-cK as cK, html-cS as cS
#import "notation.typ": html-cU as cU, html-cX as cX, html-cY as cY, html-cG as cG
#import "notation.typ": html-vg as vg, html-vm as vm, html-vr as vr, html-cR as cR
#import "notation.typ": html-ve as ve, html-vf as vf, html-vh as vh, html-vv as vv, html-vw as vw
#import "notation.typ": html-vell as vell, html-vxi as vxi, html-vtheta as vtheta, html-vphi as vphi
#import "notation.typ": html-vmu as vmu, html-vnu as vnu, html-vlambda as vlambda, html-vrho as vrho
#import "notation.typ": html-vpi as vpi
#import "notation.typ": html-vU as vU, html-vV as vV, html-vW as vW, html-vone as vone
#import "notation.typ": html-vA as vA, html-vR as vR
#import "notation.typ": html-xhat as xhat, html-yhat as yhat, html-mU as mU, html-upsans as upsans
#import "markers.typ": paragraph-marker
#import "lecture-links.typ": lecture-link, lecture-title
#import "typography.typ": course-sans-font

#let thmcounters = state("thmcounters", (:))

// Render only graphical content to SVG. Disable HTML show rules while laying
// out that SVG, so HTML elements cannot disappear inside a paged frame.
#let _html-media-frame(body) = html.frame({
  show math.equation: it => it
  show align: it => it
  show image: it => it
  show figure: it => it
  body
})

#let bpar(body) = {
  [#paragraph-marker() #strong(body + ".")~~]
}
#let lecture-bib = state("lecture-bib", (:))
#let lecnum = state("lecnum", none)
#let citation-keys() = lecture-bib.final().at(str(lecnum.get()), default: ())
#let html-footnote-counter = counter("html-footnote")
#let html-footnote-id-counter = counter("html-footnote-id")
#let html-heading-tag(level) = ("h1", "h2", "h3", "h4", "h5", "h6").at(calc.min(level - 1, 5))
#let html-text(value) = {
  if value == none {
    ""
  } else if type(value) == str {
    value
  } else if type(value) == array {
    value.map(html-text).join("")
  } else if type(value) == content {
    if value.func() in (linebreak, parbreak, [ ].func()) {
      " "
    } else if value.has("text") {
      html-text(value.text)
    } else if value.has("children") {
      value.children.map(html-text).join("")
    } else if value.has("body") {
      html-text(value.body)
    } else if value.has("child") {
      html-text(value.child)
    } else {
      ""
    }
  } else {
    str(value)
  }
}
#let html-math-mode = sys.inputs.at("html-math", default: "svg")
#let lecture-number-label(value) = if str(value).starts-with("S") { str(value) } else { "L" + str(value) }
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

#let footnote(body, numbering: auto) = {
  // Unconditional steps let all callsites stabilize in one layout pass. A
  // contextual get()+update() makes each note depend on the previous pass.
  html-footnote-counter.step()
  html-footnote-id-counter.step()
  context {
    let number = html-footnote-counter.get().first()
    let label = if numbering == none {
      []
    } else if type(numbering) == function {
      numbering(number)
    } else {
      str(number)
    }
    // Keep IDs unique if several lectures are compiled together; display numbers
    // still restart in each lecture.
    let id-number = html-footnote-id-counter.get().first()
    let id = "html-fn-" + str(id-number)
    html.elem("a", attrs: (
      id: "html-fnref-" + str(id-number),
      href: "#" + id,
      role: "doc-noteref",
    ))[#html.elem("sup")[#label]]
    // A template is not phrasing content: putting it here splits the enclosing
    // paragraph. Metadata keeps the reference inline until the lecture footer
    // renders the note body with the same math and citation show rules.
    [#metadata((
      id: id,
      note-label: html-text(label),
      body: body,
    ))<notes-html-footnote>]
  }
}

#let lecture_outline = lec_num => {
  locate(loc => {
    for elem in query(heading, loc) {
      if elem.at("numbering") != none {
        let numbering-fn = elem.at("numbering")
        let numbers = counter(heading).at(elem.location())
        let numbering = numbering(numbering-fn, ..numbers)
        let space = "    " * (numbers.len() - 1)
        if numbering.starts-with(lecture-number-label(lec_num) + ".") {
          (
            [#link(elem.location(), space + numbering + "   " + elem.body) #box(
                width: 1fr,
                repeat[~.~],
              )#h(3mm)#box[#align(right)[#elem.location().page()]]]
              + linebreak()
          )
        }
      }
    }
  })
}

#let gabri_notes(
  body,
  lec_num: none,
  date: none,
  title: none,
  extrathanks: none,
  instructor: none,
) = {
  set document(title: lecture-title(lec_num, title))
  lecture-bib.update(it => { it.insert(str(lec_num), ()); it })
  html-footnote-counter.update(0)
  counter(heading).update(0)
  counter(math.equation).update(0)
  for kind in ("shared", "algorithm", image, table) {
    counter(figure.where(kind: kind)).update(0)
  }
  set text(font: "Georgia", size: 9.5pt)
  set par(justify: true)
  set list(indent: 4.05mm)
  set enum(indent: 4.05mm)
  set figure(numbering: n => lecture-number-label(lec_num) + "." + str(n))
  set math.equation(numbering: "(1)")
  show: equate.with(breakable: true, sub-numbering: false, number-mode: "label")
  show figure.caption: body => context [
    #html.elem("span", attrs: (class: "figcaption-label"))[
      #body.supplement #numbering(body.numbering, ..body.counter.get()).
    ]
    #body.body
  ]
  set cite(style: "alphanum.csl")
  set math.equation(supplement: none)
  show cite: set text(fill: blue.darken(40%))
  show strong: set text(font: course-sans-font, weight: "bold")
  show heading: it => {
    let tag = html-heading-tag(it.level)
    // Export authored safe labels even without a reference in this document.
    // Other lectures can then link here without depending on heading numbers.
    let anchor = if it.has("label") and str(it.label).match(regex("^[a-zA-Z][a-zA-Z0-9_-]*$")) != none {
      (id: str(it.label))
    } else { (:) }
    let permalink = if it.has("label") { ("data-label": str(it.label)) } else { (:) }
    if it.numbering != none {
      let number = html-text(counter(heading).display())
      html.elem(tag, attrs: (
        class: "notes-heading",
        "data-level": str(it.level),
        "data-number": number,
        ..anchor,
        ..permalink,
      ))[
        #html.elem("span", attrs: (class: "secno"))[#(number + " ")]#it.body
      ]
    } else {
      html.elem(tag, attrs: (
        class: "notes-heading notes-heading-unnumbered",
        "data-level": str(it.level),
        ..anchor,
        ..permalink,
      ))[
        #it.body
      ]
    }
  }
  show "https://doi.org/": text(10pt, `https://doi.org/`)
  show link: it => {
    if (
      it.body.func() != raw
        and it.body.has("text")
        and (
          it.body.text.starts-with("http://")
            or it.body.text.starts-with("https://")
            or it.body.text.match(regex("^10.\d{4,9}/[-._;()/:a-zA-Z0-9]+$")) != none
        )
    ) {
      link(it.dest, text(10pt, raw(it.body.text)))
    } else {
      it
    }
  }
  show regex("arXiv:\d{4}[.]\d{4,5}(v\d+)?"): it => {
    let id = it.text.replace("arXiv:", "")
    link("https://arxiv.org/abs/" + id, it)
  }
  show "i.e.": emph
  show "e.g.": emph
  set heading(
    numbering: (..nums) => {
      lecture-number-label(lec_num) + "." + nums.pos().map(str).join(".")
    },
  )

  let ref-label(supplement, number) = {
    // A suppressed label must not leave a leading separator in the link.
    if supplement not in (none, [], "", text("")) { [#supplement~] }
    number
  }

  show ref: it => {
    if (
      it.element != none
        and it.element.has("kind")
        and it.element.kind
          in (
            "shared",
            "theorem",
            "proposition",
            "corollary",
            "definition",
            "example",
            "remark",
            "lemma",
          )
    ) {
      let counters = thmcounters.at(it.element.location())
      let target-lecture = counters.at("lecture")
      let supplement = if it.supplement == auto {
        it.element.supplement
      } else {
        it.supplement
      }
      let number = lecture-number-label(target-lecture) + "." + str(counters.at(it.element.kind, default: 0) + 1)
      link(
        it.element.location(),
      )[#ref-label(supplement, number)]
    } else if (
      it.element != none and it.element.func() == heading and it.element.at("numbering", default: none) != none
    ) {
      let numbering-fn = it.element.at("numbering")
      let numbers = counter(heading).at(it.element.location())
      let number = str(numbering(numbering-fn, ..numbers))
      let supplement = if it.supplement == auto {
        [Section]
      } else {
        it.supplement
      }
      link(it.element.location())[#ref-label(supplement, number)]
    } else {
      it
    }
  }
  show figure.where(kind: "theorem"): set block(breakable: true)
  show figure.where(kind: "proposition"): set block(breakable: true)
  show figure.where(kind: "corollary"): set block(breakable: true)
  show figure.where(kind: "definition"): set block(breakable: true)
  show figure.where(kind: "example"): set block(breakable: true)
  show figure.where(kind: "remark"): set block(breakable: true)
  show figure.where(kind: "lemma"): set block(breakable: true)
  show "TODO": highlight
  show "XXX": highlight
  thmcounters.update((lecture: lec_num))

  lecnum.update(str(lec_num))
  [#metadata((lec_num, title)) <lecture>]
  html.elem("div", attrs: (
    class: "notes-meta",
    hidden: "",
    "data-lecture-number": html-text(lec_num),
    "data-title": html-text(title),
  ))[]

  show math.equation.where(block: false): it => {
    html.elem(
      "span",
      attrs: (
        role: "math",
        ..math-data-attrs(it.body, "inline"),
      ),
      html.frame({
        show math.equation: eq => eq
        it
      }),
    )
  }

  // `align` is unsupported by native HTML export and otherwise drops its body.
  show align: it => html.elem("div", attrs: (
    class: "media-alignment",
    style: "text-align: " + if repr(it.alignment).contains("right") { "right" } else if repr(it.alignment).contains("center") { "center" } else { "left" } + ";",
  ))[#{
    set align(it.alignment)
    it.body
  }]
  show image: it => context if target() == "paged" {
    it
  } else {
    // Image widths are relative lengths even when the ratio is zero (e.g. 6cm).
    // Fixed-width images already produce a tight frame without a reference canvas.
    let proportional = it.width != auto and it.width.ratio != 0%
    let visual = it
    let css-width = ""
    if proportional {
      // An unconstrained SVG frame gives percentage-sized images zero width.
      // Resolve a vector canvas first; CSS applies the original proportion.
      let width = it.width.ratio * 585pt + it.width.length
      // Anchor the artwork before trimming the reference canvas. Otherwise a
      // figure's inherited center alignment shifts it outside the SVG viewBox.
      // Keeping the original image preserves its resolved path and alt text.
      visual = pad(right: width - 585pt, box(width: 585pt, {
        set align(left)
        it
      }))
      // Match html.frame's font-relative sizing for the absolute component.
      let ems = it.width.length.to-absolute() / (1em).to-absolute()
      css-width = "width: calc(" + repr(it.width.ratio) + " + " + str(ems) + "em);"
    }
    html.elem("span", attrs: (
      class: "lecture-image",
      role: "img",
      "aria-label": if it.alt != none { it.alt } else { "Lecture illustration" },
      "data-image-source": repr(it.source),
      style: css-width,
    ))[#_html-media-frame(visual)]
  }

  let render-caption(caption) = if caption != none {
    html.elem("figcaption")[#caption]
  }
  show table: render-html-table
  show html.elem.where(tag: "td"): style-table-cell
  show html.elem.where(tag: "th"): style-table-cell
  // Images and equations have their own SVG renderers. Keep their containing
  // figure in the DOM, including tables, captions, and algorithm links.
  let render-figure-body(body, kind: none) = body

  // Proofs are native HTML sections rather than numbered figures. Preserve
  // their authored labels even when nothing references them in the document.
  show html.elem.where(tag: "section"): it => {
    if it.attrs.at("class", default: "").split().contains("proof") and it.has("label") and not "data-label" in it.attrs {
      html.elem(it.tag, attrs: (..it.attrs, "data-label": str(it.label)), it.body)
    } else { it }
  }

  // for styling, use `where` to assign classes for different types of figure
  show figure: it => {
    // Preserve authored labels even when Typst has no reference that would
    // cause it to emit an ID. The exporter also keeps every native link target.
    let permalink = if it.has("label") { ("data-label": str(it.label)) } else { (:) }
    if it.kind == math.equation and it.body != none and it.body.func() == metadata {
      html.elem("span", attrs: (class: "equation-anchor", hidden: ""))[]
    } else if it.kind == "shared" {
      html.elem("section", attrs: (class: "env statement", ..permalink), it.body)
    } else {
      let kind = if it.kind == "algorithm" { "algorithm" } else if it.kind == table { "table" } else { "figure" }
      let number = if it.numbering != none { html-text(numbering(it.numbering, ..it.counter.get())) } else { "" }
      html.elem("figure", attrs: (
        class: "typst",
        "data-figure-kind": kind,
        "data-figure-number": number,
        ..permalink,
      ))[
        #html.elem("div", attrs: (class: "figure-body"))[
          #render-figure-body(it.body, kind: it.kind)
        ]
        #render-caption(it.caption)
      ]
    }
  }

  context {
    if instructor != none or date != none {
      html.elem("div", attrs: (class: "lecture-metadata"))[
        #if instructor != none {
          html.elem("div", attrs: (class: "lecture-metadata-item"))[
            #html.elem("span", attrs: (class: "lecture-metadata-label"))[Instructor]
            #html.elem("p", attrs: (class: "lecture-instructor"))[#instructor]
          ]
        }
        #if date != none {
          html.elem("div", attrs: (class: "lecture-metadata-item"))[
            #html.elem("span", attrs: (class: "lecture-metadata-label"))[#if str(lec_num).starts-with("S") { [Edition] } else { [Lecture date] }]
            #html.elem("p", attrs: (class: "lecture-date"))[#date]
          ]
        }
      ]
    }
    if extrathanks != none {
      html.elem("aside", attrs: (class: "lecture-acknowledgments"))[#extrathanks]
    }
  }
  context {
    let scope = here()
    set bibliography(target: selector(cite).within(scope), group: none)
    body
    context {
      for entry in query(selector(<notes-html-footnote>).after(scope).before(here())) {
        let note = entry.value
        html.elem("template", attrs: (
          class: "notes-html-footnote-body",
          id: note.id,
          "data-note-label": note.note-label,
        ))[#note.body]
      }
    }
  }
}

#let citation_register(key) = {
  let number = str(lecnum.get())
  lecture-bib.update(it => {
    let keys = it.at(number, default: ())
    if key not in keys {
      keys.push(key)
    }
    it.insert(number, keys)
    it
  })
}

#let citation-noted = state("citation-noted", (:))

// HTML supplies its own citation key in the table column and margin note.
// Omit the CSL bibliography key when rendering the entry itself.
#let full-citation-style = bytes(read("alphanum.csl").replace(
  regex("<text display=\"left-margin\"[^>]*variable=\"citation-label\"/>"), "",
))

#let full-citation(key, full-doi: false) = {
  // Citation links are supplied by citation_link; full entries need only their
  // external URLs, not native backlinks to the hidden bibliography.
  show link: it => {
    if type(it.dest) != str {
      html.span(it.body)
    } else if full-doi and it.dest.match(regex("^https?://(dx\.)?doi\.org/")) != none {
      html.elem("a", attrs: (
        class: "bibliography-link bibliography-link-doi",
        href: it.dest,
        title: it.dest,
      ))[#raw(it.dest)]
    } else if (
      it.body.func() != raw
        and it.body.has("text")
        and (
          it.body.text.starts-with("http://")
            or it.body.text.starts-with("https://")
            or it.body.text == "DOI"
            or it.body.text.match(regex("^10.\d{4,9}/[-._;()/:a-zA-Z0-9]+$")) != none
        )
    ) {
      html.elem("a", attrs: (class: "bibliography-link", href: it.dest, title: it.dest))[link]
    } else {
      it
    }
  }
  cite(key, form: "full", style: full-citation-style)
}

#let citation_note(key) = context {
  let key_name = citation_key_name(key)
  let number = str(lecnum.get())
  let noted = citation-noted.get().at(number, default: ())
  if key_name in noted {
    []
  } else {
    citation-noted.update(it => {
      let keys = it.at(number, default: ())
      keys.push(key_name)
      it.insert(number, keys)
      it
    })
    let cite_label = citation_label_text(key, cited_keys: citation-keys())
    let cite_open = html.elem("span", attrs: (class: "citation-note-bracket"))[#text("[")]
    let cite_key = html.elem("span", attrs: (class: "citation-note-key cite_key"))[#cite_label]
    let cite_close = html.elem("span", attrs: (class: "citation-note-bracket"))[#text("]")]
    let cite_authors = html.elem("span", attrs: (class: "citation-note-authors cite-authors", hidden: ""))[
      #citation_author_text(key)
    ]
    html.elem("span", attrs: (class: "citation-note"))[
      #cite_open#cite_key#cite_close#cite_authors
      #full-citation(key)
    ]
  }
}

#let citation_link(key, body) = {
  let link = html.elem("a", attrs: (
    class: "citation",
    href: "#" + citation_html_id(key),
    role: "doc-biblioref",
  ))[#body]
  html.elem("span", attrs: (class: "citation-wrap"))[
    #link#citation_note(key)
  ]
}

#let citep(..keys) = context {
  let keys = keys.pos()
  let supplement = if keys.len() > 0 and type(keys.last()) == content { keys.pop() } else { none }
  for key in keys {
    citation_register(key)
  }
  [\[]
  for (i, key) in keys.enumerate() {
    if i > 0 {
      [; ]
    }
    citation_link(key, text(fill: blue.darken(40%), citation_label_text(key, cited_keys: citation-keys())))
  }
  if supplement != none { [, #supplement] }
  [\]]
}

#let citet(key, ..supplement) = context {
  citation_register(key)
  let author_part = html.elem("span", attrs: (class: "citation-author cite-authors"))[
    #citation_author_text(key)
  ]
  let label = text(fill: blue.darken(40%), citation_label_text(key, cited_keys: citation-keys(), ..supplement))
  html.elem("span", attrs: (class: "citation-text"))[
    #author_part#text(" [")#citation_link(key, label)#text("]")
  ]
}

#let changelog(body) = html.elem("section", attrs: (class: "changelog", "data-label": "changelog"))[
  #html.elem("hr")
  #html.elem("p", attrs: (class: "changelog-title"))[*Changelog*]
  #body
]

#let lec_bibliography = (path, title: auto) => context {
  show cite: set text(black)
  set heading(numbering: none)
  let bib-title = if title != none and title != auto {
    title
  } else if title == auto {
    [Bibliography for this lecture]
  } else {
    none
  }
  html.elem("section", attrs: (class: "bibliography", id: "bibliography"))[
    #if bib-title != none {
      html.elem("h1", attrs: (
        class: "notes-heading notes-heading-unnumbered",
        "data-level": "1",
      ))[#bib-title]
    }
    #context {
      html.elem("table", attrs: (class: "bibliography-table"))[
        #for item in citation-keys() [
          #html.elem("tr", attrs: (
            class: "bibliography-row",
            id: citation_html_id(item),
          ))[
            #html.elem("td", attrs: (class: "bib-key"))[
              #text("[")#citation_label_text(item, cited_keys: citation-keys())#text("]")
            ]
            #html.elem("td", attrs: (class: "bib-entry"))[#full-citation(item, full-doi: true)]
          ]
        ]
      ]
    }
  ]

  html.div(hidden: true, {
    show link: it => it.body
    bibliography("refs.bib", title: none)
  })
}

#let appendix(body) = (
  context {
    counter(heading).update(0)
    let lec_num = lecnum.get()
    set heading(
      numbering: (..nums) => {
        lecture-number-label(lec_num) + "." + numbering("A.1", ..nums)
      },
    )
    body
  }
)
#let brown = rgb(149, 69, 53)
#let comment(body, visual: none) = {
  html.elem("aside", attrs: (class: "special-comment"))[
    #html.elem("div", attrs: (class: "special-comment-text"))[#body]
    #if visual != none {
      html.elem("div", attrs: (class: "special-comment-figure"))[
        #html.frame({
          show math.equation: eq => eq
          visual
        })
      ]
    }
  ]
}
#let todo(body) = html.elem("mark", attrs: (class: "todo"), body)

#let alertbox(body, kind: "highlight", title: none) = {
  html.elem("aside", attrs: (
    class: "callout callout-" + kind,
    "data-callout": kind,
  ))[
    #if title != none {
      html.elem("p", attrs: (class: "callout-title"))[#title]
    }
    #html.elem("div", attrs: (class: "callout-body"))[#body]
  ]
}
#let info-box(body, title: none) = alertbox(body, kind: "info", title: title)
#let warning-box(body, title: none) = alertbox(body, kind: "warning", title: title)
#let highlight-box(body, title: none) = alertbox(body, kind: "highlight", title: title)
#let wrapped-figure(text-body, figure-body, side: right, text-width: 65%) = {
  let class = "wrapped-figure"
  let side-text = repr(side)
  if side-text.contains("left") {
    class += " wrapped-figure-left"
  } else {
    class += " wrapped-figure-right"
  }
  html.elem("div", attrs: (class: class, style: "--text-width: " + repr(text-width) + ";"))[
    #html.elem("div", attrs: (class: "wrapped-figure-text"))[#text-body]
    #html.elem("div", attrs: (class: "wrapped-figure-media"))[
      #figure-body
    ]
  ]
}
#let wrapped-figure-with-caption(text-body, figure-body, caption, side: right, text-width: 65%) = {
  let class = "wrapped-figure"
  let side-text = repr(side)
  if side-text.contains("left") {
    class += " wrapped-figure-left"
  } else {
    class += " wrapped-figure-right"
  }
  html.elem("div", attrs: (class: class, style: "--text-width: " + repr(text-width) + ";"))[
    #html.elem("div", attrs: (class: "wrapped-figure-text"))[#text-body]
    #html.elem("div", attrs: (class: "wrapped-figure-media"))[
      #figure-body
      #html.elem("figcaption")[#caption]
    ]
  ]
}

#let graybox = block.with(
  breakable: true,
  fill: luma(95%),
  width: 100%,
  stroke: .2mm + luma(80%),
  inset: 3mm,
  radius: .65mm,
)

#let thm-factory(name) = {
  let Name = name.replace(
    regex("[A-Za-z]+('[A-Za-z]+)?"),
    word => upper(word.text.first()) + lower(word.text.slice(1)),
  )

  return (
    ..args,
    body,
  ) => {
    figure(
      kind: "shared",
      outlined: false,
      caption: none,
      supplement: Name,
      {
        let counter_name = "shared"
        thmcounters.update(x => {
          x.insert(counter_name, x.at(counter_name, default: 0) + 1)
          x
        })
        html.elem("p", attrs: (class: "env-heading"))[
          #html.elem("span", attrs: (class: "env-title env-title-numbered"))[
            #html.elem("strong", attrs: (class: "env-kind"))[#Name]
            #context {
              let counters = thmcounters.get()
              html.elem("strong", attrs: (class: "env-number"))[
                #lecture-number-label(counters.at("lecture"))#html.elem("span", attrs: (class: "env-number-separator"))[.]#str(
                  counters.at(counter_name),
                )
              ]
            }
            #if args.pos().len() > 0 {
              html.elem("span", attrs: (class: "env-extra"))[(#args.pos().first())]
            }
            #html.elem("strong", attrs: (class: "env-punct"))[.]
          ]
        ]
        html.elem("div", attrs: (class: "env-body"))[
          #body
        ]
      },
    )
  }
}

#let proof-factory(name) = {
  let Name = name.replace(
    regex("[A-Za-z]+('[A-Za-z]+)?"),
    word => upper(word.text.first()) + lower(word.text.slice(1)),
  )

  (..args, body) => {
    html.elem("section", attrs: (class: "env proof", "data-proof-kind": Name))[
      #html.elem("p", attrs: (class: "env-heading"))[
        #html.elem("span", attrs: (class: "env-title"))[
          #if args.pos().len() > 0 [
            _#Name #args.pos().first();._
          ] else [
            _#Name._
          ]
        ]
      ]
      #html.elem("div", attrs: (class: "env-body"))[
        #body #html.elem("span", attrs: (
          class: "proof-qed", role: "img", "aria-label": "End of " + lower(Name),
        ))[#html.elem("span", attrs: (class: "proof-qed-symbol"))[□]]
      ]
    ]
  }
}

#let restate = label => context {
  let content = query(label).at(0).body.child.children.at(1)
  assert(content.body.children.at(1) == strong([.]))
  graybox({
    strong(ref(label))
    [~(Restated)*.*]
    for field in content.body.children.slice(2) {
      field
    }
  })
}

#let theorem = thm-factory("theorem")
#let open-problem = thm-factory("open problem")
#let claim = thm-factory("claim")
#let subclaim = thm-factory("subclaim")
#let proposition = thm-factory("proposition")
#let lemma = thm-factory("lemma")
#let corollary = thm-factory("corollary")
#let exercise = thm-factory("exercise")
#let definition = thm-factory("definition")
#let example = thm-factory("example")
#let remark = thm-factory("remark")
#let proof = proof-factory("proof")
#let proofsketch = proof-factory("Proof Sketch")
#let solution = proof-factory("solution")

#let dt(s) = {
  (
    [#s]
      + if s.last() == "1" and (not s.ends-with(" 1") and not s.ends-with("11")) {
        [#super[st]]
      } else if s.last() == "2" and not s.ends-with("12") {
        [#super[nd]]
      } else if s.last() == "3" and not s.ends-with("13") {
        [#super[rd]]
      } else {
        [#super[th]]
      }
  )
}

#let manualcite(..lbls) = {
  let rows = ()
  for lbl in lbls.pos() {
    rows.push(cite(lbl))
    rows.push(cite(lbl, form: "full"))
  }
  grid(columns: (1cm, auto), row-gutter: 3.8mm, column-gutter: 2.3mm, ..rows)
}

#let proofdir(marker, body) = [#marker~~#body]

// A nested equation keeps the color marker scoped to the colored subexpression.
#let html-math-color(fill, body) = if html-math-mode == "katex" {
  math.equation(metadata("katex-color:" + fill.to-hex()) + _html-math-undisplay(body))
} else {
  text(fill, body)
}
