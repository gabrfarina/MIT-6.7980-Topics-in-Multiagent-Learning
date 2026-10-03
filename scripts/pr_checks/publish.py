"""Publish bounded data only, from a verified read-only workflow run."""
import html
import json
import os
from pathlib import Path
import re
import sys
from urllib.parse import quote

from PIL import Image

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'visual_preview'))
import publish as image_publish


def clean(value,limit=400):
    return html.escape(str(value).replace('@','＠').replace('`',"'").replace('\n',' ')[:limit]).replace('[','&#91;').replace(']','&#93;')


def validate(folder,pr,base,head,kind):
    path=folder/'report.json'
    if path.is_symlink() or path.stat().st_size>2_000_000:
        raise ValueError('Invalid report file')
    report=json.loads(path.read_text())
    if (report.get('version'),report.get('pr'),report.get('base'),report.get('head'),report.get('kind'))!=(1,pr,base,head,kind):
        raise ValueError('Report does not match the current PR')
    for name,limit in [('findings',2000),('regions',1000),('checks',40)]:
        if not isinstance(report.get(name),list) or len(report[name])>limit:
            raise ValueError('Invalid report bounds')
    images=[]
    total=0
    for region in report['regions'][:40]:
        name=region['file']
        if not re.fullmatch(r'[A-Za-z0-9_-]+\.png',name):
            raise ValueError('Invalid image path')
        path=folder/name
        if path.is_symlink() or path.stat().st_size>8_000_000:
            raise ValueError('Invalid image file')
        data=path.read_bytes()
        total+=len(data)
        if total>40_000_000:
            break
        with Image.open(path) as image:
            if image.format!='PNG' or image.width>5000 or image.height>2000:
                raise ValueError('Invalid image dimensions')
            image.verify()
        images.append((name,data))
    return report,images


def main():
    github=image_publish.GitHub()
    api=github.api
    event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
    run_id=event['workflow_run']['id'] if 'workflow_run' in event else event['inputs']['run_id']
    run=api('GET',f'actions/runs/{int(run_id)}')
    workflows={api('GET',f'actions/workflows/{file}')['id']:kind for file,kind in [('pr-prescreen.yml','prescreen'),('html-review.yml','html')]}
    kind=workflows.get(run['workflow_id'])
    if not kind or run['event'] not in ('pull_request','workflow_dispatch') or run['status']!='completed':
        raise ValueError('Unexpected workflow run')
    if run['conclusion']=='cancelled':
        return
    folder=Path('review')
    path=folder/'report.json'
    if not path.is_file():
        print('No report was produced; the failing build is visible in PR checks.')
        return
    if path.is_symlink() or path.stat().st_size>2_000_000:
        raise ValueError('Invalid metadata')
    metadata=json.loads(path.read_text())
    if run['event']=='workflow_dispatch':
        default=api('GET','')['default_branch']
        if run['head_branch']!=default or api('GET',f"compare/{run['head_sha']}...{default}")['status'] not in ('ahead','identical'):
            raise ValueError('Manual run must originate from trusted default branch')
        candidates=[{'number':int(metadata['pr'])}]
        expected_head=metadata['head']
    else:
        candidates=run['pull_requests'] or api('GET',f"commits/{run['head_sha']}/pulls")
        expected_head=run['head_sha']
    prs=[api('GET',f"pulls/{p['number']}") for p in candidates]
    prs=[p for p in prs if p['state']=='open' and p['head']['sha']==expected_head and p['base']['repo']['full_name']==github.repo]
    if len(prs)!=1:
        print('Skipping stale or unrelated run')
        return
    pr=prs[0]
    number,head=pr['number'],pr['head']['sha']
    base=api('GET','git/ref/heads/'+quote(pr['base']['ref'],safe=''))['object']['sha']
    if metadata['base']!=base:
        print('Target branch changed; rerun against its current revision')
        return
    report,images=validate(folder,number,base,head,kind)
    marker=f'<!-- course-pr-{kind}:v1 -->'
    title='HTML · checks and changed regions' if kind=='html' else 'Course · source pre-screen'
    body=[marker,f'### {title}','',f'PR `{head[:7]}` integrated into target `{base[:7]}`.','']
    errors=[x for x in report['findings'] if x['level']=='error']
    warnings=[x for x in report['findings'] if x['level']!='error' and not x.get('inherited')]
    inherited=sum(bool(x.get('inherited')) for x in report['findings'])
    body.append(f'**{len(errors)} errors · {len(warnings)} warnings · {inherited} existing issues on the target branch.**')
    body.append('')
    for finding in (errors+warnings)[:20]:
        body.append(f"- **{clean(finding['code'],60)}** {clean(finding.get('page',''),80)}: {clean(finding['message'])}")
    if len(errors+warnings)>20:
        body.append('- Additional findings are in the report artifact.')
    if kind=='html':
        image_publish.BRANCH='html-previews'
        commit=image_publish.upload_images(api,number,images) if images else None
        visible={name for name,_ in images}
        body+=['','1280px desktop and 390px mobile. Unchanged vertical movement is omitted; screenshots include nearby context.','']
        for region in report['regions']:
            if region['file'] in visible:
                body += [f"**{clean(region['page'],100)} · {clean(region['viewport'],10)}px**",
                         f"![HTML before and after](../blob/{commit}/previews/pr-{number}/{region['file']}?raw=true)",'']
        if not report['regions']:
            body.append('No changed regions were produced. Consult check status and logs for build coverage.')
        if len(report['regions'])>len(images):
            body.append(f'Showing {len(images)} of {len(report["regions"])} crops; remaining crops are in the artifact.')
    body += ['',f"[Checks, full findings, screenshots and logs](https://github.com/{github.repo}/actions/runs/{run['id']})",'',
             'Deterministic checks only; no AI review. This does not establish mathematical correctness.']
    current=api('GET',f'pulls/{number}')
    current_base=api('GET','git/ref/heads/'+quote(current['base']['ref'],safe=''))['object']['sha']
    if (current_base,current['head']['sha'])!=(base,head):
        return
    comment=None
    for page in range(1,101):
        comments=api('GET',f'issues/{number}/comments?per_page=100&page={page}')
        for item in comments:
            if item['body'].startswith(marker) and item['user']['login']=='github-actions[bot]':
                comment=item['id']
        if len(comments)<100:
            break
    api('PATCH' if comment else 'POST',f'issues/comments/{comment}' if comment else f'issues/{number}/comments',{'body':'\n'.join(body)})
    print(f'Published {kind} review on PR {number}')


if __name__=='__main__':
    main()
