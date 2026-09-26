# MIT 6.7980 · Topics in Multiagent Learning

Lecture notes and course materials for **MIT 6.7980** (Fall 2026), taught by
Constantinos Daskalakis and Gabriele Farina.

Read the notes on the [course website](https://www.mit.edu/~6.7980/) and consult
the [syllabus PDF](https://www.mit.edu/~6.7980/syllabus.pdf) for the schedule and
course policies. This repository contains the editable sources, written in
[Typst](https://typst.app/).

## Ways to contribute

Corrections, clearer explanations, worked examples, and improvements to figures
are welcome. A small fix to something that confused you while reading is a good
first contribution.

- **Report a problem:** open an [issue](https://github.com/gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning/issues)
  with the lecture title, section or theorem, and what seems wrong or unclear.
  Include a link to the passage and a suggested correction if you have one.
- **Suggest an edit:** follow the steps below and submit a pull request. Keep
  each pull request focused on one correction or related set of improvements.
- **Discuss a larger change:** open an issue before rewriting a substantial
  section or adding a new topic so we can agree on the scope.

## Set up your checkout

For editing and previewing notes, install [Git](https://git-scm.com/install/),
the desktop version of [VS Code](https://code.visualstudio.com/), and its
[Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist).
Tinymist includes a Typst compiler and live preview. The website build uses its
own toolchain, needed only for the
[optional command-line and website checks](#optional-command-line-and-website-checks)
at the end of this guide.

1. Sign in to GitHub and click **Fork** on the
   [course repository](https://github.com/gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning).
   This creates your own copy to which you can push changes.
2. In a terminal, clone your fork. Replace `YOUR-USERNAME` with your GitHub
   username; the HTTPS URL does not require setting up SSH keys.

   ```sh
   git clone https://github.com/YOUR-USERNAME/MIT-6.7980-Topics-in-Multiagent-Learning.git
   cd MIT-6.7980-Topics-in-Multiagent-Learning
   git switch -c clarify-nash-equilibrium
   code .
   ```

   Choose a branch name that describes your change. 
3. If `code .` is unavailable, launch VS Code and choose **File → Open Folder…**,
   then select the cloned repository. On macOS, you can also enable the terminal
   command using [VS Code's command-line setup](https://code.visualstudio.com/docs/setup/mac).
4. If you have not installed **Tinymist Typst** yet, install it when VS Code
   recommends it, or search for it in the Extensions view. Its extension ID is
   `myriad-dreamin.tinymist`.

Be sure to open the **whole repository folder** in VS Code so its checked-in
settings take effect. They configure the paged preview and the vendored Source Sans 3
fonts (SIL OFL 1.1). Regular and italic PDF body text uses New Computer Modern.

## Edit with a side-by-side preview

1. Open a lecture source, such as [`content/nfgs_nash.typ`](content/nfgs_nash.typ),
   from the Explorer sidebar. Each note is a standalone document.
2. With the `.typ` editor focused, press **Ctrl+K, then V** on Windows/Linux or
   **Cmd+K, then V** on macOS to open Tinymist's preview. You can also open the
   Command Palette (**Ctrl+Shift+P** / **Cmd+Shift+P**), search for
   **Typst Preview**, and choose the preview in an editor tab. Alternatively,
   the editor's title bar has a preview button, which appears only while a
   `.typ` file is the active editor:

   ![The Tinymist preview button in the VS Code editor title bar](docs/assets/tinymist-preview-button.png)
3. Keep the source on the left and the preview on the right. If they open in
   the same editor group, drag the preview tab to the right edge of the editor
   until a second group appears, then drop it.
4. Edit the source and watch the preview update. Save your changes with
   **Ctrl+S** / **Cmd+S**. Check the surrounding paragraphs, equations, and page
   breaks as well as the passage you changed.

The first preview may take longer while Typst downloads the packages used by
the notes. If compilation fails, open **View → Problems** and fix the first
reported error. If the preview command is missing, check that Tinymist is
enabled and a `.typ` source tab is active.

When editing a shared helper file (one of the files under
[`content/meta/`](content/meta/) that lectures import), open a lecture that uses
it and run **Typst: Pin Main** from the Command Palette to keep that lecture as
the preview target. Run **Typst: Unpin Main** when you want to switch to
another lecture.
See [Tinymist's VS Code guide](https://myriad-dreamin.github.io/tinymist/frontend/vscode.html)
for more editor options.

If you have not written Typst before, you can start with the
[Typst tutorial](https://typst.app/docs/tutorial/) and use nearby text in the
notes as a model for equations, examples, and proofs. Keep the existing imports
and document header when editing a lecture.

## Find the right source file

Each published note has a **View source** link to its file on GitHub. You can
also search the repository in VS Code with **Ctrl+Shift+F** / **Cmd+Shift+F** for
a distinctive phrase from the passage you want to change.

| What you want to change | Where to look |
| --- | --- |
| Lecture text, equations, examples, or proofs | [`content/`](content/), in the relevant `.typ` file |
| A figure | [`content/figures/`](content/figures/), grouped by topic; see the [figure guide](content/figures/README.md) |
| A citation | [`content/meta/refs.bib`](content/meta/refs.bib) and the citing lecture |
| Shared mathematical notation | [`content/meta/notation.typ`](content/meta/notation.typ) |
| Website rendering or build tools | [Build guide](docs/building.md) |

Edit the sources; `html/`, lecture PDFs, and the website ZIP are generated build
outputs. Preserve citations and acknowledgments when adapting material. Follow
the surrounding notation and reuse existing labels for references. The
[build guide](docs/building.md) explains how to link to results in other lectures
without hardcoding their numbers.

## Submit your changes

Preview the edited note and resolve any compilation errors. From the repository
root, review and commit your changes. The example below assumes you edited
`content/nfgs_nash.typ`; substitute your actual files and branch name.

```sh
git status
git diff
git add content/nfgs_nash.typ
git commit -m "Clarify the Nash equilibrium explanation"
git push -u origin clarify-nash-equilibrium
```

GitHub may ask you to authenticate when pushing over HTTPS. After the push
completes, open your fork on GitHub, choose **Compare & pull request**, and set
the base repository to `gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning`,
branch `main`. Describe what changed, why, and how you checked it. For
mathematical changes, explain why the correction is valid; for layout or
figure changes, include a screenshot of the result. Link any related issue,
and state whether you checked the Tinymist preview, compiled a PDF, or ran
the website checks.
Further commits pushed to the same branch update the pull request.

## Optional command-line and website checks

To compile an individual note from a terminal, install the
[Typst 0.15.1 CLI](https://github.com/typst/typst/releases/tag/v0.15.1), matching
the version used by the course build. From the repository root:

```sh
typst compile --font-path html-exporter/assets/fonts content/nfgs_nash.typ
```

This writes `content/nfgs_nash.pdf`, which you can open in any PDF viewer.
With Python **3.10 or later** and Make installed, `make check-pdf` checks that
all lecture and supplementary notes compile.

To check the website too, also install a current stable Rust toolchain with
Cargo, Node.js **22 or later**, Poppler (providing `pdfinfo`), and the Georgia
font used in website figures. See the [build guide](docs/building.md) for font
requirements and figure workflows. Initial builds download dependencies.

```sh
make html       # build the website and PDFs
make force      # rebuild everything, bypassing incremental caches
make check      # run tests and validate the built website
make serve      # serve the result locally; stop with Ctrl+C
```

While the server is running, open [the local preview](http://127.0.0.1:8798/).
Re-run `make html` and refresh the browser after further edits; the server does
not rebuild automatically. `make bundle` also creates the downloadable website
ZIP at `dist/6.7980-notes.zip`.
Unchanged figures and lecture builds are reused; see the
[incremental build and force options](docs/building.md#build-pipeline).
