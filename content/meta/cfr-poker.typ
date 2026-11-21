// A static browser player with a short, useful paged fallback.
#let cfr-poker() = context if target() == "html" {
  html.elem("link", attrs: (rel: "stylesheet", href: "assets/cfr-poker/poker.css"))
  html.elem("div", attrs: (id: "cfr-poker"))[
    Enable JavaScript to play Leduc poker and inspect the trained strategy.
  ]
  for script in ("poker-data.js", "leduc.js", "poker.js") {
    html.elem("script", attrs: (src: "assets/cfr-poker/" + script, defer: ""))[]
  }
} else {
  [#link("https://www.mit.edu/~6.7980/learning_efg.html#sec-cfr-poker")[Play and inspect the interactive Leduc poker demo on the course website.]]
}
