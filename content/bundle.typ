// Compile all notes together so native refs can see their live destinations.
// Separate HTML and PDF bundles avoid duplicating each label across formats.
#let format = sys.inputs.at("notes-format", default: "pdf")
#assert(format in ("html", "pdf"), message: "Expected notes-format=html or pdf.")
#import "meta/lecture-links.typ": lecture-title
#for note in json("../.build/note-bundle.json") {
  let name = note.source.split("/").last().trim(".typ", at: end)
  let output = if format == "html" { name + ".html" } else { "pdf/" + name + ".pdf" }
  let source = "../.build/" + format + "-source/" + name + ".typ"
  document(output, title: lecture-title(note.number, note.title), include source)
}
