#!/usr/bin/env python3
"""Validate generated course links and citation URLs, optionally checking the web."""
from __future__ import annotations

import argparse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import unquote, urljoin, urlsplit, urlunsplit
from urllib.request import Request, urlopen


def css_links(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    links = [m[2] for m in re.finditer(r'url\(\s*([\'"]?)(.*?)\1\s*\)', text, re.S)]
    links += re.findall(r'@import\s+[\'"]([^\'"]+)[\'"]', text)
    return links


class LinkPage(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.ids = set()
        self.links = []
        self.citations = []
        self.base_elements = 0
        self._citation = None
        self._details_depth = 0
        self._style = None
        self.feed(text)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if tag == 'a' and 'name' in attrs:
            self.ids.add(attrs['name'])
        if tag == 'base':
            self.base_elements += 1
        for key in ('href', 'src', 'xlink:href', 'poster', 'action', 'data' if tag == 'object' else ''):
            if attrs.get(key):
                self.links.append(attrs[key])
        if attrs.get('srcset'):
            # A URL token may contain commas (notably data URLs); descriptors
            # and trailing separator commas are not part of the URL.
            for candidate in re.finditer(r'(?:^|,\s*)(\S+?)(?:\s+\d+(?:\.\d+)?[wx])?(?=\s*,|\s*$)', attrs['srcset']):
                self.links.append(candidate[1].rstrip(','))
        if 'style' in attrs:
            self.links.extend(css_links(attrs['style']))
        if tag == 'style':
            self._style = []
        if tag == 'details':
            if self._citation is not None:
                self._details_depth += 1
            elif 'lecture-citation-details' in attrs.get('class', '').split():
                self._citation = []
                self._details_depth = 1

    def handle_data(self, text):
        if self._citation is not None:
            self._citation.append(text)
        if self._style is not None:
            self._style.append(text)

    def handle_endtag(self, tag):
        if tag == 'style' and self._style is not None:
            self.links.extend(css_links(''.join(self._style)))
            self._style = None
        if tag == 'details' and self._citation is not None:
            self._details_depth -= 1
            if self._details_depth == 0:
                self.citations.append(''.join(self._citation))
                self._citation = None


@dataclass
class Audit:
    issues: list[str] = field(default_factory=list)
    external: dict[str, set[str]] = field(default_factory=lambda: defaultdict(set))
    local_count: int = 0
    citation_count: int = 0


def validate_base(value):
    parsed = urlsplit(value)
    if (parsed.scheme not in ('http', 'https') or not parsed.hostname
            or parsed.username or parsed.password or parsed.query or parsed.fragment
            or not parsed.path.endswith('/') or any(c.isspace() for c in value)):
        raise ValueError(f'Expected an absolute HTTP(S) site URL with a trailing slash: {value!r}')
    return parsed


def audit_site(folder, config, *, base_url=None, aliases=()):
    folder = Path(folder).resolve()
    prefix = config['how_to_cite']['url_prefix']
    base_url = base_url or prefix
    bases = [validate_base(value) for value in (base_url, *aliases)]
    separate_paths = config.get('site', {}).get('separate_paths', [])
    for path in separate_paths:
        if not re.fullmatch(r'(?:[A-Za-z0-9_-]+/)+', path):
            raise ValueError(f'site.separate_paths must contain relative directory paths: {path!r}')
    audit = Audit()
    if prefix != base_url:
        audit.issues.append(f'how_to_cite.url_prefix is {prefix!r}; deployment requires {base_url!r}')
    pages = {path.relative_to(folder).as_posix(): LinkPage(path.read_text())
             for path in sorted(folder.rglob('*')) if path.suffix in ('.html', '.svg') and path.is_file()}
    links = []
    for name, page in pages.items():
        if page.base_elements:
            audit.issues.append(f'{name}: unexpected <base> changes link resolution')
        links.extend((name, link) for link in page.links)
    for path in sorted(folder.rglob('*.css')):
        links.extend((path.relative_to(folder).as_posix(), link) for link in css_links(path.read_text()))
    for chapter in config['notes']:
        name = Path(chapter['source']).stem + '.html'
        page = pages.get(name)
        if not page or len(page.citations) != 1:
            audit.issues.append(f'{name}: expected exactly one How to cite block')
            continue
        urls = re.findall(r'^\s*url\s*=\s*(?:\{([^{}]*)\}|"([^"]*)")\s*,?\s*$',
                          page.citations[0], re.M)
        if len(urls) != 1:
            audit.issues.append(f'{name}: How to cite must contain exactly one BibTeX url field')
            continue
        citation = urls[0][0] or urls[0][1]
        audit.citation_count += 1
        expected = base_url + name
        if citation != expected:
            audit.issues.append(f'{name}: How to cite URL is {citation!r}; expected {expected!r}')
        links.append((name, citation))
    for name, raw in sorted(set(links)):
        if not raw or raw.startswith('data:'):
            continue
        try:
            if raw != raw.strip() or any(ord(char) < 32 for char in raw):
                raise ValueError('contains whitespace or control characters')
            url = urlsplit(urljoin(base_url + name, raw))
            if url.scheme in ('mailto', 'tel'):
                if not url.path or (url.scheme == 'mailto' and '@' not in url.path):
                    raise ValueError('empty or malformed contact link')
                continue  # Address syntax only: never send a message or place a call.
            if url.scheme not in ('http', 'https') or not url.hostname or url.username or url.password:
                raise ValueError('not an ordinary HTTP(S) link')
            # Match a full path prefix, so /~6.79800/ is not mistaken for this site.
            matches = [b for b in bases if (url.scheme, url.netloc) == (b.scheme, b.netloc)
                       and (url.path.startswith(b.path) or url.path == b.path.rstrip('/'))]
            if not matches:
                original = urlsplit(raw)
                if not original.scheme and not original.netloc and not original.path.startswith('/'):
                    raise ValueError('relative link escapes the site directory')
                audit.external[urlunsplit(url)].add(name)
                continue
            base = max(matches, key=lambda b: len(b.path))
            relative = unquote(url.path[len(base.path):]) if url.path.startswith(base.path) else ''
            if any(relative == separate.rstrip('/') or relative.startswith(separate)
                   for separate in separate_paths):
                audit.external[urlunsplit(url)].add(name)
                continue
            target = (folder / relative).resolve()
            if target.is_dir():
                target = target / 'index.html'
            if not target.is_relative_to(folder):
                raise ValueError('escapes the site directory')
            if not target.is_file():
                raise ValueError('missing file in deployment')
            if url.fragment and target.suffix in ('.html', '.svg'):
                target_page = pages.get(target.relative_to(folder).as_posix())
                fragment = unquote(url.fragment).split(':~:text=', 1)[0]
                if fragment and (not target_page or fragment not in target_page.ids):
                    raise ValueError('missing anchor in deployment')
            audit.local_count += 1
        except ValueError as error:
            audit.issues.append(f'{name}: {error}: {raw}')
    return audit


def probe_url(url, timeout=10):
    """Return None for reachable URLs; preserve blocked/unknown versus broken."""
    parsed = urlsplit(url)
    request_url = urlunsplit(parsed._replace(fragment=''))
    fragment = unquote(parsed.fragment).split(':~:text=', 1)[0]
    methods = ['GET'] if fragment else ['HEAD', 'GET']
    for method in methods:
        try:
            request = Request(request_url, method=method, headers={
                'User-Agent': 'MIT-6.7980-Link-Checker/1.0', 'Accept': '*/*'})
            with urlopen(request, timeout=timeout) as response:
                if not 200 <= response.status < 300:
                    raise ValueError(f'HTTP {response.status}')
                if fragment and response.headers.get_content_type() == 'text/html':
                    limit = 2 * 1024 * 1024
                    body = response.read(limit + 1)
                    if len(body) > limit:
                        return 'unverified: HTML is too large to check the anchor'
                    text = body.decode(response.headers.get_content_charset() or 'utf-8', errors='replace')
                    if fragment not in LinkPage(text).ids:
                        return f'broken: missing external anchor #{fragment}'
                return None
        except HTTPError as error:
            status = error.code
            error.close()
            if method == 'HEAD':
                continue  # Some websites reject HEAD but permit ordinary GET.
            category = 'broken' if status in (404, 410) else 'unverified'
            return f'{category}: HTTP {status}'
        except (URLError, OSError, ValueError) as error:
            if method == 'HEAD':
                continue
            return f'unverified: {error}'
    return 'unverified: no successful response'


@dataclass
class ExternalAudit:
    issues: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


def check_external(links, *, timeout=10, doi_warnings=False):
    audit = ExternalAudit()
    urls = sorted(links)
    with ThreadPoolExecutor(max_workers=4) as pool:
        for url, result in zip(urls, pool.map(lambda value: probe_url(value, timeout), urls)):
            if result:
                destination = audit.issues
                if doi_warnings and urlsplit(url).hostname in ('doi.org', 'dx.doi.org'):
                    destination = audit.warnings
                destination.append(f'{", ".join(sorted(links[url]))}: {result}: {url}')
    return audit


def skip_separate_sites(audit, config, paths, *, base_url=None, aliases=()):
    configured = config.get('site', {}).get('separate_paths', [])
    if unknown := set(paths) - set(configured):
        raise ValueError('Cannot skip a site that is not in site.separate_paths: ' + ', '.join(sorted(unknown)))
    roots = [validate_base(base + path)
             for base in (base_url or config['how_to_cite']['url_prefix'], *aliases)
             for path in paths]
    skipped = []
    for value in list(audit.external):
        url = urlsplit(value)
        if any((url.scheme, url.netloc) == (root.scheme, root.netloc)
               and (url.path == root.path.rstrip('/') or url.path.startswith(root.path))
               for root in roots):
            skipped.append(value)
            del audit.external[value]
    return skipped


def main(argv=None):
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', nargs='?', default='html')
    parser.add_argument('--config', type=Path, default=root / 'html-export.json')
    parser.add_argument('--base-url', help='actual deployment URL; must agree with citation configuration')
    parser.add_argument('--alias-url', action='append', default=[], help='additional URL mapped to this payload')
    parser.add_argument('--skip-separate-site', action='append', default=[], metavar='PATH/',
                        help='skip an explicitly configured independently deployed directory')
    parser.add_argument('--online', action='store_true', help='also check external HTTP(S) links; failures block deployment')
    parser.add_argument('--doi-warnings', action='store_true',
                        help='report failed doi.org and dx.doi.org checks as non-blocking warnings')
    args = parser.parse_args(argv)
    config = json.loads(args.config.read_text())
    audit = audit_site(Path(args.folder), config,
                       base_url=args.base_url, aliases=args.alias_url)
    skipped = skip_separate_sites(audit, config, args.skip_separate_site,
                                 base_url=args.base_url, aliases=args.alias_url)
    print(f'Checked {audit.local_count} local links and {audit.citation_count} How to cite URLs.', flush=True)
    if skipped:
        print(f'Skipped {len(skipped)} link(s) into separate sites: {", ".join(args.skip_separate_site)}', flush=True)
    if audit.issues:
        print('\n'.join(sorted(set(audit.issues))), file=sys.stderr)
        return 1
    if args.online:
        print(f'Checking {len(audit.external)} distinct external URLs…', flush=True)
        external = check_external(audit.external, doi_warnings=args.doi_warnings)
        for warning in external.warnings:
            print(f'Non-blocking DOI warning: {warning}', file=sys.stderr)
        if external.issues:
            print('\n'.join(external.issues), file=sys.stderr)
            print('External verification failed; links listed as errors block deployment.', file=sys.stderr)
            return 1
        if external.warnings:
            print(f'{len(audit.external) - len(external.warnings)} external URLs responded successfully; '
                  f'{len(external.warnings)} non-blocking DOI warning(s).')
        else:
            print(f'All {len(audit.external)} external URLs responded successfully.')
    else:
        print(f'{len(audit.external)} external URLs require --online for live verification.')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError, OSError) as error:
        print(f'Link validation stopped: {error}', file=sys.stderr)
        raise SystemExit(1)
