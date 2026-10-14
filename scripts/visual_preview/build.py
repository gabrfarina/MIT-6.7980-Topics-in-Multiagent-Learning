"""Trusted entry point: invoke Typst, never a PR's shell/Python build scripts."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

from diff import compare

SOURCE = re.compile(r"content/[A-Za-z0-9_-]+\.typ\Z")
SUPPORT = {"kernelized/vertices.typ", "learning2/ftr_ent.typ", "learning2/ftr_euc.typ",
           "learning2/ftr_log.typ", "learning2/omd_euc.typ"}


def sources(root):
    return {n["source"] for n in json.loads((root / "html-export.json").read_text(encoding="utf-8"))["notes"]
            if SOURCE.fullmatch(n["source"])}


def select(before, after, changed):
    known = sources(before) | sources(after)
    direct = {p for p in changed if SOURCE.fullmatch(p) and p != "content/bundle.typ"}
    shared = any(p == "html-export.json" or p.startswith("syllabus/") or
                 p.startswith("html-exporter/assets/fonts/") or
                 (p.startswith("content/") and p not in direct) for p in changed)
    return sorted(known | direct if shared else direct)


def compile_file(typst, root, source, dest, log, inputs=()):
    path = (root / source).resolve()
    if not path.is_relative_to(root.resolve()) or path.is_symlink():
        raise ValueError("Source escapes checkout")
    args = [typst, "compile", "--root", str(root), "--font-path",
            str(root / "html-exporter/assets/fonts")]
    for item in inputs:
        args.extend(["--input", item])
    args.extend([str(path), str(dest)])
    run = subprocess.run(args, cwd=root, capture_output=True, text=True, timeout=180)
    log.write_text(run.stdout + run.stderr, encoding="utf-8")
    if run.returncode:
        raise RuntimeError(f"Typst failed for {source}; see {log.name}")


def rebuild_figures(typst, root, changed, out):
    if not any(p.startswith("content/figures/") and p.endswith(".typ") for p in changed):
        return
    # Rebuild all PDF figures when a figure helper changes. Known support modules
    # are not entry points. This uses the same naming convention as build_figures.py.
    figures = root / "content/figures"
    for source in sorted(figures.rglob("*.typ")):
        rel = source.relative_to(figures).as_posix()
        if "libs" in source.parts or rel in SUPPORT:
            continue
        if rel == "calibration/route.typ":
            raise RuntimeError("calibration/route.typ needs a section-reference build; regenerate its SVG before previewing")
        variants = [None]
        if rel == "ppad_completeness/gate.typ":
            variants = ["assignment", "constant", "addition", "subtraction", "multiplication", "comparison"]
        for variant in variants:
            dest = source.with_name(f"gate_{variant}.svg") if variant else source.with_suffix(".svg")
            inputs = ["figure-format=pdf"] + ([f"gate={variant}"] if variant else [])
            compile_file(typst, root, source.relative_to(root), dest,
                         out / ("figure-" + rel.replace("/", "-") + str(variant) + ".log"), inputs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--before", type=Path, required=True)
    parser.add_argument("--after", type=Path, required=True)
    parser.add_argument("--base-sha", required=True)
    parser.add_argument("--head-sha", required=True)
    parser.add_argument("--pr", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--typst", default="typst")
    args = parser.parse_args()
    args.before, args.after, args.output = args.before.resolve(), args.after.resolve(), args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    actual_head = subprocess.check_output(["git", "-C", str(args.after), "rev-parse", "HEAD"], text=True).strip()
    if actual_head != args.head_sha:
        raise SystemExit("PR changed during checkout; rerun for the current commit")
    changed = subprocess.check_output(["git", "-C", str(args.after), "diff", "--name-only",
                                       args.base_sha, args.head_sha], text=True).splitlines()
    report = {"version": 1, "pr": args.pr, "base": args.base_sha, "head": args.head_sha, "notes": []}
    selected = select(args.before, args.after, changed)
    figure_errors = {}
    for side, root in (("before", args.before), ("after", args.after)):
        try:
            rebuild_figures(args.typst, root, changed, args.output)
        except (RuntimeError, subprocess.TimeoutExpired, ValueError) as e:
            figure_errors[side] = str(e)
    for source in selected:
        note = {"source": source, "regions": [], "errors": []}
        name = Path(source).stem
        pdfs = []
        for side, root in (("before", args.before), ("after", args.after)):
            dest = args.output / f"{name}-{side}.pdf"
            if not (root / source).exists():
                pdfs.append(None)
                continue
            try:
                if side in figure_errors:
                    raise RuntimeError(figure_errors[side])
                compile_file(args.typst, root, source, dest, args.output / f"{name}-{side}.log")
                pdfs.append(dest)
            except (RuntimeError, subprocess.TimeoutExpired, ValueError) as e:
                note["errors"].append(f"{side}: {e}")
                pdfs.append(None)
        if not note["errors"]:
            note["regions"] = compare(*pdfs, args.output, name)
        report["notes"].append(note)
    (args.output / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"Compared {len(selected)} notes; {sum(len(n['regions']) for n in report['notes'])} cropped images")
    if any(n["errors"] for n in report["notes"]):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
