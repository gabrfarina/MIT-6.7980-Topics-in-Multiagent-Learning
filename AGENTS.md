# Course materials

Reflect every user-requested course change in both the current index page and the syllabus PDF in the same update.

- The editable syllabus and schedule are in `syllabus/6.7980 F26 Syllabus.typ`.
- Generate the current `html/index.html` with `scripts/course_index.py` and `html-export.json`.
- Rebuild `syllabus/6.7980 Fall 2026 Syllabus.pdf` and synchronize the copy at `html/syllabus.pdf`, which is linked from the index page.
- Edit shared facts in the syllabus's `course` dictionary and prose in its `item(...)` / `course-text(...)` blocks. The index reads these via `scripts/course_data.py`; do not duplicate course text in Python.
- `html-export.json` uses `notes` with stable `syllabus_ids` and a separate `slides` map keyed by lecture ID. Numbers, dates, course facts, and citation metadata are generated in `.build/html-export.json`; do not author redundant numbers or dates. Use `scripts/public_files.py` for export paths and validation shared with deployment.
- Verify schedule consistency and visually check the rebuilt PDF after changes.
- Reorder the syllabus's date-free `lecture(...)`, `no-class(...)`, and `module[...]` outline. `schedule(class-dates, outline)` assigns dates and lecture numbers; verified class dates and fixed academic-calendar exceptions are in `syllabus/fall-2026-calendar.typ`. Keep stable lecture IDs with their topics and map notes through `syllabus_ids` in `html-export.json`.
- Use Source Sans 3 for bold text and headings in the syllabus PDF, at the original authored sizes, with no size adjustment. Use New Computer Modern for regular and italic body text, and check the embedded fonts when changing typography.
- Load the vendored static regular and bold Source Sans 3 faces with `--font-path html-exporter/assets/fonts` when compiling the syllabus. `make syllabus` rebuilds and synchronizes both PDF copies with this setting; the full site build uses it too.
- Use idiomatic Typst symbol shorthands wherever an equivalent shorthand exists throughout the material, including notes, figures, and shared helpers: for example, `<=`, `>=`, `!=`, `~`, `:=`, `->`, `=>`, `<=>`, and `...`. Preserve named forms where required by code syntax or function calls, such as `tilde(x)`, and for symbols without an exact shorthand, such as the centered ellipsis `dots.c`.

# Website date and time convention

- Display and interpret all human-facing website dates and times in Boston time (`America/New_York`, US Eastern), including date/time inputs, tables, charts, and tooltips. Handle daylight saving time automatically; never use the visitor's browser timezone implicitly. Keep machine timestamps in UTC/ISO format.

# FoW arena connection settings

- The user has approved hardcoding `https://6s890.lids.mit.edu` as the default FoW arena. It may appear in the public frontend and documentation.
- An explicit arena link takes precedence over the browser's remembered successful connection, which takes precedence over the default. Remember only the validated backend origin after a successful connection.
- Keep team tokens in memory only and scrub them from the URL before making requests. A token-bearing link must provide its own explicit arena address; never send its token to a remembered or default destination implicitly.
- Label ratings as `Elo` in the FoW interface; use standard per-team Elo ratings with K=8 and the backend API identifier `elo`. Rank by Elo, with no uncertainty or lower-bound score. Select the first available team uniformly at random, then its opponent with weights proportional to the standard deviation of the Elo expected score, and play both colors. Every rated game counts across versions.

- FoW match assignments have one global 15-second minimum gap, including return-color games and retries; there is no per-team scheduling cooldown. Leaderboard W/L/D and game counts show the active version; matrix W/L/D shows games between both active versions. Elo remains a floating-point, lifetime team rating.

- The FoW team named `Baseline` is a fixed Elo reference at 1000: never update its rating, always expose 1000, and use 1000 when calculating opponents’ expected scores. Its W/L/D and game counts still update normally. Other teams retain K=8 lifetime ratings.
