# Cropped Typst previews on pull requests

Opening or updating a PR builds the affected lecture PDFs at the PR's merge base
and current head. A bot updates one comment with side-by-side PNGs of changed
regions. Unchanged pages are omitted. Red and green bars identify changed bands;
the surrounding lines provide context. No student setup or manual screenshots
are needed.

The `Typst visual preview` run contains full PDFs, compiler logs and every crop
in the `typst-visual-preview` artifact (retained for 14 days). The comment displays
up to 60 crops, and explicitly reports truncation or compilation failure.

## Installation

Merge the two workflows and `scripts/visual_preview` onto the default branch
before opening a test PR. Enable GitHub Actions. The publisher needs permission
to write repository contents and PR comments; organization policies can restrict
these permissions. No personal access token, public hosting, or custom secret is
needed. Images are stored in independent `visual-previews-pr-N` branches in the same
repository, so private materials remain private. Readers need repository access.

The publisher embeds immutable relative blob URLs with `?raw=true`, using
[GitHub's documented format for images in PR comments](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#images).
Private images require an authenticated viewer with repository access. The blob
link and downloadable artifact are also available. API-based validation confirms
the bot comment and stored images; a signed-in browser is needed to visually
verify inline rendering in the target client.

## What is compared

- The baseline is the merge base, so the preview describes the entire current PR.
- Editing a lecture builds that lecture. Editing shared notation, styles, fonts,
  figures or syllabus metadata conservatively builds all configured notes.
- Typst is pinned to 0.15.1; both builds use the vendored course fonts.
- PDF figure sources use the repository's figure naming conventions. The special
  calibration route with injected section references currently fails explicitly
  if a figure rebuild encounters it; it is not silently compared using a stale SVG.
- Text anchors match rendered bands across page breaks. Matched bands are also
  compared as pixels to catch formula, font and figure changes.
- Crops preserve each line/figure rendering but compact vertical gaps. They are
  for content review, not page-layout proofing. Running footers and page margins
  are excluded using the current course template's dimensions.
- Small gaps retain their original backgrounds, so shaded boxes remain continuous.
  Gray changelog separators are treated as decoration, not independent old/new content.
- Theorem borders and proof sidebars do not join separate text lines when
  matching content, so a page break through an unchanged theorem/proof does not
  appear as a deletion and insertion. Very large edits are split between complete rendered bands, with
  preceding context in the first tile and following context in the last.
  Corresponding context is vertically aligned. Middle tiles containing only
  inserted/deleted content use a single column. HTML output is not compared.

## Trust boundary

The PR workflow has a read-only token, no secrets, and uses tooling from the base
repository's default branch. It invokes Typst directly rather than executing student build scripts.
The separate `workflow_run` publisher runs from the default branch. It checks the
workflow identity, GitHub's PR association, current head and merge-base hashes,
and validates the report, paths, image type, dimensions and size. Artifacts are
data, never executed. Old runs cannot replace the current head's preview. The
only branches it writes are `visual-previews-pr-N`, one for each PR.

Image commits are intentionally retained so existing comment links keep working.
For long-running deployment, periodically archive/clean those branches when old
previews are no longer needed.

## Local checks

For a PR that already existed before installation, select **Actions → Typst visual
preview → Run workflow**, keep the default branch selected, and enter its PR
number. This uses its current head and merge base, and publishes in that PR
without changing the student's branch or closing/reopening the PR. Manual runs
from non-default branches are rejected by the publisher.

To replay currently open upstream PRs into a separate private repository, run
from its authenticated Git checkout (on Windows, use WSL Git if that is where
credentials are configured):

```sh
python scripts/visual_preview/backfill.py \
  --source gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning \
  --target YOUR-ACCOUNT/YOUR-PRIVATE-REPOSITORY
```

This creates private draft PRs with the original student head commits and
tooling-only base branches rooted at each original merge base. It never posts
upstream. Existing snapshots are reused; divergent rewritten heads require
manual inspection rather than a force push. The mapping is saved in
`.build/history-previews.json`. Rerun a snapshot's workflow in Actions to rebuild
its images. To republish an existing artifact without compiling again, run
`Publish Typst preview` manually with the original build's numeric `run_id`.
These snapshots do not automatically follow later upstream commits.

Install `scripts/visual_preview/requirements.txt`, then run:

```sh
python -m unittest discover -s scripts/visual_preview -p 'test_*.py'
python scripts/visual_preview/build.py --before /path/to/base-checkout \
  --after /path/to/pr-checkout --base-sha BASE --head-sha HEAD --pr 1 \
  --output .build/preview
```

Both checkouts must have the commits available locally. `typst` must be on PATH,
or pass its executable path with `--typst`.
