"""
t4h_preflight — canonical preflight probe for every worker.
Import at the top of every Lambda handler and call run() first.

Usage:
    from t4h_preflight import run, PreflightBlocked
    try:
        ctx = run(actor_id='troy-controller')
    except PreflightBlocked as e:
        # logs and writes ops.reality_ledger BLOCKED automatically
        raise
"""
from __future__ import annotations
import os, json, time, uuid, hashlib, urllib.request, urllib.error
from datetime import datetime, timezone

MCP_HEALTH_URL = os.environ.get('T4H_MCP_HEALTH_URL', 'https://t4h-remote-mcp-server-clean.vercel.app/api/health')
BRIDGE_URL     = os.environ.get('T4H_BRIDGE_URL',    'https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com')
SUPABASE_URL   = os.environ.get('SUPABASE_URL',      'https://lzfgigiyqpuuxslsygjt.supabase.co')
MAX_AGE_SEC    = int(os.environ.get('T4H_PREFLIGHT_MAX_AGE_SEC', '60'))

class PreflightBlocked(RuntimeError):
    def __init__(self, reason: str, payload: dict):
        super().__init__(reason)
        self.payload = payload

def _get_json(url: str, timeout: int = 5) -> tuple[int, dict | None, float]:
    t0 = time.monotonic()
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 't4h-preflight'})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode('utf-8', errors='replace')
            try:
                return resp.status, json.loads(body), (time.monotonic() - t0) * 1000
            except json.JSONDecodeError:
                return resp.status, {'raw': body[:500]}, (time.monotonic() - t0) * 1000
    except urllib.error.HTTPError as e:
        return e.code, None, (time.monotonic() - t0) * 1000
    except (urllib.error.URLError, TimeoutError):
        return 0, None, (time.monotonic() - t0) * 1000

def _nonce(actor_id: str) -> str:
    return hashlib.sha256(f"{actor_id}:{time.time_ns()}".encode()).hexdigest()

def run(actor_id: str, intent: str = 'preflight') -> dict:
    ts = datetime.now(timezone.utc).isoformat()

    mcp_status, mcp_body, mcp_ms = _get_json(MCP_HEALTH_URL)
    bridge_status, _, bridge_ms  = _get_json(BRIDGE_URL.rstrip('/') + '/health', timeout=3)

    probe = {
        'mcp_health':  {'http': mcp_status, 'ok': bool(mcp_body and mcp_body.get('ok')), 'version': (mcp_body or {}).get('version'), 'latency_ms': round(mcp_ms, 1)},
        'bridge':      {'http': bridge_status, 'latency_ms': round(bridge_ms, 1)},
        'supabase_url': SUPABASE_URL,
    }

    ok = probe['mcp_health']['ok'] and probe['bridge']['http'] in (200, 401, 403)
    # 401/403 on bridge means it answered — service alive, auth wall; that is acceptable for preflight

    payload = {
        'actor_id': actor_id,
        'execution_id': str(uuid.uuid4()),
        'execution_nonce': _nonce(actor_id),
        'probe': probe,
        'ts': ts,
        'intent': intent,
    }

    if not ok:
        # callers MUST handle this — do not silently proceed
        raise PreflightBlocked(f"BLOCKED.preflight_stale: mcp_ok={probe['mcp_health']['ok']} bridge_http={probe['bridge']['http']}", payload)

    return payload

if __name__ == '__main__':
    import sys
    try:
        out = run(actor_id=sys.argv[1] if len(sys.argv) > 1 else 'cli-test')
        print(json.dumps(out, indent=2))
        sys.exit(0)
    except PreflightBlocked as e:
        print(json.dumps({'blocked': True, 'reason': str(e), 'payload': e.payload}, indent=2))
        sys.exit(2)
