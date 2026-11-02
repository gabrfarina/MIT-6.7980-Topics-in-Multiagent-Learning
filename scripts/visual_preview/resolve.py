"""Resolve a requested PR from GitHub, for both new events and manual backfills."""
import json
import os
from pathlib import Path
import re
import urllib.request

event = json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())
number = int(event["pull_request"]["number"] if "pull_request" in event else event["inputs"]["pr_number"])
repo = os.environ["GITHUB_REPOSITORY"]
request = urllib.request.Request(
    f"https://api.github.com/repos/{repo}/pulls/{number}",
    headers={"Authorization": "Bearer " + os.environ["GITHUB_TOKEN"], "Accept": "application/vnd.github+json"})
with urllib.request.urlopen(request, timeout=30) as response:
    pr = json.load(response)
if pr["state"] != "open" or pr["base"]["repo"]["full_name"] != repo:
    raise SystemExit("Only open PRs targeting this repository can be previewed")
values = {"pr_number": str(number), "base_sha": pr["base"]["sha"], "head_sha": pr["head"]["sha"]}
if not all(re.fullmatch(r"[0-9a-f]{40}", values[k]) for k in ("base_sha", "head_sha")):
    raise SystemExit("Invalid commit identity")
with open(os.environ["GITHUB_OUTPUT"], "a") as output:
    for key, value in values.items():
        output.write(f"{key}={value}\n")
