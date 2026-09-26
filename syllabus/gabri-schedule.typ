#import "@preview/cetz:0.4.1"
#import "../content/meta/typography.typ": course-sans

#let item(title, body) = {
  set par(hanging-indent: 1cm)
  set list(indent: 1cm)
  strong(title + ":")
  sym.space
  body
}

#let mybox(body, bg: black, fg: white) = {
  box(baseline: 1mm, inset: 1mm, fill: bg, radius: 1mm)[#course-sans(
    weight: "bold",
    fill: fg,
    size: 7.5pt,
  )[#upper[#body]]]
};
#let proj = mybox(bg: blue)[project]
#let brk = { mybox(bg: luma(60%))[No class] }
#let break-badge = mybox(bg: rgb("#7855a6"))[break]
#let email(addr) = {
  let w = .3
  let h = .2
  box(
    cetz.canvas({
      import cetz.draw: *
      rect((0, 0), (w, h), stroke: .2mm)
      line((0, h), (w / 2, h / 2.5), (w, h), stroke: .2mm)
    }),
  )
  [~]
  raw(addr)
}

#let module(title) = (kind: "module", title: title)

// Lecture IDs stay with their topics when the outline is reordered. Dates and
// zero-based lecture numbers are assigned by schedule, never by the author.
#let lecture(id, title, description: [], instructor: [], standalone: false, badge: []) = (
  kind: "lecture",
  id: id,
  title: title,
  description: description,
  instructor: instructor,
  standalone: standalone,
  badge: badge,
)

// An undated no-class consumes one class slot without a lecture number.
// `on` pins an academic-calendar exception outside the list of class dates.
#let no-class(title: [No class], description: [], on: none, badge: brk) = (
  kind: "no-class",
  title: title,
  description: description,
  on: on,
  badge: badge,
  instructor: [],
  standalone: false,
)

#let calendar-date(value) = {
  assert(
    type(value) == str and value.match(regex("^\\d{4}-\\d{2}-\\d{2}$")) != none,
    message: "Schedule dates must be ISO strings: YYYY-MM-DD.",
  )
  let parts = value.split("-").map(int)
  datetime(year: parts.at(0), month: parts.at(1), day: parts.at(2))
}

#let assign-schedule(dates, entries) = {
  assert(dates.len() > 0, message: "The schedule needs class dates.")
  let checked-dates = dates.map(calendar-date)
  assert(
    dates == dates.sorted() and dates.dedup().len() == dates.len(),
    message: "Class dates must be unique and chronological.",
  )
  let slots = entries.filter(e => e.kind != "module" and not (e.kind == "no-class" and e.on != none))
  assert(
    slots.len() == dates.len(),
    message: "Schedule has " + str(slots.len()) + " dated entries for " + str(dates.len()) + " class dates.",
  )
  let ids = entries.filter(e => e.kind == "lecture").map(e => e.id)
  assert(
    ids.all(id => type(id) == str and id != "") and ids.dedup().len() == ids.len(),
    message: "Lecture IDs must be nonempty and unique.",
  )
  let fixed = entries.filter(e => e.kind == "no-class" and e.on != none)
  let fixed-dates = fixed.map(e => e.on)
  let checked-exceptions = fixed-dates.map(calendar-date)
  assert(fixed-dates.dedup().len() == fixed-dates.len(), message: "Repeated no-class date.")
  assert(fixed-dates.all(d => not dates.contains(d)), message: "A no-class date is also a class date.")
  assert(
    fixed-dates.all(d => d >= dates.first() and d <= dates.last()),
    message: "A no-class date falls outside the course calendar.",
  )

  let outline = entries.filter(e => not (e.kind == "no-class" and e.on != none))
  let result = ()
  let cursor = 0
  let number = 0
  for day in (dates + fixed-dates).sorted() {
    if fixed-dates.contains(day) {
      let entry = fixed.find(e => e.on == day)
      result.push(entry + (date: day, number: none))
    } else {
      while cursor < outline.len() and outline.at(cursor).kind == "module" {
        result.push(outline.at(cursor))
        cursor += 1
      }
      let entry = outline.at(cursor)
      assert(("lecture", "no-class").contains(entry.kind), message: "Unknown schedule entry.")
      result.push(entry + (date: day, number: if entry.kind == "lecture" { number }))
      if entry.kind == "lecture" { number += 1 }
      cursor += 1
    }
  }
  assert(cursor == outline.len(), message: "The schedule ends with an empty module.")
  result
}

// Export text from Typst content, preserving nested emphasis and links. Python
// reads this evaluated metadata instead of parsing the syllabus with regexes.
#let schedule-text(body) = {
  if type(body) == str { body } else if body.has("text") { body.text } else if body.has("children") {
    body.children.fold("", (acc, child) => acc + schedule-text(child))
  } else if body.has("body") { schedule-text(body.body) } else if body.has("child") {
    schedule-text(body.child)
  } else if (
    repr(body.func()) == "space" or body.func() == linebreak or body.func() == parbreak
  ) { " " } else if body.func() == smartquote { if body.at("double", default: true) { "\"" } else { "'" } } else {
    panic("Unsupported content in schedule export: " + repr(body))
  }
}

#let schedule-date(date) = {
  let parsed = calendar-date(date)
  let day = parsed.day()
  let last = calc.rem(day, 10)
  let suffix = if day >= 11 and day <= 13 { "th" } else {
    if last == 1 { "st" } else if last == 2 { "nd" } else if last == 3 { "rd" } else { "th" }
  }
  [#parsed.display("[month repr:short] [day padding:none]")#super[#suffix]]
}
#let desc(body) = {
  [#linebreak()#text(size: 9.8pt)[#body]]
  v(.5mm)
}
#let schedule(dates, entries, hide-instructors: false) = {
  let assigned = assign-schedule(dates, entries)
  let exported = assigned.map(e => if e.kind == "module" {
    (kind: "module", title: schedule-text(e.title))
  } else {
    (
      kind: e.kind,
      id: e.at("id", default: none),
      number: e.number,
      iso_date: e.date,
      date: calendar-date(e.date).display("[month repr:short] [day padding:none]"),
      title: schedule-text(e.title),
      description: schedule-text(e.description),
      instructor: schedule-text(e.instructor),
      standalone: e.standalone,
      badge: schedule-text(e.badge),
    )
  })
  [#metadata(exported) <course-schedule>]
  let cells = ()
  for entry in assigned {
    if entry.kind == "module" {
      cells += ([], table.cell(colspan: 2, align: left)[#v(3mm)#smallcaps[#entry.title]])
    } else {
      cells += (
        [#entry.number],
        [#schedule-date(entry.date)#if entry.badge != [] [#linebreak()#entry.badge]],
        [*#entry.title*#if not hide-instructors and entry.instructor != [] [#h(1fr)#box[#text(size: 8.5pt)[_#(entry.instructor)_]]]#if entry.description != [] [#desc(entry.description)]],
      )
    }
  }
  table(
    columns: (auto, auto, 1fr),
    align: (right, left, left),
    stroke: (col, row) => (
      bottom: .2mm + gray,
      left: if col == 2 { .2mm + gray } else { none },
      right: none,
      top: .2mm + gray,
    ),
    inset: 2.1mm,
    ..cells,
  )
}
