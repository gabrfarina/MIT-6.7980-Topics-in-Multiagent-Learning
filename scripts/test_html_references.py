"""Compile probes for reference labels and links in lecture headings."""
from html.parser import HTMLParser
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / 'content/meta/gabri_notes_html.typ'


class ReferencePage(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.ids = set()
        self.references = []
        self.current_reference = None
        self.headings = []
        self.labeled_elements = {}
        self.current_heading = None
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if 'data-label' in attrs:
            self.labeled_elements[attrs['data-label']] = (tag, attrs)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if self.current_reference is not None:
            self.current_reference['tags'].append(tag)
        if tag == 'a':
            self.current_reference = {'href': attrs.get('href'), 'text': [], 'tags': []}
            self.references.append(self.current_reference)
        if tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            self.current_heading = []
            self.headings.append(self.current_heading)

    def handle_data(self, text):
        if self.current_reference is not None:
            self.current_reference['text'].append(text)
        if self.current_heading is not None:
            self.current_heading.append(text)

    def handle_endtag(self, tag):
        if tag == 'a':
            self.current_reference = None
        if tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            self.current_heading = None


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required for HTML helper probes')
class HtmlReferenceTests(unittest.TestCase):
    def compile(self, body):
        with tempfile.TemporaryDirectory(prefix='notes-reference-test-') as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.html')
            source.write_text(f'#import {json.dumps(str(HELPER))}: *\n' + body)
            result = subprocess.run(
                ['typst', 'compile', '--features', 'html', '--format', 'html',
                 '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('was ignored', result.stderr)
            self.assertNotIn('did not converge', result.stderr)
            return ReferencePage(output.read_text())

    def assert_local_targets_exist(self, page):
        for reference in page.references:
            self.assertTrue(reference['href'].startswith('#'), reference)
            self.assertIn(reference['href'][1:], page.ids)

    def test_statement_and_section_supplements_have_only_their_needed_separator(self):
        page = self.compile('''
#show: gabri_notes.with(lec_num: 5, title: [Reference probe])
= Target section <target-section>
#theorem[A statement.] <target-theorem>

#ref(<target-theorem>)
#ref(<target-theorem>, supplement: [Result])
#ref(<target-theorem>, supplement: none)
#ref(<target-theorem>, supplement: [])
#ref(<target-theorem>, supplement: "")

#ref(<target-section>)
#ref(<target-section>, supplement: [Part])
#ref(<target-section>, supplement: none)
#ref(<target-section>, supplement: [])
#ref(<target-section>, supplement: "")
''')
        expected = [
            'Theorem\u00a0L5.1', 'Result\u00a0L5.1', 'L5.1', 'L5.1', 'L5.1',
            'Section\u00a0L5.1', 'Part\u00a0L5.1', 'L5.1', 'L5.1', 'L5.1',
        ]
        self.assertEqual(len(page.references), len(expected))
        for reference, label in zip(page.references, expected):
            with self.subTest(label=label, href=reference['href']):
                self.assertEqual(''.join(reference['text']), label)
        self.assert_local_targets_exist(page)

    def test_cross_lecture_numbers_and_formatted_supplements_are_preserved(self):
        page = self.compile('''
#gabri_notes(lec_num: 4, title: [Referenced lecture])[
= Target section <target-section>
#theorem[A statement.] <target-theorem>
]
#gabri_notes(lec_num: 5, title: [Referring lecture])[
#ref(<target-theorem>)
#ref(<target-theorem>, supplement: none)
#ref(<target-theorem>, supplement: [#emph[Result]])

#ref(<target-section>)
#ref(<target-section>, supplement: none)
#ref(<target-section>, supplement: [#emph[Part]])
]
''')
        self.assertEqual([''.join(ref['text']) for ref in page.references], [
            'Theorem\u00a0L4.1',
            'L4.1',
            'Result\u00a0L4.1',
            'Section\u00a0L4.1',
            'L4.1',
            'Part\u00a0L4.1',
        ])
        for index in (2, 5):
            self.assertIn('em', page.references[index]['tags'])
        self.assert_local_targets_exist(page)

    def test_appendix_heading_has_one_space_before_its_linked_theorem_number(self):
        page = self.compile('''
#show: gabri_notes.with(lec_num: 5, title: [Appendix reference probe])
#theorem[A statement.] <target-theorem>

#appendix[
= Appendix: Proof of Theorem~#ref(<target-theorem>, supplement: none)
The proof.
]
''')
        self.assertEqual(len(page.references), 1)
        self.assertEqual(''.join(page.references[0]['text']), 'L5.1')
        self.assertEqual([''.join(parts) for parts in page.headings],
                         ['L5.A Appendix: Proof of Theorem\u00a0L5.1'])
        self.assert_local_targets_exist(page)

    def test_unreferenced_labels_are_exported_for_permalinks(self):
        page = self.compile('''
#show: gabri_notes.with(lec_num: 8, title: [Permalink probe])
= Section <sec:overview>
#heading(numbering: none)[Further reading] <sec:reading>
#theorem[A statement.] <thm:result>
#proof[A proof.] <proof:result>
#proofsketch[A sketch.] <proof:sketch>
#solution[A solution.] <solution:exercise>
#figure(table(columns: 2, [A], [B]), caption: [Notation.]) <tab:notation>
#pseudocode(numbered-title: [CFR], [Continue.]) <algo:cfr>
$ a &= b #label("eq:first") \\
  c &= d #label("eq:second") $
$ x = y $ <eq:whole>
''')
        for label in ('sec:overview', 'sec:reading', 'thm:result',
                      'proof:result', 'proof:sketch', 'solution:exercise',
                      'tab:notation', 'algo:cfr', 'eq:first', 'eq:second', 'eq:whole'):
            self.assertIn(label, page.labeled_elements)
        for label, kind in (('tab:notation', 'table'), ('algo:cfr', 'algorithm')):
            tag, attrs = page.labeled_elements[label]
            self.assertEqual(tag, 'figure')
            self.assertEqual(attrs['data-figure-kind'], kind)
            self.assertEqual(attrs['data-figure-number'], 'L8.1')

    def test_labeled_proofs_keep_native_links_and_nested_targets(self):
        page = self.compile('''
#show: gabri_notes.with(lec_num: 5, title: [Proof links])
#proof[
  An outer proof.
  #claim[A claim.] <claim:inner>
  #proof[A nested proof.] <proof:inner>
] <proof:outer>
#link(<proof:outer>)[Outer proof]
#link(<proof:inner>)[Inner proof]
''')
        self.assert_local_targets_exist(page)
        for label in ('proof:outer', 'proof:inner'):
            tag, attrs = page.labeled_elements[label]
            self.assertEqual(tag, 'section')
            self.assertEqual(attrs['data-proof-kind'], 'Proof')


if __name__ == '__main__':
    unittest.main()
