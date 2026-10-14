"""List or build and publish HTML reviews for existing open PRs, including forks."""
import argparse
import json
import os
from pathlib import Path
import re
import time
from urllib.request import Request, urlopen


def github_api(method, path, body=None):
    request = Request(
        f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/{path}".rstrip('/'),
        data=json.dumps(body).encode() if body is not None else None,
        headers={'Authorization': 'Bearer ' + os.environ['GITHUB_TOKEN'],
                 'Accept': 'application/vnd.github+json', 'X-GitHub-Api-Version': '2022-11-28'},
        method=method)
    with urlopen(request, timeout=60) as response:
        data = response.read()
        return json.loads(data) if data else None


def parse_numbers(value):
    if not value.strip():
        return None
    parts = re.split(r'[\s,]+', value.strip())
    if not all(re.fullmatch(r'[1-9][0-9]*', part) for part in parts):
        raise ValueError('Expected positive PR numbers separated by commas or spaces')
    return {int(part) for part in parts}


def dispatch_run(api, workflow, branch, inputs):
    response = api('POST', f'actions/workflows/{workflow}/dispatches',
                   {'ref': branch, 'inputs': inputs, 'return_run_details': True})
    if not response or not isinstance(response.get('workflow_run_id'), int):
        raise ValueError('GitHub did not return the dispatched workflow run ID')
    return response['workflow_run_id']


def completed_runs(api, workflow, run_ids, timeout=7200):
    """Yield only the requested runs, polling pages in batches to limit API use."""
    pending = set(run_ids)
    deadline = time.monotonic() + timeout
    while pending:
        unseen = pending.copy()
        page = 1
        while unseen:
            runs = api('GET', f'actions/workflows/{workflow}/runs?per_page=100&page={page}')['workflow_runs']
            for run in runs:
                unseen.discard(run['id'])
                if run['id'] in pending and run['status'] == 'completed':
                    pending.remove(run['id'])
                    yield run
            if len(runs) < 100:
                break
            page += 1
        if pending:
            if time.monotonic() >= deadline:
                raise TimeoutError('Timed out waiting for runs: ' + ', '.join(map(str, sorted(pending))))
            time.sleep(30)


def backfill(api, numbers=None, dispatch=False):
    repository = api('GET', '')
    open_numbers = set()
    page = 1
    while True:
        prs = api('GET', f'pulls?state=open&per_page=100&page={page}')
        open_numbers.update(pr['number'] for pr in prs if pr['state'] == 'open')
        if len(prs) < 100:
            break
        page += 1
    if numbers is not None and numbers - open_numbers:
        raise ValueError('These PRs are not open: ' + ', '.join(map(str, sorted(numbers - open_numbers))))
    selected = sorted(open_numbers if numbers is None else numbers)
    builds = {}
    for number in selected:
        if dispatch:
            run_id = dispatch_run(api, 'html-review.yml', repository['default_branch'],
                                  {'pr_number': str(number)})
            builds[run_id] = number
        print(f"{'Queued' if dispatch else 'Would queue'} HTML review for PR #{number}", flush=True)
    publishers = {}
    cancelled = []
    # GITHUB_TOKEN-dispatched builds do not reliably emit a downstream
    # workflow_run. Explicit workflow_dispatch is supported for this token.
    for run in completed_runs(api, 'html-review.yml', builds):
        number = builds[run['id']]
        if run['conclusion'] == 'cancelled':
            cancelled.append(number)
            print(f'HTML review cancelled for PR #{number}', flush=True)
            continue
        publisher_id = dispatch_run(api, 'pr-quality-publish.yml', repository['default_branch'],
                                    {'run_id': str(run['id'])})
        publishers[publisher_id] = number
        print(f'Queued report publication for PR #{number}', flush=True)
    failures = []
    for run in completed_runs(api, 'pr-quality-publish.yml', publishers, timeout=1800):
        number = publishers[run['id']]
        print(f"Publication for PR #{number}: {run['conclusion']}", flush=True)
        if run['conclusion'] != 'success':
            failures.append(number)
    if cancelled or failures:
        raise RuntimeError(f'Cancelled HTML reviews: {cancelled}; failed publishers: {failures}')
    return selected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prs', default=os.environ.get('PR_NUMBERS', ''),
                        help='Comma-separated PR numbers; empty selects every open PR')
    parser.add_argument('--dispatch', action='store_true', help='Build and publish instead of just listing PRs')
    args = parser.parse_args()
    numbers = backfill(github_api, parse_numbers(args.prs), args.dispatch)
    if summary := os.environ.get('GITHUB_STEP_SUMMARY'):
        with Path(summary).open('a', encoding='utf-8') as stream:
            stream.write(f"{'Published' if args.dispatch else 'Selected'} {len(numbers)} HTML reviews: "
                         + ', '.join(f'#{number}' for number in numbers) + '\n')


if __name__ == '__main__':
    main()
