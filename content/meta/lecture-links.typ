// Bundle references use Typst's live labels, counters, and link destinations.
// A single-file preview cannot introspect another document; it uses that
// note's directly authored show-rule arguments for a lecture-level web link.
#let lecture-title(number, title) = {
  let kind = if str(number).starts-with("S") { "Supplementary Reading" } else { "Lecture" }
  [#kind~#number, “#title”]
}

// Read only the literal number and title required by a standalone link. This
// avoids importing a destination's body (and its own cross-lecture links).
// Like the site builder, this accepts a quoted or plain bracketed title.
#let lecture-header(source) = {
  let call = source.match(regex("(?ms)^#show:\\s*gabri_notes\\.with\\((.*?)\\)\\s*$"))
  assert(call != none, message: "Expected a direct #show: gabri_notes.with(...) header.")
  let arguments = call.captures.first()
  let number = arguments.match(regex("\\blec_num:\\s*(\"[^\"]+\"|[0-9]+)\\s*(?:,|$)"))
  let title = arguments.match(regex("\\btitle:\\s*(\"(?:\\\\.|[^\"\\\\])*\"|\\[[^\\]]*\\])\\s*(?:,|$)"))
  assert(number != none and title != none,
    message: "Expected literal lec_num and title arguments in the note header.")
  (lec_num: eval(number.captures.first()), title: eval(title.captures.first()))
}

// Omit the destination and body for a whole-lecture reference. Keep accepting
// positional labels and trailing content blocks for existing references.
#let lecture-link(note, ..args) = context {
  let positional = args.pos()
  assert(args.named().len() == 0 and positional.len() <= 2,
    message: "Expected a lecture name, an optional destination label, and optional link text.")
  let destination = positional.at(0, default: none)
  let body = positional.at(1, default: [])
  if positional.len() == 1 and type(destination) == content {
    body = destination
    destination = none
  }
  assert(note.match(regex("^[a-z][a-z0-9_]*$")) != none,
    message: "Expected a lecture source basename (without .typ).")
  assert(destination == none or type(destination) == label,
    message: "Expected a stable destination label, or none for the whole lecture.")
  let anchor = if destination == none { none } else { str(destination) }
  assert(anchor == none or anchor.match(regex("^[a-zA-Z][a-zA-Z0-9_-]*$")) != none,
    message: "Cross-lecture labels must use letters, digits, hyphens or underscores.")
  if "course-bundle" in sys.inputs {
    let (dest, reference) = if destination == none {
      let path = if target() == "html" { "/" + note + ".html" } else { "/pdf/" + note + ".pdf" }
      let doc = query(document.where(path: path)).first()
      (doc.location(), doc.title)
    } else {
      let reference = {
        // The outer link covers the phrase and its reference together.
        show link: it => it.body
        ref(destination)
      }
      (destination, reference)
    }
    let body = if body == [] { reference } else { [#body (#reference)] }
    link(dest, if target() == "html" { body } else { text(fill: blue.darken(40%), body) })
  } else {
    let other = lecture-header(read("../" + note + ".typ"))
    let reference = lecture-title(other.lec_num, other.title)
    let body = if body == [] { reference } else { [#body (#reference)] }
    let relative = note + ".html" + if anchor == none { "" } else { "#" + anchor }
    if target() == "html" {
      link(relative, body)
    } else {
      let base = sys.inputs.at("course-url", default: "https://www.mit.edu/~6.7980/")
      link(base + relative, text(fill: blue.darken(40%), body))
    }
  }
}
