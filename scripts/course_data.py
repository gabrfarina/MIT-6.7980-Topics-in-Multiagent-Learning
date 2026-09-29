"""Read course facts and formatted prose from the editable Typst syllabus."""
import copy
from html import escape
import json
from pathlib import Path
import subprocess


def read_course_data(syllabus: Path, root: Path) -> dict:
    result = subprocess.run([
        'typst', 'eval', '--in', str(syllabus.resolve()), '--root', str(root),
        '--font-path', str(root / 'html-exporter/assets/fonts'),
        '(info: query(<course-info>).map(e => e.value), '
        'text: query(<course-text>).map(e => e.value), '
        'schedule: query(<course-schedule>).map(e => e.value))',
    ], cwd=root, text=True, capture_output=True)
    if result.returncode:
        raise ValueError('Cannot evaluate syllabus:\n' + result.stderr)
    data = json.loads(result.stdout)
    if len(data['info']) != 1 or len(data['schedule']) != 1:
        raise ValueError('Expected one course-info and one course-schedule metadata element.')
    fields = {}
    for field in data['text']:
        if field['key'] in fields:
            raise ValueError(f'Duplicate course text: {field["key"]}')
        fields[field['key']] = field['body']
    return {'info': data['info'][0], 'text': fields, 'schedule': data['schedule'][0]}


def with_course_data(config: dict, data: dict) -> dict:
    resolved = copy.deepcopy(config)
    info = data['info']
    resolved['course'] = data
    resolved['site'].update({k: info[k] for k in ('event', 'title', 'term', 'year', 'github')})
    resolved['site']['authors'] = ' and '.join(p['name'] for p in info['instructors'])
    resolved['how_to_cite'].update({
        'authors': ' and '.join(p['citation_name'] for p in info['instructors']),
        'year': info['year'], 'note_template': f'{info["event"]}, {info["term"]}',
        'booktitle': f'MIT {info["title"]} Lecture Notes',
    })
    return resolved


def rich_html(node) -> str:
    """Translate the small set of Typst prose elements used in course information.

    Unsupported content fails explicitly rather than silently losing user edits.
    Math and lecture-note HTML still use the dedicated Rust exporter.
    """
    if isinstance(node, str):
        return escape(node)
    kind = node.get('func')
    if kind == 'sequence':
        return ''.join(rich_html(child) for child in node['children'])
    if kind in ('text', 'symbol'):
        return escape(node['text'])
    if kind == 'space':
        return ' '
    if kind == 'parbreak':
        return '\n\n'
    if kind == 'linebreak':
        return '<br>'
    if kind == 'smartquote':
        return '&quot;' if node['double'] else '&#x27;'
    if kind == 'raw':
        return '<code>' + escape(node['text']) + '</code>'
    if kind in ('strong', 'emph'):
        tag = 'strong' if kind == 'strong' else 'em'
        return f'<{tag}>' + rich_html(node['body']) + f'</{tag}>'
    if kind == 'link':
        dest = node['dest']
        if not isinstance(dest, str) or not dest.startswith(('https://', 'http://', 'mailto:', '#')):
            raise ValueError(f'Unsupported course link: {dest!r}')
        return f'<a href="{escape(dest, quote=True)}">{rich_html(node["body"])}</a>'
    if kind == 'styled':
        return rich_html(node['child'])
    raise ValueError(f'Unsupported course prose element: {kind!r}; add an explicit HTML conversion.')


def paragraphs(node) -> str:
    return '\n'.join('<p>' + paragraph.strip() + '</p>'
                     for paragraph in rich_html(node).split('\n\n') if paragraph.strip())
