// SVG text is outlined at compilation, so HTML figures need the page's fonts.
#import "../../meta/typography.typ": course-sans-font
#let figure-html = sys.inputs.at("figure-format", default: "pdf") == "html"
#let figure-font = if figure-html { "Georgia" } else { "New Computer Modern" }

#let figure-style(body) = {
  if figure-html {
    show strong: set text(font: course-sans-font, weight: "bold")
    body
  } else {
    body
  }
}
