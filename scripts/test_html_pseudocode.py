"""Compile probes for Lovelace's algorithm figures and HTML line layout."""
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
LIBRARY = ROOT / 'content/meta/lovelace_html.typ'
HELPER = ROOT / 'content/meta/gabri_notes_html.typ'

ALGORITHM_FIGURES = '''
#pseudocode(numbered-title: [First], [Initialize.]) <first>
#figure(table(columns: 1, [Other content]), caption: [An unrelated table.])
#pseudocode-list(numbered-title: [Second], caption: [Second caption.])[
  + Continue.
] <second>
#pseudocode(numbered-title: [Third], caption: [Third caption.], [Continue.]) <third>
#pseudocode-list(numbered-title: [Fourth])[
  + Finish.
] <fourth>
See @first, @second, @third, and @fourth.
#context {
  let algorithms = query(figure.where(kind: "algorithm"))
  assert(algorithms.len() == 4)
  for (index, algorithm) in algorithms.enumerate() {
    assert(algorithm.counter.at(algorithm.location()) == (index + 1,))
    assert(str(algorithm.label) == ("first", "second", "third", "fourth").at(index))
    assert((algorithm.caption == none) == (index in (0, 3)))
  }
}
'''


class Element:
    def __init__(self, tag='', attrs=None):
        self.tag = tag
        self.attrs = attrs or {}
        self.children = []

    def has_class(self, name):
        return name in self.attrs.get('class', '').split()

    def elements(self):
        for child in self.children:
            if isinstance(child, Element):
                yield child
                yield from child.elements()

    def find(self, name):
        return [element for element in self.elements() if element.has_class(name)]

    def text(self):
        return ''.join(child.text() if isinstance(child, Element) else child
                       for child in self.children)


class PseudocodePage(HTMLParser):
    VOID_TAGS = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
                 'link', 'meta', 'param', 'source', 'track', 'wbr'}

    def __init__(self, html):
        super().__init__()
        self.root = Element()
        self.stack = [self.root]
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        element = Element(tag, dict(attributes))
        self.stack[-1].children.append(element)
        if tag not in self.VOID_TAGS:
            self.stack.append(element)

    def handle_endtag(self, tag):
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag == tag:
                del self.stack[index:]
                break

    def handle_data(self, text):
        self.stack[-1].children.append(text)


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required for HTML helper probes')
class HtmlPseudocodeTests(unittest.TestCase):
    def compile(self, body, *, helper=False):
        with tempfile.TemporaryDirectory(prefix='notes-pseudocode-test-') as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.html')
            library = HELPER if helper else LIBRARY
            source.write_text(f'#import {json.dumps(str(library))}: *\n' + body)
            result = subprocess.run(
                ['typst', 'compile', '--features', 'html', '--format', 'html',
                 '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('was ignored', result.stderr)
            self.assertNotIn('did not converge', result.stderr)
            return PseudocodePage(output.read_text()).root

    def row_data(self, page):
        rows = []
        for row in page.find('pseudo-line'):
            text = row.find('pseudo-text')
            self.assertEqual(len(text), 1)
            numbers = row.find('pseudo-number')
            self.assertLessEqual(len(numbers), 1)
            # The gutter must be a sibling of the body so indentation cannot
            # move numbers and wrapped continuation lines into the same column.
            self.assertEqual(text[0].find('pseudo-number'), [])
            if numbers:
                self.assertIn(numbers[0], row.children)
            self.assertIn(text[0], row.children)
            # Preserved whitespace spans create implicit grid rows and add
            # blank lines, even though all logical line numbers are correct.
            for child in row.children:
                if isinstance(child, Element):
                    self.assertTrue(any(child.has_class(name) for name in
                                        ('pseudo-text', 'pseudo-number', 'pseudo-guide')))
                else:
                    self.assertFalse(child.strip())
            indent = re.search(r'--indent\s*:\s*(\d+)', row.attrs.get('style', ''))
            self.assertIsNotNone(indent)
            rows.append((int(indent.group(1)),
                         numbers[0].text().strip() if numbers else '',
                         text[0].text().strip()))
        return rows

    def test_nested_list_keeps_one_number_column_and_skips_comments(self):
        page = self.compile('''
#pseudocode-list(numbered-title: [Nested list])[
  - Data description
  + First statement
    - Nested comment
    + Nested statement
      + Deep statement
    + Another nested statement
  + Last statement
]
''')
        rows = self.row_data(page)
        self.assertEqual([row[0] for row in rows], [0, 0, 1, 1, 2, 1, 0])
        self.assertEqual([row[1] for row in rows], ['', '1.', '', '2.', '3.', '4.', '5.'])
        self.assertEqual([row[2] for row in rows], [
            'Data description', 'First statement', 'Nested comment',
            'Nested statement', 'Deep statement', 'Another nested statement',
            'Last statement'])

    def test_direct_api_shares_list_numbering_and_indentation(self):
        page = self.compile('''
#pseudocode(
  title: [Direct API],
  [First],
  indent(no-number([Comment]), [Second], indent([Third])),
  [Fourth],
)
''')
        self.assertEqual(self.row_data(page), [
            (0, '1.', 'First'), (1, '', 'Comment'), (1, '2.', 'Second'),
            (2, '3.', 'Third'), (0, '4.', 'Fourth')])

    def test_custom_numbering_and_numbering_disabled(self):
        page = self.compile('''
#pseudocode(line-numbering: "i)", [One], indent([Two]), [Three])
#pseudocode-list(line-numbering: none)[
  + Unnumbered first
    + Unnumbered nested
]
''')
        blocks = page.find('pseudocode')
        self.assertEqual(len(blocks), 2)
        self.assertEqual([row[1] for row in self.row_data(blocks[0])], ['i)', 'ii)', 'iii)'])
        self.assertEqual(self.row_data(blocks[1]), [
            (0, '', 'Unnumbered first'), (1, '', 'Unnumbered nested')])

    def test_final_descendant_closes_each_enclosing_guide(self):
        page = self.compile('''
#pseudocode([Start], indent([Nested], indent([Deep], [Final])))
''')
        rows = page.find('pseudo-line')
        self.assertEqual(len(rows), 4)
        self.assertEqual([len(row.find('pseudo-guide')) for row in rows], [0, 1, 2, 2])
        self.assertEqual([len(row.find('pseudo-guide-end')) for row in rows], [0, 0, 0, 2])

    def test_course_helper_preserves_math_and_algorithm_reference(self):
        page = self.compile('''
#show: gabri_notes.with(lec_num: 99, title: [Pseudocode probe])
#pseudocode-list(booktabs: true, numbered-title: [Regret matching])[
  + *function* `NextStrategy()`
    + *if* $r != 0$
      + *return* $x <- display(r / norm(r)_1)$
] <algorithm-probe>
See @algorithm-probe.
''', helper=True)
        rows = self.row_data(page)
        self.assertEqual([row[0] for row in rows], [0, 1, 2])
        self.assertEqual([row[1] for row in rows], ['1.', '2.', '3.'])
        math = [element for element in page.elements()
                if element.attrs.get('role') == 'math']
        self.assertEqual(len(math), 2)
        links = [element for element in page.elements()
                 if element.tag == 'a' and 'Algorithm' in element.text()]
        self.assertEqual(len(links), 1)
        self.assertEqual(links[0].text().replace('\u00a0', ' '), 'Algorithm L99.1')
        self.assertEqual(page.find('algorithm')[0].find('env-title')[0].text().strip(),
                         'Algorithm L99.1: Regret matching')
        target = links[0].attrs.get('href', '').removeprefix('#')
        self.assertTrue(target)
        self.assertTrue(any(element.attrs.get('id') == target
                            for element in page.elements()))

    def test_both_apis_own_one_figure_with_captions_and_reference_targets(self):
        page = self.compile(
            '#show: gabri_notes.with(lec_num: 99, title: [Algorithm figures])\n'
            + ALGORITHM_FIGURES, helper=True)
        figures = [element for element in page.elements()
                   if element.tag == 'figure' and element.find('algorithm')]
        self.assertEqual(len(figures), 4)
        for figure in figures:
            self.assertEqual(len(figure.find('algorithm')), 1)
            self.assertFalse(any(element.tag == 'figure' for element in figure.elements()))
        self.assertEqual([figure.find('env-title')[0].text().strip() for figure in figures],
                         [f'Algorithm L99.{number}: {title}' for number, title in
                          enumerate(('First', 'Second', 'Third', 'Fourth'), 1)])
        self.assertEqual([figure.attrs['data-figure-number'] for figure in figures],
                         ['L99.1', 'L99.2', 'L99.3', 'L99.4'])
        captions = [element.text().strip() for figure in figures
                    for element in figure.elements() if element.tag == 'figcaption']
        self.assertEqual(captions, ['Algorithm L99.2. Second caption.', 'Algorithm L99.3. Third caption.'])
        references = [element for element in page.elements()
                      if element.tag == 'a' and element.text().startswith('Algorithm')]
        self.assertEqual([element.text().replace('\u00a0', ' ') for element in references],
                         ['Algorithm L99.1', 'Algorithm L99.2', 'Algorithm L99.3', 'Algorithm L99.4'])
        self.assertEqual([element.attrs['href'] for element in references],
                         ['#' + figure.attrs['id'] for figure in figures])


@unittest.skipUnless(shutil.which('typst') and shutil.which('pdftotext'),
                     'Typst CLI and Poppler are required for PDF algorithm probes')
class PagedPseudocodeTests(unittest.TestCase):
    def test_both_apis_preserve_numbered_titles_captions_and_references(self):
        for lecture in (None, 15, 'S8'):
            with self.subTest(lecture=lecture):
                self.check_algorithm_figures(lecture)

    def check_algorithm_figures(self, lecture):
        with tempfile.TemporaryDirectory(prefix='notes-algorithm-test-') as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.pdf')
            library = 'lovelace.typ' if lecture is None else 'gabri_notes.typ'
            style = '' if lecture is None else (
                f'#show: gabri_notes.with(lec_num: {json.dumps(lecture)}, title: [Algorithms])\n')
            prefix = '' if lecture is None else ('L15.' if lecture == 15 else 'S8.')
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta" / library))}: *\n'
                + style +
                '#set page(width: 450pt, height: auto, margin: 20pt)\n'
                + ALGORITHM_FIGURES)
            result = subprocess.run(
                ['typst', 'compile', '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('did not converge', result.stderr)
            text = ' '.join(subprocess.check_output(['pdftotext', str(output), '-'],
                                                   text=True).split())
            for number, title in enumerate(('First', 'Second', 'Third', 'Fourth'), 1):
                self.assertIn(f'Algorithm {prefix}{number}: {title}', text)
            self.assertIn(f'Algorithm {prefix}2: Second caption.', text)
            self.assertIn(f'Algorithm {prefix}3: Third caption.', text)
            self.assertIn(f'See Algorithm {prefix}1, Algorithm {prefix}2, '
                          f'Algorithm {prefix}3, and Algorithm {prefix}4.', text)


if __name__ == '__main__':
    unittest.main()
