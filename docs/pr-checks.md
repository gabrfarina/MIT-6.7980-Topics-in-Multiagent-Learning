# PR source and HTML checks

Two additional Actions complement the PDF preview. They run on opened, updated,
and reopened PRs. Neither uses AI, a model API, or an additional repository secret.
Both also have a **Run workflow** input for an existing open PR number.

## Source pre-screen

**Course source pre-screen** checks whether the PR merges with its current target
branch, validates note headers and syllabus metadata, checks configured assets and
cross-lecture references, and runs the repository's source Python regression suite.
Figure tests that need a compiled exporter run in the HTML job instead.
Whitespace errors are warnings. Individual test failures already present on the
target branch are listed as existing issues; new failing tests fail the check.
The target and proposed-merge logs remain available for investigation.

## HTML review

**Course HTML review** builds the complete target-branch website and proposed
merge website using their respective exporters and runs exporter regression tests.
It audits every generated note and the index with Chromium at 1280px and 390px,
opens solution disclosures, waits for fonts, and checks:

- KaTeX parsing, equations that remain unrendered, and accent counts/types against
  Typst's exported math metadata. This catches a bar silently becoming a hat even
  when both are valid KaTeX. Unsupported math preserved as Typst SVG is a warning.
- Page overflow, content outside its article, and clipped equations or figures.
  Intentional horizontal scrolling is allowed. Intended desktop sidenotes are
  excluded from article-boundary checks, but page overflow is still checked.
- Missing images, zero-size figures, broken SVG references, JavaScript errors,
  failed local resources, source/rendered figure inventories, and local links and
  anchors, including links between lectures.
- Up to 80 distinct external URLs newly introduced by the PR. Confirmed 404/410
  responses fail; timeouts, authentication requirements, rate limits, and blocked
  destinations warn. Existing external URLs are listed but not rechecked. These
  network checks are unauthenticated and restricted to public HTTP(S) destinations.

The bot posts before/after crops directly in the PR. Matching uses DOM content and
rendered blocks, so inserting a paragraph does not make every paragraph below it
look deleted. Desktop and mobile changes are shown separately. Long additions
are split into bounded panels; continuation panels can use one column. Full-page
screenshots, both generated websites, all crops, JSON findings, and build logs are
available as a 14-day Actions artifact. PR comments show at most 40 crops; the
report records any additional crop limit.

Exact browser/static findings present in both snapshots are labeled existing
issues. Compilation or browser failures leave an incomplete-check error, never a
claim that the content passed. This is an integration comparison (current target
versus proposed merge), while the existing PDF preview compares the merge base
with the student's head commit.

## Limits and publication

These are deterministic checks, not a mathematical correctness review. Accent
metadata checks do not prove equivalence of arbitrary expressions. The browser
checks cover two Chromium viewport widths, not every browser, accessibility mode,
or possible responsive layout. A reachable external URL can still point at the
wrong document. Structural and visual findings still need human review.

PR builds have read-only permissions and no publishing credentials. A separate
**Publish course PR checks** workflow runs trusted default-branch code, validates
the originating workflow and current PR revisions, validates bounded JSON/PNG
data, and updates a bot comment. It never executes artifacts. HTML images use
separate `html-previews-pr-N` branches, avoiding races with the PDF image branches.
Stale results are skipped if either PR head or target branch changed; rerun the
check against the latest revisions. Compiler caches only contain build inputs and
outputs; no secrets are stored in them.

Run the tooling's regressions locally with:

```sh
python -m pip install -r scripts/visual_preview/requirements.txt
npm ci --ignore-scripts --prefix scripts/pr_checks
cd scripts/pr_checks
npx playwright install chromium
python -m unittest discover -p 'test_*.py'
node --test test_math.cjs test_browser.cjs
```

End-to-end website builds additionally need the tools in [the build guide](building.md),
including Georgia for figure text. CI installs Georgia from Ubuntu's Microsoft
core-font installer. Negative browser fixtures deliberately introduce malformed
KaTeX, a wrong accent, overflow, and a missing image inside a solution.
