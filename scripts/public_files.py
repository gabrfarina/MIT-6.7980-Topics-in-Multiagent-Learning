"""The public file contract shared by rendering, building, and deployment."""
from html.parser import HTMLParser
from pathlib import Path, PurePosixPath
import json
import re
import shutil
import subprocess

COURSE_FIGURES = {
    'traffic-cone.svg': 'content/meta/traffic-cone.svg',
    'course-image-transparent.svg': 'website/thumbnail-transparent.svg',
    'html-notes-collage.svg': 'syllabus/assets/html-notes-collage.svg',
    'fog-of-war-challenge.png': 'syllabus/assets/fog-of-war-challenge.png',
}
ASSET_SUFFIXES = {'.css', '.js', '.svg', '.png', '.jpg', '.jpeg', '.gif', '.webp',
                  '.ttf', '.otf', '.woff', '.woff2'}


def copy_font_assets(root: Path, destination: Path) -> None:
    """Replace generated fonts so retired faces are no longer distributed."""
    source = root / 'html-exporter/assets/fonts'
    target = destination / 'assets/fonts'
    if target.is_symlink():
        target.unlink()
    elif target.exists():
        shutil.rmtree(target)
    shutil.copytree(source, target)


def note_outputs(note: dict) -> dict[str, str]:
    source = Path(note['source'])
    return {'html': source.stem + '.html', 'pdf': f'pdf/{source.stem}.pdf'}


def slide_output(source: str) -> str:
    if not isinstance(source, str) or Path(source).suffix.lower() != '.pdf':
        raise ValueError(f'Configured slides must be PDFs: {source!r}')
    return 'slides/' + Path(source).name


def interactive_slide_output(source: str) -> str:
    if not isinstance(source, str) or Path(source).suffix.lower() != '.html':
        raise ValueError(f'Configured interactive slides must be standalone HTML: {source!r}')
    return 'slides/' + Path(source).name


class StandaloneSlides(HTMLParser):
    """Check standalone assets and keep private speaker notes out of published slides."""
    def __init__(self):
        super().__init__()
        self.document = False
        self.in_style = False
        self.in_slide_data = False
        self.slide_data = []

    @staticmethod
    def asset(value: str) -> None:
        if value and not value.strip().lower().startswith(('data:', '#')):
            raise ValueError('Interactive slides must embed their assets; found: ' + value[:120])

    @classmethod
    def css(cls, value: str) -> None:
        if re.search(r'@import\b', value, re.I):
            raise ValueError('Interactive slides must inline imported stylesheets.')
        for match in re.finditer(r'url\(\s*([\'"]?)(.*?)\1\s*\)', value, re.I | re.S):
            cls.asset(match[2])

    def handle_starttag(self, tag, attrs):
        self.document |= tag == 'html'
        self.in_style |= tag == 'style'
        attributes = dict(attrs)
        if tag == 'aside' and 'notes' in (attributes.get('class') or '').split():
            raise ValueError('Interactive slides must not contain speaker notes.')
        if 'data-notes' in attributes:
            raise ValueError('Interactive slides must not contain speaker notes.')
        if tag == 'script' and attributes.get('id') == 'slide-data':
            self.in_slide_data = True
            self.slide_data = []
        if tag == 'base':
            raise ValueError('Interactive slides must not set a base URL.')
        for key, value in attrs:
            if value is None:
                continue
            if key == 'srcset':
                raise ValueError('Interactive slides must embed images with src, not srcset.')
            if (key in {'src', 'poster'} or (tag == 'object' and key == 'data')
                    or (tag in {'link', 'image', 'use'} and key in {'href', 'xlink:href'})):
                self.asset(value)
            if key == 'style':
                self.css(value)

    def handle_endtag(self, tag):
        if tag == 'style':
            self.in_style = False
        if tag == 'script' and self.in_slide_data:
            try:
                slides = json.loads(''.join(self.slide_data))
            except json.JSONDecodeError as error:
                raise ValueError('Interactive slides have invalid slide metadata.') from error
            if isinstance(slides, list) and any(
                    isinstance(slide, dict) and ({'notes', 'source'} & slide.keys())
                    for slide in slides):
                raise ValueError('Interactive slides must not contain speaker notes.')
            self.in_slide_data = False

    def handle_data(self, data):
        if self.in_style:
            self.css(data)
        if self.in_slide_data:
            self.slide_data.append(data)


def validate_standalone_slide(path: Path) -> None:
    page = StandaloneSlides()
    page.feed(path.read_text(encoding='utf-8'))
    page.close()
    if not page.document:
        raise ValueError(f'Interactive slides must be a complete HTML document: {path}')


def copied_files(config: dict) -> dict[str, str]:
    files = {'assets/course/' + name: source for name, source in COURSE_FIGURES.items()}
    owners = {}
    for field, output_name in (('slides', slide_output),
                               ('interactive_slides', interactive_slide_output)):
        slides = config.get(field, {})
        if not isinstance(slides, dict):
            raise ValueError(f'{field} must map stable lecture IDs to source paths.')
        for source in slides.values():
            output = output_name(source)
            key = output.casefold()
            if key in owners and owners[key] != source:
                raise ValueError(f'Colliding slide output: {output} ({owners[key]}, {source})')
            owners[key] = source
            files[output] = source
    return files


def required_files(config: dict) -> set[str]:
    required = {'index.html', 'syllabus.pdf'}
    claimed = {name.casefold() for name in required}
    for note in config['notes']:
        for output in note_outputs(note).values():
            if output.casefold() in claimed:
                raise ValueError(f'Colliding note output: {output}')
            claimed.add(output.casefold())
            required.add(output)
    required.update(copied_files(config))
    return required


def validate_public_path(name: str, required: set[str]) -> None:
    path = PurePosixPath(name)
    if (not name or path.is_absolute() or name != path.as_posix()
            or any(part.startswith('.') or part.lower().startswith('fow')
                   or part.lower() == 'challenge' for part in path.parts)
            or '\\' in name or any(ord(c) < 32 for c in name)):
        raise ValueError(f'Unsafe or private manifest path: {name!r}')
    is_asset = (path.parts[0] == 'assets' and
                (path.suffix in ASSET_SUFFIXES or name in
                 {'assets/katex/LICENSE', 'assets/katex/VERSION',
                  'assets/fonts/OFL.txt', 'assets/fonts/README.md'}))
    if name not in required and not is_asset:
        raise ValueError(f'Unexpected public build artifact: {name}')


def validate_inputs(config: dict, modules: list[dict], root: Path) -> None:
    """Fail before writing outputs, including for unlinked or corrupt slides."""
    required = required_files(config)
    for name in required:
        validate_public_path(name, required)
    ids = {r['id'] for m in modules for r in m['rows'] if r['kind'] == 'lecture'}
    for field in ('slides', 'interactive_slides'):
        if unknown := config.get(field, {}).keys() - ids:
            raise ValueError('Unknown slide lecture IDs: ' + ', '.join(sorted(unknown)))
    sources = [n['source'] for n in config['notes']] + list(copied_files(config).values())
    for source in set(sources):
        path = root / source
        if Path(source).is_absolute() or not path.resolve().is_relative_to(root.resolve()):
            raise ValueError(f'Source must stay inside the course directory: {source}')
        if not path.is_file():
            raise ValueError(f'Missing course source: {source}')
    for source in set(config.get('slides', {}).values()):
        result = subprocess.run(['pdfinfo', str(root / source)], capture_output=True, text=True)
        if result.returncode:
            raise ValueError(f'Invalid slide PDF: {source}\n{result.stderr.strip()}')
    for source in set(config.get('interactive_slides', {}).values()):
        validate_standalone_slide(root / source)


def copy_public_files(config: dict, root: Path, destination: Path) -> None:
    # Recheck at the copy boundary even if a caller skipped validate_inputs.
    for source in set(config.get('interactive_slides', {}).values()):
        validate_standalone_slide(root / source)
    for output, source in copied_files(config).items():
        target = destination / output
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / source, target)
