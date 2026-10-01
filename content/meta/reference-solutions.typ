// Hide reference solutions by default in HTML; show them in full in PDFs.
#let reference-solutions(body) = context {
  if target() == "html" {
    html.elem("details", attrs: (class: "reference-solutions"))[
      #html.elem("summary", attrs: (
        style: "cursor: pointer; font-weight: 600; padding: 0.75em 0;",
      ))[Show / hide reference solutions]
      #body
    ]
  } else {
    body
  }
}
