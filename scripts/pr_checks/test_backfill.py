from contextlib import redirect_stdout
from io import BytesIO, StringIO
import unittest
from unittest.mock import patch

from backfill_html import backfill, completed_runs, dispatch_run, github_api, parse_numbers


class BackfillTests(unittest.TestCase):
    def setUp(self):
        self.pages = [[dict(number=47, state='open', draft=False),
                       dict(number=48, state='open', draft=True)]]
        self.writes = []
        self.runs = {'html-review.yml': [], 'pr-quality-publish.yml': []}
        self.build_results = {}
        self.publisher_result = 'success'

    def api(self, method, path, body=None):
        if method == 'POST':
            self.writes.append((path, body))
            workflow = path.split('/')[2]
            conclusion = (self.build_results.get(int(body['inputs']['pr_number']), 'success')
                          if workflow == 'html-review.yml' else self.publisher_result)
            run = dict(id=1000 + len(self.writes), status='completed', conclusion=conclusion)
            self.runs[workflow].append(run)
            return {'workflow_run_id': run['id']}
        if path == '':
            return {'default_branch': 'trunk'}
        page = int(path.rsplit('=', 1)[1])
        if path.startswith('actions/workflows/'):
            runs = self.runs[path.split('/')[2]]
            return {'workflow_runs': runs[(page - 1) * 100:page * 100]}
        return self.pages[page - 1]

    def run_backfill(self, **kwargs):
        with redirect_stdout(StringIO()):
            return backfill(self.api, **kwargs)

    def test_all_open_prs_are_dispatched_from_the_default_branch(self):
        self.assertEqual(self.run_backfill(dispatch=True), [47, 48])
        self.assertEqual(self.writes[:2], [
            ('actions/workflows/html-review.yml/dispatches',
             {'ref': 'trunk', 'inputs': {'pr_number': str(number)}, 'return_run_details': True})
            for number in (47, 48)])
        self.assertEqual(self.writes[2:], [
            ('actions/workflows/pr-quality-publish.yml/dispatches',
             {'ref': 'trunk', 'inputs': {'run_id': str(run_id)}, 'return_run_details': True})
            for run_id in (1001, 1002)])

    def test_selection_is_validated_before_any_build_is_queued(self):
        with self.assertRaises(ValueError):
            self.run_backfill(numbers={47, 999}, dispatch=True)
        self.assertEqual(self.writes, [])

    def test_selected_prs_only(self):
        self.run_backfill(numbers={48}, dispatch=True)
        self.assertEqual(len(self.writes), 2)
        self.assertEqual(self.writes[0][1]['inputs'], {'pr_number': '48'})

    def test_default_is_read_only(self):
        self.assertEqual(self.run_backfill(), [47, 48])
        self.assertEqual(self.writes, [])

    def test_all_pages_are_included_without_duplicate_dispatches(self):
        self.pages = [[dict(number=n, state='open') for n in range(1, 101)],
                      [dict(number=100, state='open'), dict(number=101, state='open')]]
        self.assertEqual(self.run_backfill(dispatch=True), list(range(1, 102)))
        self.assertEqual(len(self.writes), 202)

    def test_closed_prs_are_not_dispatched(self):
        self.pages[0][0]['state'] = 'closed'
        self.assertEqual(self.run_backfill(dispatch=True), [48])

    def test_empty_repository_queues_nothing(self):
        self.pages = [[]]
        self.assertEqual(self.run_backfill(dispatch=True), [])
        self.assertEqual(self.writes, [])

    def test_failed_html_build_still_gets_published(self):
        self.build_results[47] = 'failure'
        self.assertEqual(self.run_backfill(numbers={47}, dispatch=True), [47])
        self.assertEqual(self.writes[1][1]['inputs'], {'run_id': '1001'})

    def test_cancelled_build_is_reported_after_other_results_publish(self):
        self.build_results[47] = 'cancelled'
        with self.assertRaisesRegex(RuntimeError, r'Cancelled HTML reviews: \[47\]'):
            self.run_backfill(dispatch=True)
        self.assertEqual(self.writes[-1][1]['inputs'], {'run_id': '1002'})
        self.assertEqual(len(self.writes), 3)

    def test_publisher_failure_fails_the_backfill(self):
        self.publisher_result = 'failure'
        with self.assertRaisesRegex(RuntimeError, r'failed publishers: \[47\]'):
            self.run_backfill(numbers={47}, dispatch=True)

    def test_missing_dispatch_id_cannot_guess_an_unrelated_run(self):
        with self.assertRaisesRegex(ValueError, 'run ID'):
            dispatch_run(lambda *args: None, 'html-review.yml', 'trunk', {'pr_number': '47'})

    def test_waits_until_the_exact_run_is_completed(self):
        responses = [
            {'workflow_runs': [dict(id=1, status='in_progress'), dict(id=2, status='completed')]},
            {'workflow_runs': [dict(id=1, status='completed', conclusion='failure')]},
        ]
        with patch('backfill_html.time.sleep') as sleep:
            actual = list(completed_runs(lambda *args: responses.pop(0), 'html-review.yml', {1}))
        self.assertEqual(actual, [dict(id=1, status='completed', conclusion='failure')])
        sleep.assert_called_once_with(30)

    def test_wait_reads_all_pages_and_ignores_unrequested_runs(self):
        self.runs['html-review.yml'] = [dict(id=n, status='completed') for n in range(1, 102)]
        actual = list(completed_runs(self.api, 'html-review.yml', {1, 101}))
        self.assertEqual([run['id'] for run in actual], [1, 101])

    def test_wait_times_out_instead_of_silently_missing_results(self):
        with patch('backfill_html.time.monotonic', side_effect=[0, 120]), \
                patch('backfill_html.time.sleep') as sleep:
            with self.assertRaisesRegex(TimeoutError, '42'):
                list(completed_runs(lambda *args: {'workflow_runs': []}, 'html-review.yml', {42}, timeout=60))
        sleep.assert_not_called()

    def test_parse_selection(self):
        self.assertIsNone(parse_numbers(' '))
        self.assertEqual(parse_numbers('47, 48 47'), {47, 48})
        self.assertEqual(parse_numbers('47,,48'), {47, 48})
        for value in ('0', '-1', '47,invalid'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                parse_numbers(value)

    def test_dispatch_handles_github_empty_204_response(self):
        with patch.dict('os.environ', {'GITHUB_REPOSITORY': 'course/material', 'GITHUB_TOKEN': 'test'}), \
                patch('backfill_html.urlopen', return_value=BytesIO(b'')) as request:
            self.assertIsNone(github_api('POST', 'actions/workflows/html-review.yml/dispatches',
                                        {'ref': 'main', 'inputs': {'pr_number': '47'}}))
        self.assertEqual(request.call_args.args[0].method, 'POST')

    def test_dispatch_reads_the_returned_run_id(self):
        with patch.dict('os.environ', {'GITHUB_REPOSITORY': 'course/material', 'GITHUB_TOKEN': 'test'}), \
                patch('backfill_html.urlopen', return_value=BytesIO(b'{"workflow_run_id": 42}')):
            self.assertEqual(dispatch_run(github_api, 'html-review.yml', 'main', {'pr_number': '47'}), 42)


if __name__ == '__main__':
    unittest.main()
