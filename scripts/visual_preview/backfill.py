"""Replay open upstream PRs as private draft PRs, preserving student commits.

Run from an authenticated Git checkout. The target MUST be private. Only target
branches and draft PRs are created; no upstream PR is commented on or modified.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import urllib.request


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="owner/repo to read")
    parser.add_argument("--target", required=True, help="private owner/repo to write")
    parser.add_argument("--tooling-ref", default="main")
    parser.add_argument("--output", type=Path, default=Path(".build/history-previews.json"))
    args = parser.parse_args()
    root = Path.cwd()

    def git(*command, input=None, env=None):
        return subprocess.check_output(["git", *command], input=input, text=True, env=env).strip()

    credential = subprocess.run(["git", "credential", "fill"],
                                input="protocol=https\nhost=github.com\n\n", text=True,
                                capture_output=True, env={**os.environ, "GIT_TERMINAL_PROMPT": "0"})
    if credential.returncode:
        raise SystemExit("Git could not supply credentials (credential output withheld)")
    fields = dict(line.split("=", 1) for line in credential.stdout.splitlines() if "=" in line)
    secret = fields["password"]

    def api(method, path, data=None):
        req = urllib.request.Request("https://api.github.com/repos/" + path,
                                     data=json.dumps(data).encode() if data is not None else None,
                                     headers={"Authorization": "Bearer " + secret,
                                              "Accept": "application/vnd.github+json"}, method=method)
        with urllib.request.urlopen(req, timeout=60) as response:
            return json.load(response)

    if not api("GET", args.target)["private"] or args.source == args.target:
        raise SystemExit("Choose a separate PRIVATE target repository")
    if git("remote", "get-url", "origin").removesuffix(".git") != "https://github.com/" + args.target:
        raise SystemExit("origin must point to the chosen target")
    if git("status", "--porcelain"):
        raise SystemExit("Commit or save local changes first")
    prs = []
    for page in range(1, 11):
        batch = api("GET", f"{args.source}/pulls?state=open&per_page=100&page={page}")
        prs.extend(batch)
        if len(batch) < 100:
            break
    if not prs:
        print("No open upstream PRs")
        return
    git("fetch", "--no-tags", "https://github.com/" + args.source + ".git",
        *[f"+refs/pull/{p['number']}/head:refs/remotes/history/pr-{p['number']}" for p in prs])
    existing = []
    for page in range(1, 11):
        batch = api("GET", f"{args.target}/pulls?state=open&per_page=100&page={page}")
        existing.extend(batch)
        if len(batch) < 100:
            break
    tools = git("ls-tree", "-r", args.tooling_ref, "--", ".github/workflows",
                "scripts/visual_preview", "docs/visual-previews.md").splitlines()
    bases = {}
    results = []
    args.output.parent.mkdir(parents=True, exist_ok=True)
    index = root / ".build/history-preview.index"
    env = {**os.environ, "GIT_INDEX_FILE": str(index)}
    for pr in prs:
        head = pr["head"]["sha"]
        base = git("merge-base", pr["base"]["sha"], head)
        base_branch = f"codex/history-base-{base[:12]}"
        # A tooling-only child of the original merge base ensures a conflict-free
        # replay and leaves the student's exact head SHA and source diff intact.
        if base not in bases:
            remote = git("ls-remote", "origin", f"refs/heads/{base_branch}")
            if remote:
                bases[base] = remote.split()[0]
            else:
                git("read-tree", base, env=env)
                for entry in tools:
                    mode_type_sha, path = entry.split("\t", 1)
                    mode, kind, sha = mode_type_sha.split()
                    git("update-index", "--add", "--cacheinfo", f"{mode},{sha},{path}", env=env)
                tree = git("write-tree", env=env)
                commit = git("commit-tree", tree, "-p", base, "-m", "Install trusted tooling for historical preview")
                git("push", "origin", f"{commit}:refs/heads/{base_branch}")
                bases[base] = commit
        head_branch = f"codex/history-pr-{pr['number']}"
        git("push", "origin", f"{head}:refs/heads/{head_branch}")
        found = next((p for p in existing if p["head"]["ref"] == head_branch), None)
        if found:
            target = found
        else:
            target = api("POST", f"{args.target}/pulls", {
                "title": f"[Upstream {pr['number']}] {pr['title']}"[:256],
                "head": head_branch, "base": base_branch, "draft": True,
                "body": f"Private visual-preview replay of [the original PR]({pr['html_url']}).\n\n"
                        f"Original head: `{head}`\n\nOriginal merge base: `{base}`\n\n"
                        "The student commit is preserved unchanged. The target branch adds only trusted preview tooling "
                        "to the original merge base. The bot compares the original before/after lecture PDFs here. "
                        "HTML and EPUB changes are outside this PDF preview.\n\n"
                        "This is a snapshot for review, not a replacement submission. No comment is posted upstream."
            })
        result = {"upstream": pr["number"], "title": pr["title"], "head": head, "base": base,
                  "private_pr": target["number"], "url": target["html_url"]}
        results.append(result)
        args.output.write_text(json.dumps(results, indent=2), encoding="utf-8")
        print(json.dumps(result), flush=True)
    print(f"Prepared {len(results)} private historical previews", flush=True)


if __name__ == "__main__":
    main()
