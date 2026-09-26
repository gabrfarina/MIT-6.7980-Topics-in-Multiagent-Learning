# Building and editing the notes

Run commands from the repository root. The Makefile uses `python3` by default;
set `PYTHON=/path/to/python3` if needed. The converter's Cargo lockfile pins
Typst 0.15.1; use the matching Typst CLI for consistent output.

## Editing individual lectures

Open the repository folder in VS Code and install the recommended Tinymist
extension. Each lecture and supplementary reading is a standalone
`content/<topic>.typ` document that imports `meta/gabri_notes.typ`, the default
PDF style. Its styles, figures, and bibliography all live below `content/`,
inside Typst's default project root. No root override, input variables, target
flags, or generated source file is needed; load the vendored fonts explicitly:

```sh
typst compile --font-path html-exporter/assets/fonts content/nfgs_nash.typ
```

The checked-in `.vscode/settings.json` selects the paged target and loads the
bundled Source Sans 3 fonts via
[Tinymist's fontPaths setting](https://myriad-dreamin.github.io/tinymist/config/vscode.html#tinymistfontpaths).
The CLI font-path option embeds these same static faces directly into PDFs;
no system font installation or network font service is needed.

`make check-pdf` compiles every authored note with the vendored fonts and its
default project root, without `TYPST_*` environment overrides, writing PDFs and diagnostics under
`.build/standalone-pdfs/`. This check also runs as part of `make check`.
PDFs created alongside the lecture sources by the editor or CLI are ignored by
Git; the site build writes its published PDFs under `html/pdf/`.

The old nested source layout, numbered figure paths, and `gabri_notes_bk.typ`
and `gabri_notes_pdf.typ` imports are rejected by the build. The former `web`,
`html`, and `combined` compiler inputs are rejected by both styles. Combined
document cross-reference injection and the exporter's old source-rewriting
shims have been removed. Standalone previews compile one note; the site build
uses native Typst document bundles for cross-lecture references.

## Links between lectures

Link a specific result or section using its stable label:

```typst
// In content/learning_intro.typ:
== Learning a Nash equilibrium in two-player zero-sum games <sec-learning-zero-sum>

// In another lecture:
See #lecture-link("learning_intro", <sec-learning-zero-sum>)[the self-play proof].
// Renders: the self-play proof (Section L4.2.2).

// Use an empty body when the numbered reference fits the sentence directly:
By #lecture-link("learning_intro", <thm-regret-gap>)[], the saddle-point gap vanishes.
// Renders: By Theorem L4.9, ...

// Omit the label and body to link the whole lecture, including its number and title:
#lecture-link("efg_intro")
// Renders: Lecture 7, “Modeling extensive-form games”.

#lecture-link("kernelized") develops this construction.
// Renders: Lecture 16, “High-dimensional games” develops this construction.
```

Both styles export `lecture-link` from `content/meta/lecture-links.typ`.
The older `#lecture-link("efg_intro", none)[]` form remains supported.
The body is optional for labeled links too: `#lecture-link("learning_intro", <thm-regret-gap>)`.
Use `#lecture-link("efg_intro")[the modeling notes]` to add descriptive text.
Use the source basename and an authored destination label consisting of letters,
digits, hyphens, or underscores, starting with a letter. Keep the label with its
topic when moving a section or result. The helper adds the numbered reference
to descriptive text; prefer an exact theorem, definition, or other environment
over its surrounding section when that is what the sentence invokes. Never
hardcode the number in the prose. Whole-note references use the scheduled title
and lecture number, or “Supplementary Reading S3” for a supplement. Within the
same lecture, use native `@label`, `ref`, or `link` as before. The HTML style
exports safe heading and environment labels even without a local reference.
Environment labels coexist with the exporter's numbered IDs for older links.

The site build uses Typst 0.15's [native cross-document references and links](https://typst.app/docs/reference/model/link/#links-in-bundle-export).
`content/bundle.typ` creates one `document(...)` per note. `lecture-link` delegates
to native `ref` and `link`, so labels, numbers, and destinations resolve together
in the compilation. HTML links point to the other HTML files; PDF links point
to the other PDFs with named destinations. Keep the PDF directory together to
follow these links offline. Each format is compiled in its own bundle.

Each note passes its header arguments directly to `#show: gabri_notes.with(...)`.
Keep `lec_num` literal and `title` a quoted string or plain bracketed content.
In a standalone preview, the helper reads those arguments from the destination's
source and displays its lecture number and title,
linking to the corresponding public HTML section. Exact environment and section
numbers require the bundle, where Typst can introspect every destination. This
fallback needs no generated files. A standalone PDF's website base can be
overridden with `--input course-url=https://example.org/course/`.

The bundle takes document titles from the resolved course configuration, whose
titles are validated against the authored headers before compilation.

`scripts/lecture_links.py` checks literal link calls against published sources
and unique labels before the build. Typst validates the actual reference targets
and computes their counters; there is no reference index or cache to refresh.

The final site audit checks rendered fragments. Rendering tests cover section
and environment insertions, lecture renumbering, appendices, supplementary notes,
incoming-only anchors, local references, numbered link text, and PDF link actions.

Typst's [bundle introspection](https://typst.app/docs/reference/bundle/#introspection)
shares labels, counters, and states across documents. Labels must therefore be
unique across the notes. The shared styles reset counters for each lecture,
scope native bibliographies to their own document bodies, and keep HTML citation
state separate by lecture. The HTML postprocessor preserves native destination
IDs and supplies the old numbered statement IDs as aliases.

## Build pipeline

`make html` builds the Rust converter, updates stale standalone Typst figures,
compiles native HTML and PDF bundles, postprocesses the HTML,
generates the course index and syllabus PDF, and assembles `html/`. The bundle
target requires Typst 0.15.1 and currently uses its experimental feature flag.
`make bundle` also produces `dist/6.7980-notes.zip`.

`make figures` rebuilds just the SVGs beside their sources. The figure builder
discovers new standalone sources automatically, skips shared libraries and
include-only component plots, and expands `gate.typ` into all six gate SVGs.
It recompiles every figure to pick up changes in imported dependencies. See
`content/figures/README.md` for source locations and individual rebuild commands.

The generated website has a schedule, 18 lecture and supplementary pages,
PDF downloads, links to chapter sources on GitHub, a syllabus, and local browser
assets. “View source” links to each note's source on the course repository's
`main` branch. Push source moves before
publishing the site. Chapter sources are not copied into the website or ZIP;
rebuilding removes the retired `html/source/` directory.
KaTeX 0.16.22 renders supported expressions; unsupported expressions
retain their Typst SVG rendering. No npm installation is needed for the course
build: the browser runtime and its license are under `html-exporter/assets/katex/`.

Use [Typst's built-in symbol shorthands](https://typst.app/docs/reference/symbols/#shorthands)
whenever an equivalent exists, such as `<=`, `>=`, `!=`, `~`, `:=`, `->`, `=>`,
`<=>`, and `...`. Keep named forms for symbols without an exact shorthand and
where code syntax or function calls require them, such as the accent `tilde(x)`.

When authoring indexed functions, group the index explicitly: `u_(i)(a)` and
`EE_(t)[x]`. Typst parses `u_i(a)` and `EE_t[x]` with the argument inside the
subscript. `scripts/test_lecture_math.py` checks the compiled math trees of all
configured notes for these mistakes. Use `cases(...)` for a brace spanning
several rows, and positive spacing between derivations and their annotations;
manual negative spacing can make the HTML overlap. KaTeX syntax validation does
not detect missing operands or visual overlap, so changes to the converter also
need a browser comparison with the native Typst rendering.

After the Rust converter has been built, a quicker rebuild is:

```sh
python3 scripts/build_site.py --skip-build --zip
```

Builds reuse unchanged figure variants, native lecture bundles, individual
postprocessed HTML pages, and the syllabus PDF. Dependency records include the
files actually read by Typst, compiler settings, and output checksums; missing
or modified outputs are rebuilt. Each lecture's final HTML is checked separately.
The native PDF and HTML compilations are cached as whole bundles because their
cross-document references share live labels and counters. A change to any
dependency of a bundle recompiles that bundle, keeping incoming references correct.
The index, public attachments, and validation checks still run on every build.

To bypass all build caches:

```sh
make force               # rebuild figures, lectures, and syllabus; recreate ZIP
make html FORCE=1        # force a site rebuild without the ZIP
make figures FORCE=1     # force only the figures
```

Both Python builders also accept `--force`. Cached lecture products live under
`.build/native-*`, `.build/lecture-pages/`, and `.build/lecture-cache/`.
Deleting `.build/` safely forces regeneration on the next build.

Compiler diagnostics are saved under `.build/logs/`. Build products in `.build/`,
`html/`, `dist/`, and `html-exporter/target/` are not versioned.

All lecture and supplementary PDFs share `content/meta/gabri_notes.typ`.
The print style uses A4 pages, 1.3-inch side margins, 1.6-inch top/bottom margins,
10.2pt New Computer Modern body text, and Source Sans 3 Bold headings. A ruled opening
panel carries the course, date, lecture title, and instructor. Each footer keeps
the full authored title beside the lecture identifier and a right-aligned
current/total page count. Long titles wrap without hyphenation; section markers
vary by heading level. Headings have more space above than below: 9/5mm for
sections, 7.5/4.5mm for subsections, and 6/4.5mm for deeper levels. Unnumbered
headings follow the same hierarchy. Block spacing collapses adjacent gaps,
and headings stay with the following text. Build with the
bundled font directory as shown in the build scripts. The HTML exporter selects
`gabri_notes_html.typ` and its CSS explicitly; the authored notes always use the
working PDF style.

## Source files

- Edit `content/*.typ` for explanations, equations, and proofs.
- Edit `html-export.json` for published notes, slides, and export settings.
- Edit `scripts/course_index.py` for course-home markup.
- Edit `html-exporter/src/course.css` for the homepage layout.
- Edit `html-exporter/src/gabri-notes.css` for the lecture layout.
- Edit `content/meta/gabri_notes_html.typ` for semantic HTML components.
- Edit `content/meta/gabri_notes.typ` for the native PDF layout.
- Edit `content/meta/notation.typ` for mathematical symbols, operators, and notation helpers shared by the notes and figures.
- Edit `content/meta/lovelace_html.typ` for HTML pseudocode.

Both note styles re-export `notation.typ`. Keep notation definitions in that
file and use the same convention throughout the course: `v*` for bold vectors
(such as `vx`), `c*` for calligraphic sets (such as `cX`), and `mat*` for upright
bold matrices (such as `matA`). `xhat` and `yhat` put hats on the corresponding
vectors; `mU` denotes the bold utility matrix with player subscript 1.
Use bold notation for whole vectors and vector blocks, including player strategies
(`vx_i`), iterates, gradients, finite probability vectors, and neural parameter
vectors (`vtheta`). Keep scalar coordinates plain (`x_(i,a)`, `g_a`), or use
explicit indexing of a bold vector (`vx[a]`). Hats, bars, and time indices
preserve the underlying scalar/vector distinction. Scalar-valued functions,
abstract policies and probability measures, discrete actions, and graph labels
are not made bold merely because they appear next to vectors. Use `ve` for
standard basis vectors and `vone` for the all-ones vector.
The HTML style selects the `html-` encodings of these same conventions for
KaTeX. Standalone figures import notation from `../../meta/notation.typ`.

`how_to_cite.url_prefix` in `html-export.json` sets the published base URL for
lecture citation links, currently `https://www.mit.edu/~6.7980/`. Keep the trailing
slash. Navigation and asset links remain relative so local previews and the
downloadable bundle work without a web server at that address.

## Public files

`scripts/public_files.py` defines note output paths, copied course illustrations,
slide output paths, required files, and permitted public asset types. Index links,
the site build, and the local deployment tool use that same contract. Deployment
still checks staged bytes, rejects private paths and symlinks, and excludes stray
files from the payload. A configured slide PDF needs no additional deployment
allowlist entry.
The source repository explicitly includes the configured lecture 0 PDF in
`.gitignore`; editable slide decks remain excluded. When adding another public
slide PDF, also make sure its source is included in version control so clean
checkouts can build it.

## Permalinks

Lecture HTML exposes anchor icons on sections (including unnumbered
headings), figures, tables, algorithms, theorem-style statements, proofs, proof
sketches, solutions, footnotes, and
numbered equations. Icons appear on hover or keyboard focus. Section and environment
icons sit in the left margin. Figures, tables, and algorithms with captions place
their icons immediately to the left of the caption label. Captionless algorithms
keep the icon beside their title. The shared side-column gutter is 32 pixels.
Footnote anchors sit to the left of the note. Equation anchors align to the left
edge of the right gutter, level with their numbered rows and outside the formula's
horizontal scroll area.
A footnote URL opens its margin copy
on desktop or its endnote on narrow screens; without JavaScript, it opens the endnote.
Click an icon to navigate to its anchor, or use the browser's
“Copy link address” action to share it. These are ordinary links and work
without JavaScript.

Authored Typst labels become the permalink fragment, including labels containing
colons or Unicode: `<tab:notation>` produces `#tab:notation`. Whitespace in a
label becomes a hyphen to keep the HTML ID valid. Labels are
exported even when nothing references them. Keep a label unchanged when moving
or renumbering an item to keep its permalink stable. Without a label, the
exporter uses the heading title or the item's kind and number, adding a suffix
for duplicates. Unlabeled proofs use `proof-1`, `proof-2`, and so on; proof
sketches and solutions have their own sequences. Label a proof explicitly, for
example `#proof[... ] <proof:main-result>`, to keep its URL stable when reordering
proofs. Native Typst targets and existing numbered statement anchors
remain available, so existing references continue to resolve. The lecture
outline uses the same section anchors as the permalink icons.

## Figures

All active figure dependencies live in `content/figures/<topic>/`, normally
matching the lecture's Typst filename. Shared figures retain their owning topic:
for example, `kernelized.typ` reuses `figures/efg_intro/nf_strategies.svg`.
Folder names never depend on lecture numbers. Each SVG has an editable Typst
source beside it, with the six gate variants sharing `gate.typ`; no separate
assets copy is needed.

```sh
make figures                           # rebuild every figure SVG
```

The same figure builder runs during the full site build. Editable sources
live under `content/figures/`; the dynamics helpers are in
`content/meta/dyns.typ`. SVGs beside the sources use the lecture PDF typography.
The builder also generates `.build/html-figures/` variants with Georgia body
labels and Source Sans 3 bold labels to match the HTML pages, preserving mathematical
fonts and explicit sans-serif labels. Georgia must be installed or supplied via
`TYPST_FONT_PATHS`; the build checks availability. Generated HTML sources select
these variants automatically; standalone figure PDFs are neither needed nor generated.

HTML SVGs retain their visible glyph outlines and include a transparent,
selectable text layer from Typst's original text runs. The HTML exporter embeds
these SVGs directly into the page, so readers can select and copy labels rather
than interact with an opaque image. Repeated figures receive separate SVG IDs.
`make figures` builds the Rust exporter before regenerating these variants.

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
  #image("figures/learning_intro/self_play.svg", width: 300pt)
]
```

The two columns stack on narrow screens. `wrapped-figure-with-caption` accepts
a third content argument for a caption.

The first content argument is always the text and the second is the figure;
`side` chooses which side holds the figure. `text-width` controls the column
split. Image percentages are relative to the figure column: `width: 100%`
fills it, while `width: 60%` uses 60% of it. In PDFs, fixed and automatic image
widths are also preserved, and oversized images shrink to fit without changing
their aspect ratio. Smaller images remain centered in the figure column.

## Algorithms

The vendored Lovelace renderers create the numbered algorithm figure inside
`pseudocode` and `pseudocode-list`. Ruled headers, bottom rules, and hooked scope
lines are enabled by default (`booktabs: true`, `hooks: true`), matching the HTML
style. In the PDF renderer, `hooks: false` removes the horizontal ends; a length
such as `hooks: .5em` sets their width explicitly. Attach a label to the call and
pass an optional `caption` directly:

```typst
#pseudocode-list(
  numbered-title: [Example algorithm],
  caption: [An optional explanation of the algorithm.],
)[
  + Initialize the state.
  + *function* `NextStrategy()`
    + *return* $x$
] <algo-example>

See @algo-example.
```

Both entry points create exactly one `figure(kind: "algorithm")`, including when
the caption is omitted. Do not add an outer figure. `numbered-title` supplies the
title within the algorithm; `caption` supplies its figure caption. Numbering,
references, and the existing HTML figure and side-caption layout are preserved.

Write function names in backticks in both declarations and calls, as in the
example above. Keep mathematical arguments in math, for example
`` `ObserveUtility`($g^((t))$) ``.

## Typography and verification

The build loads the vendored static Source Sans 3 Regular (400) and Bold (700)
faces from `html-exporter/assets/fonts`. They are licensed under SIL OFL 1.1;
the license and pinned provenance ship beside the fonts. PDFs use New Computer
Modern for regular and italic body text. The shared `content/meta/typography.typ`
helper selects Source Sans 3 at the original authored sizes, without scaling.
Webfonts are self-hosted WOFF copies; regular is used for dates, small links, and diagram labels.
See the font directory README for reproducible font and webfont generation.

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
