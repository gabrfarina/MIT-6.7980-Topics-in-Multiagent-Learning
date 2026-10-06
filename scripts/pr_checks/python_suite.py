"""Record individual unittest results so baseline failures cannot hide new ones."""
import json
from pathlib import Path
import sys
import unittest

root=Path(sys.argv[1]).resolve()
sys.path.insert(0,str(root/'scripts'))
suite=unittest.defaultTestLoader.discover(str(root/'scripts'),pattern='test_*.py')
deferred=[]
if '--source-only' in sys.argv:
    def tests(suite):
        for item in suite:
            if isinstance(item,unittest.TestSuite):yield from tests(item)
            else:yield item
    selected=[]
    for item in tests(suite):
        if item.id().startswith(('test_build_figures.','test_html_svg_text.')):
            deferred.append(item.id())
        else:selected.append(item)
    suite=unittest.TestSuite(selected)
result=unittest.TextTestRunner(verbosity=1).run(suite)
Path(sys.argv[2]).write_text(json.dumps(dict(run=result.testsRun,
    deferred_to_html=deferred,
    failures=[dict(test=test.id(),detail=detail) for test,detail in result.failures+result.errors],
    skipped=[dict(test=test.id(),reason=reason) for test,reason in result.skipped]),indent=2))
sys.exit(not result.wasSuccessful())
