"""Check that native HTML preserves multiline equation alignment columns."""
from html.parser import HTMLParser
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class EquationPage(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.equations = []
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        classes = attrs.get('class', '').split()
        if tag == 'figure' and 'equation' in classes:
            self.equations.append({'attrs': attrs, 'rows': []})
        elif tag == 'div' and 'equation-line' in classes:
            self.equations[-1]['rows'].append([])
        elif tag == 'span' and any(c in classes for c in
                                  ('equation-align-cell', 'equation-align-full', 'eqno')):
            self.equations[-1]['rows'][-1].append(attrs)


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required')
class HtmlEquationTests(unittest.TestCase):
    def compile(self, body):
        with tempfile.TemporaryDirectory(prefix='notes-equation-test-') as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.html')
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta/gabri_notes_html.typ"))}: *\n'
                '#show: gabri_notes.with(lec_num: 1, title: [Equation probe])\n' + body)
            result = subprocess.run(
                ['typst', 'compile', '--features', 'html', '--format', 'html',
                 '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('was ignored', result.stderr)
            return EquationPage(output.read_text()).equations

    def test_step_justifications_have_a_shared_right_aligned_column(self):
        equation, = self.compile(r'''
$
  & a+b \
  & = c+d & quad ("linearity of" u) \
  & <= e & quad ("from" (1))
$
''')
        self.assertIn('--equation-alignment-columns: 3;', equation['attrs']['style'])
        self.assertEqual([len(row) for row in equation['rows']], [3, 3, 3])
        for row in equation['rows']:
            self.assertEqual([cell['data-align-column'] for cell in row], ['0', '1', '2'])
            self.assertIn('grid-column: 4; justify-self: end;', row[2]['style'])
            self.assertNotIn('linearity', row[1]['data-typst-math'])
        self.assertEqual(equation['rows'][0][2]['data-typst-math'], '[]')
        self.assertIn('linearity of', equation['rows'][1][2]['data-typst-math'])
        self.assertIn('from', equation['rows'][2][2]['data-typst-math'])

    def test_multiple_alignment_pairs_keep_full_rows_and_equation_numbers(self):
        equation, = self.compile(r'''
#set math.equation(numbering: "(1)")
$
  a &= b & c &= d \
  x &= y \
  "a full width row"
$ <eq-probe>
''')
        self.assertIn('--equation-alignment-columns: 4;', equation['attrs']['style'])
        self.assertIn('--equation-number-column: 7;', equation['attrs']['style'])
        for row in equation['rows'][:2]:
            cells = row[:-1]
            self.assertEqual(len(cells), 4)
            self.assertEqual([cell['style'].split('justify-self: ')[1] for cell in cells],
                             ['end;', 'start;', 'end;', 'start;'])
            self.assertEqual(row[-1]['class'], 'eqno')
        self.assertIn('equation-align-full', equation['rows'][2][0]['class'])
        self.assertEqual(equation['rows'][2][1]['class'], 'eqno')


if __name__ == '__main__':
    unittest.main()
