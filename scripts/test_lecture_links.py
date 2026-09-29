"""Native cross-note references, isolated previews, and lecture-scoped citations."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from lecture_links import validate_lecture_links
from test_html_pseudocode import PseudocodePage
from test_html_references import ReferencePage

ROOT = Path(__file__).resolve().parents[1]


class LectureLinkValidationTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory()
        self.addCleanup(folder.cleanup)
        self.root = Path(folder.name)
        self.source = self.root / 'one.typ'
        self.target = self.root / 'two.typ'
        self.source.write_text('#lecture-link("two", <stable-result>)[The result]')
        self.target.write_text('= The result <stable-result>\n')
        self.config = {'notes': [{'source': 'one.typ'}, {'source': 'two.typ'}]}

    def test_current_course_links_are_valid(self):
        config = json.loads((ROOT / 'html-export.json').read_text())
        self.assertGreater(validate_lecture_links(ROOT, config), 0)

    def test_renaming_heading_text_preserves_links(self):
        self.target.write_text('= Renamed result <stable-result>\n')
        self.assertEqual(validate_lecture_links(self.root, self.config), 1)

    def test_missing_or_ambiguous_heading_is_rejected(self):
        for text in ('= Result <renamed-label>',
                     '= Result <stable-result>\n== Another <stable-result>',
                     'Unattached label <stable-result>'):
            with self.subTest(text=text):
                self.target.write_text(text)
                with self.assertRaisesRegex(ValueError, 'expected one labeled section or environment'):
                    validate_lecture_links(self.root, self.config)

    def test_whole_lecture_needs_no_heading(self):
        self.target.write_text('No numbered headings.')
        for call in ('#lecture-link("two")', '#lecture-link("two")[]',
                     '#lecture-link("two")[the notes]', '#lecture-link("two", none)',
                     '#lecture-link("two", none)[]'):
            with self.subTest(call=call):
                self.source.write_text(call)
                self.assertEqual(validate_lecture_links(self.root, self.config), 1)

    def test_label_without_body_still_checks_destination(self):
        self.source.write_text('#lecture-link("two", <missing-result>)')
        with self.assertRaisesRegex(ValueError, 'expected one labeled section or environment'):
            validate_lecture_links(self.root, self.config)

    def test_unpublished_note_is_rejected(self):
        self.config['notes'].pop()
        for call in ('#lecture-link("two", <stable-result>)[The result]',
                     '#lecture-link("two")'):
            with self.subTest(call=call):
                self.source.write_text(call)
                with self.assertRaisesRegex(ValueError, 'unknown linked lecture'):
                    validate_lecture_links(self.root, self.config)

    def test_dynamic_or_local_destinations_are_rejected(self):
        for call in ('#lecture-link(name, <stable-result>)[Result]',
                     '#lecture-link("../two", <stable-result>)[Result]',
                     '#lecture-link("one", <stable-result>)[Result]',
                     '#lecture-link(name)', '#lecture-link("../two")',
                     '#lecture-link("one")', '#lecture-link("two", destination)'):
            with self.subTest(call=call):
                self.source.write_text(call)
                with self.assertRaises(ValueError):
                    validate_lecture_links(self.root, self.config)


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required')
class LectureLinkRenderingTests(unittest.TestCase):
    def setUp(self):
        folder = tempfile.TemporaryDirectory(prefix='lecture-link-test-')
        self.addCleanup(folder.cleanup)
        self.folder = Path(folder.name)

    def compile(self, body, *, html=True, bundle=False, inputs=(), expect_error=None):
        helper = ROOT / 'content/meta' / ('gabri_notes_html.typ' if html else 'gabri_notes.typ')
        source = self.folder / 'probe.typ'
        source.write_text(f'#import {json.dumps(str(helper))}: *\n' + body)
        output = self.folder / 'bundle' if bundle else source.with_suffix('.html' if html else '.pdf')
        args = ['typst', 'compile', '--root', ROOT.anchor,
                '--font-path', str(ROOT / 'html-exporter/assets/fonts')]
        if bundle:
            args += ['--features', 'html,bundle', '--format', 'bundle', '--input', 'course-bundle=true']
        elif html:
            args += ['--features', 'html', '--format', 'html']
        for value in inputs:
            args += ['--input', value]
        result = subprocess.run([*args, str(source), str(output)], capture_output=True, text=True)
        if expect_error:
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(expect_error, result.stderr)
        else:
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('did not converge', result.stderr)
        return output

    def fixture(self, number, *, html=True, inserted=False):
        source = 'source.html' if html else 'pdf/source.pdf'
        destination = 'destination.html' if html else 'pdf/destination.pdf'
        insertion = '= Earlier section\n#example[Earlier example.]' if inserted else ''
        return f'''
#document("{source}", title: lecture-title(5, [Source]))[
  #show: gabri_notes.with(lec_num: 5, title: [Source])
  #example[An unrelated example.]
  #theorem[An earlier result.] <source-result>
  #lecture-link("destination", <target-theorem>)[the _result_]
  #lecture-link("destination", <target-section>)[]
  #lecture-link("destination", <target-appendix>)[]
  #lecture-link("destination", none)[]
  #lecture-link("destination")
  #lecture-link("destination")[the _notes_]
]
#document("{destination}", title: lecture-title({json.dumps(number)}, [Destination]))[
  #show: gabri_notes.with(lec_num: {json.dumps(number)}, title: [Destination])
  {insertion}
  = Destination <target-section>
  #theorem[The target result.] <target-theorem>
  #lecture-link("source", <source-result>)[the earlier result]
  #appendix[
    = Details <target-appendix>
    Details of the proof.
  ]
]
'''

    def test_native_bundle_references_follow_actual_counters_in_both_directions(self):
        for number, prefix in ((19, 'L19'), ('S8', 'S8')):
            for inserted in (False, True):
                with self.subTest(number=number, inserted=inserted):
                    output = self.compile(self.fixture(number, inserted=inserted), bundle=True)
                    page = ReferencePage((output / 'source.html').read_text())
                    target = ReferencePage((output / 'destination.html').read_text())
                    n = 2 if inserted else 1
                    kind = 'Supplementary Reading' if prefix.startswith('S') else 'Lecture'
                    self.assertEqual([''.join(ref['text']) for ref in page.references], [
                        f'the result (Theorem\u00a0{prefix}.{n})',
                        f'Section\u00a0{prefix}.{n}', f'Section\u00a0{prefix}.A',
                        f'{kind}\u00a0{number}, “Destination”',
                        f'{kind}\u00a0{number}, “Destination”',
                        f'the notes ({kind}\u00a0{number}, “Destination”)',
                    ])
                    self.assertIn('em', page.references[0]['tags'])
                    self.assertEqual([ref['href'] for ref in page.references], [
                        'destination.html#target-theorem', 'destination.html#target-section',
                        'destination.html#target-appendix', 'destination.html',
                        'destination.html', 'destination.html',
                    ])
                    for ref in page.references[:3]:
                        self.assertIn(ref['href'].split('#')[1], target.ids)
                    self.assertEqual(''.join(target.references[0]['text']),
                                     'the earlier result (Theorem\u00a0L5.2)')
                    self.assertIn(target.references[0]['href'].split('#')[1], page.ids)

    def test_native_typst_rejects_an_invalid_reference_target(self):
        body = self.fixture(19).replace('#theorem[The target result.]', '#text[Unnumbered text.]')
        self.compile(body, bundle=True, expect_error='cannot reference text')

    @unittest.skipUnless(shutil.which('pdftotext'), 'Poppler is required for PDF figure references')
    def test_figure_numbers_reset_per_kind_and_note_and_references_use_destination_prefix(self):
        for html in (True, False):
            for number, prefix in ((15, 'L15'), ('S8', 'S8')):
                with self.subTest(html=html, number=number):
                    source = 'source.html' if html else 'pdf/source.pdf'
                    destination = 'destination.html' if html else 'pdf/destination.pdf'
                    output = self.compile(f'''
#document("{source}")[
  #show: gabri_notes.with(lec_num: 5, title: [Source])
  #theorem[An unrelated statement.]
  #figure(rect(width: 10pt, height: 10pt), caption: [First figure.]) <first-figure>
  #pseudocode(numbered-title: [First], [Start.]) <first-algorithm>
  #figure(table([A]), caption: [First table.]) <first-table>
  #figure(rect(width: 10pt, height: 10pt), caption: [Second figure.]) <second-figure>
  #pseudocode-list(numbered-title: [Second], caption: [Source caption.])[
    + Continue.
  ] <second-algorithm>
  #figure(table([B]), caption: [Second table.]) <second-table>
  See #lecture-link("destination", <target-algorithm>)[] and @second-algorithm.
  See #lecture-link("destination", <target-figure>)[] and @second-figure.
  See #lecture-link("destination", <target-table>)[] and @second-table.
]
#document("{destination}")[
  #show: gabri_notes.with(lec_num: {json.dumps(number)}, title: [Destination])
  #figure(rect(width: 10pt, height: 10pt), caption: [Target figure.]) <target-figure>
  #pseudocode-list(numbered-title: [Target], caption: [Target caption.])[
    + Finish.
  ] <target-algorithm>
  #figure(table([C]), caption: [Target table.]) <target-table>
  See #lecture-link("source", <second-algorithm>)[] and @target-algorithm.
  See #lecture-link("source", <second-figure>)[] and @target-figure.
  See #lecture-link("source", <second-table>)[] and @target-table.
]
''', html=html, bundle=True)
                    if html:
                        texts = [PseudocodePage((output / name).read_text()).root.text()
                                 for name in (source, destination)]
                    else:
                        texts = [subprocess.check_output(
                            ['pdftotext', str(output / name), '-'], text=True)
                            for name in (source, destination)]
                    first, second = [' '.join(text.split()) for text in texts]
                    self.assertIn('Algorithm L5.1: First', first)
                    self.assertIn('Algorithm L5.2: Second', first)
                    self.assertIn(f'Algorithm {prefix}.1: Target', second)
                    self.assertIn(f'See Algorithm {prefix}.1 and Algorithm L5.2.', first)
                    self.assertIn(f'See Algorithm L5.2 and Algorithm {prefix}.1.', second)
                    separator = '.' if html else ':'
                    for kind in ('Figure', 'Table'):
                        self.assertIn(f'{kind} L5.1{separator} First {kind.lower()}.', first)
                        self.assertIn(f'{kind} L5.2{separator} Second {kind.lower()}.', first)
                        self.assertIn(f'{kind} {prefix}.1{separator} Target {kind.lower()}.', second)
                        self.assertIn(f'See {kind} {prefix}.1 and {kind} L5.2.', first)
                        self.assertIn(f'See {kind} L5.2 and {kind} {prefix}.1.', second)

    def test_standalone_preview_uses_the_destination_notes_own_header(self):
        output = self.compile('''
#show: gabri_notes.with(lec_num: 5, title: [Source])
See #lecture-link("learning_intro", <sec-learning-zero-sum>)[the _self-play_ proof].
See #lecture-link("efg_intro").
''')
        page = ReferencePage(output.read_text())
        self.assertEqual(page.references[0]['href'], 'learning_intro.html#sec-learning-zero-sum')
        self.assertEqual(''.join(page.references[0]['text']),
                         'the self-play proof (Lecture\u00a04, “Learning in games: Foundations”)')
        self.assertIn('em', page.references[0]['tags'])
        self.assertEqual(page.references[1]['href'], 'efg_intro.html')
        self.assertEqual(''.join(page.references[1]['text']),
                         'Lecture\u00a07, “Modeling extensive-form games”')

    def test_direct_headers_support_reordered_arguments_and_literal_title_forms(self):
        helper = ROOT / 'content/meta/lecture-links.typ'
        cases = (
            ('#show: gabri_notes.with(lec_num: 6, title: "Bandits")', 6, '"Bandits"'),
            ('#show: gabri_notes.with(\n  title: [Supplement (part 2)],\n'
             '  instructor: [An instructor],\n  lec_num: "S8",\n)',
             'S8', '[Supplement (part 2)]'),
            ('#show: gabri_notes.with(\n  lec_num: 19,\n'
             '  title: "Games (and \\"learning\\")",\n)',
             19, '"Games (and \\"learning\\")"'),
        )
        for source, number, title in cases:
            with self.subTest(source=source):
                self.compile(f'''
#import {json.dumps(str(helper))}: lecture-header
#let header = lecture-header({json.dumps(source)})
#assert.eq(header.lec_num, {json.dumps(number)})
#assert.eq(header.title, {title})
''')

    def test_standalone_header_reader_reports_missing_or_dynamic_metadata(self):
        helper = ROOT / 'content/meta/lecture-links.typ'
        for source, error in (
            ('#let lecture = (lec_num: 6, title: "Bandits")', 'Expected a direct'),
            ('#show: gabri_notes.with(title: "Bandits")', 'Expected literal lec_num and title'),
            ('#show: gabri_notes.with(lec_num: 6, title: topic)', 'Expected literal lec_num and title'),
        ):
            with self.subTest(source=source):
                self.compile(f'''
#import {json.dumps(str(helper))}: lecture-header
#let header = lecture-header({json.dumps(source)})
''', expect_error=error)

    @unittest.skipUnless(shutil.which('pdfinfo'), 'Poppler is required for PDF links')
    def test_native_pdf_links_have_relative_urls_and_matching_named_destinations(self):
        output = self.compile(self.fixture('S8', html=False, inserted=True), html=False, bundle=True)
        source = output / 'pdf/source.pdf'
        target = output / 'pdf/destination.pdf'
        urls = subprocess.check_output(['pdfinfo', '-url', str(source)], text=True)
        for anchor in ('target-theorem', 'target-section', 'target-appendix'):
            self.assertIn('destination.pdf#' + anchor, urls)
        dests = subprocess.check_output(['pdfinfo', '-dests', str(target)], text=True)
        for anchor in ('target-theorem', 'target-section', 'target-appendix'):
            self.assertIn('"' + anchor + '"', dests)
        text = subprocess.check_output(['pdftotext', str(source), '-'], text=True)
        self.assertIn('Theorem S8.2', text)
        self.assertIn('Section S8.A', text)
        self.assertIn('the notes (Supplementary Reading S8, “Destination”)', ' '.join(text.split()))

    @unittest.skipUnless(shutil.which('pdfinfo'), 'Poppler is required for PDF links')
    def test_standalone_pdf_uses_canonical_web_links_and_honors_override(self):
        configured = json.loads((ROOT / 'html-export.json').read_text())['how_to_cite']['url_prefix']
        for base, inputs in ((configured, ()),
                             ('https://example.org/course/', ('course-url=https://example.org/course/',))):
            with self.subTest(base=base):
                output = self.compile('''
#show: gabri_notes.with(lec_num: 5, title: [PDF source])
See #lecture-link("learning_intro", <sec-learning-zero-sum>)[the self-play proof].
See #lecture-link("efg_intro").
''', html=False, inputs=inputs)
                urls = subprocess.check_output(['pdfinfo', '-url', str(output)], text=True)
                self.assertIn(base + 'learning_intro.html#sec-learning-zero-sum', urls)
                self.assertIn(base + 'efg_intro.html', urls)

    def test_native_html_bibliographies_and_first_citation_notes_stay_with_their_lecture(self):
        output = self.compile('''
#document("one.html")[
  #show: gabri_notes.with(lec_num: 1, title: [One])
  #citep(<Nash51:NonCooperative>)
  #lec_bibliography("refs.bib")
]
#document("two.html")[
  #show: gabri_notes.with(lec_num: 2, title: [Two])
  #citep(<Nash51:NonCooperative>) and #citep(<auer2002nonstochastic>)
  #lec_bibliography("refs.bib")
]
''', bundle=True)
        first = (output / 'one.html').read_text()
        second = (output / 'two.html').read_text()
        self.assertIn('id="bib-Nash51-NonCooperative"', first)
        self.assertNotIn('id="bib-auer2002nonstochastic"', first)
        self.assertIn('id="bib-Nash51-NonCooperative"', second)
        self.assertIn('id="bib-auer2002nonstochastic"', second)
        self.assertEqual(first.count('class="citation-note"'), 1)
        self.assertEqual(second.count('class="citation-note"'), 2)
        entry = re.search(r'class="bib-entry">(.*?)</td>', first, re.S)[1]
        self.assertNotIn('[Nas51]', entry)
        self.assertIn('Non-Cooperative Games', entry)
        self.assertIn('href="http://www.jstor.org/stable/1969529"', entry)

    @unittest.skipUnless(shutil.which('pdftotext'), 'Poppler is required for PDF bibliographies')
    def test_native_pdf_bibliographies_include_only_their_own_citations(self):
        shutil.copy2(ROOT / 'content/meta/refs.bib', self.folder / 'refs.bib')
        output = self.compile('''
#document("one.pdf")[
  #show: gabri_notes.with(lec_num: 1, title: [One])
  #citep(<Nash51:NonCooperative>)
  #lec_bibliography("refs.bib")
]
#document("two.pdf")[
  #show: gabri_notes.with(lec_num: 2, title: [Two])
  #citep(<auer2002nonstochastic>)
  #lec_bibliography("refs.bib")
]
''', html=False, bundle=True)
        first, second = [' '.join(subprocess.check_output(
            ['pdftotext', str(output / name), '-'], text=True).split())
            for name in ('one.pdf', 'two.pdf')]
        self.assertIn('Non-Cooperative Games', first)
        self.assertNotIn('nonstochastic', first.lower())
        self.assertIn('nonstochastic', second.lower())
        self.assertNotIn('Non-Cooperative Games', second)


if __name__ == '__main__':
    unittest.main()
