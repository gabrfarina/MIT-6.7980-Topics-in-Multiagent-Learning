# Editable figure sources

Every SVG in this directory has an editable Typst source. Usually it has the
same basename beside the SVG. The six `ppad_completeness/gate_*.svg` files share
`ppad_completeness/gate.typ` and select their gate with a compiler input.

`make`, `make html`, and `make bundle` rebuild stale figure SVGs before
compiling the notes. Run `make figures` to update just the figures. The builder
also writes HTML variants under `.build/html-figures/`, using Georgia for body
labels and Source Sans 3 for bold labels, matching the HTML pages. Georgia must be
installed or available through `TYPST_FONT_PATHS`. Mathematical notation keeps
its math font. HTML variants also contain a selectable text layer taken directly
from Typst's layout; the visible glyph outlines retain the exact typography.
The SVGs beside the sources retain the PDF typography.

From the repository root, regenerate an individual figure with Typst 0.15.1:

```sh
typst compile --root . --font-path html-exporter/assets/fonts \
  content/figures/nfgs_nash/nash_plots.typ \
  content/figures/nfgs_nash/nash_plots.svg
```

For a gate, add `--input gate=assignment` (or `constant`, `addition`,
`subtraction`, `multiplication`, `comparison`) and compile `gate.typ` to the
corresponding `gate_<name>.svg`.

For a selectable HTML variant, use the exporter after `make figures` builds it:

```sh
html-exporter/target/release/notes-html-exporter --figure-svg --root . \
  content/figures/nfgs_nash/nash_plots.typ \
  .build/html-figures/nfgs_nash/nash_plots.svg
```

For gate variants, add `--figure-input gate=assignment` (or another gate name).
Shared typography is defined in
`libs/typography.typ`; new figures should import `figure-font` and `figure-style`,
use `#set text(font: figure-font, ...)`, and apply `#show: figure-style`.

The root flag lets figures import shared libraries and component plots.
`learning2/plots.typ` includes the four `ftr_*.typ` / `omd_euc.typ` files beside
it; these are large, generated Matplotlib drawing sources. Compile the combined
`plots.typ` to reproduce the existing four-panel SVG. The shared libraries in
`libs/` reuse `content/meta/linalg.typ`, and the extensive-form strategy figures
reuse `kernelized/vertices.typ`.

`scripts/build_figures.py` discovers standalone `.typ` sources recursively,
including those whose SVG has not been generated yet. It excludes `libs/`
directories and the include-only files listed in `SUPPORT_SOURCES`. New shared
libraries should go in `libs/`; add other include-only files to that exclusion
list. The builder records each variant's actual dependencies, including imported
libraries, included plots, and data files. It skips an output when its contents,
dependencies, compiler inputs, fonts, and rendering tools are unchanged. PDF and
HTML variants are checked separately, including all six gate variants and resolved
lecture-section labels. Missing outputs and failed builds are retried. Build
records live in `.build/figure-cache/`; removing that directory forces a rebuild.
Use `make figures FORCE=1` (or `python3 scripts/build_figures.py --force`) to
rebuild all figure variants without deleting the records yourself.
Historical font metrics and
lecture-level scaling can differ slightly under the current compiler.

## Rendering conventions

Figures use native Typst math for labels and `curve` commands for point-list
paths. Sampled gradient colors are converted to RGB so that SVG embedding in
PDFs retains the colors. Sans-serif labels use the bundled Source Sans 3 font.
Figure pages have transparent backgrounds; standalone drawings set their own
widths and scaling.
