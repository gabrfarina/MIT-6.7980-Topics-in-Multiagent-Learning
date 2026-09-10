# Building and editing the notes

Run commands from the repository root. The Makefile uses `python3` by default;
set `PYTHON=/path/to/python3` if needed. The converter's Cargo lockfile pins
Typst 0.15.1; use the matching Typst CLI for consistent output.

## Build pipeline

`make html` builds the Rust converter, regenerates the editable dynamics and
diagram figures, compiles each lecture to HTML and PDF, generates the course
index from the syllabus, and assembles `html/` using Typst's experimental bundle
target. `make bundle` also produces `dist/6.7980-notes.zip`.

The generated website has a schedule, 15 lecture and supplementary pages,
PDF downloads, downloadable chapter sources, a syllabus, and local browser
assets. KaTeX 0.16.22 renders supported expressions; unsupported expressions
retain their Typst SVG rendering. No npm installation is needed for the course
build: the browser runtime and its license are under `html-exporter/assets/katex/`.

After the Rust converter has been built, a quicker rebuild is:

```sh
python3 scripts/build_site.py --skip-build --zip
```

Compiler diagnostics are saved under `.build/logs/`. Build products in `.build/`,
`html/`, `dist/`, and `html-exporter/target/` are not versioned.

## E-book

`make epub` packages an already built `html/` as `dist/6.7980-notes.epub`, with
lecture order, numbers, and titles from `.build/html-export.json`; run `make html`
first. Math is converted to MathML with the bundled KaTeX, so no npm installation
is needed. The script requires `beautifulsoup4` and `lxml`. When
[uv](https://docs.astral.sh/uv/) is installed, `make epub` runs the script with
`uv run`, which installs both automatically. Otherwise it uses `python3`, and the
packages must be installed first with `python3 -m pip install beautifulsoup4 lxml`.
A cover image is rendered
with headless Google Chrome when it is available at its standard macOS location;
otherwise the book is built without one.

The converter recognizes the exporter's lecture markup by class name. It stops
without writing the book if a formula fails to render, an embedded image has an
unsupported type, or a lecture still contains TeX delimiters, inline SVG, or
embedded images after conversion. Update `scripts/build_epub.py` when changing
the HTML templates or exporter in ways that trigger these errors.

## Source files

- Edit `content/content/*.typ` for explanations, equations, and proofs.
- Edit `html-export.json` for reading order, syllabus mappings, and site metadata.
- Edit `syllabus/6.7980 F26 Syllabus.typ` for the ordered lecture/module outline and instructors.
- Edit `syllabus/fall-2026-calendar.typ` for verified class dates and fixed academic-calendar exceptions.
- Edit `scripts/course_index.py` for course-home content and markup.
- Edit `html-exporter/src/course.css` for the homepage layout.
- Edit `html-exporter/src/gabri-notes.css` for the lecture layout.
- Edit `html-exporter/src/epub.css` for the EPUB layout.
- Edit `content/meta/gabri_notes_html.typ` for semantic HTML components.
- Edit `content/meta/gabri_notes_pdf.typ` for the native PDF layout.
- Edit `content/meta/lovelace_html.typ` for HTML pseudocode.

`how_to_cite.url_prefix` in `html-export.json` sets the published base URL for
lecture citation links, currently `https://www.mit.edu/~6.7980/`. Keep the trailing
slash. Navigation and asset links remain relative so local previews and the
downloadable bundle work without a web server at that address.

The syllabus calls `schedule(class-dates, outline)`. Its outline contains
`lecture("stable-id", [Title], description: [...], instructor: [...])`,
`module[Part title]`, and `no-class(title: [...], description: [...])` entries.
Lectures consume the next class date and receive a zero-based lecture number.
An undated `no-class` consumes a class date without advancing that number;
module headings consume neither. Use `standalone: true` on a lecture to start
a section without a part heading.

Set `hide-instructors: true` on `schedule(...)` to hide all lecturer names in
the PDF schedule while keeping their assignments in the source. This syllabus
enables the flag; its default is `false`. The website schedule also hides names.

MIT's fixed exceptions use `no-class(on: "YYYY-MM-DD", description: [...])` and
are inserted chronologically without consuming a class date. They are defined
beside the date list, then included in the outline via `..calendar-exceptions`.
Their placement in that outline has no effect on their dates. Typst rejects
duplicate or unordered dates, duplicate lecture IDs, conflicting exceptions,
and a mismatch between class dates and entries. Adding or deleting a lecture
therefore requires adjusting another slot, for example replacing a project break.

The Fall 2026 calendar was verified on September 9, 2026 against the
[MIT Registrar's calendar](https://registrar.mit.edu/calendar-pdf) and
[class-day totals](https://registrar.mit.edu/calendar/class-days).
Classes run September 9–December 10. The course has 12 Tuesday and 13 Thursday
slots, starting September 10. October 13 follows a Monday schedule and November
26 is Thanksgiving; November 11 is a Wednesday holiday.

The website reads `<course-schedule>` metadata evaluated by Typst, so it uses
the same assigned dates as the PDF and supports nested Typst text without a
second schedule parser. `html-export.json` maps notes to stable `syllabus_ids`.
The build derives their current numbers, dates, and ordering, and writes a
resolved exporter configuration to `.build/html-export.json`; numeric fields
in the authored config are only defaults for standalone note exports.
Generated HTML/PDF note sources receive the derived header metadata without
rewriting the authored lecture files. Supplementary readings retain S1, S2,
and so on, with the term in place of a class date.

Use `make syllabus` after outline changes to rebuild both syllabus PDF copies
and regenerate the current index. Use `make html` to also regenerate lecture
notes and their navigation with the new session numbers and dates.

## Figures

All active figure dependencies live inside `content/`.

```sh
python3 scripts/build_dynamics.py       # OGD/MWU and optimism figures
python3 scripts/build_diagrams.py       # self-play, bandits, and PPAD diagrams
```

These commands run during the full site build. Editable dynamics and diagram
sources live under `content/figures/`; the dynamics helpers are in
`content/meta/dyns.typ`. Generated SVGs are used by both rendering paths.

The optional `prepare_kuhn_figure.py` and `prepare_kuhn_alternatives.py` scripts
require Pillow. They preserve white node interiors and verify that compositing
the transparent figures over white reproduces the original pixels exactly.
`course_collage.py` rebuilds the homepage illustration collage from the screenshots
under `syllabus/assets/`.

Use `wrapped-figure` for prose alongside a compact diagram:

```typst
#wrapped-figure(side: right, text-width: 55%)[
  Explain the learning process here.
][
  #image("../figures/L04/self_play.svg", width: 300pt)
]
```

The two columns stack on narrow screens. `wrapped-figure-with-caption` accepts
a third content argument for a caption.

## Typography and verification

The build loads the bundled regular and bold Frutiger faces from
`html-exporter/assets/fonts`. The syllabus uses Frutiger for bold text and
headings, with New Computer Modern for regular and italic body text.
The font files and other third-party assets retain their respective terms.

`make check` runs the Python and Rust regression suites, verifies local links
and image occurrences, validates each “How to cite” URL against the generated
lecture page, and checks every KaTeX expression. Absolute URLs under
`how_to_cite.url_prefix` are checked against the build as well as relative links,
including CSS assets and HTML/SVG anchors. For a live check of external links,
run `python3 scripts/check_links.py html --online`; blocked or unreachable
destinations are reported as unverified, separately from HTTP 404/410 failures.
Add `--doi-warnings` to report failed checks of `doi.org` and `dx.doi.org`
links as non-blocking warnings. Those URLs are still checked, including their
redirects; other external failures and all local/citation errors remain blocking.
`site.separate_paths` lists directories deployed independently of the course
bundle (currently `fow/`); links into those directories are checked online unless
explicitly excluded with `--skip-separate-site fow/`.
Review rendered PDFs
and representative desktop/mobile pages after visual changes: automated checks
do not establish that every equation fits or every figure label is readable.
