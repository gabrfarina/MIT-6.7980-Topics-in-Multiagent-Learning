"""Build both integration snapshots and audit/diff their rendered HTML."""
import json
import os
import re
import shlex
from pathlib import Path
import shutil
import sys

from common import arguments, command, finish, prepare, run_check
from html_diff import compare
from external_links import audit as audit_external


def classify(findings):
    def key(x):
        return (x['code'],x.get('page',''),x.get('viewport',0),x['message'])
    baseline={key(x) for x in findings if x['side']=='before'}
    result=[]
    seen=set()
    for x in findings:
        if x['side']!='after' or key(x) in seen:
            continue
        seen.add(key(x))
        x=dict(x)
        incomplete=x['code'].endswith(('-incomplete','-unavailable')) or x['code']=='screenshot-limit'
        x['inherited']=key(x) in baseline and not incomplete
        if x['inherited']:
            x['level']='warning'
        result.append(x)
    return result


def main():
    args,report=arguments('html')
    scripts=Path(__file__).resolve().parent
    try:
        before,after=prepare(args,report)
        if after:
            status,chrome=command(['node','-e',"process.stdout.write(require('playwright').chromium.executablePath())"],cwd=scripts)
            if status:raise RuntimeError('Cannot resolve the pinned Chromium executable')
            wrapper=args.output/'chromium-ci'
            wrapper.write_text('#!/bin/sh\nexec '+shlex.quote(chrome.strip())+' --no-sandbox "$@"\n')
            wrapper.chmod(0o755)
            site_env={**os.environ,'CHROME_BIN':str(wrapper)}
            findings=[]
            target=Path(os.environ.get('PR_CARGO_TARGET',str(args.output/'cargo-target'))).resolve()
            env={**os.environ,'CARGO_TARGET_DIR':str(target),'CARGO_BUILD_JOBS':'2'}
            for side,root in [('before',before),('after',after)]:
                built=run_check(report,args.output,'exporter-build',side,
                    ['cargo','build','--release','--locked','--manifest-path','html-exporter/Cargo.toml'],root,timeout=2400,env=env)
                if built['status']!='pass':
                    findings.append(dict(side=side,level='error',code='build-unavailable',page='',message='Exporter did not compile; see build log.'))
                    continue
                binary=root/'html-exporter/target/release/notes-html-exporter'
                binary.parent.mkdir(parents=True,exist_ok=True)
                shutil.copy2(target/'release/notes-html-exporter',binary)
                tested=run_check(report,args.output,'exporter-tests',side,
                    ['cargo','test','--release','--locked','--manifest-path','html-exporter/Cargo.toml'],root,timeout=1200,env=env)
                if tested['status']!='pass':
                    failed=re.findall(r'^test ([\w:]+) \.\.\. FAILED', (args.output/tested['log']).read_text(),re.M)
                    for name in failed or ['Exporter test run did not finish successfully; inspect the test log.']:
                        findings.append(dict(side=side,level='error',code='exporter-test' if failed else 'exporter-tests-incomplete',page='',message=name))
                tested=run_check(report,args.output,'svg-regressions',side,
                    [sys.executable,'-m','unittest','discover','-s','scripts','-p','test_html_svg_text.py'],root,timeout=300)
                if tested['status']!='pass':
                    findings.append(dict(side=side,level='error',code='svg-regressions',page='',message='Selectable SVG figure regression failed; inspect svg-regressions.log.'))
                tested=run_check(report,args.output,'figure-build-regressions',side,
                    [sys.executable,'-m','unittest','discover','-s','scripts','-p','test_build_figures.py'],root,timeout=300)
                if tested['status']!='pass':
                    findings.append(dict(side=side,level='error',code='figure-build-regressions',page='',message='Figure build regression failed; inspect figure-build-regressions.log.'))
                built=run_check(report,args.output,'site-build',side,
                    [sys.executable,'scripts/build_site.py','--skip-build'],root,timeout=1500,env=site_env)
                if not (root/'html/index.html').is_file():
                    findings.append(dict(side=side,level='error',code='site-unavailable',page='',message='Site did not build; see site-build log.'))
                    continue
                check=run_check(report,args.output,'site-validation',side,
                    [sys.executable,str(scripts/'site_probe.py'),str(root)],root)
                if check['status']=='pass':
                    for message in json.loads((args.output/check['log']).read_text()):
                        findings.append(dict(side=side,level='error',code='site-validation',page='',message=message))
                else:
                    findings.append(dict(side=side,level='error',code='site-validation-incomplete',page='',message='Site validator failed to run.'))
                # Strict parsing is separate from successful browser auto-rendering.
                check=run_check(report,args.output,'katex-validation',side,
                    ['node',str(scripts.parent/'check_katex.cjs'),str(root/'html')],root)
                if check['status']!='pass':
                    log=(args.output/check['log']).read_text().replace(str(root/'html')+'/','')
                    for line in log.splitlines():
                        if '.html:' in line:
                            findings.append(dict(side=side,level='warning' if 'untranslated math:' in line else 'error',
                                code='math-fallback' if 'untranslated math:' in line else 'katex-parse',page='',message=line[:1000]))
                if built['status']!='pass':
                    findings.append(dict(side=side,level='warning',code='site-build-warning',page='',message='Site was generated but its build command returned a failure; inspect site-build.log.'))
            screenshots=args.output/'browser'
            check=run_check(report,args.output,'browser', 'both',
                ['node',str(scripts/'browser.cjs'),str(before/'html'),str(after/'html'),str(screenshots)],scripts,timeout=1800)
            if check['status']!='pass':
                report['findings'].append(dict(level='error',code='browser-incomplete',page='',message='Browser audit did not finish; see both-browser.log.'))
            else:
                browser=json.loads((screenshots/'browser.json').read_text())
                findings.extend(browser['findings'])
                external,count=audit_external(browser['external'])
                findings.extend(external)
                report['coverage']['external_links_checked']=count
                report['coverage']['pages']=len(browser['pages'])
                report['regions'],limited=compare(screenshots,args.output)
                report['coverage']['diff_limited']=limited
            report['findings'].extend(classify(findings))
            if not (after/'html/index.html').is_file() or not (before/'html/index.html').is_file():
                report['findings'].append(dict(level='error',code='comparison-incomplete',page='',message='Both generated sites are required for a complete HTML comparison.'))
            report['coverage']['html']='All configured pages; 1280px and 390px Chromium; open solutions; local assets and anchors; source image inventory; KaTeX parsing and accent metadata; overflow, SVG references and browser errors. Up to 80 new external URLs are checked: 404/410 fail; blocked or inconclusive requests warn.'
    except Exception as error:
        report['findings'].append(dict(level='error',code='check-incomplete',page='',message=str(error)[:1000]))
    return finish(args,report)


if __name__=='__main__':
    sys.exit(main())
