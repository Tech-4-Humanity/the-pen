"""
tradie-intake-handler — entry point for the AI Tradies operating system.

Accepts an inbound enquiry (phone form, web form, SMS gateway, etc.),
writes a tradie_jobs row + tradie_events row to Supabase via the existing
run_sql RPC, and returns the created job_id.

Bridge contract:
  Triggered direct via Function URL or via API Gateway, with JSON body:
    {
      "business_id":     "<uuid>",            # required — the tradie business this enquiry belongs to
      "customer":        {                     # optional — created if not present
        "full_name": str, "phone": str, "email": str,
        "address": str, "suburb": str, "customer_type": "residential"|"commercial"
      },
      "customer_id":     "<uuid>",            # optional — alternative to customer block
      "job_type":        str,                  # required — free text (job_type_classifier later normalises)
      "description":     str,                  # optional
      "urgency":         "low"|"normal"|"urgent"|"emergency",   # default normal
      "source_channel":  "phone"|"web"|"sms"|"facebook"|"google"|"referral"|"other",
      "quoted_amount":   number                # optional, usually populated later by WRITE.quote_generator
    }

Returns 200 with {ok:true, job_id, customer_id, created_at} on success.
"""
import json
import os
import urllib.request
import urllib.error
import uuid

SUPABASE_URL  = os.environ.get("SUPABASE_URL", "https://lzfgigiyqpuuxslsygjt.supabase.co")
SUPABASE_KEY  = os.environ["SUPABASE_SERVICE_ROLE_KEY"]  # required, not a default
RUN_SQL_RPC   = f"{SUPABASE_URL.rstrip('/')}/rest/v1/rpc/run_sql"

VALID_URGENCY = {"low", "normal", "urgent", "emergency"}
VALID_CHANNEL = {"phone", "web", "sms", "facebook", "google", "referral", "other"}


def _esc(v):
    """Defensive SQL string escape. We only use this for VALUES inside literals
    because run_sql does not accept parameterised queries."""
    if v is None:
        return "null"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def _run_sql(sql: str) -> dict:
    payload = json.dumps({"query": sql}).encode("utf-8")
    req = urllib.request.Request(
        RUN_SQL_RPC,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=10) as r:
        body = r.read().decode("utf-8")
        return json.loads(body) if body else {}


def _resolve_customer(business_id, customer_block, customer_id):
    if customer_id:
        return customer_id
    if not customer_block:
        customer_block = {}
    cid = str(uuid.uuid4())
    sql = (
        "insert into public.tradie_customers "
        "(id, business_id, full_name, phone, email, address, suburb, customer_type) "
        "values ("
        f"{_esc(cid)}, {_esc(business_id)}, "
        f"{_esc(customer_block.get('full_name'))}, "
        f"{_esc(customer_block.get('phone'))}, "
        f"{_esc(customer_block.get('email'))}, "
        f"{_esc(customer_block.get('address'))}, "
        f"{_esc(customer_block.get('suburb'))}, "
        f"{_esc(customer_block.get('customer_type') or 'residential')}"
        ") returning id"
    )
    _run_sql(sql)
    return cid


def _create_job(business_id, customer_id, job_type, description, urgency, source_channel, quoted_amount):
    jid = str(uuid.uuid4())
    sql = (
        "insert into public.tradie_jobs "
        "(id, business_id, customer_id, job_type, status, urgency, source_channel, description, quoted_amount) "
        "values ("
        f"{_esc(jid)}, {_esc(business_id)}, {_esc(customer_id)}, {_esc(job_type)}, "
        "'new', "
        f"{_esc(urgency)}, {_esc(source_channel)}, {_esc(description)}, {_esc(quoted_amount)}"
        ") returning id, created_at"
    )
    _run_sql(sql)
    return jid


def _log_event(business_id, job_id, event_type, payload):
    sql = (
        "insert into public.tradie_events (business_id, job_id, event_type, payload, source) values ("
        f"{_esc(business_id)}, {_esc(job_id)}, {_esc(event_type)}, "
        f"'{json.dumps(payload).replace(chr(39), chr(39)+chr(39))}'::jsonb, "
        "'tradie-intake-handler')"
    )
    _run_sql(sql)


def _bad_request(msg):
    return {"statusCode": 400, "headers": {"Content-Type": "application/json"}, "body": json.dumps({"ok": False, "error": msg})}


def handler(event, context):
    raw = event.get("body") if isinstance(event, dict) and "body" in event else event
    if isinstance(raw, str):
        try:
            body = json.loads(raw)
        except json.JSONDecodeError:
            return _bad_request("body is not valid JSON")
    elif isinstance(raw, dict):
        body = raw
    else:
        return _bad_request("body is missing")

    business_id = body.get("business_id")
    job_type    = body.get("job_type")
    if not business_id:
        return _bad_request("business_id is required")
    if not job_type:
        return _bad_request("job_type is required")

    urgency = body.get("urgency", "normal")
    if urgency not in VALID_URGENCY:
        return _bad_request(f"urgency must be one of {sorted(VALID_URGENCY)}")

    source_channel = body.get("source_channel", "web")
    if source_channel not in VALID_CHANNEL:
        return _bad_request(f"source_channel must be one of {sorted(VALID_CHANNEL)}")

    try:
        customer_id = _resolve_customer(business_id, body.get("customer"), body.get("customer_id"))
        job_id      = _create_job(
            business_id, customer_id, job_type,
            body.get("description"), urgency, source_channel,
            body.get("quoted_amount"),
        )
        _log_event(business_id, job_id, "job.created", {
            "source_channel": source_channel,
            "urgency": urgency,
            "job_type": job_type,
            "intake_handler_version": "1.0.0",
        })
    except urllib.error.HTTPError as e:
        return {
            "statusCode": 502,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"ok": False, "error": f"supabase error: {e.code} {e.reason}"}),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"ok": False, "error": f"unhandled: {type(e).__name__}: {e}"}),
        }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"ok": True, "job_id": job_id, "customer_id": customer_id}),
    }
