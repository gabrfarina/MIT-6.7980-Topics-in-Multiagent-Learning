#!/usr/bin/env python3
"""Regenerate Source Sans 3 webfonts from the bundled static TTFs.

Requires fontTools. WOFF compression retains the TTF outlines, metrics,
hinting, and licensing metadata. See the font directory's README.md for
the original, unmodified Adobe sources and reproduction procedure.
"""
from hashlib import sha256
from pathlib import Path
import re

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[1]
FONTS = ROOT / 'html-exporter/assets/fonts'
CSS = ROOT / 'html-exporter/src/gabri-notes.css'


def build_web_font(source: Path, output: Path) -> None:
    with TTFont(source, recalcTimestamp=False) as font:
        font.flavor = 'woff'
        font.save(output)


def main() -> None:
    css = CSS.read_text()
    for face in ('Regular', 'Bold'):
        output = FONTS / f'SourceSans3-{face}-web.woff'
        build_web_font(FONTS / f'SourceSans3-{face}.ttf', output)
        version = sha256(output.read_bytes()).hexdigest()[:12]
        css, count = re.subn(
            rf'url\("fonts/SourceSans3-{face}(?:\.ttf|-web\.woff)\?v=[0-9a-f]+"\) format\("(?:truetype|woff)"\)',
            f'url("fonts/{output.name}?v={version}") format("woff")', css)
        if count != 1:
            raise ValueError(f'Expected one font-face source for Source Sans 3 {face}')
        print(f'{output.relative_to(ROOT)}: {output.stat().st_size} bytes')
    CSS.write_text(css)


if __name__ == '__main__':
    main()
