"""Copy-as-Markdown and agentic line-id contract for lecture HTML."""
from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]


class HtmlCopyMarkdownTests(unittest.TestCase):
    def test_copy_contract_rejects_native_katex_and_keeps_mid_line_ids(self):
        result = subprocess.run(
            ['node', str(ROOT / 'scripts/test_copy_markdown.cjs')],
            capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('native KaTeX glyphs are not the copied math', result.stdout)
        self.assertIn('a mid-paragraph fragment keeps its line id', result.stdout)


if __name__ == '__main__':
    unittest.main()
