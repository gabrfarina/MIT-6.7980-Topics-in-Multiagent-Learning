"""Source conventions that compile cleanly but read wrong in the notes."""
import unittest

from check_note_source import check_paths, check_text


def rules(text):
    return [(finding.line, finding.rule) for finding in check_text(text)]


class HardcodedNumberTests(unittest.TestCase):
    def test_flags_environment_numbers_in_prose(self):
        self.assertEqual(rules('Consider the game in Example L16.12.\n'),
                         [(1, 'hardcoded-number')])
        self.assertEqual(rules('See L3.4 and the remark.'), [(1, 'hardcoded-number')])

    def test_ignores_labels_math_raw_and_comments(self):
        self.assertEqual(rules('Consider @ex:branch-continuation.\n'
                               '$L1.5$ and `L2.3` and ```\nL4.1\n```\n'
                               '// L5.6 stays in a comment\n'), [])


class MathShorthandTests(unittest.TestCase):
    def test_flags_named_forms_with_shorthand(self):
        self.assertEqual(
            [f.message for f in check_text('$x eq.not y$ and $a lt.eq b arrow.r.double c$')],
            ['use `!=` instead of `eq.not`', 'use `<=` instead of `lt.eq`',
             'use `=>` instead of `arrow.r.double`'])

    def test_keeps_forms_without_exact_shorthand(self):
        self.assertEqual(rules('$x_1, ..., x_k$, $a dots.c b$, $norm(dot.c)$, $tilde(x)$, $arrow.r.long.bar$'), [])

    def test_flags_named_ellipsis(self):
        self.assertEqual(
            [f.message for f in check_text('$x_1, dots, x_k$ and $y_1, dots.h, y_n$')],
            ['use `...` instead of `dots`', 'use `...` instead of `dots.h`'])

    def test_ignores_prose_strings_and_escaped_dollars(self):
        self.assertEqual(rules('In prose, arrow.r is just text; \\$3 prizes; $x_"lt.eq"$.\n'), [])

    def test_allow_comment_silences_a_line(self):
        self.assertEqual(rules('$x lt.eq y$ // source-check: allow\n'), [])

    def test_reports_line_and_column(self):
        finding, = check_text('first\n  $a, lt.eq$\n')
        self.assertEqual((finding.line, finding.column), (2, 7))


class RepositoryTests(unittest.TestCase):
    def test_course_sources_follow_conventions(self):
        findings = check_paths()
        self.assertEqual(findings, [], '\n' + '\n'.join(map(str, findings)))


if __name__ == '__main__':
    unittest.main()
