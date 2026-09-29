"""Check Typst's compiled math tree for subscript/function grouping errors."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
INDEXED_FUNCTIONS = {'K', 'λ', 'φ', 'ϕ', 'F', 'u', 's', 'μ', 'softmax'}


def nodes(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from nodes(child)
    elif isinstance(value, list):
        for child in value:
            yield from nodes(child)


def misplaced_arguments(bodies):
    return [node for node in nodes(bodies)
            if node.get('func') == 'attach'
            and isinstance(node.get('base', {}).get('text'), str)
            and node.get('base', {}).get('text') in INDEXED_FUNCTIONS
            and any(child.get('text') == '(' for child in nodes(node.get('b')))]


def misplaced_expectation_operands(bodies):
    mistakes = []
    for node in nodes(bodies):
        if node.get('func') != 'attach':
            continue
        is_expectation = any(child.get('text') == '𝔼'
                             for child in nodes(node.get('base')))
        subscript = node.get('b', {}).get('children', [])
        # E_t[...] is parsed as the index t followed by a bracketed expression
        # inside the subscript. Domains such as E_((i, phi) ~ nu) are valid.
        if is_expectation and len(subscript) == 2 and subscript[1].get('func') == 'lr':
            mistakes.append(node)
    return mistakes


@unittest.skipUnless(shutil.which('typst'), 'Typst is needed to inspect compiled math')
class LectureMathRenderingTests(unittest.TestCase):
    def compile_math(self, formulas):
        # Compile the authored equations with the PDF's actual notation helpers.
        # The temporary document avoids touching the site's prepared sources.
        with tempfile.TemporaryDirectory(prefix='.lecture-math-', dir=ROOT) as tmp:
            source = Path(tmp) / 'math.typ'
            source.write_text('#import "/content/meta/gabri_notes.typ": *\n'
                              + '\n\n'.join(formulas))
            result = subprocess.run([
                'typst', 'eval', '--root', str(ROOT), '--in', str(source),
                'query(math.equation).map(it => it.body)',
            ], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            return json.loads(result.stdout)

    def test_kernelized_formulas_keep_arguments_outside_function_subscripts(self):
        source = (ROOT / 'content/kernelized.typ').read_text()
        formulas = re.findall(r'(?<!\\)\$.*?(?<!\\)\$', source, flags=re.S)
        bodies = self.compile_math(formulas)
        self.assertEqual(len(bodies), len(formulas))
        self.assertFalse(misplaced_arguments(bodies))
        symbols = {node.get('base', {}).get('text') for node in nodes(bodies)
                   if node.get('func') == 'attach'}
        self.assertTrue({'K', 'λ', 'F'} <= symbols)
        self.assertTrue({'φ', 'ϕ'} & symbols)

    def test_all_published_notes_keep_arguments_outside_function_subscripts(self):
        config = json.loads((ROOT / 'html-export.json').read_text())
        for note in config['notes']:
            with self.subTest(source=note['source']):
                result = subprocess.run([
                    'typst', 'eval', '--root', str(ROOT), '--in',
                    str(ROOT / note['source']),
                    'query(math.equation).map(it => it.body)',
                ], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                bodies = json.loads(result.stdout)
                self.assertFalse(misplaced_arguments(bodies))
                self.assertFalse(misplaced_expectation_operands(bodies))

    def test_expectation_operands_are_not_swallowed_into_the_index(self):
        self.assertTrue(misplaced_expectation_operands(self.compile_math([
            '$EE_t[sum_b p_b ell_b^2]$'])))
        self.assertFalse(misplaced_expectation_operands(self.compile_math([
            '$EE_(t)[sum_b p_b ell_b^2]$', '$EE_((i, phi) ~ nu) [u_i]$'])))

    def test_check_detects_the_actual_typst_parenthesis_trap(self):
        bad = self.compile_math([
            '$K_V(z,w)$', '$lambda_t(v)$', '$phi_V(z)_v$', '$F_j(r)$',
            '$u_i(a)$', '$s_i(x-y)$', '$mu_i(a_i)$', '$"softmax"_a(eta r)$'])
        symbols = {node['base']['text'] for node in misplaced_arguments(bad)}
        self.assertTrue({'K', 'λ', 'F', 'u', 's', 'μ', 'softmax'} <= symbols)
        self.assertTrue({'φ', 'ϕ'} & symbols)
        good = self.compile_math([
            '$K_(V)(z,w)$', '$lambda_(t)(v)$', '$phi_(V)(z)_v$', '$F_(j)(r)$',
            '$u_(i)(a)$', '$s_(i)(x-y)$', '$mu_(i)(a_i)$', '$"softmax"_(a)(eta r)$'])
        self.assertFalse(misplaced_arguments(good))


if __name__ == '__main__':
    unittest.main()
