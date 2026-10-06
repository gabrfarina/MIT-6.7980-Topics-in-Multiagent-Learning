"""Publish validated data from a read-only render job. Never execute its output."""
from __future__ import annotations

import base64
import json
import os
from pathlib import Path
import re
import urllib.error
from urllib.parse import urlencode
import urllib.request

from PIL import Image

MARKER = "<!-- typst-visual-preview:v1 -->"
BRANCH = "visual-previews"
MAX_IMAGES = 60
SAFE_SOURCE = re.compile(r"content/[A-Za-z0-9_-]+\.typ\Z")
SAFE_IMAGE = re.compile(r"[A-Za-z0-9_-]+\.png\Z")


class GitHub:
    def __init__(self):
        self.repo = os.environ["GITHUB_REPOSITORY"]
        self.token = os.environ["GITHUB_TOKEN"]

    def api(self, method, path, body=None):
        req = urllib.request.Request(
            f"https://api.github.com/repos/{self.repo}/{path}".rstrip("/"),
            data=json.dumps(body).encode() if body is not None else None,
            headers={"Authorization": f"Bearer {self.token}", "Accept": "application/vnd.github+json",
                     "X-GitHub-Api-Version": "2022-11-28"}, method=method)
        with urllib.request.urlopen(req, timeout=60) as response:
            return json.load(response)


def pull_request_candidates(github, run):
    """Resolve PRs using GitHub run metadata, including runs from forks."""
    if run["pull_requests"]:
        return run["pull_requests"]
    # Fork runs can have no PR association, and looking up their commit in the
    # base repository can also return nothing. Query the source branch instead.
    source = run.get("head_repository") or {}
    owner = (source.get("owner") or {}).get("login")
    branch = run.get("head_branch")
    if not owner or not source.get("full_name") or not branch:
        print("PR lookup unavailable: workflow run has no source repository or branch")
        return []
    candidates = []
    page = 1
    while True:
        query = urlencode({"state": "open", "head": f"{owner}:{branch}",
                           "per_page": 100, "page": page})
        prs = github.api("GET", f"pulls?{query}")
        candidates.extend(pr for pr in prs
                          if (pr["head"].get("repo") or {}).get("full_name") == source["full_name"]
                          and pr["head"]["ref"] == branch)
        if len(prs) < 100:
            break
        page += 1
    print(f"Source-branch lookup found {len(candidates)} candidate PR(s)")
    return candidates


def validate_report(folder, pr, base, head):
    path = folder / "report.json"
    if path.is_symlink() or path.stat().st_size > 1_000_000:
        raise ValueError("Invalid report size or path")
    report = json.loads(path.read_text(encoding="utf-8"))
    if (report.get("version"), report.get("pr"), report.get("base"), report.get("head")) != (1, pr, base, head):
        raise ValueError("Report does not match the current PR")
    if not isinstance(report.get("notes"), list) or len(report["notes"]) > 100:
        raise ValueError("Invalid note list")
    images = []
    total = 0
    for note in report["notes"]:
        if not SAFE_SOURCE.fullmatch(note["source"]):
            raise ValueError("Invalid source path")
        if len(note["errors"]) > 10 or len(note["regions"]) > 1000:
            raise ValueError("Invalid report bounds")
        for region in note["regions"]:
            if not SAFE_IMAGE.fullmatch(region["file"]):
                raise ValueError("Invalid image path")
            for field in ("before_pages", "after_pages"):
                if not re.fullmatch(r"(?:none|[0-9,]{1,300})", region[field]):
                    raise ValueError("Invalid page label")
            if len(images) >= MAX_IMAGES:
                continue
            image = folder / region["file"]
            if image.is_symlink() or image.stat().st_size > 8_000_000:
                raise ValueError("Invalid image size or path")
            data = image.read_bytes()
            total += len(data)
            if total > 40_000_000:
                raise ValueError("Preview exceeds upload budget")
            with Image.open(image) as png:
                if png.format != "PNG" or png.width > 5000 or png.height > 2000:
                    raise ValueError("Invalid image format or dimensions")
                png.verify()
            images.append((region["file"], data))
    return report, images


def upload_images(api, pr, images):
    branch = f"{BRANCH}-pr-{pr}"
    parent = None
    base_tree = None
    try:
        ref = api("GET", f"git/ref/heads/{branch}")
        parent = ref["object"]["sha"]
        base_tree = api("GET", f"git/commits/{parent}")["tree"]["sha"]
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise
    tree = []
    for name, data in images:
        sha = api("POST", "git/blobs", {"content": base64.b64encode(data).decode(), "encoding": "base64"})["sha"]
        tree.append({"path": f"previews/pr-{pr}/{name}", "mode": "100644", "type": "blob", "sha": sha})
    body = {"tree": tree}
    if base_tree:
        body["base_tree"] = base_tree
    tree_sha = api("POST", "git/trees", body)["sha"]
    commit = api("POST", "git/commits", {"message": f"Update visual preview for PR {pr}",
                                         "tree": tree_sha, "parents": [parent] if parent else []})["sha"]
    if parent:
        api("PATCH", f"git/refs/heads/{branch}", {"sha": commit, "force": False})
    else:
        api("POST", "git/refs", {"ref": f"refs/heads/{branch}", "sha": commit})
    return commit


def main():
    github = GitHub()
    api = github.api
    event = json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())
    run_id = event["workflow_run"]["id"] if "workflow_run" in event else event["inputs"]["run_id"]
    run = api("GET", f"actions/runs/{int(run_id)}")
    expected = api("GET", "actions/workflows/typst-preview.yml")
    if run["event"] not in ("pull_request", "workflow_dispatch") or run["workflow_id"] != expected["id"] or run["status"] != "completed":
        raise ValueError("Unexpected workflow run")
    if run["conclusion"] == "cancelled":
        return
    # PR association comes from GitHub, not a number supplied by an artifact.
    if run["event"] == "workflow_dispatch":
        # Manual builds must originate from the trusted default branch. PR event
        # artifacts cannot opt into this path by changing their report contents.
        default = api("GET", "")["default_branch"]
        if run["head_branch"] != default:
            raise ValueError("Manual previews must run from the default branch")
        lineage = api("GET", f"compare/{run['head_sha']}...{default}")
        if lineage["status"] not in ("ahead", "identical"):
            raise ValueError("Manual workflow commit is not on the default branch")
        report_path = Path("preview/report.json")
        if report_path.is_symlink() or report_path.stat().st_size > 1_000_000:
            raise ValueError("Invalid manual-build metadata")
        metadata = json.loads(report_path.read_text())
        candidates = [{"number": int(metadata["pr"])}]
        expected_head = metadata["head"]
    else:
        candidates = pull_request_candidates(github, run)
        expected_head = run["head_sha"]
    prs = [api("GET", f"pulls/{p['number']}") for p in candidates]
    prs = [p for p in prs if p["state"] == "open" and p["head"]["sha"] == expected_head
           and p["base"]["repo"]["full_name"] == github.repo]
    if len(prs) != 1:
        print(f"Skipping publication: {len(candidates)} candidate PR(s), {len(prs)} matching open PR(s)")
        return
    pr = prs[0]
    number, head = pr["number"], pr["head"]["sha"]
    base = api("GET", f"compare/{pr['base']['sha']}...{head}")["merge_base_commit"]["sha"]
    run_url = f"https://github.com/{github.repo}/actions/runs/{run['id']}"
    body = [MARKER, "### Typst · changed regions", "",
            f"Compared `{base[:7]}` → `{head[:7]}`. Red = before; green = after.", ""]
    try:
        report, images = validate_report(Path("preview"), number, base, head)
        commit = upload_images(api, number, images) if images else None
        visible = {name for name, _ in images}
        total = 0
        for note in report["notes"]:
            if note["errors"]:
                body += [f"**{note['source']} — compilation failed.** See the compiler logs below.", ""]
                continue
            for region in note["regions"]:
                total += 1
                if region["file"] not in visible:
                    continue
                # GitHub documents this relative form for images in PR comments,
                # including repositories whose images require read access.
                url = f"../blob/{commit}/previews/pr-{number}/{region['file']}?raw=true"
                left_label = region['before_pages'] if region['before_pages'] != 'none' else '—'
                right_label = region['after_pages'] if region['after_pages'] != 'none' else '—'
                body += [f"**{note['source']}** · pages {left_label} → {right_label}",
                         f"![Before and after]({url})", ""]
        if not report["notes"]:
            body += ["No lecture PDF sources were affected. Changes to HTML, EPUB or build scripts are outside this preview.", ""]
        elif not total and not any(n["errors"] for n in report["notes"]):
            body += ["No visible changes in the affected lecture PDFs.", ""]
        if total > len(images):
            body += [f"Showing {len(images)} of {total} crops; the artifact contains all of them.", ""]
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"Preview unavailable: {type(error).__name__}")
        body += ["The preview could not be built or validated. See the build logs.", ""]
    body += [f"[Build logs, complete PDFs and all crops]({run_url}) · PDF preview only; HTML is not compared.",
             "", "<sub>Continuous changes show preceding context only in the first panel and following context only in the last. Pure additions/deletions in middle panels use one column. Running footers are omitted.</sub>"]
    # Recheck immediately before writing: a newer student commit makes this run stale.
    if api("GET", f"pulls/{number}")["head"]["sha"] != head:
        return
    comment = None
    page = 1
    while True:
        comments = api("GET", f"issues/{number}/comments?per_page=100&page={page}")
        for item in comments:
            if item["body"].startswith(MARKER) and item["user"]["login"] == "github-actions[bot]":
                comment = item["id"]
        if len(comments) < 100:
            break
        page += 1
    api("PATCH" if comment else "POST", f"issues/comments/{comment}" if comment else f"issues/{number}/comments",
        {"body": "\n".join(body)})
    print(f"Published preview on PR {number}")


if __name__ == "__main__":
    main()
