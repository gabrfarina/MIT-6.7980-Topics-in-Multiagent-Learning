// An interactive companion to a lecture's static Sperner plots. The paged
// edition points at the web version instead.
#let sperner-explorer(body) = context if target() == "html" {
  body
  html.elem("div", attrs: (class: "sperner-explorer", role: "group", "aria-label": "Interactive Sperner discretization"))[
    #html.elem("noscript")[This figure needs JavaScript. The plots above show the same construction on three fixed games.]
  ]
} else {
  block(above: 8pt, below: 8pt, text(size: 9pt, fill: luma(40%))[See the interactive version of this plot in the web edition of these notes.])
}
