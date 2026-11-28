// Embeds one of the course's interactive pages (interactive/<name>.html, listed
// under `interactive_pages` in html-export.json). The HTML edition embeds the
// page in an iframe; the paged edition links to its public page, like
// `interactive-link` in lecture-links.typ.
#import "lecture-links.typ": course-url

#let interactive-demo(name, title: "Interactive demo", height: 640) = context {
  assert(name.match(regex("^[a-z][a-z0-9_]*$")) != none,
    message: "Expected the basename of an interactive/*.html page.")
  assert(type(title) == str, message: "Expected a plain-text demo title.")
  let page = "interactive/" + name + ".html"
  if target() == "html" {
    html.elem("div", attrs: (class: "interactive-demo", style: "--demo-height: " + str(height) + "px"))[
      #html.elem("iframe", attrs: (src: page + "?embed=1", title: title, loading: "lazy"))
      #html.elem("p", attrs: (class: "interactive-demo-link"))[
        #html.elem("a", attrs: (href: page, target: "_blank", rel: "noopener"))[Open “#title” in a new tab]
      ]
    ]
  } else {
    let url = course-url + page
    block(width: 100%, inset: (x: 8pt, y: 6pt), radius: 3pt, stroke: .5pt + luma(75%), breakable: false)[
      #strong[Interactive demo.] “#title” can be played in the HTML version of these notes or at
      #link(url, text(fill: blue.darken(40%), raw(url))).
    ]
  }
}
