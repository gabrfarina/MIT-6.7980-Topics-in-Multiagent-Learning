#!/usr/bin/env python3
"""Compile native Typst document bundles and postprocess the course website."""
from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
from hashlib import sha256
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import zipfile

from build_figures import HTML_FIGURES, build_figures
from build_cache import current, fingerprint, save, tool_signature, write_if_changed
from course_index import load_course, render_index
from lecture_links import validate_lecture_links
from public_files import copy_font_assets, copy_public_files, note_outputs, required_files, validate_public_path

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / '.build' / 'site'
CONFIG = ROOT / 'html-export.json'
RESOLVED_CONFIG = ROOT / '.build' / 'html-export.json'


def run(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, check=True)


def chapter_source_text(source: Path, chapter: dict | None = None) -> str:
    """Validate authored titles and derive schedule numbers/dates for export."""
    content = source.read_text()
    if re.search(r'gabri_notes_(?:bk|pdf)\.typ|"\.\./(?:meta|figures|assets)/|figures/L\d+/', content):
        raise ValueError(f'{source.name}: obsolete source layout or notes style; '
                         'use content/<topic>.typ with meta/gabri_notes.typ and figures/<topic>/.')
    if chapter is not None and 'date' in chapter:
        content, numbers = re.subn(r'lec_num:\s*(?:"[^"]+"|\d+)',
            lambda _: 'lec_num: ' + json.dumps(chapter['number']), content, count=1)
        content, dates = re.subn(r'date:\s*\[[^\]]*\]',
            lambda _: 'date: [' + chapter['date'] + ']', content, count=1)
        if numbers != 1 or dates != 1:
            raise ValueError(f'{source.name}: expected one lecture number and date in the note header.')
    if chapter is not None and 'title' in chapter:
        match = re.search(r'\btitle:\s*("(?:\\.|[^"\\])*"|\[[^\]]*\])', content)
        if match is None:
            raise ValueError(f'{source.name}: expected a literal lecture title in the note header.')
        literal = match[1]
        title = json.loads(literal) if literal.startswith('"') else literal[1:-1].strip()
        if title != chapter['title']:
            raise ValueError(
                f'{source.name}: authored title {title!r} does not match '
                f'syllabus/list title {chapter["title"]!r}. Edit the Typst title explicitly.')
    return content


def relocate_source_paths(source: Path, content: str, *, root: Path | None = None) -> str:
    """Resolve lecture-local dependencies before moving a source into .build/."""
    root = (ROOT if root is None else root).resolve()

    def absolute_path(match: re.Match) -> str:
        target = (source.parent / match[1]).resolve().relative_to(root)
        return '"/' + target.as_posix() + '"'

    return re.sub(r'"((?:meta|figures)/[^"]+)"', absolute_path, content)


def prepare_pdf_source(source: Path, chapter: dict | None = None,
                       *, root: Path | None = None) -> Path:
    """Apply scheduled headers and relocate paths, keeping the authored PDF style."""
    root = (ROOT if root is None else root).resolve()
    content = relocate_source_paths(source, chapter_source_text(source, chapter), root=root)
    target = root / '.build' / 'pdf-source' / source.name
    write_if_changed(target, content)
    return target


def prepare_html_source(source: Path, chapter: dict) -> Path:
    content = chapter_source_text(source, chapter)
    content = relocate_source_paths(source, content)
    content = content.replace('/content/meta/gabri_notes.typ',
                              '/content/meta/gabri_notes_html.typ')
    content = re.sub(r'"/content/figures/([^"\n]+\.svg)"',
                     lambda match: '"/' + HTML_FIGURES.as_posix() + '/' + match[1] + '"',
                     content)
    target = ROOT / '.build' / 'html-source' / source.name
    write_if_changed(target, content)
    return target


def compile_note_bundle(format: str, *, force: bool = False, tools: dict | None = None) -> Path:
    """Resolve cross-document refs natively, without exporting reference data."""
    output = ROOT / '.build' / ('native-' + format)
    log = ROOT / '.build/logs' / ('bundle-' + format + '.log')
    cache = ROOT / '.build/lecture-cache' / ('bundle-' + format + '.json')
    deps = cache.with_suffix('.deps.json')
    command = [
        'typst', 'compile', '--root', str(ROOT),
        '--font-path', str(ROOT / 'html-exporter/assets/fonts'),
        '--features', 'bundle,html', '--format', 'bundle',
        '--deps', str(deps),
        '--input', 'course-bundle=true', '--input', 'notes-format=' + format,
        '--input', 'html-math=katex', str(ROOT / 'content/bundle.typ'), str(output),
    ]
    signature = dict(tools if tools is not None else tool_signature(ROOT),
                     command=command, builder=fingerprint(Path(__file__)))
    if not force and current(cache, signature):
        print(f'Lecture {format.upper()} bundle: up to date.', flush=True)
        return output
    cache.parent.mkdir(parents=True, exist_ok=True)
    cache.unlink(missing_ok=True)
    deps.unlink(missing_ok=True)
    if output.exists():
        shutil.rmtree(output)
    log.parent.mkdir(parents=True, exist_ok=True)
    with log.open('w') as stream:
        result = subprocess.run(command, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f'Native {format} bundle failed:\n{log.read_text()}')
    dependencies = [ROOT / path for path in json.loads(deps.read_text())['inputs']]
    save(cache, signature, dependencies, (path for path in output.rglob('*') if path.is_file()))
    print(f'Lecture {format.upper()} bundle: rebuilt.', flush=True)
    return output


def build_chapter(chapter: dict, *, force: bool = False) -> str:
    """Style native bundle HTML while preserving its cross-document anchors."""
    source = ROOT / chapter['source']
    outputs = note_outputs(chapter)
    directory = ROOT / '.build/lecture-pages' / source.stem
    output = directory / outputs['html']
    if not (STAGE / outputs['pdf']).is_file():
        raise RuntimeError(f"Native PDF missing for {source.name}")
    cache = ROOT / '.build/lecture-cache' / (source.stem + '.json')
    native_html = ROOT / '.build/native-html' / outputs['html']
    # The whole navigation and citation configuration is visible on each page.
    dependencies = [native_html, RESOLVED_CONFIG, STAGE / 'assets/notes.css']
    signature = dict(builder=fingerprint(Path(__file__)),
                     exporter=fingerprint(ROOT / 'html-exporter/target/release/notes-html-exporter'),
                     chapter=chapter)
    if not force and current(cache, signature):
        shutil.copytree(directory, STAGE, dirs_exist_ok=True)
        return f"Lecture {chapter['number']}: up to date."
    cache.unlink(missing_ok=True)
    if directory.exists():
        shutil.rmtree(directory)
    directory.mkdir(parents=True)
    log = ROOT / '.build' / 'logs' / (source.stem + '.log')
    with log.open('w') as stream:
        result = subprocess.run([
            str(ROOT / 'html-exporter/target/release/notes-html-exporter'),
            '--root', str(ROOT), '--config', str(RESOLVED_CONFIG), '--math', 'katex',
            '--pdf', outputs['pdf'],
            '--from-html', str(native_html),
            str(source), str(output),
        ], cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f"Lecture {chapter['number']} failed:\n{log.read_text()}")
    html = output.read_text()
    # Keep one shared stylesheet; KaTeX sources stay in the lecture HTML.
    stylesheet_version = sha256((STAGE / 'assets/notes.css').read_bytes()).hexdigest()[:12]
    html, count = re.subn(r'<style>\s*.*?</style>',
                         f'<link rel="stylesheet" href="assets/notes.css?v={stylesheet_version}">',
                         html, count=1, flags=re.S)
    if count != 1:
        raise RuntimeError(f'Expected the converter stylesheet in {output}')
    html = html.replace('https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/', 'assets/katex/')
    output.write_text(html)
    save(cache, signature, dependencies, (path for path in directory.rglob('*') if path.is_file()))
    shutil.copytree(directory, STAGE, dirs_exist_ok=True)
    return f"Lecture {chapter['number']}: {source.stem}.html"


def make_index(config: dict, schedule: list[dict], *, force: bool = False,
               tools: dict | None = None) -> None:
    syllabus = ROOT / config['site']['syllabus_source']
    stylesheet_version = sha256((STAGE / 'assets/course.css').read_bytes()).hexdigest()[:12]
    notes_version = sha256((STAGE / 'assets/notes.css').read_bytes()).hexdigest()[:12]
    (STAGE / 'index.html').write_text(render_index(
        config, schedule, stylesheet_version=stylesheet_version,
        notes_stylesheet_version=notes_version))
    copy_public_files(config, ROOT, STAGE)
    # Cache the linked syllabus with its actual imports and image dependencies.
    output = ROOT / '.build/syllabus/syllabus.pdf'
    cache = ROOT / '.build/lecture-cache/syllabus.json'
    deps = cache.with_suffix('.deps.json')
    command = ['typst', 'compile', '--root', str(ROOT),
               '--font-path', str(ROOT / 'html-exporter/assets/fonts'),
               '--deps', str(deps), str(syllabus), str(output)]
    signature = dict(tools if tools is not None else tool_signature(ROOT), command=command)
    if force or not current(cache, signature):
        cache.parent.mkdir(parents=True, exist_ok=True)
        output.parent.mkdir(parents=True, exist_ok=True)
        cache.unlink(missing_ok=True)
        deps.unlink(missing_ok=True)
        run(*command)
        save(cache, signature, [ROOT / path for path in json.loads(deps.read_text())['inputs']], [output])
        print('Syllabus: rebuilt.', flush=True)
    else:
        print('Syllabus: up to date.', flush=True)
    shutil.copy2(output, STAGE / 'syllabus.pdf')
    shutil.copy2(output, ROOT / 'syllabus/6.7980 Fall 2026 Syllabus.pdf')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--zip', action='store_true', help='also create dist/6.7980-notes.zip')
    parser.add_argument('--skip-build', action='store_true', help='reuse the existing Rust binary')
    parser.add_argument('--force', action='store_true', help='rebuild figures, lectures, and syllabus regardless of caches')
    args = parser.parse_args()
    config, schedule = load_course(CONFIG)
    print(f"Validated {validate_lecture_links(ROOT, config)} inter-lecture links.", flush=True)
    RESOLVED_CONFIG.parent.mkdir(exist_ok=True)
    write_if_changed(RESOLVED_CONFIG, json.dumps(config, indent=2) + "\n")
    # Native bundles need only document identity; course logistics and slide
    # attachments must not invalidate every lecture compilation.
    bundle_notes = [{key: note[key] for key in ('source', 'number', 'title')}
                    for note in config['notes']]
    write_if_changed(ROOT / '.build/note-bundle.json', json.dumps(bundle_notes) + '\n')
    version = subprocess.check_output(['typst', '--version'], text=True)
    match = re.search(r'typst (\d+)\.(\d+)\.(\d+)', version)
    if not match or tuple(map(int, match.groups())) < (0, 15, 1):
        raise RuntimeError('Typst 0.15.1 or later is required for the native bundle target.')
    if not args.skip_build:
        run('cargo', 'build', '--release', '--locked', '--manifest-path', 'html-exporter/Cargo.toml')
    if STAGE.exists():
        shutil.rmtree(STAGE)
    (STAGE / 'assets').mkdir(parents=True)
    shutil.copytree(ROOT / 'html-exporter/assets', STAGE / 'assets', dirs_exist_ok=True)
    (STAGE / 'pdf').mkdir()
    (ROOT / '.build' / 'logs').mkdir(exist_ok=True)
    shutil.copy2(ROOT / 'html-exporter/src/gabri-notes.css', STAGE / 'assets/notes.css')
    shutil.copy2(ROOT / 'html-exporter/src/course.css', STAGE / 'assets/course.css')
    tools = tool_signature(ROOT)
    build_figures(ROOT, force=args.force)
    for chapter in config['notes']:
        prepare_pdf_source(ROOT / chapter['source'], chapter)
        prepare_html_source(ROOT / chapter['source'], chapter)
    pdf_bundle = compile_note_bundle('pdf', force=args.force, tools=tools)
    shutil.copytree(pdf_bundle / 'pdf', STAGE / 'pdf', dirs_exist_ok=True)
    compile_note_bundle('html', force=args.force, tools=tools)
    with ThreadPoolExecutor(max_workers=3) as pool:
        for message in pool.map(lambda chapter: build_chapter(chapter, force=args.force), config['notes']):
            print(message, flush=True)
    make_index(config, schedule, force=args.force, tools=tools)
    entries = [{'output': str(p.relative_to(STAGE)), 'source': str(p.relative_to(ROOT))}
               for p in sorted(STAGE.rglob('*')) if p.is_file()]
    required = required_files(config)
    for entry in entries:
        validate_public_path(entry['output'], required)
    if missing := required - {entry['output'] for entry in entries}:
        raise ValueError('Incomplete site: ' + ', '.join(sorted(missing)))
    shutil.copytree(STAGE, ROOT / 'html', dirs_exist_ok=True)
    copy_font_assets(ROOT, ROOT / 'html')
    # Retire downloads from earlier builds, including in the local preview.
    legacy_source = ROOT / 'html/source'
    if legacy_source.is_symlink():
        legacy_source.unlink()
    elif legacy_source.exists():
        shutil.rmtree(legacy_source)
    run(sys.executable, 'scripts/check_site.py', 'html')
    run('node', 'scripts/check_katex.cjs', 'html')
    (ROOT / '.build/bundle-files.json').write_text(json.dumps(entries, indent=2) + '\n')
    if args.zip:
        target = ROOT / 'dist/6.7980-notes.zip'
        target.parent.mkdir(exist_ok=True)
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as archive:
            for entry in entries:
                archive.write(ROOT / 'html' / entry['output'], entry['output'])
        print(f'ZIP: {target.relative_to(ROOT)}')
    print('Site: html/index.html')


if __name__ == '__main__':
    main()
