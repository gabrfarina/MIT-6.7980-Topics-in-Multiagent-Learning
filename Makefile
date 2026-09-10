PYTHON ?= python3

.PHONY: all html bundle epub syllabus check serve

all: bundle

html:
	$(PYTHON) scripts/build_site.py

bundle:
	$(PYTHON) scripts/build_site.py --zip

# uv installs the script's dependencies; without it, beautifulsoup4 and lxml must already be installed.
epub:
	if command -v uv >/dev/null 2>&1; then uv run scripts/build_epub.py; else $(PYTHON) scripts/build_epub.py; fi

syllabus:
	typst compile --root . --font-path html-exporter/assets/fonts 'syllabus/6.7980 F26 Syllabus.typ' 'syllabus/6.7980 Fall 2026 Syllabus.pdf'
	mkdir -p html
	cp 'syllabus/6.7980 Fall 2026 Syllabus.pdf' html/syllabus.pdf
	$(PYTHON) scripts/course_index.py

check:
	$(PYTHON) -m unittest discover -s scripts -p 'test_*.py'
	cargo test --locked --manifest-path html-exporter/Cargo.toml
	$(PYTHON) scripts/check_site.py html
	node scripts/check_katex.cjs html

serve:
	$(PYTHON) -m http.server 8798 --bind 127.0.0.1 --directory html
