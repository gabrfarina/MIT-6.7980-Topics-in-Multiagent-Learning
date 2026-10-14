"""Trusted orchestration for read-only PR checks and bounded review artifacts."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time


def command(args, *, cwd=None, timeout=900, env=None):
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True,
                            errors="replace", timeout=timeout, env=env)
    return result.returncode, result.stdout + result.stderr


def arguments(kind):
    parser = argparse.ArgumentParser()
    parser.add_argument("--checkout", type=Path, required=True)
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    parser.add_argument("--pr", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not all(re.fullmatch(r"[0-9a-f]{40}", x) for x in (args.base, args.head)) or args.pr < 1:
        parser.error("Expected authoritative PR number and commit SHAs")
    args.checkout = args.checkout.resolve()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    report = dict(version=1, kind=kind, pr=args.pr, base=args.base, head=args.head,
                  findings=[], checks=[], regions=[], coverage={})
    return args, report


def prepare(args, report):
    missing=[name for name in ('typst','pdfinfo','node') if not shutil.which(name)]
    if missing:
        raise RuntimeError('Missing check dependencies: '+', '.join(missing))
    status,fonts=command(['typst','fonts'])
    if status or 'Georgia' not in fonts.splitlines():
        raise RuntimeError('Georgia must be installed for the course regression suite and figures')
    git = ["git", "-C", str(args.checkout)]
    status, sha = command(git + ["rev-parse", "HEAD"])
    if status or sha.strip() != args.head:
        raise RuntimeError("PR head changed during checkout; rerun for its current commit")
    before = args.output / "work-before"
    after = args.output / "work-after"
    status, log = command(git + ["worktree", "add", "--detach", str(before), args.base])
    if status:
        raise RuntimeError(log)
    status, log = command(git + ["merge-tree", "--write-tree", args.base, args.head])
    (args.output / "merge.log").write_text(log, encoding="utf-8")
    if status:
        report["findings"].append(dict(level="error", code="merge-conflict", page="",
                                        message="PR cannot merge cleanly with its current target branch. See merge.log."))
        return before, None
    tree = log.splitlines()[0]
    env = {**os.environ, "GIT_AUTHOR_NAME": "PR checks", "GIT_COMMITTER_NAME": "PR checks",
           "GIT_AUTHOR_EMAIL": "checks@localhost", "GIT_COMMITTER_EMAIL": "checks@localhost"}
    status, commit = command(git + ["commit-tree", tree, "-p", args.base, "-p", args.head,
                                     "-m", "Temporary PR integration check"], env=env)
    if status:
        raise RuntimeError(commit)
    status, log = command(git + ["worktree", "add", "--detach", str(after), commit.strip()])
    if status:
        raise RuntimeError(log)
    _, changed = command(git + ["diff", "--name-only", args.base, commit.strip()])
    report["changed_files"] = changed.splitlines()
    report["coverage"]["comparison"] = "Current target branch versus the proposed merge, including integration changes."
    return before, after


def run_check(report, output, name, side, cmd, root, timeout=900, env=None):
    started = time.monotonic()
    try:
        status, log = command(cmd, cwd=root, timeout=timeout, env=env)
    except subprocess.TimeoutExpired:
        status, log = 124, f"Check timed out after {timeout} seconds."
    filename = f"{side}-{name}.log"
    (output / filename).write_text(log, encoding="utf-8")
    result = dict(name=name, side=side, status="pass" if status == 0 else "fail",
                  seconds=round(time.monotonic() - started), log=filename)
    report["checks"].append(result)
    print(f"{side}: {name}: {result['status']} ({result['seconds']} s)", flush=True)
    return result


def finish(args, report):
    report["failed"] = any(x["level"] == "error" for x in report["findings"])
    report['coverage']['findings_total']=len(report['findings'])
    report["findings"] = sorted(report["findings"],key=lambda x:(x['level']!='error',bool(x.get('inherited'))))[:2000]
    (args.output / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    lines = [f"## {report['kind']} PR check", "",
             f"Compared target `{args.base[:7]}` with PR `{args.head[:7]}` integrated into it.", ""]
    for check in report["checks"]:
        lines.append(f"- {check['side']} / {check['name']}: **{check['status']}** ({check['seconds']} s)")
    lines.append("")
    for finding in report["findings"][:80]:
        message = str(finding["message"]).replace("`", "'").replace("\n", " ")[:500]
        lines.append(f"- **{finding['level']} / {finding['code']}**: {message}")
    if not report["findings"]:
        lines.append("No issues detected by the configured checks.")
    lines += ["", "This is a deterministic pre-screen, not a mathematical correctness review."]
    text = "\n".join(lines) + "\n"
    (args.output / "summary.md").write_text(text, encoding="utf-8")
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(summary, "a", encoding="utf-8") as stream:
            stream.write(text)
    return int(report["failed"])
