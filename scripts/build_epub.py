# /// script
# requires-python = ">=3.9"
# dependencies = ["beautifulsoup4", "lxml"]
# ///
"""Package the built course website as an EPUB 3 e-book.

Run `make html` first; `make epub` then writes dist/6.7980-notes.epub. Lecture
pages come from html/, and their order, numbers, and titles from the resolved
exporter configuration in .build/html-export.json. Math is pre-rendered to
MathML with the bundled KaTeX, since e-readers generally cannot run the site's
scripts. Requires beautifulsoup4 and lxml; `make epub` runs the script with uv
when it is installed, which installs them from the header above.
"""
from __future__ import annotations

import argparse
import base64
import datetime
import html
import json
from pathlib import Path
import re
import subprocess
import sys
import textwrap
import urllib.parse
import uuid
import zipfile

try:
    from bs4 import BeautifulSoup
    from lxml import etree
except ImportError as error:
    if __name__ != '__main__':
        raise
    sys.exit(f'The EPUB build needs beautifulsoup4 and lxml ({error}). Install them with '
             '`python3 -m pip install beautifulsoup4 lxml`, or install uv and rerun `make epub`.')

from course_index import COURSE_FIGURES

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'html'
CONFIG = ROOT / '.build' / 'html-export.json'
WORK = ROOT / '.build' / 'epub'
OUTPUT = ROOT / 'dist' / '6.7980-notes.epub'
STYLESHEET = ROOT / 'html-exporter/src/epub.css'
MATHML_RENDERER = ROOT / 'scripts/render_mathml.cjs'
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'  # used to rasterize the cover
MATH_TOKEN = re.compile('(\\d+)')  # placeholders swapped for MathML after serialization
TEX_DELIMS = re.compile(r'\\\((.+?)\\\)|\\\[(.+?)\\\]', re.S)
PARAGRAPH_MARKERS = {
    'paragraph-marker-square': '▪',
    'paragraph-marker-triangle-right': '▸',
    'paragraph-marker-triangle-up': '▴',
}
IMAGE_TYPES = {'svg+xml': ('svg', 'image/svg+xml'), 'png': ('png', 'image/png'), 'jpeg': ('jpg', 'image/jpeg')}
# Site markup that should never survive conversion; finding it means the site changed under the converter.
LEFTOVERS = {
    'unconverted TeX delimiters': re.compile(r'\\\(|\\\['),
    'inline SVG (a figure outside span.lecture-image, or SVG math fallback)': re.compile(r'<svg\b'),
    'embedded image outside span.lecture-image': re.compile(r'embedded:\d+'),
}


def esc(text: str) -> str:
    return html.escape(text, quote=True)


class MathQueue:
    """Collects TeX snippets, renders them in one KaTeX call, and substitutes the MathML back."""

    def __init__(self):
        self.jobs = []
        self.results = None

    def token(self, tex: str, display: bool) -> str:
        self.jobs.append({'tex': tex, 'display': display})
        return f'{len(self.jobs) - 1}'

    def render(self) -> int:
        proc = subprocess.run(['node', str(MATHML_RENDERER)], input=json.dumps(self.jobs),
                              capture_output=True, text=True, cwd=ROOT, check=True)
        self.results = json.loads(proc.stdout)
        for job, result in zip(self.jobs, self.results):
            if result['error']:
                print(f"  KaTeX error: {result['error']}\n    in: {job['tex'][:120]}", file=sys.stderr)
        return sum(1 for r in self.results if r['error'])

    def substitute(self, text: str) -> str:
        def mathml(match):
            rendered = self.results[int(match[1])]['html']
            return clean_mathml(re.sub(r'^<span class="katex">(.*)</span>$', r'\1', rendered, flags=re.S))

        return MATH_TOKEN.sub(mathml, text)


MATHML = '{http://www.w3.org/1998/Math/MathML}'
MATHML_TOKENS = {'mi', 'mo', 'mn', 'mtext', 'ms'}


def clean_mathml(markup: str) -> str:
    """Fit KaTeX's MathML to the MathML 3 schema EPUB validators use: no nested token elements, no width."""
    root = etree.fromstring(markup)
    for el in root.iter(f'{MATHML}mtable', f'{MATHML}mtd'):
        el.attrib.pop('width', None)
    for el in list(root.iter(*(MATHML + t for t in MATHML_TOKENS))):
        children = list(el)
        if not children:
            continue
        if all(etree.QName(c).localname in MATHML_TOKENS and len(c) == 0 for c in children):
            # e.g. <mo><mi mathvariant="normal">≔</mi></mo> becomes <mo mathvariant="normal">≔</mo>
            el.text = (el.text or '') + ''.join((c.text or '') + (c.tail or '') for c in children)
            for c in children:
                for key, value in c.attrib.items():
                    if key not in el.attrib:
                        el.set(key, value)
                el.remove(c)
        else:
            el.tag = MATHML + ('mstyle' if el.attrib else 'mrow')
    return etree.tostring(root, encoding='unicode')


def strip_delims(source: str) -> str:
    source = source.strip()
    match = re.fullmatch(r'\\\((.*)\\\)|\\\[(.*)\\\]', source, re.S)
    if not match:
        return source
    return (match[1] if match[1] is not None else match[2]).strip()


def tex_to_plain(text: str) -> str:
    """Rough plain-text rendering of TeX for navigation labels."""
    greek = {'Phi': 'Φ', 'phi': 'φ', 'Psi': 'ψ', 'epsilon': 'ε', 'Delta': 'Δ', 'alpha': 'α', 'beta': 'β',
             'gamma': 'γ', 'Gamma': 'Γ', 'lambda': 'λ', 'mu': 'μ', 'sigma': 'σ', 'Sigma': 'Σ', 'Pi': 'Π', 'pi': 'π'}

    def inner(match):
        tex = match[1] if match[1] is not None else match[2]
        tex = re.sub(r'\\([A-Za-z]+)', lambda m: greek.get(m[1], ''), tex)
        return re.sub(r'[{}^_\s]', '', tex)

    return TEX_DELIMS.sub(inner, text)


def navigation_number(chapter: dict) -> str:
    """Mirror the lecture rail numbering in html-exporter/src/chapters.rs."""
    numbers = chapter.get('syllabus_numbers') or []
    if chapter.get('supplementary') or not numbers:
        return str(chapter['number'])
    return '–'.join(map(str, numbers))


def reading_groups(config: dict) -> list[dict]:
    """Lectures and supplementary readings, grouped and ordered as in the site's lecture rail."""
    groups = []
    for supplementary, label in ((False, 'Lectures'), (True, 'Supplementary readings')):
        lectures = [{'slug': Path(c['source']).stem, 'number': navigation_number(c), 'title': c['short_title']}
                    for c in config['lectures'] if bool(c.get('supplementary')) == supplementary]
        if lectures:
            groups.append({'label': label, 'lectures': lectures})
    return groups


def clean_style(style: str) -> str:
    decls = [d.strip() for d in style.split(';') if d.strip()]
    kept = [d for d in decls if not d.startswith('--') and '+' not in d]
    return '; '.join(kept)


def leftovers(body: str) -> list[str]:
    """Describe unconverted site markup in a lecture body, ignoring code listings."""
    text = re.sub(r'<(code|pre)\b.*?</\1>', '', body, flags=re.S)
    return [label for label, pattern in LEFTOVERS.items() if pattern.search(text)]


def convert_lecture(lecture: dict, raw: bytes, slugs: set[str], math: MathQueue, images: dict,
                    base: str) -> tuple[str, list[tuple[int, str, str]]]:
    # Some embedded figures exceed libxml2's attribute size limit, so lift data URIs out before parsing.
    embedded = []

    def lift(match):
        embedded.append((match[1], match[2]))
        return f'href="embedded:{len(embedded) - 1}"'

    raw = re.sub(r'href="data:image/([a-z0-9.+-]+);base64,([A-Za-z0-9+/=\s]+)"', lift, raw.decode('utf-8'))
    soup = BeautifulSoup(raw, 'lxml')
    art = soup.select_one('article.lecture-content')
    slug = lecture['slug']

    for selector in ['nav.compact-course-nav', 'aside.lecture-citation-sidenote', 'span.footnote',
                     'span.citation-note', 'span.pseudo-guide', 'script', '[hidden]']:
        for el in art.select(selector):
            el.decompose()
    for el in art.select('span.citation-wrap'):
        el.unwrap()

    # Section outline for the navigation document (before math is replaced by tokens).
    sections = []
    for li in art.select('nav.toc li'):
        level = int(re.search(r'toc-l(\d)', ' '.join(li.get('class', [])))[1])
        label = ' '.join(' '.join(x.get_text().split()) for x in li.select('.toc-no, .toc-title'))
        sections.append((level, tex_to_plain(label), f"{slug}.xhtml{li.a['href']}"))

    # Figures: embedded data-URI images become separate files.
    for n, span in enumerate(art.select('span.lecture-image'), 1):
        svg = span.find('svg')
        image = svg.find('image')
        href = image.get('xlink:href') or image.get('href')
        subtype, data = embedded[int(href.removeprefix('embedded:'))]
        if subtype not in IMAGE_TYPES:
            raise ValueError(f'{slug}.html: unsupported embedded image type image/{subtype}; add it to IMAGE_TYPES')
        ext, media_type = IMAGE_TYPES[subtype]
        name = f'images/{slug}-{n}.{ext}'
        images[name] = (base64.b64decode(data), media_type)
        width = re.search(r'width:\s*([\d.]+)em', svg.get('style', ''))
        width_em = float(width[1]) if width else float(svg['width'].removesuffix('pt')) / 9.5
        img = soup.new_tag('img', attrs={
            'src': name, 'alt': span.get('aria-label', ''), 'class': 'lecture-image',
            'style': f'width: {width_em:.2f}em',
        })
        span.replace_with(img)

    for marker in art.select('span.paragraph-marker'):
        symbol = next((v for k, v in PARAGRAPH_MARKERS.items() if k in marker['class']), '▪')
        marker.string = symbol
        del marker['aria-hidden']

    # The site hides the whitespace between "Theorem", "L2.1" and "." with font-size: 0.
    for title in art.select('.env-title-numbered'):
        for gap in title.find_all(string=True, recursive=False):
            if not gap.strip():
                gap.extract()

    for line in art.select('div.pseudo-line'):
        indent = re.search(r'--indent:\s*(\d+)', line.get('style', ''))
        text = line.select_one('.pseudo-text')
        if indent and text and int(indent[1]):
            text['style'] = f'padding-left: {int(indent[1]) * 1.4:.1f}em'

    # Display equations: aligned multi-line figures become a single align* environment.
    for fig in art.select('figure.equation'):
        div = soup.new_tag('div', attrs={'class': 'equation'})
        if fig.get('id'):
            div['id'] = fig['id']
        lines = fig.select('div.equation-line')
        if 'equation-aligned' in fig.get('class', []):
            rows = []
            for line in lines:
                left, right = line.select_one('.equation-align-left'), line.select_one('.equation-align-right')
                if left is not None or right is not None:
                    row = ' & '.join(strip_delims(x.get_text()) if x else '' for x in (left, right))
                else:
                    full = line.select_one('.equation-math, .equation-align-full')
                    row = strip_delims(full.get_text())
                eqno = line.select_one('.eqno')
                if eqno:
                    row += ' \\tag{%s}' % eqno.get_text(strip=True).strip('()')
                rows.append(row)
            tex = '\\begin{align*}' + ' \\\\ '.join(rows) + '\\end{align*}'
            div.append(math.token(tex, True))
        else:
            for line in lines:
                source = line.select_one('.equation-math')
                tex = strip_delims(source.get_text())
                eqno = line.select_one('.eqno')
                if eqno:
                    tex += ' \\tag{%s}' % eqno.get_text(strip=True).strip('()')
                div.append(math.token(tex, True))
        fig.replace_with(div)

    for span in art.select('span.math-katex-source'):
        span.unwrap()
    for node in list(art.find_all(string=TEX_DELIMS)):
        if node.find_parent(['code', 'pre']):
            continue

        def tokenize(match):
            if match[1] is not None:
                return math.token(match[1].strip(), False)
            return math.token(match[2].strip(), True)

        node.replace_with(TEX_DELIMS.sub(tokenize, str(node)))

    # Links between notes stay inside the book; other site files point to the published course.
    for a in art.find_all('a', href=True):
        href = a['href']
        if href.startswith('#') or re.match(r'[a-z]+:', href):
            continue
        path, _, fragment = href.partition('#')
        stem = path[:-5] if path.endswith('.html') else None
        if stem in slugs:
            a['href'] = f'{stem}.xhtml' + (f'#{fragment}' if fragment else '')
        else:
            a['href'] = urllib.parse.urljoin(base, href)

    for ref in art.select('sup.footnote-ref a'):
        ref['epub:type'] = 'noteref'
    for note in art.select('section.endnotes > p[id]'):
        note['epub:type'] = 'endnote'

    for el in [art, *art.find_all(True)]:
        for attr in list(el.attrs):
            if attr.startswith('data-') or attr in ('role', 'aria-current'):
                del el[attr]
        if 'style' in el.attrs:
            style = clean_style(el['style'])
            if style:
                el['style'] = style
            else:
                del el['style']

    return art.decode(formatter='minimal'), sections


def xhtml_page(title: str, body: str) -> str:
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en" xml:lang="en">
<head>
<meta charset="utf-8"/>
<title>{esc(title)}</title>
<link rel="stylesheet" type="text/css" href="style.css"/>
</head>
<body>
{body}
</body>
</html>
'''


def nest(entries: list[tuple[int, str, str]]) -> list[dict]:
    root = []
    stack = [(0, root)]
    for level, label, href in entries:
        node = {'label': label, 'href': href, 'children': []}
        while stack[-1][0] >= level:
            stack.pop()
        stack[-1][1].append(node)
        stack.append((level, node['children']))
    return root


def nav_ol(nodes: list[dict]) -> str:
    items = []
    for node in nodes:
        label = f'<a href="{esc(node["href"])}">{esc(node["label"])}</a>'
        if node['children']:
            label += nav_ol(node['children'])
        items.append(f'<li>{label}</li>')
    return '<ol>' + ''.join(items) + '</ol>'


def ncx_points(nodes: list[dict], orders: dict, counter: list[int] | None = None) -> str:
    """NCX navPoints; entries sharing a target must share a playOrder."""
    counter = counter if counter is not None else [0]
    out = []
    for node in nodes:
        counter[0] += 1
        order = orders.setdefault(node['href'], len(orders) + 1)
        out.append(f'<navPoint id="np{counter[0]}" playOrder="{order}">'
                   f'<navLabel><text>{esc(node["label"])}</text></navLabel>'
                   f'<content src="{esc(node["href"])}"/>{ncx_points(node["children"], orders, counter)}</navPoint>')
    return ''.join(out)


def make_cover(course_svg: bytes, title: str, subtitle: str, authors: list[str]) -> bytes | None:
    """Rasterize a simple cover with headless Google Chrome; returns PNG bytes or None."""
    data = base64.b64encode(course_svg).decode()
    title_lines = ''.join(f'<tspan x="100" y="{400 + 130 * i}">{esc(line)}</tspan>'
                          for i, line in enumerate(textwrap.wrap(title, 10)))
    author_lines = ''.join(f'<tspan x="100" y="{1540 + 70 * i}">{esc(a)}</tspan>' for i, a in enumerate(authors))
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1200" height="1800" viewBox="0 0 1200 1800">
<rect width="1200" height="1800" fill="#f7f4ee"/>
<rect x="0" y="0" width="1200" height="18" fill="#8a1f2b"/>
<text x="100" y="230" font-family="Helvetica Neue, Helvetica, Arial, sans-serif" font-size="46" letter-spacing="4" fill="#8a1f2b">{esc(subtitle.upper())}</text>
<text font-family="Georgia, Times New Roman, serif" font-size="112" fill="#1d1d1d">{title_lines}</text>
<text x="100" y="770" font-family="Helvetica Neue, Helvetica, Arial, sans-serif" font-size="40" fill="#555">Lecture notes</text>
<image x="700" y="820" width="400" height="818" xlink:href="data:image/svg+xml;base64,{data}"/>
<text font-family="Georgia, Times New Roman, serif" font-size="48" fill="#1d1d1d">{author_lines}</text>
</svg>'''
    work = WORK / 'cover'
    work.mkdir(parents=True, exist_ok=True)
    (work / 'cover.svg').write_text(svg, encoding='utf-8')
    png = work / 'cover.png'
    png.unlink(missing_ok=True)
    try:
        subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1200,1800',
                        f'--screenshot={png}', (work / 'cover.svg').as_uri()],
                       capture_output=True, check=True, timeout=120)
        return png.read_bytes()
    except (OSError, subprocess.SubprocessError):
        print('  (no cover image: headless Google Chrome unavailable)')
        return None


def item_id(name: str) -> str:
    return 'i-' + re.sub(r'[^A-Za-z0-9]', '-', name)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--site', type=Path, default=SITE, help='built course website (default: html/)')
    parser.add_argument('--config', type=Path, default=CONFIG,
                        help='resolved exporter configuration (default: .build/html-export.json)')
    parser.add_argument('-o', '--output', type=Path, default=OUTPUT,
                        help='EPUB path (default: dist/6.7980-notes.epub)')
    args = parser.parse_args()
    if not (args.site / 'index.html').is_file() or not args.config.is_file():
        sys.exit(f'Missing {args.site / "index.html"} or {args.config}; run `make html` first.')

    config = json.loads(args.config.read_text())
    site = config['site']
    base = config['how_to_cite']['url_prefix']
    book_id = f'urn:uuid:{uuid.uuid5(uuid.NAMESPACE_URL, base)}'
    title = site['title']
    term = f"{site['event']} · {site['term']}"
    authors = re.split(r',\s*|\s+and\s+', site['authors'])
    groups = reading_groups(config)
    lectures = [lec for group in groups for lec in group['lectures']]
    slugs = {lec['slug'] for lec in lectures}
    course_svg = (ROOT / COURSE_FIGURES['course-image-transparent.svg']).read_bytes()
    index = BeautifulSoup((args.site / 'index.html').read_bytes(), 'lxml')
    overview = '\n'.join(p.decode(formatter='minimal') for p in index.select('#overview .overview-copy > p'))

    print('Converting lectures')
    math, images, chapters, problems = MathQueue(), {}, {}, []
    for lec in lectures:
        raw = (args.site / f"{lec['slug']}.html").read_bytes()
        chapters[lec['slug']] = convert_lecture(lec, raw, slugs, math, images, base)
        problems += [f"{lec['slug']}.html: {label}" for label in leftovers(chapters[lec['slug']][0])]
    print(f'Rendering {len(math.jobs)} formulas to MathML')
    errors = math.render()
    if errors:
        problems.append(f'{errors} KaTeX errors (listed above)')
    if problems:
        sys.exit('EPUB not written; the converter does not handle:\n  ' + '\n  '.join(problems))

    files = {}
    for lec in lectures:
        body, _ = chapters[lec['slug']]
        files[f"{lec['slug']}.xhtml"] = xhtml_page(f"{lec['number']}. {lec['title']}", math.substitute(body))

    generated = datetime.date.today().isoformat()
    author_lines = '<br/>'.join(esc(a) for a in authors)
    title_body = f'''<section class="title-page" epub:type="titlepage">
<p class="title-term">{esc(term)}</p>
<h1 class="title-main">{esc(title)}</h1>
<p class="title-authors">{author_lines}</p>
<img class="title-image" src="images/course.svg" alt="Two phase portraits of learning dynamics in two-player games."/>
<div class="title-overview">{overview}</div>
<p class="title-source">Built from the course sources on {generated}. The notes are published at
<a href="{esc(base)}">{esc(base)}</a>, with a PDF of each lecture.</p>
</section>'''
    files['title.xhtml'] = xhtml_page(title, title_body)
    images['images/course.svg'] = (course_svg, 'image/svg+xml')

    cover = make_cover(course_svg, title, term, authors)
    if cover:
        images['images/cover.png'] = (cover, 'image/png')
        files['cover.xhtml'] = xhtml_page('Cover', '<div class="cover"><img src="images/cover.png" alt="Cover"/></div>')

    toc = [{'label': 'About this course', 'href': 'title.xhtml', 'children': []}]
    for group in groups:
        children = [{'label': f"{lec['number']}. {lec['title']}", 'href': f"{lec['slug']}.xhtml",
                     'children': nest(chapters[lec['slug']][1])} for lec in group['lectures']]
        toc.append({'label': group['label'], 'href': children[0]['href'], 'children': children})

    files['nav.xhtml'] = xhtml_page('Contents', f'''<nav epub:type="toc" id="toc"><h1>Contents</h1>{nav_ol(toc)}</nav>
<nav epub:type="landmarks" hidden=""><ol>
<li><a epub:type="titlepage" href="title.xhtml">Title page</a></li>
<li><a epub:type="bodymatter" href="{lectures[0]['slug']}.xhtml">Lectures</a></li>
</ol></nav>''')
    files['toc.ncx'] = f'''<?xml version="1.0" encoding="utf-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
<head><meta name="dtb:uid" content="{book_id}"/></head>
<docTitle><text>{esc(title)}</text></docTitle>
<navMap>{ncx_points(toc, {})}</navMap>
</ncx>
'''
    files['style.css'] = STYLESHEET.read_text(encoding='utf-8')

    spine = (['cover.xhtml'] if cover else []) + ['title.xhtml', 'nav.xhtml'] + [f"{lec['slug']}.xhtml" for lec in lectures]
    manifest = []
    for name, content in files.items():
        if name == 'toc.ncx':
            manifest.append('<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>')
            continue
        media = 'text/css' if name.endswith('.css') else 'application/xhtml+xml'
        props = ['nav'] if name == 'nav.xhtml' else []
        if '<math' in content:
            props.append('mathml')
        attr = f' properties="{" ".join(props)}"' if props else ''
        manifest.append(f'<item id="{item_id(name)}" href="{name}" media-type="{media}"{attr}/>')
    for name, (_, media) in images.items():
        attr = ' properties="cover-image"' if name == 'images/cover.png' else ''
        manifest.append(f'<item id="{item_id(name)}" href="{name}" media-type="{media}"{attr}/>')
    modified = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    creators = '\n'.join(f'<dc:creator id="author{i}">{esc(a)}</dc:creator>' for i, a in enumerate(authors))
    cover_meta = f'<meta name="cover" content="{item_id("images/cover.png")}"/>' if cover else ''
    manifest_items = '\n'.join(manifest)
    spine_items = '\n'.join(f'<itemref idref="{item_id(n)}"/>' for n in spine)
    opf = f'''<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
<dc:identifier id="bookid">{book_id}</dc:identifier>
<dc:title>{esc(title)} ({esc(site['event'])})</dc:title>
{creators}
<dc:language>en</dc:language>
<dc:publisher>MIT</dc:publisher>
<dc:source>{esc(base)}</dc:source>
<dc:description>Lecture notes for {esc(site['event'])}, {esc(site['term'])}: game theory, optimization, and learning in multiagent systems.</dc:description>
<meta property="dcterms:modified">{modified}</meta>
{cover_meta}
</metadata>
<manifest>
{manifest_items}
</manifest>
<spine toc="ncx">
{spine_items}
</spine>
</package>
'''

    out = args.output
    out.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out, 'w') as z:
        z.writestr(zipfile.ZipInfo('mimetype'), 'application/epub+zip', compress_type=zipfile.ZIP_STORED)
        z.writestr('META-INF/container.xml', '''<?xml version="1.0" encoding="utf-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>
''', compress_type=zipfile.ZIP_DEFLATED)
        z.writestr('OEBPS/content.opf', opf, compress_type=zipfile.ZIP_DEFLATED)
        for name, content in files.items():
            z.writestr(f'OEBPS/{name}', content, compress_type=zipfile.ZIP_DEFLATED)
        for name, (data, _) in images.items():
            z.writestr(f'OEBPS/{name}', data, compress_type=zipfile.ZIP_DEFLATED)

    print(f'Wrote {out} ({out.stat().st_size / 1e6:.1f} MB): {len(lectures)} chapters, '
          f'{len(math.jobs)} formulas, {len(images)} images')


if __name__ == '__main__':
    main()
