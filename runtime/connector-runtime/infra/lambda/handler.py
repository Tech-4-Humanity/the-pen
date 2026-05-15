"""
Connector Probe Runner
======================
Daily executor for runtime.connector_probes ledger.

Reads SCHEDULED rows from Supabase via public.fn_connector_probes_get_scheduled(),
runs the appropriate safe (read-only) probe for each connector, writes a new row
back via public.fn_connector_probes_record() with REAL/BLOCKED + receipt.

Aligns with TML-4PM/the-pen House Rules:
  §11 — Supabase is system of record
  §17 — Reality state REAL/PARTIAL/BLOCKED only
  §20 — Archive-not-delete: insert new rows, never overwrite SCHEDULED
  §24 — Transport-agnostic receipt contract
  §25 — Re-fetch-by-ID discipline (the new row IS the post-write re-fetch)

All probes MUST be read-only against the external connector. No mutations.

Author: Claude Opus 4.7
Audit:  connector-runtime-audit-2026-05-15
"""
from __future__ import annotations

import base64
import json
import logging
import os
import time
import urllib.error
import urllib.request
from typing import Any, Optional, Tuple

import boto3

LOG = logging.getLogger()
LOG.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

SUPABASE_URL = os.environ["SUPABASE_URL"].rstrip("/")
SUPABASE_SECRET_ARN = os.environ["SUPABASE_SECRET_ARN"]
CONNECTOR_SECRETS_ARN = os.environ["CONNECTOR_SECRETS_ARN"]

_secrets_client = boto3.client("secretsmanager")
_supabase_key_cache: Optional[str] = None
_connector_keys_cache: Optional[dict] = None

ProbeResult = Tuple[str, Optional[str], Optional[str], dict, str]
# (status, receipt_type, receipt_id, evidence_dict, notes)


def _get_secret_json(arn: str) -> dict:
    resp = _secrets_client.get_secret_value(SecretId=arn)
    return json.loads(resp["SecretString"])


def _supabase_key() -> str:
    global _supabase_key_cache
    if _supabase_key_cache is None:
        _supabase_key_cache = _get_secret_json(SUPABASE_SECRET_ARN)["service_role_key"]
    return _supabase_key_cache


def _connector_keys() -> dict:
    global _connector_keys_cache
    if _connector_keys_cache is None:
        _connector_keys_cache = _get_secret_json(CONNECTOR_SECRETS_ARN)
    return _connector_keys_cache


def _http(method: str, url: str, headers: dict,
          body: Optional[bytes] = None, timeout: int = 10) -> Tuple[int, str]:
    req = urllib.request.Request(url, method=method, headers=headers, data=body)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", errors="replace")
    except Exception as e:
        return 0, f"network_error: {type(e).__name__}: {e}"


def _supabase_rpc(fn: str, payload: dict) -> Any:
    key = _supabase_key()
    url = f"{SUPABASE_URL}/rest/v1/rpc/{fn}"
    status, body = _http(
        "POST", url,
        {
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        body=json.dumps(payload).encode("utf-8"),
        timeout=15,
    )
    if status >= 400 or status == 0:
        raise RuntimeError(f"Supabase RPC {fn} failed: HTTP {status} body={body[:500]}")
    return json.loads(body) if body else None


# ---------------------------------------------------------------------------
# Connector probes. Read-only against external APIs. Each returns ProbeResult.
# ---------------------------------------------------------------------------

def probe_stripe(creds: dict) -> ProbeResult:
    key = creds.get("stripe_api_key")
    if not key:
        return ("BLOCKED", None, None,
                {"reason": "no stripe_api_key in connector secrets"},
                "set stripe_api_key in CONNECTOR_SECRETS_ARN")
    status, body = _http("GET", "https://api.stripe.com/v1/account",
                          {"Authorization": f"Bearer {key}"})
    if status == 200:
        data = json.loads(body)
        return ("REAL", "stripe_account_id", data.get("id"), {
            "type": data.get("type"),
            "country": data.get("country"),
            "default_currency": data.get("default_currency"),
            "business_profile_name": (data.get("business_profile") or {}).get("name"),
            "charges_enabled": data.get("charges_enabled"),
            "details_submitted": data.get("details_submitted"),
        }, "GET /v1/account 200")
    return ("BLOCKED", None, None,
            {"http_status": status, "body": body[:400]},
            f"GET /v1/account http={status}")


def probe_canva(creds: dict) -> ProbeResult:
    token = creds.get("canva_access_token")
    if not token:
        return ("BLOCKED", None, None,
                {"reason": "no canva_access_token in connector secrets"},
                "set canva_access_token (OAuth bearer) in CONNECTOR_SECRETS_ARN")
    status, body = _http("GET", "https://api.canva.com/rest/v1/users/me",
                          {"Authorization": f"Bearer {token}"})
    if status == 200:
        data = (json.loads(body).get("user") or {})
        return ("REAL", "canva_user_id", data.get("user_id"), {
            "team_id": data.get("team_id"),
            "display_name": data.get("display_name"),
        }, "GET /rest/v1/users/me 200")
    return ("BLOCKED", None, None,
            {"http_status": status, "body": body[:400]},
            f"GET /rest/v1/users/me http={status}")


def probe_spotify(creds: dict) -> ProbeResult:
    cid = creds.get("spotify_client_id")
    csec = creds.get("spotify_client_secret")
    if not (cid and csec):
        return ("BLOCKED", None, None,
                {"reason": "spotify_client_id/secret missing"},
                "set spotify_client_id and spotify_client_secret in CONNECTOR_SECRETS_ARN")
    basic = base64.b64encode(f"{cid}:{csec}".encode()).decode()
    status, body = _http(
        "POST", "https://accounts.spotify.com/api/token",
        {"Authorization": f"Basic {basic}",
         "Content-Type": "application/x-www-form-urlencoded"},
        body=b"grant_type=client_credentials",
    )
    if status != 200:
        return ("BLOCKED", None, None,
                {"http_status": status, "body": body[:400]},
                f"client_credentials token http={status}")
    token = json.loads(body)["access_token"]
    status2, body2 = _http("GET",
                            "https://api.spotify.com/v1/browse/new-releases?limit=1",
                            {"Authorization": f"Bearer {token}"})
    if status2 == 200:
        data = json.loads(body2)
        items = (data.get("albums") or {}).get("items") or [{}]
        return ("REAL", "spotify_oauth_grant", "client_credentials", {
            "first_new_release_id": items[0].get("id"),
            "first_new_release_name": items[0].get("name"),
        }, "client_credentials grant + GET /v1/browse/new-releases 200")
    return ("BLOCKED", None, None,
            {"http_status": status2, "body": body2[:400]},
            f"browse/new-releases http={status2}")


def probe_unsupported(name: str) -> ProbeResult:
    return ("BLOCKED", None, None, {
        "reason": "no public REST account endpoint for safe-probe",
        "rationale": "connector accessed via MCP wrapper only; no direct read-only account endpoint in public docs",
    }, f"{name} has no programmatic safe-probe path; remains MCP-only")


PROBES = {
    "Stripe": probe_stripe,
    "Canva": probe_canva,
    "Spotify": probe_spotify,
    "Tripadvisor": lambda c: probe_unsupported("Tripadvisor"),
    "Booking": lambda c: probe_unsupported("Booking"),
    "Lovable": lambda c: probe_unsupported("Lovable"),
}


# ---------------------------------------------------------------------------
# Lambda entrypoint
# ---------------------------------------------------------------------------

def lambda_handler(event, context):
    started = time.time()
    LOG.info("connector-probe-runner start")

    scheduled = _supabase_rpc("fn_connector_probes_get_scheduled", {}) or []
    if isinstance(scheduled, dict):
        scheduled = scheduled.get("rows", [])
    LOG.info("found %d SCHEDULED rows", len(scheduled))

    creds = _connector_keys()
    results: list[dict] = []
    for row in scheduled:
        probe_id = row.get("id")
        connector = row.get("connector")
        probe_fn = PROBES.get(connector)
        if probe_fn is None:
            status, rtype, rid, evidence, notes = (
                "BLOCKED", None, None,
                {"reason": "no probe registered for connector"},
                f"unknown connector {connector!r}",
            )
        else:
            try:
                status, rtype, rid, evidence, notes = probe_fn(creds)
            except Exception as e:
                LOG.exception("probe raised for %s id=%s", connector, probe_id)
                status, rtype, rid, evidence, notes = (
                    "BLOCKED", None, None,
                    {"exception": type(e).__name__, "message": str(e)[:400]},
                    "probe raised exception",
                )
        try:
            _supabase_rpc("fn_connector_probes_record", {
                "p_scheduled_probe_id": probe_id,
                "p_connector": connector,
                "p_status": status,
                "p_receipt_type": rtype,
                "p_receipt_id": rid,
                "p_evidence": evidence,
                "p_notes": notes,
                "p_auditor": "lambda:connector-probe-runner",
            })
            results.append({"id": probe_id, "connector": connector, "status": status})
        except Exception as e:
            LOG.exception("record failed id=%s connector=%s", probe_id, connector)
            results.append({"id": probe_id, "connector": connector,
                            "status": "RECORD_FAILED", "error": str(e)[:300]})

    summary = {
        "probed": len(results),
        "duration_ms": int((time.time() - started) * 1000),
        "results": results,
    }
    LOG.info("connector-probe-runner done %s", json.dumps(summary))
    return summary
