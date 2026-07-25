#!/usr/bin/env python3
"""FY24/25 MAAT fresh export runner for GitHub issue #267.

This script is deliberately credential-free. It expects the governed Pen/AWS
execution environment to provide a SQL executor command via MAAT_SQL_EXECUTOR.
The command must accept SQL on stdin and return JSON rows on stdout.

Private outputs are written locally for subsequent S3 publication. GitHub must
receive only privacy-safe manifests, scripts and receipts.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import shlex
import subprocess
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

OUTPUTS = [
    "fy2425_fresh_account_summary.csv",
    "fy2425_fresh_source_file_inventory.csv",
    "fy2425_fresh_transactions.csv",
    "fy2425_statement_period_coverage.csv",
    "fy2425_balance_reconciliation.csv",
    "fy2425_transfer_pairs.csv",
    "fy2425_amex_repayment_pairs.csv",
    "fy2425_refund_reversals.csv",
    "fy2425_supplier_normalisation.csv",
    "fy2425_cost_discovery_register.csv",
    "fy2425_director_funded_candidates.csv",
    "fy2425_excluded_movements.csv",
]

REQUIRED_ACCOUNTS = {
    ("ANZ", "8406"), ("ANZ", "6495"), ("ANZ", "6563"),
    ("CBA", "3821"), ("CBA", "1795"), ("Amex", "2000"),
}


def run_sql(sql: str) -> list[dict[str, Any]]:
    command = os.getenv("MAAT_SQL_EXECUTOR")
    if not command:
        raise RuntimeError("MAAT_SQL_EXECUTOR is not configured in the governed runtime")
    proc = subprocess.run(shlex.split(command), input=sql, text=True, shell=False,
                          capture_output=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"SQL executor failed: {proc.stderr.strip()}")
    payload = json.loads(proc.stdout)
    rows = payload.get("rows", payload) if isinstance(payload, dict) else payload
    if not isinstance(rows, list):
        raise RuntimeError("SQL executor returned non-list rows")
    return rows


def write_csv(path: Path, rows: Iterable[dict[str, Any]], fields: list[str] | None = None) -> int:
    rows = list(rows)
    if fields is None:
        fields = sorted({key for row in rows for key in row.keys()})
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    return len(rows)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", required=True)
    parser.add_argument("--end", required=True)
    parser.add_argument("--issue", required=True, type=int)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    try:
        start_date = datetime.fromisoformat(args.start).date()
        end_date = datetime.fromisoformat(args.end).date()
    except ValueError as exc:
        raise RuntimeError("start and end must be ISO dates (YYYY-MM-DD)") from exc
    if start_date >= end_date:
        raise RuntimeError("start must be before end")

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    run_id = f"issue-{args.issue}-{datetime.now(timezone.utc):%Y%m%dT%H%M%SZ}-{uuid.uuid4().hex[:8]}"
    queried_at = datetime.now(timezone.utc).isoformat()

    account_sql = """
      SELECT id::text AS account_id, institution, display_name,
             account_number_last4, entity_id::text AS entity_id
      FROM maat_bank_accounts
      ORDER BY institution, account_number_last4, display_name
    """
    accounts = run_sql(account_sql)
    account_index = {(str(r.get("institution")), str(r.get("account_number_last4"))): r for r in accounts}
    missing = sorted(REQUIRED_ACCOUNTS - set(account_index))
    if missing:
        raise RuntimeError(f"Required MAAT accounts missing: {missing}")

    account_ids = [account_index[k]["account_id"] for k in REQUIRED_ACCOUNTS]
    id_list = ",".join("'%s'" % str(v).replace("'", "''") for v in account_ids)
    transactions = run_sql(f"""
      SELECT t.*, b.institution, b.display_name AS account_name,
             b.account_number_last4
      FROM maat_transactions t
      JOIN maat_bank_accounts b ON b.id=t.account_id
      WHERE t.posted_at >= '{args.start}'::date
        AND t.posted_at < '{args.end}'::date
        AND t.is_estimate=false
        AND t.account_id::text IN ({id_list})
      ORDER BY t.posted_at, t.account_id, t.id
    """)
    sources = run_sql(f"""
      SELECT sr.source_id::text, sr.filename, sr.provider, sr.bank,
             sr.account_id::text, sr.account_label, sr.account_number_last4,
             sr.txn_count, sr.status, sr.sha256,
             sr.statement_period_start, sr.statement_period_end, sr.created_at
      FROM maat_source_registry sr
      WHERE sr.account_id::text IN ({id_list})
        AND COALESCE(sr.statement_period_end, '{args.end}'::date) >= '{args.start}'::date
        AND COALESCE(sr.statement_period_start, '{args.start}'::date) < '{args.end}'::date
      ORDER BY sr.bank, sr.account_number_last4, sr.statement_period_start, sr.filename
    """)

    # Additional accounts needed to reconcile transfers, repayments, refunds or loans.
    additional = run_sql(f"""
      WITH selected AS (
        SELECT id, account_id, posted_at, amount, description, vendor
        FROM maat_transactions
        WHERE posted_at >= '{args.start}'::date AND posted_at < '{args.end}'::date
          AND is_estimate=false AND account_id::text IN ({id_list})
      )
      SELECT DISTINCT b.id::text AS account_id, b.institution, b.display_name,
             b.account_number_last4,
             CASE WHEN b.display_name ILIKE '%loan%' THEN 'loan_reconciliation'
                  WHEN b.display_name ILIKE '%credit%' OR b.institution='Amex' THEN 'card_repayment_reconciliation'
                  ELSE 'transfer_or_refund_reconciliation' END AS reconciliation_role
      FROM maat_transactions t
      JOIN maat_bank_accounts b ON b.id=t.account_id
      JOIN selected s ON ABS(ABS(t.amount)-ABS(s.amount)) < 0.01
                     AND t.posted_at BETWEEN s.posted_at - INTERVAL '5 day' AND s.posted_at + INTERVAL '5 day'
                     AND t.account_id <> s.account_id
      WHERE t.posted_at >= '{args.start}'::date AND t.posted_at < '{args.end}'::date
        AND t.is_estimate=false
      ORDER BY b.institution, b.account_number_last4
    """)

    counts: dict[str, int] = {}
    for row in transactions:
        key = f"{row.get('institution')} {row.get('account_number_last4')}"
        counts[key] = counts.get(key, 0) + 1

    summary_rows = []
    for key in sorted(REQUIRED_ACCOUNTS):
        acct = account_index[key]
        label = f"{key[0]} {key[1]}"
        tx = [r for r in transactions if str(r.get("institution")) == key[0] and str(r.get("account_number_last4")) == key[1]]
        summary_rows.append({
            "institution": key[0], "account_last4": key[1],
            "account_name": acct.get("display_name"), "transaction_count": len(tx),
            "debits": round(sum(float(r.get("amount") or 0) for r in tx if float(r.get("amount") or 0) < 0), 2),
            "credits": round(sum(float(r.get("amount") or 0) for r in tx if float(r.get("amount") or 0) > 0), 2),
            "net": round(sum(float(r.get("amount") or 0) for r in tx), 2),
            "first_date": min((str(r.get("posted_at")) for r in tx), default=""),
            "last_date": max((str(r.get("posted_at")) for r in tx), default=""),
        })
    for row in additional:
        summary_rows.append({
            "institution": row.get("institution"), "account_last4": row.get("account_number_last4"),
            "account_name": row.get("display_name"), "transaction_count": "",
            "debits": "", "credits": "", "net": "", "first_date": "", "last_date": "",
            "reconciliation_role": row.get("reconciliation_role"),
        })

    write_csv(output_dir / OUTPUTS[0], summary_rows)
    write_csv(output_dir / OUTPUTS[1], sources)
    write_csv(output_dir / OUTPUTS[2], transactions)

    # Reconciliation-specific datasets are generated by SQL so the runtime remains the source of truth.
    queries = {
      OUTPUTS[3]: f"SELECT bank, account_label, account_number_last4, statement_period_start, statement_period_end, status, filename FROM maat_source_registry WHERE account_id::text IN ({id_list}) AND COALESCE(statement_period_end,'{args.end}'::date)>='{args.start}'::date AND COALESCE(statement_period_start,'{args.start}'::date)<'{args.end}'::date ORDER BY bank,account_number_last4,statement_period_start",
      OUTPUTS[4]: f"SELECT b.institution,b.display_name,b.account_number_last4,MIN(t.posted_at) first_date,MAX(t.posted_at) last_date,ROUND(SUM(CASE WHEN t.amount<0 THEN t.amount ELSE 0 END)::numeric,2) debits,ROUND(SUM(CASE WHEN t.amount>0 THEN t.amount ELSE 0 END)::numeric,2) credits,ROUND(SUM(t.amount)::numeric,2) net FROM maat_transactions t JOIN maat_bank_accounts b ON b.id=t.account_id WHERE t.posted_at>='{args.start}'::date AND t.posted_at<'{args.end}'::date AND t.is_estimate=false AND t.account_id::text IN ({id_list}) GROUP BY b.id,b.institution,b.display_name,b.account_number_last4 ORDER BY b.institution,b.account_number_last4",
      OUTPUTS[5]: f"WITH x AS (SELECT t.id,t.account_id,t.posted_at,t.amount,t.description,b.institution,b.account_number_last4 FROM maat_transactions t JOIN maat_bank_accounts b ON b.id=t.account_id WHERE t.posted_at>='{args.start}'::date AND t.posted_at<'{args.end}'::date AND t.is_estimate=false) SELECT a.id::text debit_id,c.id::text credit_id,a.posted_at debit_date,c.posted_at credit_date,a.institution debit_bank,a.account_number_last4 debit_last4,c.institution credit_bank,c.account_number_last4 credit_last4,a.amount debit_amount,c.amount credit_amount,a.description debit_description,c.description credit_description FROM x a JOIN x c ON a.amount<0 AND c.amount>0 AND ABS(a.amount+c.amount)<0.01 AND a.account_id<>c.account_id AND c.posted_at BETWEEN a.posted_at-INTERVAL '5 day' AND a.posted_at+INTERVAL '5 day' ORDER BY a.posted_at,a.id",
      OUTPUTS[6]: f"SELECT * FROM ({'SELECT 1 AS placeholder WHERE false'}) q",
      OUTPUTS[7]: f"SELECT * FROM ({'SELECT 1 AS placeholder WHERE false'}) q",
      OUTPUTS[8]: f"SELECT COALESCE(NULLIF(TRIM(vendor),''),NULLIF(TRIM(description),''),'UNKNOWN') supplier_raw,UPPER(REGEXP_REPLACE(COALESCE(NULLIF(TRIM(vendor),''),NULLIF(TRIM(description),''),'UNKNOWN'),'[^A-Za-z0-9 ]','','g')) supplier_normalised,COUNT(*) transaction_count,ROUND(SUM(amount)::numeric,2) net_amount FROM maat_transactions WHERE posted_at>='{args.start}'::date AND posted_at<'{args.end}'::date AND is_estimate=false AND account_id::text IN ({id_list}) GROUP BY 1,2 ORDER BY COUNT(*) DESC,1",
      OUTPUTS[9]: f"SELECT t.id::text,t.posted_at,b.institution,b.account_number_last4,b.display_name AS account_name,t.amount,t.vendor,t.description,t.category,t.source_id::text FROM maat_transactions t JOIN maat_bank_accounts b ON b.id=t.account_id WHERE t.posted_at>='{args.start}'::date AND t.posted_at<'{args.end}'::date AND t.is_estimate=false AND t.amount<0 AND t.account_id::text IN ({id_list}) ORDER BY t.posted_at,t.id",
      OUTPUTS[10]: f"SELECT t.id::text,t.posted_at,b.institution,b.account_number_last4,b.display_name AS account_name,t.amount,t.vendor,t.description,t.category,t.source_id::text FROM maat_transactions t JOIN maat_bank_accounts b ON b.id=t.account_id WHERE t.posted_at>='{args.start}'::date AND t.posted_at<'{args.end}'::date AND t.is_estimate=false AND t.amount<0 AND (b.entity_id IS NULL OR b.display_name ILIKE '%personal%' OR b.display_name ILIKE '%offset%') ORDER BY t.posted_at,t.id",
      OUTPUTS[11]: f"SELECT t.id::text,t.posted_at,b.institution,b.account_number_last4,b.display_name AS account_name,t.amount,t.vendor,t.description,CASE WHEN t.description ILIKE '%transfer%' THEN 'transfer' WHEN t.description ILIKE '%payment%' AND (b.institution='Amex' OR b.display_name ILIKE '%credit%') THEN 'card_repayment' WHEN b.display_name ILIKE '%loan%' THEN 'loan_movement' ELSE 'review_required' END exclusion_reason FROM maat_transactions t JOIN maat_bank_accounts b ON b.id=t.account_id WHERE t.posted_at>='{args.start}'::date AND t.posted_at<'{args.end}'::date AND t.is_estimate=false AND (t.description ILIKE '%transfer%' OR t.description ILIKE '%payment%' OR b.display_name ILIKE '%loan%') ORDER BY t.posted_at,t.id",
    }
    for filename, sql in queries.items():
        write_csv(output_dir / filename, run_sql(sql))

    # Derive exact Amex repayment and refund pairs from the full transfer set in Python.
    with (output_dir / OUTPUTS[5]).open(newline="", encoding="utf-8") as fh:
        pairs = list(csv.DictReader(fh))
    amex_pairs = [r for r in pairs if r.get("debit_bank") == "Amex" or r.get("credit_bank") == "Amex"]
    write_csv(output_dir / OUTPUTS[6], amex_pairs, list(pairs[0].keys()) if pairs else [])
    refunds = []
    for a in transactions:
        for b in transactions:
            if a.get("id") == b.get("id") or a.get("account_id") != b.get("account_id"):
                continue
            if abs(float(a.get("amount") or 0) + float(b.get("amount") or 0)) < 0.01:
                refunds.append({"original_id": a.get("id"), "reversal_id": b.get("id"),
                                "original_date": a.get("posted_at"), "reversal_date": b.get("posted_at"),
                                "amount": a.get("amount"), "account_last4": a.get("account_number_last4")})
    write_csv(output_dir / OUTPUTS[7], refunds)

    hashes = {name: sha256(output_dir / name) for name in OUTPUTS}
    receipt = {
        "run_id": run_id, "issue": args.issue, "period": {"start": args.start, "end_exclusive": args.end},
        "queried_at_utc": queried_at, "runtime_source": "MAAT live via governed MAAT_SQL_EXECUTOR",
        "required_accounts": sorted([{"institution": x[0], "last4": x[1]} for x in REQUIRED_ACCOUNTS], key=lambda x:(x['institution'],x['last4'])),
        "additional_reconciliation_accounts": additional, "row_counts_by_account": counts,
        "outputs": [{"path": str(output_dir / name), "sha256": hashes[name]} for name in OUTPUTS],
        "validation": {
            "required_accounts_present": not missing,
            "transaction_rows_present": len(transactions) > 0,
            "source_rows_present": len(sources) > 0,
            "all_outputs_present": all((output_dir / name).is_file() for name in OUTPUTS),
        },
        "ready_for_publish": (not missing and len(transactions) > 0 and len(sources) > 0 and all((output_dir / name).is_file() for name in OUTPUTS)),
        "classification": "PARTIAL", "classification_reason": "Awaiting validation-gated S3 upload and independent readback verification"
    }
    receipt_path = output_dir / "fy2425_fresh_export_receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps({"run_id": run_id, "receipt": str(receipt_path)}, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(json.dumps({"status": "BLOCKED", "error": str(exc)}), file=sys.stderr)
        raise SystemExit(2)
