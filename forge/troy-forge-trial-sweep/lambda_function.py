"""
troy-forge-trial-sweep v3
Actions:
  - forge.run_trial_sweep   : list S3 prefix, sample N records, write receipt
  - forge.seed_and_sweep    : seed fixture, then sweep
  - forge.read_receipt      : read a receipt JSON back from S3
RDTI: project_code=OUTRD-FORGE-001
"""
import json, os, random, traceback
from datetime import datetime, timezone
import boto3

s3 = boto3.client("s3")

DEFAULT_BUCKET   = os.environ.get("FORGE_BUCKET", "tech4humanity-forge")
DEFAULT_INPUT    = os.environ.get("FORGE_INPUT_PREFIX", "trials/input/")
DEFAULT_RECEIPT  = os.environ.get("FORGE_RECEIPT_PREFIX", "trials/receipts/")
DEFAULT_SAMPLE_N = int(os.environ.get("FORGE_SAMPLE_N", "250"))


def _utc():
    return datetime.now(timezone.utc).isoformat()


def _list_keys(bucket, prefix, max_files=200):
    keys = []
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []) or []:
            k = obj["Key"]
            if k.endswith(".json") or k.endswith(".jsonl"):
                keys.append(k)
                if len(keys) >= max_files:
                    return keys
    return keys


def _read_records(bucket, key):
    body = s3.get_object(Bucket=bucket, Key=key)["Body"].read().decode("utf-8")
    if key.endswith(".jsonl"):
        return [json.loads(line) for line in body.splitlines() if line.strip()]
    parsed = json.loads(body)
    return parsed if isinstance(parsed, list) else [parsed]


def _seed_fixture(bucket, input_prefix, run_id):
    random.seed(run_id)
    records = [
        {
            "id": f"rec-{i:04d}",
            "score": round(random.random(), 4),
            "category": random.choice(["alpha", "beta", "gamma"]),
            "weight": random.randint(1, 100),
            "tag": random.choice(["rdti", "trial", "forge", "outrd"]),
        }
        for i in range(500)
    ]
    key = f"{input_prefix.rstrip('/')}/seed-{run_id}.jsonl"
    body = "\n".join(json.dumps(r) for r in records).encode()
    s3.put_object(Bucket=bucket, Key=key, Body=body, ContentType="application/x-ndjson")
    return {"seeded_key": f"s3://{bucket}/{key}", "records_seeded": len(records)}


def _run_sweep(event, started, run_id, seed_info=None):
    bucket = (event or {}).get("bucket", DEFAULT_BUCKET)
    input_prefix = (event or {}).get("input_prefix", DEFAULT_INPUT)
    receipt_prefix = (event or {}).get("receipt_prefix", DEFAULT_RECEIPT)
    sample_n = int((event or {}).get("sample_n", DEFAULT_SAMPLE_N))
    write_receipt = bool((event or {}).get("write_receipt", True))

    keys = _list_keys(bucket, input_prefix)
    if not keys:
        return {"success": False, "error": f"no .json/.jsonl found at s3://{bucket}/{input_prefix}",
                "started_utc": started, "finished_utc": _utc()}

    per_file, all_samples, total_records = [], [], 0
    for k in keys:
        try:
            recs = _read_records(bucket, k)
            total_records += len(recs)
            per_file.append({"key": k, "ok": True, "records": len(recs)})
            all_samples.extend(recs)
        except Exception as e:
            per_file.append({"key": k, "ok": False, "error": f"{type(e).__name__}: {e}"})

    if len(all_samples) > sample_n:
        random.seed(run_id)
        all_samples = random.sample(all_samples, sample_n)

    receipt_key = f"{receipt_prefix.rstrip('/')}/{run_id}.json"
    receipt = {
        "run_id": run_id, "started_utc": started, "finished_utc": _utc(),
        "bucket": bucket, "input_prefix": input_prefix,
        "files_scanned": len(keys), "total_records": total_records,
        "sampled_records": len(all_samples), "sample_target": sample_n,
        "files": per_file, "ok": all(x["ok"] for x in per_file),
        "rdti": {"is_rd": True, "project_code": "OUTRD-FORGE-001"},
    }
    if seed_info:
        receipt["seed"] = seed_info
    if write_receipt:
        s3.put_object(Bucket=bucket, Key=receipt_key,
                      Body=json.dumps(receipt, default=str, indent=2).encode(),
                      ContentType="application/json")
        receipt["receipt_uri"] = f"s3://{bucket}/{receipt_key}"
    return {"success": True, "receipt": receipt}


def _read_receipt(event):
    bucket = (event or {}).get("bucket", DEFAULT_BUCKET)
    receipt_prefix = (event or {}).get("receipt_prefix", DEFAULT_RECEIPT)
    run_id = (event or {}).get("run_id")
    if not run_id:
        return {"success": False, "error": "run_id required"}
    key = f"{receipt_prefix.rstrip('/')}/{run_id}.json"
    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
        body = obj["Body"].read().decode("utf-8")
        return {
            "success": True,
            "receipt_uri": f"s3://{bucket}/{key}",
            "size_bytes": obj["ContentLength"],
            "etag": obj["ETag"].strip('"'),
            "last_modified": obj["LastModified"].isoformat(),
            "receipt": json.loads(body),
        }
    except s3.exceptions.NoSuchKey:
        return {"success": False, "error": f"no receipt at s3://{bucket}/{key}"}


def lambda_handler(event, context):
    started = _utc()
    try:
        action = (event or {}).get("action", "forge.run_trial_sweep")
        run_id = (event or {}).get("run_id") or f"forge-trial-{started.replace(':','').replace('-','')[:15]}"
        bucket = (event or {}).get("bucket", DEFAULT_BUCKET)
        input_prefix = (event or {}).get("input_prefix", DEFAULT_INPUT)

        if action == "forge.run_trial_sweep":
            return _run_sweep(event, started, run_id)
        if action == "forge.seed_and_sweep":
            seed_info = _seed_fixture(bucket, input_prefix, run_id)
            return _run_sweep(event, started, run_id, seed_info=seed_info)
        if action == "forge.read_receipt":
            return _read_receipt(event)
        return {"success": False, "error": f"unknown action: {action}"}
    except Exception as e:
        return {
            "success": False,
            "error": f"{type(e).__name__}: {e}",
            "trace": traceback.format_exc()[-2000:],
            "started_utc": started,
            "finished_utc": _utc(),
        }
