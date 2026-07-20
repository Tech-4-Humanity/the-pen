#!/usr/bin/env python3
from pathlib import Path

path = Path('inbox/bundles/issue-237-runtime-one-bundle-v2.sh')
text = path.read_text()

text = text.replace(
    'if header :is "X-T4H-Routing-Test" "$TOKEN" { fileinto :copy "Systems/GitHub/Failures"; redirect :copy "$AGENT_MAILBOX"; stop; }',
    'if header :contains "subject" "$TOKEN" { fileinto :copy "Systems/GitHub/Failures"; redirect :copy "$AGENT_MAILBOX"; stop; }',
)
text = text.replace("; m['X-T4H-Routing-Test']=os.environ['TOKEN']", '')

old = '''q=lambda s:'"'+s.replace('\\\\','\\\\\\\\').replace('"','\\\\"')+'"'\ndef count(u,p,f):\n with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:\n  m.login(u,p); t,_=m.select(q(f),readonly=True)\n  if t!='OK': return 0\n  t,d=m.search(None,'HEADER','X-T4H-Routing-Test',q(os.environ['TOKEN'])); return len((d[0] or b'').split()) if t=='OK' else 0\ns=a=0\nfor _ in range(12):\n s=count(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD'],'Systems/GitHub/Failures'); a=count(os.environ['AGENT_MAILBOX'],os.environ['AGENT_MAILBOX_PASSWORD'],'INBOX')\n if s==1 and a==1: break\n time.sleep(5)\nout={'source':s,'agent':a,'exactly_once':s==1 and a==1}; open(os.environ['OUT'],'w').write(json.dumps(out,indent=2)+'\\n')\nif not out['exactly_once']: raise SystemExit(6)'''

new = '''q=lambda s:'"'+s.replace('\\\\','\\\\\\\\').replace('"','\\\\"')+'"'\ndef count(u,p,f):\n with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:\n  m.login(u,p); t,_=m.select(q(f),readonly=True)\n  if t!='OK': return 0\n  t,d=m.search(None,'SUBJECT',q(os.environ['TOKEN'])); return len((d[0] or b'').split()) if t=='OK' else 0\ns=a=0\nfor _ in range(12):\n s=count(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD'],'Systems/GitHub/Failures'); a=count(os.environ['AGENT_MAILBOX'],os.environ['AGENT_MAILBOX_PASSWORD'],'INBOX')\n if s==1 and a==1: break\n time.sleep(5)\nout={'token':os.environ['TOKEN'],'source':s,'agent':a,'exactly_once':s==1 and a==1}; open(os.environ['OUT'],'w').write(json.dumps(out,indent=2)+'\\n')\nif not out['exactly_once']: raise SystemExit(6)'''

if old not in text:
    raise SystemExit('BLOCKED: expected readback block not found')

path.write_text(text.replace(old, new, 1))
print('STATUS=REAL')
print('PATCH=SUBJECT_TOKEN_READBACK')
print(f'FILE={path}')
