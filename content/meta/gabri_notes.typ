// Shared paged renderer for all active lecture and supplementary PDFs.
// Imported directly by each lecture; PDF compilation needs no build-time rewrite.
#assert(
  not ("web" in sys.inputs or "combined" in sys.inputs or "html" in sys.inputs),
  message: "Legacy web/combined/html inputs are unsupported. Compile each lecture directly, or use the site build.",
)
#import "linalg.typ": *
#import "lovelace.typ": *
#import "notation.typ": *
#import "markers.typ": paragraph-marker
#import "lecture-links.typ": lecture-link, lecture-title
#import "typography.typ": course-sans-font

#let lecnum = state("lecnum", none)
#let lecture-number-label(value) = if str(value).starts-with("S") { str(value) } else { "L" + str(value) }
#let lecture-label(value) = if str(value).starts-with("S") { "Supplementary reading " + str(value) } else {
  "Lecture " + str(value)
}
#let html-math-color(fill, body) = text(fill: fill, body)
#let proofdir(marker, body) = [#marker~~#body]
#let comment = body => text(luma(128))[~~~~ $triangle.stroked.small.r$ _ #body _]

#let bpar(body) = [#strong(body) #h(0.5em)]
#let changelog(body) = block(above: 3em, stroke: (top: 0.15mm + luma(80%)), inset: (top: 8pt))[
  #text(size: 9pt, fill: luma(40%))[*Changelog*]
  #v(0.4em)
  #text(size: 9pt, body)
]
#let citep(..keys) = {
  let keys = keys.pos()
  if keys.len() == 2 and type(keys.last()) == content {
    cite(keys.first(), supplement: keys.last())
  } else {
    for key in keys { cite(key) }
  }
}
#let citet = cite.with(form: "prose")
// Keep the native callsite so relative bibliography paths resolve in the lecture.
#let lec_bibliography = bibliography

#let plain-text(value) = if type(value) == str {
  value
} else if value.func() in (linebreak, parbreak, [ ].func()) {
  " "
} else if value.has("text") {
  value.text
} else if value.has("children") {
  value.children.map(plain-text).join("")
} else if value.has("body") {
  plain-text(value.body)
} else {
  ""
}

#let gabri_notes(
  body,
  lec_num: none,
  date: none,
  title: none,
  instructor: [Prof. Gabriele Farina],
  show_outline: false,
  extrathanks: none,
) = {
  set document(title: lecture-title(lec_num, title), author: plain-text(instructor))
  set page(
    width: 8.27in,
    height: 11.69in,
    margin: (x: 1.3in, top: 1.6in, bottom: 1.6in),
    numbering: none,
    footer: context {
      set text(font: "New Computer Modern", size: 10.2pt, hyphenate: false)
      set par(justify: false, leading: .55em)
      let label = if str(lec_num).starts-with("S") { str(lec_num) } else { lecture-label(lec_num) }
      grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (left, right),
        [#label #sym.bullet #title], [| #counter(page).display("1")/#numbering("1", ..counter(page).final())],
      )
    },
  )
  set text(font: "New Computer Modern", size: 10.2pt)
  set par(justify: true)
  set list(indent: 4.05mm)
  set enum(indent: 4.05mm)
  set heading(numbering: (..nums) => lecture-number-label(lec_num) + "." + nums.pos().map(str).join("."))
  set figure(numbering: n => lecture-number-label(lec_num) + "." + str(n))
  set math.equation(supplement: none)
  set cite(style: "alphanum.csl")
  show cite: set text(fill: blue.darken(40%))
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "lecture-environment" {
      let target = it.element
      let supplement = if it.supplement == auto { target.supplement } else { it.supplement }
      let number = lecture-number-label(lecnum.at(target.location()))
      let n = counter(figure.where(kind: "lecture-environment")).at(target.location()).first()
      link(target.location())[#if supplement not in (none, [], "", text("")) { [#supplement~] }#number.#n]
    } else { it }
  }
  show strong: set text(font: course-sans-font, weight: "bold")
  show heading: it => {
    // More space above than below connects each heading to its following text.
    // Use block spacing so adjacent gaps collapse and page tops stay aligned.
    let space-above = if it.level == 1 { 9mm } else if it.level == 2 { 7.5mm } else { 6mm }
    let space-below = if it.level == 1 { 5mm } else { 4.5mm }
    block(breakable: false, sticky: true, above: space-above, below: space-below)[
      #set text(hyphenate: false)
      #set par(justify: false)
      #if it.numbering != none {
        [#h(-.4in)#box(width: .3in, fill: gray, height: calc.max(.7mm, (3 - it.level) * 1mm + .7mm))#h(.1in)#box(
            width: .6in,
          )[#strong(counter(heading).display())]#strong(it.body)]
      } else {
        [#h(-.4in)#box(width: .3in, fill: gray, height: 2mm)#h(.1in)#strong(it.body)]
      }
    ]
  }
  show figure.caption: caption => context pad(left: 2em, right: 1em, align(
    left,
  )[#h(-1em)*#caption.supplement #numbering(caption.numbering, ..caption.counter.get())*#caption.separator#caption.body])
  show figure.where(kind: "lecture-environment"): it => it.body
  // Bundle counters are global except for page; each note starts afresh.
  counter(heading).update(0)
  counter(math.equation).update(0)
  counter(footnote).update(0)
  for kind in ("lecture-environment", "algorithm", image, table) {
    counter(figure.where(kind: kind)).update(0)
  }
  lecnum.update(str(lec_num))
  box(stroke: .5pt, inset: 3mm, width: 100%, radius: 0mm)[
    #text(size: 9pt)[
      #grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: (left, right),
        [MIT 6.7980 --- Topics in Multiagent Learning], [#date],
      )
    ]
    #v(8mm)
    #align(center)[
      #set par(justify: false)
      #text(size: 16pt, hyphenate: false)[*#lecture-label(lec_num)#v(-2mm)#strong(title)*]
    ]
    #v(3mm)
    Instructor: #instructor
    #if extrathanks != none { footnote(extrathanks) }
  ]
  v(1cm)
  if show_outline { outline() }
  context {
    set bibliography(target: selector(cite).within(here()), group: none)
    body
  }
}

#let appendix(body) = context {
  counter(heading).update(0)
  let number = lecture-number-label(lecnum.get())
  set heading(numbering: (..nums) => number + "." + numbering("A.1", ..nums))
  body
}

#let environment(name) = (..args, body) => figure(
  kind: "lecture-environment",
  supplement: name,
  outlined: false,
  caption: none,
  numbering: n => context [#lecture-number-label(lecnum.get()).#n],
  block(width: 100%, fill: luma(95%), stroke: .15mm + luma(80%), inset: 3mm, radius: .65mm, breakable: true, align(
    left,
  )[
    #context {
      strong(
        [#name #lecture-number-label(lecnum.get()).#counter(figure.where(kind: "lecture-environment")).get().first()],
      )
      if args.pos().len() > 0 { [ (#args.pos().first())] }
      strong[.]
    }
    #h(0.2em)#body
  ]),
)
#let theorem = environment("Theorem")
#let corollary = environment("Corollary")
#let definition = environment("Definition")
#let example = environment("Example")
#let remark = environment("Remark")
#let claim = environment("Claim")
#let subclaim = environment("Subclaim")
#let lemma = environment("Lemma")
#let exercise = environment("Exercise")
#let open-problem = environment("Open Problem")
#let proof-environment(name) = (..args, body) => block(
  width: 100%,
  stroke: (left: .3mm + luma(60%), right: none),
  inset: (left: 4mm, y: 1mm),
  breakable: true,
)[
  _#name#if args.pos().len() > 0 { [ #args.pos().first()] }._
  #h(0.2em)#body #h(1fr) $square$
]
#let proof = proof-environment("Proof")
#let proofsketch = proof-environment("Proof Sketch")
#let solution = proof-environment("Solution")

#let wrapped-figure(text-body, figure-body, side: right, text-width: 65%) = layout(size => {
  let available = size.width - 12pt
  let figure-width = (1 - text-width / 100%) * available
  let text-width = text-width / 100% * available
  let figure-body = {
    // Preserve requested sizes; only shrink images that exceed their column.
    show image: it => context {
      let width = if it.width == auto {
        measure(it, width: figure-width).width
      } else {
        (it.width.ratio * figure-width + it.width.length).to-absolute()
      }
      if width <= figure-width {
        it
      } else {
        // Keep the original element's resolved source path and alt text, and
        // anchor its artwork before cropping and scaling the oversized frame.
        let visual = pad(right: width - figure-width, box(width: figure-width, align(left, it)))
        scale(figure-width / width * 100%, reflow: true, visual)
      }
    }
    align(center, figure-body)
  }
  if side == left {
    grid(
      columns: (figure-width, text-width),
      column-gutter: 12pt,
      figure-body, text-body,
    )
  } else {
    grid(
      columns: (text-width, figure-width),
      column-gutter: 12pt,
      text-body, figure-body,
    )
  }
})
#let wrapped-figure-with-caption(text-body, figure-body, caption, side: right, text-width: 65%) = {
  wrapped-figure(text-body, figure(figure-body, caption: caption), side: side, text-width: text-width)
}
