"""Regressions for deployment URLs, citations, and HTTP verification failures."""
from email.message import Message
from contextlib import redirect_stderr, redirect_stdout
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError, URLError

import check_links as links


BASE = 'https://www.mit.edu/~6.7980/'


class LinkTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.folder = Path(self.directory.name)
        self.config = {'site': {}, 'how_to_cite': {'url_prefix': BASE},
                       'notes': [{'source': 'content/lecture.typ'}]}
        self.write('index.html', '<a href="lecture.html#result">Lecture</a>')
        self.lecture()

    def write(self, name, text):
        path = self.folder / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def lecture(self, url=BASE + 'lecture.html', extra=''):
        self.write('lecture.html', '<h1 id="result">Result</h1>' + extra +
                   '<details class="lecture-citation-details"><summary>How to cite</summary>'
                   '<pre><code>@misc{lecture,\n  url = {' + url + '}\n}</code></pre></details>')

    def audit(self, **kwargs):
        return links.audit_site(self.folder, self.config, **kwargs)

    def test_absolute_citation_is_validated_without_a_live_course_site(self):
        result = self.audit()
        self.assertEqual(result.issues, [])
        self.assertEqual(result.citation_count, 1)
        self.assertFalse(result.external)

    def test_typo_or_wrong_lecture_in_bibtex_url_is_rejected(self):
        for url in (BASE + 'missing.html', './lecture.html',
                    'https://wrong.example/lecture.html', BASE + 'index.html'):
            with self.subTest(url=url):
                self.lecture(url)
                self.assertTrue(any('How to cite URL' in issue for issue in self.audit().issues))

    def test_wrong_config_prefix_cannot_redefine_the_actual_deployment_url(self):
        self.config['how_to_cite']['url_prefix'] = 'https://wrong.example/'
        self.lecture('https://wrong.example/lecture.html')
        self.assertTrue(any('deployment requires' in issue for issue in self.audit(base_url=BASE).issues))

    def test_missing_or_duplicate_citation_blocks_are_rejected(self):
        for html in ('<p>No citation</p>', (self.folder / 'lecture.html').read_text() * 2):
            self.write('lecture.html', html)
            self.assertTrue(any('exactly one How to cite' in issue for issue in self.audit().issues))

    def test_missing_url_field_is_rejected(self):
        self.write('lecture.html', '<details class="lecture-citation-details"><pre>@misc{test}</pre></details>')
        self.assertTrue(any('exactly one BibTeX url' in issue for issue in self.audit().issues))

    def test_missing_absolute_local_file_and_anchor_are_rejected(self):
        for url, expected in ((BASE + 'missing.html', 'missing file'),
                              (BASE + 'lecture.html#missing', 'missing anchor')):
            with self.subTest(url=url):
                self.write('index.html', f'<a href="{url}">Test</a>')
                self.assertTrue(any(expected in issue for issue in self.audit().issues))

    def test_alias_paths_and_percent_encoded_anchors_use_the_payload(self):
        alias = 'https://web.mit.edu/6.7980/www/'
        self.write('index.html', f'<a href="{alias}extra%20page.html#a%20b">Test</a>')
        self.write('extra page.html', '<a name="a b">Named anchor</a>')
        result = self.audit(aliases=[alias])
        self.assertEqual(result.issues, [])
        self.assertFalse(result.external)

    def test_separate_fow_deployment_is_checked_online_but_typos_are_not_exempt(self):
        self.config['site']['separate_paths'] = ['fow/']
        self.write('index.html', f'<a href="{BASE}fow">FoW</a><a href="{BASE}fow/?tab=submit">Submit</a>')
        result = self.audit()
        self.assertEqual(result.issues, [])
        self.assertEqual(len(result.external), 2)
        self.write('index.html', f'<a href="{BASE}fow-typo">FoW</a>')
        self.assertTrue(any('missing file' in issue for issue in self.audit().issues))

    def test_css_srcset_and_svg_links_are_checked(self):
        self.write('index.html', '<link href="assets/main.css" rel="stylesheet">'
                   '<img srcset="assets/small.svg 1x, assets/large.svg 2x">')
        self.write('assets/main.css', '@font-face{src:url("font.woff2")}')
        self.write('assets/small.svg', '<svg><use href="large.svg#piece"/></svg>')
        self.write('assets/large.svg', '<svg><g id="piece"/></svg>')
        self.write('assets/font.woff2', 'test font')
        self.assertEqual(self.audit().issues, [])
        (self.folder / 'assets/font.woff2').unlink()
        self.assertTrue(any('font.woff2' in issue for issue in self.audit().issues))
        self.write('assets/font.woff2', 'test font')
        self.write('assets/large.svg', '<svg/>')
        self.assertTrue(any('missing anchor' in issue for issue in self.audit().issues))

    def test_skipping_fow_is_explicit_and_limited_to_the_separate_site(self):
        self.config['site']['separate_paths'] = ['fow/']
        result = links.Audit()
        urls = [BASE + 'fow', BASE + 'fow/?tab=submit', BASE + 'fow/game.html',
                BASE + 'fow-typo', 'https://other.example/fow/', 'https://doi.org/paper']
        for url in urls:
            result.external[url].add('index.html')
        skipped = links.skip_separate_sites(result, self.config, ['fow/'])
        self.assertEqual(set(skipped), set(urls[:3]))
        self.assertEqual(set(result.external), set(urls[3:]))
        with self.assertRaisesRegex(ValueError, 'not in site.separate_paths'):
            links.skip_separate_sites(result, self.config, ['anything/'])

    def test_contact_and_data_links_do_not_trigger_network_requests(self):
        self.write('index.html', '<a href="mailto:person@mit.edu">Email</a>'
                   '<a href="tel:6172531000">Telephone</a><img src="data:image/png;base64,AAA=">')
        result = self.audit()
        self.assertEqual(result.issues, [])
        self.assertFalse(result.external)

    def test_relative_escapes_and_base_elements_are_rejected(self):
        for html in ('<a href="../private.html">Oops</a>', '<base href="https://other.example/">'):
            with self.subTest(html=html):
                self.write('index.html', html)
                self.assertTrue(self.audit().issues)

    def test_external_query_strings_survive_and_duplicate_urls_are_grouped(self):
        self.write('index.html', '<a href="https://example.edu/paper?id=2&amp;version=3">Paper</a>' * 2)
        result = self.audit()
        self.assertEqual(list(result.external), ['https://example.edu/paper?id=2&version=3'])

    def test_doi_warnings_allow_deployment_but_other_failures_still_block(self):
        config_path = self.folder / 'config.json'
        config_path.write_text(json.dumps(self.config))
        for url, extra_args, expected in (
                ('https://doi.org/10.1234/paper', [], 1),
                ('https://doi.org/10.1234/paper', ['--doi-warnings'], 0),
                ('https://publisher.example/paper', ['--doi-warnings'], 1)):
            with self.subTest(url=url, extra_args=extra_args):
                self.write('index.html', f'<a href="{url}">Paper</a>')
                output, errors = io.StringIO(), io.StringIO()
                with patch.object(links, 'probe_url', return_value='unverified: HTTP 403'), \
                        redirect_stdout(output), redirect_stderr(errors):
                    status = links.main([str(self.folder), '--config', str(config_path),
                                         '--online', *extra_args])
                self.assertEqual(status, expected)
                if expected == 0:
                    self.assertIn('Non-blocking DOI warning:', errors.getvalue())
                    self.assertIn('0 external URLs responded successfully', output.getvalue())
        self.lecture(BASE + 'missing.html')
        with patch.object(links, 'probe_url') as probe, \
                redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            self.assertEqual(links.main([str(self.folder), '--config', str(config_path),
                                         '--online', '--doi-warnings']), 1)
        probe.assert_not_called()


class Response(io.BytesIO):
    def __init__(self, body=b'', content_type='text/html'):
        super().__init__(body)
        self.status = 200
        self.headers = Message()
        self.headers['Content-Type'] = content_type


class OnlineTests(unittest.TestCase):
    def error(self, status):
        return HTTPError('https://example.edu/', status, 'test response', Message(), io.BytesIO())

    def test_head_failure_falls_back_to_get(self):
        with patch.object(links, 'urlopen', side_effect=[self.error(405), Response()]) as open_url:
            self.assertIsNone(links.probe_url('https://example.edu/'))
        self.assertEqual([c.args[0].method for c in open_url.call_args_list], ['HEAD', 'GET'])

    def test_404_and_410_are_broken(self):
        for status in (404, 410):
            with self.subTest(status=status), patch.object(links, 'urlopen',
                    side_effect=[self.error(status), self.error(status)]):
                self.assertEqual(links.probe_url('https://example.edu/'), f'broken: HTTP {status}')

    def test_authentication_bot_blocks_rate_limits_and_timeouts_are_unverified(self):
        for status in (401, 403, 429, 503):
            with self.subTest(status=status), patch.object(links, 'urlopen',
                    side_effect=[self.error(status), self.error(status)]):
                self.assertEqual(links.probe_url('https://example.edu/'), f'unverified: HTTP {status}')
        with patch.object(links, 'urlopen', side_effect=URLError('timed out')):
            self.assertIn('unverified:', links.probe_url('https://example.edu/'))

    def test_external_html_anchors_are_checked(self):
        for fragment, expected in (('found', None), ('missing', 'broken: missing external anchor #missing')):
            with patch.object(links, 'urlopen', return_value=Response(b'<h2 id="found">Title</h2>')) as open_url:
                self.assertEqual(links.probe_url('https://example.edu/#' + fragment), expected)
            self.assertEqual(open_url.call_args.args[0].method, 'GET')

    def test_failures_include_every_referring_page_and_urls_are_checked_once(self):
        with patch.object(links, 'probe_url', return_value='unverified: HTTP 403') as probe:
            result = links.check_external({'https://example.edu/': {'index.html', 'lecture.html'}})
        probe.assert_called_once()
        self.assertEqual(result.issues, ['index.html, lecture.html: unverified: HTTP 403: https://example.edu/'])
        self.assertEqual(result.warnings, [])

    def test_doi_exception_is_limited_to_resolver_hosts_and_reports_all_failures(self):
        urls = {f'https://{host}/10.1234/paper': {'lecture.html'} for host in
                ('doi.org', 'dx.doi.org', 'doi.org.example', 'example.org', 'publisher.example')}
        for failure in ('unverified: HTTP 403', 'broken: HTTP 404', 'unverified: timed out'):
            with self.subTest(failure=failure), patch.object(links, 'probe_url', return_value=failure) as probe:
                result = links.check_external(urls, doi_warnings=True)
            self.assertEqual(probe.call_count, len(urls))
            self.assertEqual(len(result.warnings), 2)
            self.assertEqual(len(result.issues), 3)
            self.assertTrue(all(failure in item for item in result.warnings + result.issues))


if __name__ == '__main__':
    unittest.main()
