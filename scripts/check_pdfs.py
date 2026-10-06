#!/usr/bin/env python3
"""Compile every authored note with its default project root and vendored fonts."""
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def check_pdfs() -> None:
    output = ROOT / '.build' / 'standalone-pdfs'
    output.mkdir(parents=True, exist_ok=True)
    # A local compiler environment must not hide missing source dependencies.
    env = {key: value for key, value in os.environ.items()
           if not key.startswith('TYPST_')}
    sources = sorted(path for path in (ROOT / 'content').glob('*.typ')
                     if path.name != 'bundle.typ')
    if not sources:
        raise RuntimeError('No lecture sources found.')

    def compile_note(source: Path) -> bool:
        result = subprocess.run(
            ['typst', 'compile', '--font-path', str(ROOT / 'html-exporter/assets/fonts'),
             source.name, str(output / source.with_suffix('.pdf').name)],
            cwd=source.parent, env=env, capture_output=True, text=True,
        )
        diagnostics = result.stdout + result.stderr
        (output / source.with_suffix('.log').name).write_text(diagnostics)
        print(f'{source.name}: {"FAILED" if result.returncode else "OK"}', flush=True)
        if result.returncode:
            print(diagnostics, flush=True)
        return result.returncode == 0

    with ThreadPoolExecutor(max_workers=3) as pool:
        results = list(pool.map(compile_note, sources))
    if not all(results):
        raise RuntimeError(f'{results.count(False)} note(s) failed default PDF compilation.')
    print(f'All {len(sources)} notes compile with the vendored fonts and default project root.', flush=True)


if __name__ == '__main__':
    check_pdfs()
