# MIT 6.7980 · Topics in Multiagent Learning

Lecture notes and course materials for **MIT 6.7980, Fall 2026**, taught by
**Constantinos Daskalakis and Gabriele Farina**.

The course studies game theory, optimization, and learning in multiagent systems:
Nash and correlated equilibria, regret minimization, extensive-form games,
stochastic games, and the computational complexity of equilibrium computation.
The [syllabus](syllabus/6.7980%20Fall%202026%20Syllabus.pdf) contains the full
course description, schedule, and policies.

The notes are written in [Typst](https://typst.app/). This repository includes
the Rust HTML converter and the scripts needed to build a static course website,
lecture PDFs, and a downloadable website bundle from the same sources.

## Getting started

Install Typst **0.15.1**, a current stable Rust toolchain with Cargo, Python
**3.9 or later**, Node.js **22 or later**, and Make. Initial builds download
Cargo dependencies and the Typst packages referenced by the notes. The optional
EPUB build (`make epub`) also needs [uv](https://docs.astral.sh/uv/), or the
`beautifulsoup4` and `lxml` Python packages.

```sh
git clone git@github.com:gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning.git
cd MIT-6.7980-Topics-in-Multiagent-Learning
make bundle
make serve
```

Open **http://127.0.0.1:8798/** to browse the course schedule and notes.
The portable site is written to `html/`, and its ZIP to
`dist/6.7980-notes.zip`. The site includes local fonts and KaTeX assets for
offline reading.

## Repository layout

| Path | Contents |
| --- | --- |
| [`content/content/`](content/content/) | Current lecture notes and supplementary readings |
| [`content/meta/`](content/meta/) | Shared notation, bibliography, and HTML/PDF templates |
| [`content/figures/`](content/figures/) | Figures and their editable sources |
| [`content/assets/`](content/assets/) | Shared rendered lecture illustrations |
| [`syllabus/`](syllabus/) | Editable syllabus, schedule, and current PDF |
| [`html-exporter/`](html-exporter/) | Rust converter, stylesheets, fonts, and KaTeX runtime |
| [`scripts/`](scripts/) | Site generation, figure preparation, and validation |
| [`html-export.json`](html-export.json) | Site metadata and lecture-to-schedule mapping |
| [`website/`](website/) | Course homepage illustration |
| [`docs/`](docs/) | Build details and source provenance |

## Building and checking changes

```sh
make html       # regenerate the course website and PDFs
make syllabus   # rebuild the syllabus, both PDF copies, and the index schedule
make check      # run Python/Rust tests and validate the built site and math
make bundle     # build, validate, and package the portable website
make epub       # package the built website as dist/6.7980-notes.epub
```

The syllabus is the source of truth for the schedule. When changing course
logistics, descriptions, or policies, update both the syllabus and the index
generator, rebuild the site, and check the resulting PDF. See
[the build guide](docs/building.md) for figure generation and rendering details.

Reorder `lecture(...)` and `module[...]` entries in the syllabus's `outline`;
`schedule(class-dates, outline)` assigns dates and zero-based lecture numbers.
The verified Tuesday/Thursday dates and fixed MIT calendar exceptions live in
[`syllabus/fall-2026-calendar.typ`](syllabus/fall-2026-calendar.typ).
`no-class(...)` entries consume a date but no lecture number. Keep each lecture's
stable ID with its topic so its notes remain linked after reordering.

## Contributing

Corrections, clearer explanations, additional examples, and improvements to
figures and exercises are welcome. Open an
[issue](https://github.com/gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning/issues)
to discuss a change, or submit a pull request with the relevant Typst sources.
Include the validation you ran and a rendered preview when changing layout.

Edit source files rather than generated HTML. Keep citations and acknowledgments
when adapting material.
