"""Use trusted validators against an explicitly selected source and HTML snapshot."""
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import course_index
from check_site import Page, image_inventory_issues, source_image_paths, dropped_content_warnings
from check_links import audit_site
import json

root=Path(sys.argv[1]).resolve()
course_index.ROOT=root
config,_=course_index.load_course(root/'html-export.json')
folder=root/'html'
issues=[]
for note in config['notes']:
    name=Path(note['source']).stem+'.html'
    source=root/note['source']
    if not (folder/name).is_file():
        issues.append(f'Missing page: {name}')
        continue
    page=Page((folder/name).read_text())
    title=' '.join(''.join(page.h1_text).split())
    if title != note['title']:
        issues.append(f'{name}: title does not match the syllabus')
    issues.extend(image_inventory_issues(source,source.read_text(),page,name,root=root))
for log in sorted((root/'.build/logs').glob('*.log')):
    issues.extend(f'{log.name}: {warning}' for warning in dropped_content_warnings(log.read_text()))
issues.extend(audit_site(folder,config).issues)
print(json.dumps(sorted(set(issues)),indent=2))
