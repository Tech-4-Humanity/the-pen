"""
bridge_sql.py — canonical bridge client for troy-sql-executor / run_sql RPC.

Replaces the legacy wrapper that masked pg errors as `sql_error` / `command:null`
and silently returned `rows:[]`.

Contract:
  ok  -> returns {"rows": [...], "command": "<UPPER>", "rowcount": int, "raw": {...}}
  bad -> raises BridgeSqlError carrying http_status, code, message, details, hint, raw

Failure modes detected (all raise, none return):
  1. HTTP non-2xx                            -> http_status + body
  2. Bridge envelope error (statusCode!=200) -> upstream error
  3. PostgREST error body (code/message/...)  -> verbatim pg fields
  4. Lambda body has `error`                 -> raised
  5. Lambda body has `sql_error`             -> raised (legacy mask)
  6. `command` is None / "" / missing        -> raised (NEW: was silent success)
  7. `rows` missing entirely                 -> raised (suspicious shape)

Usage:
    from bridge_sql import run_sql, BridgeSqlError
    try:
        out = run_sql("SELECT 1 AS x;")
        print(out["rows"])
    except BridgeSqlError as e:
        print(e.as_dict())  # full pg context
"""

from __future__ import annotations

import json
import os
import socket
import ssl
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field, asdict
from typing import Any

BRIDGE_URL_DEFAULT = (
    "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke"
)


# ---------- error type --------------------------------------------------------

@dataclass
class BridgeSqlError(Exception):
    """Raised on any non-OK bridge/SQL response. Carries full pg context."""
    http_status: int | None = None
    code: str | None = None            # PostgREST/pg SQLSTATE-ish code
    message: str | None = None         # primary human message
    details: str | None = None         # pg detail
    hint: str | None = None            # pg hint
    where: str | None = None           # which check tripped
    sql: str | None = None             # SQL we sent (truncated)
    raw: dict | None = field(default=None, repr=False)

    def __post_init__(self) -> None:
        # Build a useful __str__ for callers that just print(e)
        parts = [f"BridgeSqlError[{self.where or '?'}]"]
        if self.http_status is not None:
            parts.append(f"http={self.http_status}")
        if self.code:
            parts.append(f"code={self.code}")
        if self.message:
            parts.append(f"msg={self.message}")
        if self.details:
            parts.append(f"details={self.details}")
        if self.hint:
            parts.append(f"hint={self.hint}")
        super().__init__(" | ".join(parts))

    def as_dict(self) -> dict:
        return {k: v for k, v in asdict(self).items() if v is not None}


# ---------- helpers -----------------------------------------------------------

_PG_FIELDS = ("code", "message", "details", "hint")


def _extract_pg(obj: Any) -> dict[str, Any]:
    """Pull standard pg/PostgREST fields from any dict-shaped body."""
    if not isinstance(obj, dict):
        return {}
    return {k: obj.get(k) for k in _PG_FIELDS if obj.get(k) is not None}


def _truncate(s: str, n: int = 240) -> str:
    return s if len(s) <= n else s[:n] + "...[truncated]"


# ---------- main entrypoint ---------------------------------------------------

def run_sql(
    sql: str,
    *,
    bridge_url: str | None = None,
    api_key: str | None = None,
    timeout: float = 30.0,
    fn: str = "troy-sql-executor",
) -> dict:
    """
    Invoke troy-sql-executor via the bridge with fail-fast semantics.

    Returns: {"rows": list, "command": str, "rowcount": int, "raw": dict}
    Raises:  BridgeSqlError on ANY failure path (incl. command:null).
    """
    bridge_url = bridge_url or os.environ.get("BRIDGE_URL", BRIDGE_URL_DEFAULT)
    api_key = api_key or os.environ.get("BRIDGE_API_KEY", "")
    if not api_key:
        raise BridgeSqlError(
            where="config",
            message="BRIDGE_API_KEY not set (env BRIDGE_API_KEY or pass api_key=)",
        )

    # Bridge envelope: troy-sql-executor uses NESTED payload (sql under payload)
    envelope = {"fn": fn, "payload": {"sql": sql}}
    body = json.dumps(envelope).encode("utf-8")

    req = urllib.request.Request(
        bridge_url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
        },
    )

    # ---- transport ---------------------------------------------------------
    raw_text: str = ""
    http_status: int | None = None
    last_err: Exception | None = None

    # Single retry for the known sandbox proxy "DNS cache overflow" symptom.
    for attempt in (1, 2):
        try:
            opener = urllib.request.build_opener()
            opener.addheaders = [("Connection", "keep-alive")]
            with opener.open(req, timeout=timeout) as r:
                http_status = r.status
                raw_text = r.read().decode("utf-8", errors="replace")
            break
        except urllib.error.HTTPError as e:
            http_status = e.code
            raw_text = e.read().decode("utf-8", errors="replace") if e.fp else ""
            # Try to surface pg error from non-2xx body too
            try:
                parsed = json.loads(raw_text) if raw_text else {}
            except Exception:
                parsed = {}
            pg = _extract_pg(parsed)
            raise BridgeSqlError(
                http_status=http_status,
                where="http",
                message=pg.get("message") or f"HTTP {http_status}",
                code=pg.get("code"),
                details=pg.get("details"),
                hint=pg.get("hint"),
                sql=_truncate(sql),
                raw={"body": raw_text[:4000]},
            ) from e
        except (urllib.error.URLError, socket.timeout, ssl.SSLError, ConnectionError) as e:
            last_err = e
            if attempt == 1:
                time.sleep(0.5)
                continue
            raise BridgeSqlError(
                where="transport",
                message=f"{type(e).__name__}: {e}",
                sql=_truncate(sql),
            ) from e

    # ---- parse outer ------------------------------------------------------
    try:
        outer = json.loads(raw_text) if raw_text else {}
    except json.JSONDecodeError as e:
        raise BridgeSqlError(
            http_status=http_status,
            where="parse_outer",
            message=f"non-JSON bridge response: {e}",
            raw={"body": raw_text[:4000]},
            sql=_truncate(sql),
        ) from e

    # API Gateway wraps Lambda response as {statusCode, body:"<json string>"}
    inner: Any = outer
    if isinstance(outer, dict) and "statusCode" in outer and "body" in outer:
        if outer.get("statusCode") and outer["statusCode"] >= 400:
            pg = _extract_pg(outer)
            raise BridgeSqlError(
                http_status=outer["statusCode"],
                where="bridge_envelope",
                message=pg.get("message") or f"bridge statusCode={outer['statusCode']}",
                code=pg.get("code"),
                details=pg.get("details"),
                hint=pg.get("hint"),
                raw=outer,
                sql=_truncate(sql),
            )
        try:
            inner = json.loads(outer["body"]) if isinstance(outer["body"], str) else outer["body"]
        except json.JSONDecodeError as e:
            raise BridgeSqlError(
                http_status=http_status,
                where="parse_inner",
                message=f"non-JSON Lambda body: {e}",
                raw=outer,
                sql=_truncate(sql),
            ) from e

    if not isinstance(inner, dict):
        raise BridgeSqlError(
            http_status=http_status,
            where="shape",
            message="Lambda body is not an object",
            raw={"body": inner},
            sql=_truncate(sql),
        )

    # ---- legacy / explicit error fields -----------------------------------
    # `error` is generic; `sql_error` is the legacy mask used by troy-sql-executor.
    explicit = inner.get("error") or inner.get("sql_error")
    if explicit:
        pg = _extract_pg(inner)
        # explicit may itself be a dict carrying pg fields
        if isinstance(explicit, dict):
            pg = {**_extract_pg(explicit), **pg}
            msg = explicit.get("message") or json.dumps(explicit)
        else:
            msg = str(explicit)
        raise BridgeSqlError(
            http_status=http_status,
            where="lambda_error",
            message=pg.get("message") or msg,
            code=pg.get("code"),
            details=pg.get("details"),
            hint=pg.get("hint"),
            raw=inner,
            sql=_truncate(sql),
        )

    # ---- THE FIX: command:null is FAILURE, not success --------------------
    cmd = inner.get("command")
    if cmd in (None, "", "null"):
        pg = _extract_pg(inner)
        raise BridgeSqlError(
            http_status=http_status,
            where="command_null",
            message=pg.get("message") or "command is null (pg execution did not produce a tag)",
            code=pg.get("code"),
            details=pg.get("details"),
            hint=pg.get("hint") or "split multi-statement SQL; troy-sql-executor does not support BEGIN/COMMIT chains",
            raw=inner,
            sql=_truncate(sql),
        )

    # ---- shape sanity -----------------------------------------------------
    if "rows" not in inner:
        raise BridgeSqlError(
            http_status=http_status,
            where="shape",
            message="response missing `rows` field",
            raw=inner,
            sql=_truncate(sql),
        )

    rows = inner["rows"] or []
    return {
        "rows": rows,
        "command": str(cmd).upper(),
        "rowcount": inner.get("rowcount", len(rows) if isinstance(rows, list) else 0),
        "raw": inner,
    }


# ---------- self-test ---------------------------------------------------------

def _selftest() -> int:
    """Run a small matrix. Requires BRIDGE_API_KEY in env."""
    cases: list[tuple[str, str, str]] = [
        ("ok_select",       "SELECT 1 AS x;",                                   "ok"),
        ("ok_no_semi",      "SELECT 2 AS x",                                    "ok"),
        ("bad_syntax",      "SELEKT 1;",                                        "raise"),
        ("bad_relation",    "SELECT * FROM no_such_table_xyz_42;",              "raise"),
        ("multi_stmt",      "SELECT 1; SELECT 2;",                              "raise"),  # not supported
        ("empty",           "",                                                 "raise"),
    ]
    failed = 0
    for name, sql, expect in cases:
        try:
            out = run_sql(sql)
            got = "ok"
            print(f"[{name}] -> ok rows={len(out['rows'])} cmd={out['command']}")
        except BridgeSqlError as e:
            got = "raise"
            print(f"[{name}] -> raise {e}")
        if got != expect:
            print(f"  !! expected {expect} got {got}")
            failed += 1
    print(f"\nfailed={failed}/{len(cases)}")
    return failed


if __name__ == "__main__":
    raise SystemExit(_selftest())
