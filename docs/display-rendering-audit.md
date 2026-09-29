# Display rendering audit — September 12, 2026

Visually reviewed all 250 display blocks on the 17 lecture and supplementary
pages configured in `html-export.json`. The review covered subscripts and
superscripts, multiline equations, matrices and vectors, delimiters, and proof
annotations. Formula grouping was also inspected in the compiled Typst trees.

Repairs:

- S1: kept the marginal-distribution and utility arguments outside their indices,
  and kept the expectation difference outside the multiplier's index.
- Lecture 5: corrected the softmax argument grouping. Fixed the exporter to
  preserve all entries of Typst column vectors instead of emitting empty arrow
  accents.
- Lecture 6: kept the conditional expectation's operand outside its index.
- Equilibrium algorithms: preserved three literal set-difference backslashes
  that previously became TeX spacing commands.
- Refinements: replaced the isolated opening brace with a brace spanning the
  entire trembling linear program.
- Swap regret: removed negative annotation spacing that overlapped the formula.

All 250 displays also passed browser checks for vertical clipping and inaccessible
left edges at desktop width and a 390-pixel viewport. Wide mobile equations retain
horizontal scrolling. The repaired displays were rechecked visually in HTML;
pages affected by source changes were checked in the rebuilt PDFs.

`make html` and `make check` passed: 103 Python tests, 86 Rust tests, and 2,475
KaTeX expressions with no errors or SVG fallbacks. The index and both syllabus
PDF copies were rebuilt and synchronized; the syllabus passed visual and font
checks. Regression tests now cover column vectors, literal backslashes, and
argument grouping across every configured note.
