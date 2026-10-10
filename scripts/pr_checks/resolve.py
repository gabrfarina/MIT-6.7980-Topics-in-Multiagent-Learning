"""Resolve the PR head and live target-branch tip (not cached PR base metadata)."""
import json
import os
from pathlib import Path
import re
from urllib.parse import quote
from urllib.request import Request,urlopen

def get(path):
    request=Request(f'https://api.github.com/repos/{os.environ["GITHUB_REPOSITORY"]}/{path}',headers={
        'Authorization':'Bearer '+os.environ['GITHUB_TOKEN'],'Accept':'application/vnd.github+json'})
    with urlopen(request,timeout=30) as response:return json.load(response)

event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
number=int(event['pull_request']['number'] if 'pull_request' in event else event['inputs']['pr_number'])
pr=get(f'pulls/{number}')
if pr['state']!='open' or pr['base']['repo']['full_name']!=os.environ['GITHUB_REPOSITORY']:
    raise SystemExit('Only open PRs targeting this repository can be checked')
base=get('git/ref/heads/'+quote(pr['base']['ref'],safe=''))['object']['sha']
values=dict(pr_number=str(number),base_sha=base,head_sha=pr['head']['sha'])
if not all(re.fullmatch('[0-9a-f]{40}',values[key]) for key in ('base_sha','head_sha')):
    raise SystemExit('Invalid commit identity')
with open(os.environ['GITHUB_OUTPUT'],'a') as output:
    for key,value in values.items():output.write(f'{key}={value}\n')
