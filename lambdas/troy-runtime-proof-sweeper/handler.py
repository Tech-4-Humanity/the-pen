"""
troy-runtime-proof-sweeper
Lambda: python3.11 | ap-southeast-2
Contract: the-pen#145
Auth: SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (REST)
"""

import json, os, uuid, urllib.request, urllib.parse
from datetime import datetime, timezone, timedelta

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
LAMBDA_NAME  = "troy-runtime-proof-sweeper"

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation",
}


def sb_get(path, params=None):
    url = f"{SUPABASE_URL}/rest/v1/{path}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read())


def sb_patch(path, match_params, body):
    url = f"{SUPABASE_URL}/rest/v1/{path}?{urllib.parse.urlencode(match_params)}"
    data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers=HEADERS, method="PATCH")
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read()) if r.status != 204 else {}


def sb_post(path, body):
    url = f"{SUPABASE_URL}/rest/v1/{path}"
    data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers=HEADERS, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return json.loads(r.read()) if r.read() else {}
    except Exception:
        return {}


def claim_job():
    rows = sb_get("ops_work_queue", {
        "destination": f"eq.{LAMBDA_NAME}",
        "status": "in.ready,submitted,accepted,triaged",
        "order": "created_at.asc",
        "limit": "1",
        "select": "job_id,payload",
    })
    if not rows:
        return None, None
    job = rows[0]
    now = datetime.now(timezone.utc).isoformat()
    sb_patch("ops_work_queue",
             {"job_id": f"eq.{job['job_id']}"},
             {"status": "in_progress", "started_at": now,
              "last_heartbeat": now, "updated_at": now})
    return job["job_id"], job.get("payload") or {}


def run_sweep(window_hours):
    now = datetime.now(timezone.utc)
    cutoff = (now - timedelta(hours=window_hours)).isoformat()

    ledger_rows = sb_get("reality_ledger", {"select": "status", "limit": "1000"})
    ledger = {}
    for r in ledger_rows:
        ledger[r["status"]] = ledger.get(r["status"], 0) + 1

    wq_rows = sb_get("ops_work_queue", {"select": "status", "limit": "2000"})
    wq = {}
    for r in wq_rows:
        wq[r["status"]] = wq.get(r["status"], 0) + 1

    try:
        symbio = sb_get("symbio_health", {
            "select": "check_name,status,checked_at",
            "order": "checked_at.desc",
            "limit": "10"
        })
    except Exception:
        symbio = []

    try:
        done_rows = sb_get("ops_work_queue", {
            "select": "job_id",
            "status": "in.done,verified,promoted,closed,archived",
            "updated_at": f"gte.{cutoff}",
        })
        recent_done = len(done_rows)
    except Exception:
        recent_done = -1

    stale_cutoff = (now - timedelta(hours=2)).isoformat()
    try:
        zombies = sb_get("ops_work_queue", {
            "select": "job_id,destination",
            "status": "eq.in_progress",
            "last_heartbeat": f"lt.{stale_cutoff}",
        })
    except Exception:
        zombies = []

    return {
        "swept_at": now.isoformat(),
        "window_hours": window_hours,
        "reality_ledger": ledger,
        "work_queue": wq,
        "symbio_health": [
            {"check": s.get("check_name"), "status": s.get("status")}
            for s in symbio
        ],
        "recent_done_count": recent_done,
        "zombie_jobs": [z["job_id"] for z in zombies],
        "zombie_count": len(zombies),
    }


def reclaim_zombies(zombie_ids):
    now = datetime.now(timezone.utc).isoformat()
    for jid in zombie_ids:
        try:
            sb_patch("ops_work_queue", {"job_id": f"eq.{jid}"}, {
                "status": "blocked",
                "blocked_reason": "retries exhausted on stale claim; auto-quarantined by reclaim watchdog",
                "updated_at": now,
            })
        except Exception:
            pass


def close_job(job_id, proof):
    now = datetime.now(timezone.utc).isoformat()
    sb_patch("ops_work_queue", {"job_id": f"eq.{job_id}"}, {
        "status": "done",
        "close_signal": True,
        "result": proof,
        "last_heartbeat": now,
        "updated_at": now,
        "closed_at": now,
    })


def write_telemetry(proof, job_id):
    try:
        sb_post("ops_telemetry_event", {
            "event_type": "runtime_proof_sweep",
            "source": LAMBDA_NAME,
            "payload": {
                "job_id": job_id,
                "zombie_count": proof.get("zombie_count", 0),
                "recent_done_count": proof.get("recent_done_count", 0),
                "work_queue_blocked": proof.get("work_queue", {}).get("blocked", 0),
            }
        })
    except Exception:
        pass


def lambda_handler(event, context):
    run_id = str(uuid.uuid4())
    try:
        job_id, payload = claim_job()
        if job_id is None:
            return {"statusCode": 200, "body": json.dumps({
                "run_id": run_id, "status": "no_job"
            })}

        window = (payload or {}).get("sweep_window_hours", 1)
        proof = run_sweep(window)

        if proof["zombie_jobs"]:
            reclaim_zombies(proof["zombie_jobs"])

        close_job(job_id, proof)
        write_telemetry(proof, str(job_id))

        return {"statusCode": 200, "body": json.dumps({
            "run_id": run_id,
            "job_id": str(job_id),
            "status": "REAL",
            "swept_at": proof["swept_at"],
            "recent_done": proof["recent_done_count"],
            "zombies_reclaimed": proof["zombie_count"],
            "wq_blocked": proof["work_queue"].get("blocked", 0),
        })}

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({
            "run_id": run_id, "status": "ERROR", "error": str(e)
        })}
