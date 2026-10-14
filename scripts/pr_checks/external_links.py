"""Bounded, unauthenticated checks of public HTTP(S) links added by a PR."""
from concurrent.futures import ThreadPoolExecutor
import ipaddress
import socket
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit, urlunsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener


def public_url(url):
    parsed=urlsplit(url)
    if parsed.scheme not in ('http','https') or not parsed.hostname or parsed.username or parsed.password or parsed.port not in (None,80,443):
        raise ValueError('Only public HTTP(S) URLs without credentials are checked')
    addresses=socket.getaddrinfo(parsed.hostname,parsed.port or (443 if parsed.scheme=='https' else 80))
    if not addresses or any(not ipaddress.ip_address(item[4][0]).is_global for item in addresses):
        raise ValueError('Private or special-use network destination is not checked')
    return urlunsplit(parsed._replace(fragment=''))


class PublicRedirect(HTTPRedirectHandler):
    def redirect_request(self,req,fp,code,msg,headers,newurl):
        public_url(newurl)
        return super().redirect_request(req,fp,code,msg,headers,newurl)


def probe(url):
    try:
        url=public_url(url)
        opener=build_opener(PublicRedirect())
        for method in ('HEAD','GET'):
            try:
                with opener.open(Request(url,method=method,headers={'User-Agent':'Course-PR-Checks/1.0'}),timeout=8) as response:
                    return None if response.status<400 else ('warning',f'HTTP {response.status}')
            except HTTPError as error:
                status=error.code
                error.close()
                if method=='HEAD':continue
                return ('error' if status in (404,410) else 'warning',f'HTTP {status}')
    except (OSError,ValueError,URLError) as error:
        return ('warning',str(error)[:180])


def audit(entries):
    old={x['url'] for x in entries if x['side']=='before'}
    added=sorted({x['url'] for x in entries if x['side']=='after'}-old)
    findings=[]
    with ThreadPoolExecutor(max_workers=4) as pool:
        for url,result in zip(added[:80],pool.map(probe,added[:80])):
            if result:
                level,message=result
                findings.append(dict(side='after',level=level,code='external-link',page='',message=f'{url}: {message}'))
    if len(added)>80:
        findings.append(dict(side='after',level='warning',code='external-link-limit',page='',message=f'Checked 80 of {len(added)} new URLs; remaining URLs require inspection.'))
    return findings,len(added[:80])
