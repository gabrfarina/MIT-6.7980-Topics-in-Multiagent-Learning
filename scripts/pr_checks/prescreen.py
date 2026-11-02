"""Check integration, course-wide source consistency, and existing regressions."""
from pathlib import Path
import json
import sys

from common import arguments, command, finish, prepare, run_check


def main():
    args, report = arguments("prescreen")
    try:
        before, after = prepare(args, report)
        if after:
            for side, root in (("before", before), ("after", after)):
                run_check(report, args.output, "course-consistency", side,
                          [sys.executable, str(Path(__file__).with_name("source_probe.py")), str(root)], root)
                run_check(report, args.output, "python-regressions", side,
                          [sys.executable, str(Path(__file__).with_name('python_suite.py')), str(root), str(args.output/f'{side}-tests.json'),'--source-only'],
                          root, timeout=1200)
            baseline = {x["name"]: x for x in report["checks"] if x["side"] == "before"}
            def normalized(text):
                return text.replace(str(before),'<snapshot>').replace(str(after),'<snapshot>')
            for check in (x for x in report["checks"] if x["side"] == "after" and x["status"] == "fail"):
                if check['name']=='python-regressions' and all((args.output/f'{side}-tests.json').is_file() for side in ('before','after')):
                    old=json.loads((args.output/'before-tests.json').read_text())
                    new=json.loads((args.output/'after-tests.json').read_text())
                    previous={(x['test'],normalized(x['detail'].strip().splitlines()[-1])) for x in old['failures']}
                    for failure in new['failures']:
                        inherited=(failure['test'],normalized(failure['detail'].strip().splitlines()[-1])) in previous
                        report['findings'].append(dict(level='warning' if inherited else 'error',code='python-regression',page='',inherited=inherited,
                            message=failure['test']+': '+failure['detail'].strip().splitlines()[-1]))
                    continue
                old_check=baseline[check['name']]
                inherited = old_check["status"] == "fail" and normalized((args.output/old_check['log']).read_text()) == normalized((args.output/check['log']).read_text())
                report["findings"].append(dict(level="warning" if inherited else "error", inherited=inherited, code=check["name"], page="",
                    message=f"{check['name']} failed. " + ("The same failure is present on the target branch." if inherited else "This failure is new or differs from the target branch; inspect both logs.") + f" See {check['log']}."))
            status, log = command(["git", "-C", str(after), "diff", "--check", args.base, "HEAD"])
            (args.output / "whitespace.log").write_text(log, encoding="utf-8")
            if status:
                report["findings"].append(dict(level="warning", code="whitespace", page="", message="Changed lines contain whitespace errors; see whitespace.log."))
            report["coverage"]["source"] = "Merge conflicts, syllabus/header consistency, configured assets, cross-lecture labels, and source Python regressions. Exporter-dependent figure tests and Rust tests run in HTML review."
    except Exception as error:
        report["findings"].append(dict(level="error", code="check-incomplete", page="", message=str(error)[:1000]))
    return finish(args, report)


if __name__ == "__main__":
    sys.exit(main())
