import json
import os
from pathlib import Path
from urllib.parse import parse_qs

REPORT_PATH = Path(os.environ.get("GHA_REPORT_PATH", "receipts/failure-census/github-actions-failure-census.json"))


def load_report() -> dict:
    if not REPORT_PATH.exists():
        return {
            "status": "BLOCKED",
            "reason": "Census report not found",
            "report_path": str(REPORT_PATH),
        }
    return json.loads(REPORT_PATH.read_text(encoding="utf-8"))


def response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "content-type": "application/json",
            "cache-control": "no-store",
        },
        "body": json.dumps(body, separators=(",", ":")),
    }


def handler(event, context):
    method = (event.get("requestContext", {}).get("http", {}).get("method") or event.get("httpMethod") or "GET").upper()
    path = event.get("rawPath") or event.get("path") or "/health"
    query = parse_qs(event.get("rawQueryString", ""))

    if method != "GET":
        return response(405, {"status": "BLOCKED", "reason": "Method not allowed"})

    if path == "/health":
        return response(200, {"status": "REAL", "service": "github-actions-health-api"})

    report = load_report()
    if report.get("status") == "BLOCKED":
        return response(503, report)

    if path == "/reports/latest":
        return response(200, report)

    if path == "/clusters":
        return response(200, {
            "status": "REAL",
            "generated_at": report.get("generated_at"),
            "clusters": report.get("clusters", []),
            "counts_by_signature": report.get("counts_by_signature", {}),
        })

    if path == "/failures":
        max_duration = int(query.get("duration_lte", [2])[0])
        records = []
        for record in report.get("records", []):
            duration = record.get("duration_seconds")
            if record.get("step_count", 0) == 0 or (duration is not None and duration <= max_duration):
                records.append(record)
        return response(200, {
            "status": "REAL",
            "duration_lte": max_duration,
            "count": len(records),
            "records": records,
        })

    if path == "/repos":
        repositories = sorted({record.get("repository") for record in report.get("records", []) if record.get("repository")})
        return response(200, {
            "status": "REAL",
            "count": len(repositories),
            "repositories": repositories,
        })

    return response(404, {"status": "BLOCKED", "reason": "Route not found", "path": path})
