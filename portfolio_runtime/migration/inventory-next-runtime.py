#!/usr/bin/env python3
"""Inventory concrete Next.js runtime routes without executing application code."""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
from datetime import datetime, timezone
from typing import Any

METHOD_RE = re.compile(r"export\s+(?:async\s+)?function\s+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\b")
DEPENDENCY_MARKERS = {
    "supabase": ("supabase", "createClient", "supabaseAdmin"),
    "stripe": ("stripe", "Stripe"),
    "email": ("resend", "sendMail", "nodemailer"),
    "pdf": ("puppeteer", "pdf", "PDF"),
    "authentication": ("auth", "cookie", "session"),
    "telemetry": ("telemetry", "analytics"),
}


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dependencies(source: str) -> list[str]:
    return sorted(
        name
        for name, markers in DEPENDENCY_MARKERS.items()
        if any(marker in source for marker in markers)
    )


def api_url(app: pathlib.Path, route_file: pathlib.Path) -> str:
    relative = route_file.parent.relative_to(app)
    return "/" + "/".join(relative.parts)


def page_url(app: pathlib.Path, page_file: pathlib.Path) -> str:
    relative = page_file.parent.relative_to(app)
    if not relative.parts:
        return "/"
    return "/" + "/".join(relative.parts)


def inventory(source_root: pathlib.Path) -> dict[str, Any]:
    app = source_root / "app"
    if not app.is_dir():
        raise ValueError(f"Next.js app directory not found: {app}")

    routes: list[dict[str, Any]] = []
    patterns = ("route.ts", "route.tsx", "route.js", "route.jsx")
    api_files = sorted(
        path
        for pattern in patterns
        for path in (app / "api").rglob(pattern)
    ) if (app / "api").is_dir() else []

    for path in api_files:
        source = path.read_text(errors="replace")
        methods = sorted(set(METHOD_RE.findall(source)))
        routes.append({
            "path": api_url(app, path),
            "kind": "api",
            "classification": "dynamic",
            "methods": methods or ["UNKNOWN"],
            "dependencies": dependencies(source),
            "source": str(path.relative_to(source_root)),
            "source_sha256": sha256(path),
            "owner": "UNRESOLVED",
            "runtime_target": "UNRESOLVED",
            "lifecycle": "RUNTIME_TARGET_REQUIRED",
        })

    page_patterns = ("page.ts", "page.tsx", "page.js", "page.jsx")
    page_files = sorted(
        path for pattern in page_patterns for path in app.rglob(pattern)
        if any(part.startswith("[") and part.endswith("]") for part in path.parts)
    )
    for path in page_files:
        source = path.read_text(errors="replace")
        routes.append({
            "path": page_url(app, path),
            "kind": "parameterised-page",
            "classification": "dynamic",
            "methods": ["GET"],
            "dependencies": dependencies(source),
            "source": str(path.relative_to(source_root)),
            "source_sha256": sha256(path),
            "owner": "UNRESOLVED",
            "runtime_target": "UNRESOLVED",
            "lifecycle": "RUNTIME_TARGET_REQUIRED",
        })

    routes.sort(key=lambda route: (route["path"], route["kind"]))
    payload = {
        "schema": "t4h.next_runtime_route_inventory.v1",
        "source_root": str(source_root.resolve()),
        "api_route_count": sum(route["kind"] == "api" for route in routes),
        "parameterised_page_count": sum(
            route["kind"] == "parameterised-page" for route in routes
        ),
        "runtime_route_count": len(routes),
        "unresolved_owner_count": sum(route["owner"] == "UNRESOLVED" for route in routes),
        "unresolved_target_count": sum(
            route["runtime_target"] == "UNRESOLVED" for route in routes
        ),
        "classification": "PARTIAL" if routes else "BLOCKED",
        "routes": routes,
        "created_at": now(),
    }
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    payload["evidence_sha256"] = hashlib.sha256(canonical).hexdigest()
    return payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=pathlib.Path)
    parser.add_argument("--output", type=pathlib.Path)
    args = parser.parse_args()
    try:
        result = inventory(args.source_root)
    except (OSError, ValueError) as exc:
        print(json.dumps({"status": "BLOCKED", "error": str(exc)}, indent=2))
        return 2
    encoded = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded)
    print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
