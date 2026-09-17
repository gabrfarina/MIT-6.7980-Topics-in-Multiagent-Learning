# Notes HTML Exporter

This Rust binary exports the notes by compiling Typst with its experimental HTML backend and then applying a light postprocessing pass for the public lecture layout.

The Typst side lives primarily in `meta/gabri_notes_html.typ`, which emits HTML-friendly classes and attributes for the exporter. The Rust side calls Typst as a library, reads the resulting HTML, and handles the page shell, lecture rail, citation and footnote sidenotes, equation sizing hooks, bibliography cleanup, and KaTeX conversion.

## Usage

The canonical entry point is the course Makefile:

```sh
make bundle
```

That generates `html/` with a shared stylesheet using the native Typst bundle
target and packages `dist/6.7980-notes.zip`. It validates local links and math.
See the [course README](../README.md) and [build guide](../docs/building.md).

For a single lecture:

```sh
make figures
python3 scripts/course_index.py --resolve-only
cargo run --manifest-path html-exporter/Cargo.toml -- \
  --root . \
  --config .build/html-export.json --math katex \
  'content/nfgs_nash.typ' \
  .build/nfgs_nash.html
```

The Rust exporter reads the resolved `notes` configuration in `.build/`, whose
numbers, dates, course facts, and citation metadata come from the syllabus.
Use `make html` for publishing: it also updates the Typst note headers, compiles
PDFs, copies slide attachments, and synchronizes the index and syllabus PDF.

The desktop lecture rail keeps the course title and instructors visible.
“In this lecture” opens with every section and subsection expanded by default.
Use the chevrons to collapse subsections and the section titles to jump to them.
The active marker follows the visible parent when its subsections are collapsed.
“Browse lectures” reveals the full course list. Both disclosures work without
JavaScript. With browser storage available, its open/closed state is remembered
across the course, and each lecture remembers its own expanded subsections,
including after reloading or reopening the browser.
Previous/next links follow the available notes in course order;
supplementary readings have their own sequence.

Tables retain Typst's resolved cell borders, horizontal and vertical alignment,
solid fills (including transparency), and linear-gradient fills. Borders support
thickness, solid colors, borderless cells, per-side overrides, and standard
solid/dashed/dotted styles. Table defaults, column arrays, position-dependent
functions, and cell overrides are resolved by Typst before conversion; native
headers and merged cells are kept. The outer alignment positions the table
independently of its cells.

Column definitions become native HTML `colgroup` tracks: lengths and percentages
retain their requested widths, `fr` tracks divide the space left by explicit and
`auto` tracks, and `auto` tracks use browser content sizing. Fully specified
tables use fixed layout. A browser sizing pass resolves mixed units (unsupported
in native column CSS) after font loading and on resize; without JavaScript these
mixed widths are approximate. The browser may adjust fractional proportions
alongside content-sized `auto` columns. Wide tables scroll within the lecture
column. Nonlinear gradients, tiled fills, and exact custom dash patterns are not
currently reproduced.

Useful options:

- `--root <dir>`: set the Typst project root.
- `--math <svg|katex>`: choose the math backend. The course build uses `katex`, with SVG fallback for unsupported expressions. Unsupported KaTeX conversions retain Typst's SVG.
- `--site-title <title>`: change the header title.
- `--authors <text>`: change the author line.
- `--index <href>` and `--pdf <href>`: add header links.
- `--figure-svg`: compile a single-page figure using the HTML fonts and add a
  selectable text layer. Gate variants accept `--figure-input gate=addition`.

The page exporter inlines these selectable SVGs so labels can be selected and
copied in the browser. Their visible outlines preserve Typst's mathematical
glyphs and exact spacing; the text layer supplies the original Unicode strings.
URL links on those labels also work in the text layer, including within scaled
or rotated drawings. Link regions use the same nested transforms as the artwork;
unlinked labels remain selectable text.

Lecture HTML intercepts copy in `.lecture-content` and writes Markdown. Math
uses TeX from `data-tex`, with inline vs display taken from `data-math-display`
rather than on-screen size. Expressions that stayed as Typst SVG copy as
`[math not available as TeX]`. The lecture rail, permalink icons, and citation
sidenotes are omitted. **Enable agentic tools** (off until checked) exposes
line ids on the page and includes the originating line id when copying a
fragment, including a mid-paragraph selection.

## Checks

```sh
make check
```

This runs the Python/Rust regression tests and validates the already-generated site.
The converter embeds Typst 0.15.1 and supports its current font, file, package,
and diagnostic APIs. `SOURCE_DATE_EPOCH` can fix the compiler's clock for
reproducible builds.

## Bundled browser assets

`assets/katex/` contains the pinned KaTeX 0.16.22 browser runtime, styles, fonts,
and MIT license. The course builder rewrites the standalone converter's CDN
links to these local assets. See the [KaTeX browser documentation](https://katex.org/docs/browser).

`assets/fonts/` contains genuine Frutiger Regular (400) and Bold (700) faces
from the existing notes. Environment names and numbers, including generated
algorithm counters, proof labels, and figure/table caption labels, request 600
through `--environment-label-weight`. Browsers currently match this to the
available Bold face; add a genuine Semibold face with a 600 `@font-face` rule
to obtain that distinct weight. Synthetic weight remains disabled.
