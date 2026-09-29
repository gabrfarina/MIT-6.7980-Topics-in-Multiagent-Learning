#!/usr/bin/env python3
"""Check course pages for missing assets, anchors, math, and dropped content."""
from collections import Counter
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import sys
from check_links import audit_site
from build_figures import HTML_FIGURES


class Page(HTMLParser):
    void_tags = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
                 'link', 'meta', 'param', 'source', 'track', 'wbr'}

    def __init__(self, text):
        super().__init__()
        self.ids = set()
        self.links = []
        self.math = 0
        self.image_sources = []
        self.image_rendering_issues = []
        self.open_elements = []
        self.h1_text = []
        self.in_lecture_title = False
        self.feed(text)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if tag == 'h1':
            self.in_lecture_title = 'lecture-title' in attrs.get('class', '').split()
        marker = attrs.get('data-image-source',
                           self.open_elements[-1][1] if self.open_elements else None)
        github_code_ref = ('github-code-ref' in attrs.get('class', '').split()
                           or bool(self.open_elements and self.open_elements[-1][2]))
        if tag not in self.void_tags:
            self.open_elements.append((tag, marker, github_code_ref))
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if attrs.get('role') == 'math':
            self.math += 1
        if 'data-image-source' in attrs:
            # The helper stores repr(image.source); HTMLParser unescapes entities.
            # Imported code-reference icons are not authored lecture diagrams.
            # Keep their markers in the element stack for size validation below.
            if not (github_code_ref and attrs.get('aria-label') == 'GitHub'):
                self.image_sources.append(attrs['data-image-source'])
        if tag in ('a', 'link') and attrs.get('href'):
            self.links.append(attrs['href'])
        if tag in ('img', 'script') and attrs.get('src'):
            self.links.append(attrs['src'])
        if marker is not None and tag in ('svg', 'image'):
            if tag == 'svg':
                dimensions = dict((name.strip().lower(), value.strip())
                                  for declaration in attrs.get('style', '').split(';')
                                  for name, colon, value in [declaration.partition(':')]
                                  if colon)
                location = '<svg> style'
            else:
                dimensions = attrs
                location = '<image>'
            for dimension in ('width', 'height'):
                value = dimensions.get(dimension, '')
                if zero_dimension(value):
                    self.image_rendering_issues.append(
                        f'zero-size rendered image {marker}: '
                        f'{location} {dimension}={value!r}')

    def handle_endtag(self, tag):
        if tag == 'h1':
            self.in_lecture_title = False
        for index in range(len(self.open_elements) - 1, -1, -1):
            if self.open_elements[index][0] == tag:
                del self.open_elements[index:]
                break

    def handle_data(self, data):
        if self.in_lecture_title:
            self.h1_text.append(data)


def zero_dimension(value):
    """Recognize numeric zero with SVG/CSS units without interpreting layout."""
    match = re.fullmatch(
        r'([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)'
        r'(?:[a-zA-Z%]+)?(?:\s*!important)?', value.strip())
    return bool(match and float(match[1]) == 0)


def typst_string(value):
    """Decode the string literal used by image(path) and repr(image.source)."""
    value = re.sub(r'\\u\{([0-9a-fA-F]+)\}',
                   lambda m: json.dumps(chr(int(m[1], 16)))[1:-1], value)
    return json.loads(value)


def source_image_paths(text):
    """Find literal image(path) calls, including calls nested in layout helpers.

    Skip comments, other strings, and raw code examples, so illustrated snippets
    do not count as images that the lecture must render. The active chapters use
    literal paths; image.decode and imported helpers are outside this inventory.
    """
    string = r'"(?:\\.|[^"\\])*"'
    token = re.compile(
        rf'(?P<string>{string})|(?P<line>//[^\n]*)|(?P<block>/\*)|'
        rf'(?P<raw>`+)|(?<![\w.-])image\s*\(\s*(?P<path>{string})')
    position = 0
    paths = []
    while match := token.search(text, position):
        position = match.end()
        if match.lastgroup == 'path':
            paths.append(typst_string(match['path']))
        elif match.lastgroup == 'raw':
            end = text.find(match['raw'], position)
            position = len(text) if end < 0 else end + len(match['raw'])
        elif match.lastgroup == 'block':
            depth = 1
            while depth and (delimiter := re.search(r'/\*|\*/', text[position:])):
                depth += 1 if delimiter[0] == '/*' else -1
                position += delimiter.end()
            if depth:
                position = len(text)
    return paths


def image_inventory_issues(source, source_text, page, page_name, *, root=None):
    """Compare paths and multiplicities, not merely the number of <img> tags."""
    def resolve_image(path):
        candidate = Path(path)
        if root is not None and candidate.is_absolute() and not candidate.is_relative_to(root):
            # Relocated build inputs use Typst's project-root absolute paths.
            candidate = root / path.lstrip('/')
        candidate = (source.parent / candidate).resolve()
        if root is not None and candidate.is_relative_to(root / HTML_FIGURES):
            candidate = root / 'content/figures' / candidate.relative_to(root / HTML_FIGURES)
        return candidate

    expected = Counter(resolve_image(path)
                       for path in source_image_paths(source_text))
    actual = Counter()
    issues = [f'{page_name}: {issue}' for issue in page.image_rendering_issues]
    for value in page.image_sources:
        try:
            path = typst_string(value)
            if not isinstance(path, str):
                raise ValueError('image source is not a string')
            actual[resolve_image(path)] += 1
        except (ValueError, TypeError):
            issues.append(f'{page_name}: invalid data-image-source marker: {value!r}')
    for path in sorted(expected.keys() | actual.keys()):
        if expected[path] != actual[path]:
            issues.append(
                f'{page_name}: image inventory mismatch for {path}: '
                f'expected {expected[path]} rendered occurrence(s), found {actual[path]}')
    return issues


def dropped_content_warnings(text):
    """Allow discarded h/v spacing, but reject discarded content containers."""
    warnings = []
    for line in text.splitlines():
        match = re.search(r'\bwarning:\s*(.*)', line)
        if not match:
            continue
        message = match[1].strip()
        if not re.search(r'\b(?:ignored|discarded|dropped)\b', message, re.I):
            continue
        if re.fullmatch(r'[hv] was ignored during HTML export\.?', message):
            continue
        warnings.append(message)
    return warnings


def main():
    root = Path(__file__).resolve().parents[1]
    folder = (root / (sys.argv[1] if len(sys.argv) > 1 else 'html')).resolve()
    from course_index import load_course
    config, _ = load_course(root / 'html-export.json')
    expected = ['index.html'] + [Path(c['source']).stem + '.html' for c in config['notes']]
    issues = []
    pages = {}
    if (folder / 'source').exists() or (folder / 'source').is_symlink():
        issues.append('Retired source/ directory must not be served; rebuild the site.')
    image_count = 0
    for name in expected:
        path = folder / name
        if not path.is_file():
            issues.append(f'Missing page: {name}')
            continue
        text = path.read_text()
        if '[unsupported math:' in text or 'class="katex-error"' in text:
            issues.append(f'Failed math rendering: {name}')
        pages[path] = Page(text)
        if name != 'index.html' and pages[path].math == 0:
            issues.append(f'No rendered mathematics: {name}')
    for chapter in config['notes']:
        source = root / chapter['source']
        name = source.stem + '.html'
        if not source.is_file():
            issues.append(f'Missing lecture source: {chapter["source"]}')
            continue
        source_text = source.read_text()
        image_count += len(source_image_paths(source_text))
        if page := pages.get(folder / name):
            title = ' '.join(''.join(page.h1_text).split())
            if title != chapter['title']:
                issues.append(f'{name}: title {title!r} does not match canonical title {chapter["title"]!r}')
            issues.extend(image_inventory_issues(source, source_text, page, name, root=root))
    for log in sorted((root / '.build/logs').glob('*.log')):
        issues.extend(f'{log.relative_to(root)}: dropped content: {warning}'
                      for warning in dropped_content_warnings(log.read_text()))
    link_audit = audit_site(folder, config)
    issues.extend(link_audit.issues)
    if issues:
        print('\n'.join(sorted(set(issues))), file=sys.stderr)
        raise SystemExit(1)
    print(f'Checked {len(pages)} pages and {image_count} source image occurrences: '
          'local files, anchors, rendered math, and image inventories are present; '
          'no zero-size images or dropped-content warnings.')
    print(f'Checked {link_audit.citation_count} How to cite URLs against the generated pages; '
          f'{len(link_audit.external)} external URLs require online deployment verification.')
    print(f'Checked {len(config["notes"])} note titles against the syllabus and supplementary list.')


if __name__ == '__main__':
    main()
