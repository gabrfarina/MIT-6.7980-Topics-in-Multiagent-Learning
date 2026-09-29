"""Validate authored cross-lecture destinations before native bundle compilation."""
from __future__ import annotations

from collections import Counter
from pathlib import Path
import re


LINK = re.compile(
    r'#lecture-link\s*\(\s*"([a-z][a-z0-9_]*)"\s*'
    r'(?:,\s*(?:<([A-Za-z][A-Za-z0-9_-]*)>|none)\s*)?\)')
DESTINATION_LABEL = re.compile(
    r'(?:^={1,6} [^\n]*?|\])\s*(?:<([A-Za-z][A-Za-z0-9_-]*)>'
    r'|#label\("([A-Za-z][A-Za-z0-9_-]*)"\))', re.M)


def validate_lecture_links(root: Path, config: dict) -> int:
    """Check note membership and labels; Typst validates referenceability.

    Keep these calls literal so destinations are reviewable in the prose and
    can be checked before compiling the native document bundles.
    The generated-site audit independently checks the final HTML fragments.
    """
    sources = {Path(note['source']).stem: (root / note['source']).read_text()
               for note in config['notes']}
    # Full-line comments are documentation, not authored cross-references.
    sources = {name: re.sub(r'^[ \t]*//[^\n]*', '', text, flags=re.M)
               for name, text in sources.items()}
    labels = {name: Counter(a or b for a, b in DESTINATION_LABEL.findall(text))
              for name, text in sources.items()}
    count = 0
    for source, text in sources.items():
        links = list(LINK.finditer(text))
        if len(links) != len(re.findall(r'#lecture-link\s*\(', text)):
            raise ValueError(f'{source}: use lecture-link("note", <label>)[text] '
                             'or lecture-link("note") with literal destinations.')
        for match in links:
            target, anchor = match.groups()
            prefix = f'{source}:{text[:match.start()].count(chr(10)) + 1}'
            if target not in sources:
                raise ValueError(f'{prefix}: unknown linked lecture {target!r}')
            if target == source:
                raise ValueError(f'{prefix}: use a native Typst link/ref within the same lecture')
            if anchor is not None:
                if labels[target][anchor] != 1:
                    raise ValueError(f'{prefix}: expected one labeled section or environment '
                                     f'<{anchor}> in {target}.typ; found {labels[target][anchor]}')
            count += 1
    return count
