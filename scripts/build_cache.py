"""Content-based build records, written only after successful builds."""
from hashlib import sha256
import json
import os
from pathlib import Path
import shutil


def fingerprint(path: Path) -> str | None:
    try:
        return sha256(path.read_bytes()).hexdigest()
    except FileNotFoundError:
        return None


def write_if_changed(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.is_file() or path.read_text() != text:
        path.write_text(text)


def current(cache: Path, signature: dict) -> bool:
    try:
        record = json.loads(cache.read_text())
        if record['signature'] != signature:
            return False
        for key in ('dependencies', 'outputs'):
            entries = record[key]
            if not isinstance(entries, dict) or not entries:
                return False
            if any(not isinstance(digest, str) or fingerprint(Path(path)) != digest
                   for path, digest in entries.items()):
                return False
        return True
    except (OSError, ValueError, KeyError, TypeError):
        return False


def save(cache: Path, signature: dict, dependencies, outputs) -> None:
    record = {'signature': signature}
    for key, paths in (('dependencies', dependencies), ('outputs', outputs)):
        values = {str(path.resolve()): fingerprint(path) for path in paths}
        if not values or None in values.values():
            raise RuntimeError(f'Incomplete build {key}: {cache}')
        record[key] = values
    cache.parent.mkdir(parents=True, exist_ok=True)
    temporary = cache.with_suffix('.tmp')
    temporary.write_text(json.dumps(record, sort_keys=True) + '\n')
    temporary.replace(cache)


def tool_signature(root: Path) -> dict:
    font_dirs = [root / 'html-exporter/assets/fonts']
    font_dirs.extend(Path(p) for p in os.environ.get('TYPST_FONT_PATHS', '').split(os.pathsep) if p)
    compiler = shutil.which('typst')
    return {
        'cache_code': fingerprint(Path(__file__)),
        'compiler': fingerprint(Path(compiler)) if compiler else None,
        'environment': {key: value for key, value in os.environ.items()
                        if key.startswith('TYPST_') or key == 'SOURCE_DATE_EPOCH'},
        'fonts': {str(path.resolve()): fingerprint(path)
                  for folder in font_dirs for path in sorted(folder.rglob('*'))
                  if path.is_file()},
    }
