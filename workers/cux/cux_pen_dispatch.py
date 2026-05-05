#!/usr/bin/env python3
import json, os, time, hashlib, glob, urllib.request

INBOX_GLOB = 'inbox/*.json'
RUNTIME_DIR = 'receipts/runtime'
DEAD_DIR = 'receipts/dead-letter'

BRIDGE_URL = os.getenv('BRIDGE_INVOKE_URL')
BRIDGE_KEY = os.getenv('BRIDGE_API_KEY')

os.makedirs(RUNTIME_DIR, exist_ok=True)
os.makedirs(DEAD_DIR, exist_ok=True)


def sha(s: str) -> str:
    return hashlib.sha256(s.encode('utf-8')).hexdigest()[:16]


def write_receipt(key, status, details):
    path = os.path.join(RUNTIME_DIR, f"{key}.json")
    payload = {
        'idempotency_key': key,
        'status': status,
        'ts': int(time.time()),
        'details': details
    }
    with open(path, 'w') as f:
        json.dump(payload, f, indent=2)
    return path


def move_to_dead(src, reason):
    base = os.path.basename(src)
    dst = os.path.join(DEAD_DIR, base)
    try:
        os.rename(src, dst)
    except Exception:
        pass
    write_receipt(base.replace('.json',''), 'dead_letter', {'reason': reason})


def call_bridge(job):
    if not BRIDGE_URL:
        return {'ok': False, 'error': 'BRIDGE_URL_MISSING'}
    data = json.dumps(job).encode('utf-8')
    req = urllib.request.Request(BRIDGE_URL, data=data, method='POST')
    req.add_header('Content-Type', 'application/json')
    if BRIDGE_KEY:
        req.add_header('x-api-key', BRIDGE_KEY)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read().decode('utf-8')
            return {'ok': True, 'status': resp.status, 'body': body}
    except Exception as e:
        return {'ok': False, 'error': str(e)}


def process(path):
    with open(path, 'r') as f:
        job = json.load(f)

    key = job.get('idempotency_key') or sha(json.dumps(job, sort_keys=True))

    # validate
    if 'action' not in job:
        write_receipt(key, 'rejected', {'reason': 'missing action'})
        move_to_dead(path, 'missing action')
        return

    # execute
    res = call_bridge(job)

    if not res.get('ok'):
        write_receipt(key, 'retry', {'error': res.get('error')})
        # simple retry once
        time.sleep(2)
        res2 = call_bridge(job)
        if not res2.get('ok'):
            write_receipt(key, 'dead_letter', {'error': res2.get('error')})
            move_to_dead(path, res2.get('error'))
            return
        else:
            write_receipt(key, 'complete', {'bridge': res2})
    else:
        write_receipt(key, 'complete', {'bridge': res})

    # archive inbox file (do not delete)
    try:
        os.rename(path, path + '.processed')
    except Exception:
        pass


if __name__ == '__main__':
    files = glob.glob(INBOX_GLOB)
    if not files:
        print('no inbox jobs')
    for p in files:
        process(p)
