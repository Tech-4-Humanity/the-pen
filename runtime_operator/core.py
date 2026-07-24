from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import urllib.request
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


class RuntimeFailure(RuntimeError):
    pass


@dataclass
class Check:
    name: str
    ok: bool
    detail: str


@dataclass
class Receipt:
    command: str
    status: str
    started_at: str
    finished_at: str
    checks: list[Check] = field(default_factory=list)
    evidence: dict[str, object] = field(default_factory=dict)
    gaps: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, object]:
        return {
            **asdict(self),
            "checks": [asdict(c) for c in self.checks],
        }


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def run(command: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(command, text=True, capture_output=True, check=False)
    if check and proc.returncode != 0:
        raise RuntimeFailure(f"command failed ({proc.returncode}): {' '.join(command)}\n{proc.stderr.strip()}")
    return proc


def find_repo(start: Path | None = None, expected_name: str = "the-pen") -> Path:
    candidates: list[Path] = []
    current = (start or Path.cwd()).resolve()
    candidates.extend([current, *current.parents])
    for env_name in ("RUNTIME_REPO", "GITHUB_WORKSPACE"):
        value = os.getenv(env_name)
        if value:
            candidates.append(Path(value).expanduser().resolve())
    candidates.extend([Path.home() / expected_name, Path.home() / "src" / expected_name])
    seen: set[Path] = set()
    for candidate in candidates:
        if candidate in seen:
            continue
        seen.add(candidate)
        if (candidate / ".git").exists() and candidate.name == expected_name:
            return candidate
        if (candidate / ".git").exists():
            remote = run(["git", "-C", str(candidate), "remote", "get-url", "origin"], check=False)
            if remote.returncode == 0 and remote.stdout.strip().rstrip("/").endswith(f"/{expected_name}.git"):
                return candidate
    raise RuntimeFailure(f"unable to discover repository {expected_name!r}; set RUNTIME_REPO")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def files_under(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*") if path.is_file())


def classify_bucket(name: str) -> str:
    lowered = name.lower()
    private_tokens = ("archive", "vault", "backup", "private", "evidence")
    public_tokens = ("site", "website", "www", "public", "web")
    if any(token in lowered for token in private_tokens):
        return "PRIVATE_ARCHIVE"
    if any(token in lowered for token in public_tokens):
        return "PUBLIC_WEBSITE"
    return "UNCLASSIFIED"


def require_safe_public_source(source: Path, bucket_class: str) -> None:
    if bucket_class != "PUBLIC_WEBSITE":
        return
    prohibited = {".pdf", ".xlsx", ".xls", ".csv", ".ofx", ".qif", ".zip"}
    offenders = [str(p) for p in files_under(source) if p.suffix.lower() in prohibited]
    if offenders:
        raise RuntimeFailure("refusing public deployment of likely private evidence: " + ", ".join(offenders[:10]))


def aws_json(args: list[str]) -> object:
    proc = run(["aws", *args, "--output", "json"])
    return json.loads(proc.stdout or "null")


def aws_inventory() -> dict[str, object]:
    identity = aws_json(["sts", "get-caller-identity"])
    buckets_payload = aws_json(["s3api", "list-buckets"])
    distributions_payload = aws_json(["cloudfront", "list-distributions"])
    buckets = [item["Name"] for item in buckets_payload.get("Buckets", [])]
    items = (distributions_payload.get("DistributionList") or {}).get("Items") or []
    distributions = []
    for item in items:
        origins = [origin["DomainName"] for origin in item.get("Origins", {}).get("Items", [])]
        distributions.append({
            "id": item.get("Id"),
            "domain": item.get("DomainName"),
            "aliases": (item.get("Aliases") or {}).get("Items") or [],
            "origins": origins,
            "enabled": item.get("Enabled"),
        })
    matches = []
    for bucket in buckets:
        for dist in distributions:
            if any(origin.startswith(bucket + ".s3") or origin == bucket for origin in dist["origins"]):
                matches.append({"bucket": bucket, "bucket_class": classify_bucket(bucket), "distribution": dist})
    return {"identity": identity, "buckets": [{"name": b, "class": classify_bucket(b)} for b in buckets], "distributions": distributions, "matches": matches}


def deploy_and_verify(source: Path, bucket: str, prefix: str, distribution_id: str | None = None, endpoint: str | None = None) -> dict[str, object]:
    source = source.resolve()
    if not source.is_dir():
        raise RuntimeFailure(f"source directory not found: {source}")
    bucket_class = classify_bucket(bucket)
    require_safe_public_source(source, bucket_class)
    destination = f"s3://{bucket}/{prefix.strip('/')}".rstrip("/") + "/"
    run(["aws", "s3", "sync", str(source) + "/", destination, "--only-show-errors"])
    local_hashes = {str(path.relative_to(source)): sha256(path) for path in files_under(source)}
    with tempfile.TemporaryDirectory(prefix="runtime-readback-") as temp:
        readback = Path(temp)
        run(["aws", "s3", "sync", destination, str(readback) + "/", "--only-show-errors"])
        remote_hashes = {str(path.relative_to(readback)): sha256(path) for path in files_under(readback)}
    if local_hashes != remote_hashes:
        missing = sorted(set(local_hashes) - set(remote_hashes))
        extra = sorted(set(remote_hashes) - set(local_hashes))
        changed = sorted(k for k in set(local_hashes) & set(remote_hashes) if local_hashes[k] != remote_hashes[k])
        raise RuntimeFailure(f"S3 readback mismatch missing={missing} extra={extra} changed={changed}")
    invalidation = None
    if distribution_id:
        invalidation = aws_json(["cloudfront", "create-invalidation", "--distribution-id", distribution_id, "--paths", "/*"])
    http_result = None
    if endpoint:
        request = urllib.request.Request(endpoint, method="GET", headers={"User-Agent": "runtime-operator/0.1"})
        with urllib.request.urlopen(request, timeout=20) as response:
            http_result = {"url": endpoint, "status": response.status, "content_type": response.headers.get("content-type")}
        if http_result["status"] >= 400:
            raise RuntimeFailure(f"endpoint check failed: {http_result}")
    return {
        "source": str(source),
        "destination": destination,
        "bucket_class": bucket_class,
        "file_count": len(local_hashes),
        "hashes": local_hashes,
        "readback_verified": True,
        "invalidation": invalidation,
        "http": http_result,
    }


def write_receipt(receipt: Receipt, output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    json_path = output_dir / f"runtime-{receipt.command}-{stamp}.json"
    md_path = output_dir / f"runtime-{receipt.command}-{stamp}.md"
    json_path.write_text(json.dumps(receipt.to_dict(), indent=2, sort_keys=True) + "\n", encoding="utf-8")
    lines = [f"# Runtime {receipt.command} receipt", "", f"- Status: **{receipt.status}**", f"- Started: `{receipt.started_at}`", f"- Finished: `{receipt.finished_at}`", "", "## Checks"]
    lines.extend(f"- [{'x' if c.ok else ' '}] **{c.name}** — {c.detail}" for c in receipt.checks)
    lines.extend(["", "## Evidence", "", "```json", json.dumps(receipt.evidence, indent=2, sort_keys=True), "```"])
    if receipt.gaps:
        lines.extend(["", "## Gaps", *[f"- {gap}" for gap in receipt.gaps]])
    md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return json_path, md_path
