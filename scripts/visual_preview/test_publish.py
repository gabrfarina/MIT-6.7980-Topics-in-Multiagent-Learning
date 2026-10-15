"""Exercise all publishers without making GitHub writes or network requests."""
from contextlib import chdir, redirect_stdout
from copy import deepcopy
import importlib.util
from io import StringIO
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
from urllib.parse import parse_qs, urlsplit

import publish as preview_publisher

spec = importlib.util.spec_from_file_location(
    "course_publisher", Path(__file__).resolve().parents[1] / "pr_checks" / "publish.py")
course_publisher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(course_publisher)


class PublisherTests(unittest.TestCase):
    def setUp(self):
        self.repo = "course/material"
        self.base, self.head = "a" * 40, "b" * 40
        self.source = {"full_name": "student/material", "owner": {"login": "student"}}
        self.branch = "notes/feedback&revision"
        self.pr = {"number": 47, "state": "open",
                   "head": {"sha": self.head, "ref": self.branch, "repo": self.source},
                   "base": {"sha": self.base, "ref": "main", "repo": {"full_name": self.repo}}}
        self.run = {"id": 101, "event": "pull_request", "status": "completed",
                    "conclusion": "success", "head_sha": self.head,
                    "head_branch": self.branch, "head_repository": self.source,
                    "display_title": "HTML review for PR #47",
                    "pull_requests": []}
        self.workflows = {"typst-preview.yml": 201, "pr-prescreen.yml": 202, "html-review.yml": 203}
        self.prs = {47: self.pr}
        self.pages = [[self.pr]]
        self.lookups = []
        self.writes = []
        self.findings = []
        self.check_pages = [[]]

    def api(self, method, path, body=None):
        if method != "GET":
            self.writes.append((method, path, body))
            return {"id": 1001}
        if path == "":
            return {"default_branch": "main"}
        if path == "actions/runs/101":
            return self.run
        if path.startswith("actions/workflows/"):
            return {"id": self.workflows[path.removeprefix("actions/workflows/")]}
        if path == f"commits/{self.head}/pulls":
            # Reproduce #47: the base repository has no commit-to-PR association.
            return []
        if path.startswith(f"commits/{self.head}/check-runs?"):
            query = parse_qs(urlsplit(path).query)
            self.assertEqual(query['check_name'], ['Course HTML review'])
            self.assertEqual(query['filter'], ['all'])
            page = int(query['page'][0])
            return {'check_runs': self.check_pages[page - 1]}
        if path.startswith("pulls?"):
            query = parse_qs(urlsplit(path).query)
            self.assertEqual(query["state"], ["open"])
            self.assertEqual(query["head"], [f"{self.source['owner']['login']}:{self.branch}"])
            self.assertEqual(query["per_page"], ["100"])
            page = int(query["page"][0])
            self.lookups.append(page)
            return self.pages[page - 1] if page <= len(self.pages) else []
        if path.startswith("pulls/"):
            return self.prs[int(path.removeprefix("pulls/"))]
        if path == f"compare/{self.base}...{self.head}":
            return {"merge_base_commit": {"sha": self.base}}
        if path == f"compare/{self.base}...main":
            return {"status": "identical"}
        if path == "git/ref/heads/main":
            return {"object": {"sha": self.base}}
        if path.startswith("issues/47/comments?"):
            return []
        self.fail(f"Unexpected GitHub request: {method} {path}")

    def publish(self, kind):
        self.writes.clear()
        self.lookups.clear()
        self.run["workflow_id"] = {"preview": 201, "prescreen": 202, "html": 203}[kind]
        publisher = preview_publisher if kind == "preview" else course_publisher
        report = {"version": 1, "pr": 47, "base": self.base, "head": self.head}
        report.update({"notes": []} if kind == "preview" else
                      {"kind": kind, "findings": self.findings, "checks": [], "regions": []})
        output = StringIO()
        with tempfile.TemporaryDirectory() as tmp, chdir(tmp):
            event = Path(tmp) / "event.json"
            event.write_text(json.dumps({"workflow_run": {"id": 101}}))
            folder = Path("preview" if kind == "preview" else "review")
            folder.mkdir()
            (folder / "report.json").write_text(json.dumps(report))
            github = SimpleNamespace(repo=self.repo, api=self.api)
            with patch.dict("os.environ", {"GITHUB_EVENT_PATH": str(event)}), \
                    patch.object(preview_publisher, "GitHub", return_value=github), \
                    redirect_stdout(output):
                publisher.main()
        return output.getvalue()

    def assert_publishes(self):
        for kind in ("preview", "prescreen", "html"):
            with self.subTest(kind=kind):
                self.publish(kind)
                comments = [write for write in self.writes if write[1].startswith('issues/')]
                self.assertEqual(len(comments), 1)
                method, path, body = comments[0]
                self.assertEqual((method, path), ("POST", "issues/47/comments"))
                self.assertIn(self.head[:7], body["body"])
                checks = [write for write in self.writes if write[1] == 'check-runs']
                self.assertEqual(len(checks), int(kind == 'html'))
                if kind == 'html':
                    self.assertEqual(checks[0][2]['head_sha'], self.head)
                    self.assertEqual(checks[0][2]['conclusion'], 'success')

    def assert_skips(self):
        for kind in ("preview", "prescreen", "html"):
            with self.subTest(kind=kind):
                self.publish(kind)
                self.assertEqual(self.writes, [])

    def test_fork_with_empty_run_and_commit_associations_publishes(self):
        self.assert_publishes()

    def test_same_repository_branch_without_run_association_publishes(self):
        self.source.update(full_name=self.repo, owner={"login": "course"})
        self.assert_publishes()

    def test_explicit_run_association_still_publishes(self):
        self.run["pull_requests"] = [{"number": 47}]
        self.pages = []
        self.assert_publishes()
        self.assertEqual(self.lookups, [])

    def test_stale_head_is_not_published(self):
        self.pr["head"]["sha"] = "c" * 40
        self.assert_skips()

    def test_closed_pr_is_not_published(self):
        self.pr["state"] = "closed"
        self.assert_skips()

    def test_wrong_target_repository_is_not_published(self):
        self.pr["base"]["repo"]["full_name"] = "other/material"
        self.assert_skips()

    def test_same_commit_on_another_repository_or_branch_is_not_selected(self):
        for field, value in (("repo", {"full_name": "student/other-material"}),
                             ("ref", "other-branch")):
            with self.subTest(field=field):
                unrelated = deepcopy(self.pr)
                unrelated["number"] = 48
                unrelated["head"][field] = value
                self.prs[48] = unrelated
                self.pages = [[unrelated, self.pr]]
                self.assert_publishes()

    def test_missing_source_metadata_does_not_guess_a_pr(self):
        for field in ("head_repository", "head_branch"):
            with self.subTest(field=field), patch.dict(self.run, {field: None}):
                self.assert_skips()

    def test_multiple_matching_prs_are_not_published(self):
        other = deepcopy(self.pr)
        other["number"] = 48
        other["base"]["ref"] = "release"
        self.prs[48] = other
        self.pages = [[self.pr, other]]
        self.assert_skips()

    def test_lookup_checks_later_pages_for_ambiguous_matches(self):
        unrelated = deepcopy(self.pr)
        unrelated["head"]["repo"] = {"full_name": "student/other-material"}
        other = deepcopy(self.pr)
        other["number"] = 48
        other["base"]["ref"] = "release"
        self.prs[48] = other
        self.pages = [[self.pr] + [unrelated] * 99, [other]]
        self.assert_skips()
        self.assertEqual(self.lookups, [1, 2])

    def test_trusted_manual_build_still_publishes(self):
        self.run.update(event="workflow_dispatch", head_branch="main", head_sha=self.base)
        self.pages = []
        self.assert_publishes()
        self.assertEqual(self.lookups, [])

    def test_failed_html_build_is_not_reported_as_success(self):
        self.run['conclusion'] = 'failure'
        self.publish('html')
        self.assertEqual(self.writes[-1][2]['conclusion'], 'failure')
        self.assertEqual(self.writes[-1][2]['head_sha'], self.head)

    def test_manual_html_artifact_cannot_select_another_pr(self):
        self.run.update(event='workflow_dispatch', head_branch='main', head_sha=self.base,
                        display_title='HTML review for PR #48')
        with self.assertRaisesRegex(ValueError, 'Cannot verify the manual HTML PR'):
            self.publish('html')
        self.assertEqual(self.writes, [])

    def test_legacy_manual_html_run_requires_a_fresh_build(self):
        self.run.update(event='workflow_dispatch', head_branch='main', head_sha=self.base,
                        display_title='Course HTML review')
        with self.assertRaisesRegex(ValueError, 'rerun the HTML review'):
            self.publish('html')
        self.assertEqual(self.writes, [])

    def test_reported_errors_fail_the_html_check_even_if_workflow_succeeded(self):
        self.findings = [dict(level='error', code='overflow', message='Page overflows')]
        self.publish('html')
        self.assertEqual(self.writes[-1][2]['conclusion'], 'failure')
        self.assertIn('1 reported errors', self.writes[-1][2]['output']['summary'])

    def test_republishing_updates_only_its_own_html_check_across_pages(self):
        other = dict(id=10, external_id='other-run', head_sha=self.head,
                     app={'slug': 'github-actions'})
        ours = dict(id=11, external_id='course-pr-html:101', head_sha=self.head,
                    app={'slug': 'github-actions'})
        foreign = dict(ours, id=12, app={'slug': 'other-app'})
        self.check_pages = [[other] * 99 + [foreign], [ours]]
        self.publish('html')
        method, path, body = self.writes[-1]
        self.assertEqual((method, path), ('PATCH', 'check-runs/11'))
        self.assertNotIn('head_sha', body)


if __name__ == "__main__":
    unittest.main()
