// A notice for the lecture note's paged and HTML editions only.
#let note-status(body) = context if target() == "html" {
  html.elem("aside", attrs: (class: "note-status", "aria-label": "Lecture note status"))[
    #html.elem("img", attrs: (src: "assets/course/traffic-cone.svg", width: "22", height: "22", alt: ""))
    #html.elem("p")[#body]
  ]
} else {
  block(width: 100%, inset: (x: 7pt, y: 5pt), radius: 3pt, fill: rgb("fff4e6"), above: 5pt, below: 5pt)[
    #set text(size: 8.5pt, fill: rgb("88410c"))
    #grid(columns: (13pt, 1fr), column-gutter: 6pt, align: (left, horizon),
      image("traffic-cone.svg", width: 13pt, alt: "Traffic cone"),
      [#body],
    )
  ]
}
