"""Run the default branch's course consistency validators on another checkout."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import course_index
from build_site import chapter_source_text
from lecture_links import validate_lecture_links

root = Path(sys.argv[1]).resolve()
course_index.ROOT = root
config, schedule = course_index.load_course(root / "html-export.json")
for note in config["notes"]:
    chapter_source_text(root / note["source"], note)
count = validate_lecture_links(root, config)
print(f"Validated {len(config['notes'])} note headers, syllabus metadata, published inputs, and {count} cross-lecture links.")
