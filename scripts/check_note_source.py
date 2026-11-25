#!/usr/bin/env python3
"""Check Typst note sources for conventions that compile but read wrong.

Rules:
  hardcoded-number  Prose such as "Example L16.12" goes stale when environments
                    are added or reordered; use a label and `@label` instead.
  math-shorthand    Inside math, use Typst's shorthand when one exists, e.g.
                    `<=` for `lt.eq`, `->` for `arrow.r`.

Append `// source-check: allow` to a line to silence a deliberate exception.

Usage: check_note_source.py [PATH ...]   (default: content/ and syllabus/)
"""
from dataclasses import dataclass
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PATHS = (ROOT / 'content', ROOT / 'syllabus')
ALLOW = 'source-check: allow'

# Named symbols with an exact math shorthand. Keys are full dotted names, so
# `arrow.r.long.bar` never matches a shorter entry, and `dots.c` (no
# shorthand) is kept.
SHORTHANDS = {
    'dots': '...', 'dots.h': '...',
    'lt.eq': '<=', 'gt.eq': '>=', 'eq.not': '!=',
    'colon.eq': ':=', 'tilde.op': '~',
    'arrow.r': '->', 'arrow.l': '<-', 'arrow.l.r': '<->',
    'arrow.r.bar': '|->', 'arrow.r.long': '-->', 'arrow.l.long': '<--',
    'arrow.r.double': '=>', 'arrow.l.r.double': '<=>',
    'arrow.r.double.long': '==>', 'arrow.l.double.long': '<==',
    'arrow.l.r.double.long': '<==>',
}
IDENT = re.compile(r'(?<![\w.#-])(?:sym\.)?([A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z]+)*)(?![\w(])')
NUMBER = re.compile(r'(?<![\w.])L\d+\.\d+(?![\w.]*\d)')


@dataclass(frozen=True)
class Finding:
    path: Path
    line: int
    column: int
    rule: str
    message: str

    def __str__(self):
        try:
            shown = self.path.relative_to(ROOT)
        except ValueError:
            shown = self.path
        return f'{shown}:{self.line}:{self.column}: {self.rule}: {self.message}'


def segments(text):
    """Yield (kind, start, end) spans of markup and math, skipping comments,
    raw text, escapes, and strings inside math."""
    i, n = 0, len(text)
    kind, start = 'markup', 0
    while i < n:
        c = text[i]
        if c == '\\' and i + 1 < n:
            i += 2
            continue
        if kind == 'markup' and c == '`':
            run = len(text[i:]) - len(text[i:].lstrip('`'))
            end = text.find('`' * run, i + run)
            if end < 0:
                end = n
            yield kind, start, i
            i = start = end + run
            continue
        if kind == 'math' and c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            yield kind, start, i
            i = start = j + 1
            continue
        if text.startswith('//', i) and (i == 0 or text[i - 1] != ':'):
            end = text.find('\n', i)
            end = n if end < 0 else end
            yield kind, start, i
            i = start = end
            continue
        if text.startswith('/*', i):
            end = text.find('*/', i + 2)
            end = n if end < 0 else end + 2
            yield kind, start, i
            i = start = end
            continue
        if c == '$':
            yield kind, start, i
            kind = 'math' if kind == 'markup' else 'markup'
            i = start = i + 1
            continue
        i += 1
    yield kind, start, n


def check_text(text, path=Path('<string>')):
    allowed = {number for number, line in enumerate(text.splitlines(), 1) if ALLOW in line}
    findings = []

    def add(offset, rule, message):
        line = text.count('\n', 0, offset) + 1
        if line not in allowed:
            column = offset - (text.rfind('\n', 0, offset) + 1) + 1
            findings.append(Finding(path, line, column, rule, message))

    for kind, start, end in segments(text):
        chunk = text[start:end]
        if kind == 'markup':
            for match in NUMBER.finditer(chunk):
                add(start + match.start(), 'hardcoded-number',
                    f'"{match[0]}" is a hard-coded number; label the target and reference it with @label')
        else:
            for match in IDENT.finditer(chunk):
                name = match[1]
                if name in SHORTHANDS:
                    add(start + match.start(), 'math-shorthand',
                        f'use `{SHORTHANDS[name]}` instead of `{match[0]}`')
    return findings


def typst_files(paths):
    for path in paths:
        path = Path(path)
        if path.is_dir():
            yield from sorted(p for p in path.rglob('*.typ') if '.build' not in p.parts)
        else:
            yield path


def check_paths(paths=DEFAULT_PATHS):
    findings = []
    for path in typst_files(paths):
        findings += check_text(path.read_text(encoding='utf-8'), path.resolve())
    return findings


def main(argv):
    findings = check_paths([Path(p) for p in argv] or DEFAULT_PATHS)
    for finding in findings:
        print(finding)
    if findings:
        print(f'{len(findings)} finding(s). Append `// {ALLOW}` to a line for a deliberate exception.')
    return 1 if findings else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
