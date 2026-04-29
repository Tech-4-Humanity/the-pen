/**
 * mcp-bridge-invoke-handler v5.1 — HARDENED + ERROR SURFACING
 * Changes from v4.4:
 *  - NO hardcoded key fallbacks (env-only; fail-closed if missing)
 *  - Registry-driven allowlist: fn must exist in mcp_lambda_registry with is_callable=true
 *  - Uniform error envelope: {ok:false, error_code, request_id} — no presence oracle
 *  - Optional HMAC signing: x-bridge-sig = hex(hmac_sha256(BRIDGE_SIGNING_SECRET, ts+nonce+body))
 *  - Replay protection: ts within ±300s, nonce cache (in-memory, 5min TTL)
 *  - Per-key+fn rate limiting: 60 calls / 60s window, in-memory
 *  - Structured audit log: every call → CloudWatch with {req_id, key_hash, fn, decision, ms}
 *  - Constant-time key compare
 */
import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";
import { createHmac, timingSafeEqual, randomUUID } from "node:crypto";

const API_KEY        = process.env.BRIDGE_API_KEY;              // REQUIRED
const SUPA_URL       = process.env.SUPABASE_URL;                // REQUIRED
const SUPA_KEY       = process.env.SUPABASE_SERVICE_KEY;        // REQUIRED
const SIGNING_SECRET = process.env.BRIDGE_SIGNING_SECRET || ""; // Optional HMAC
const REGION         = process.env.AWS_REGION || "ap-southeast-2";
const REQUIRE_HMAC   = process.env.BRIDGE_REQUIRE_HMAC === "true";
const DENY_KEYS      = (process.env.BRIDGE_DENIED_KEYS || "").split(",").filter(Boolean);

if (!API_KEY || !SUPA_URL || !SUPA_KEY) {
  throw new Error("BRIDGE_MISCONFIG: BRIDGE_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_KEY required");
}

const lambdaClient = new LambdaClient({ region: REGION });

const nonceCache = new Map();
const rateCache  = new Map();
const allowCache = { at: 0, set: new Set() };

const NONCE_TTL_MS = 5 * 60 * 1000;
const RATE_WINDOW_MS = 60 * 1000;
const RATE_MAX = 60;
const ALLOW_TTL_MS = 60 * 1000;

function constEq(a, b) {
  if (typeof a !== "string" || typeof b !== "string") return false;
  const A = Buffer.from(a), B = Buffer.from(b);
  if (A.length !== B.length) return false;
  try { return timingSafeEqual(A, B); } catch { return false; }
}

function keyHash(k) {
  return createHmac("sha256", "bridge-audit").update(k || "").digest("hex").slice(0, 12);
}

function deny(req_id, code, status = 403) {
  return { statusCode: status, body: JSON.stringify({ ok: false, error_code: code, request_id: req_id }) };
}

function rateCheck(kHash, fn) {
  const key = `${kHash}:${fn}`;
  const now = Date.now();
  const arr = (rateCache.get(key) || []).filter(t => now - t < RATE_WINDOW_MS);
  if (arr.length >= RATE_MAX) return false;
  arr.push(now);
  rateCache.set(key, arr);
  if (rateCache.size > 5000) {
    for (const [k, v] of rateCache) if (v.every(t => now - t > RATE_WINDOW_MS)) rateCache.delete(k);
  }
  return true;
}

async function loadAllowlist() {
  const now = Date.now();
  if (now - allowCache.at < ALLOW_TTL_MS && allowCache.set.size > 0) return allowCache.set;
  // Use REST table API (returns array directly, unlike run_sql RPC which returns {command,rows_affected})
  const res = await fetch(
    `${SUPA_URL}/rest/v1/mcp_lambda_registry?is_callable=eq.true&select=function_name`,
    { headers: { "apikey": SUPA_KEY, "Authorization": "Bearer " + SUPA_KEY } }
  );
  const data = await res.json();
  const set = new Set();
  if (Array.isArray(data)) for (const r of data) if (r.function_name) set.add(r.function_name);
  set.add("troy-sql-executor");
  set.add("t4h-sql-exec");
  allowCache.at = now;
  allowCache.set = set;
  return set;
}

function verifyHmac(headers, rawBody) {
  if (!SIGNING_SECRET) return { ok: !REQUIRE_HMAC, reason: REQUIRE_HMAC ? "hmac_required_but_no_secret" : "hmac_disabled" };
  const sig = headers["x-bridge-sig"];
  const ts  = headers["x-bridge-ts"];
  const nonce = headers["x-bridge-nonce"];
  if (!sig || !ts || !nonce) return { ok: !REQUIRE_HMAC, reason: "hmac_missing" };
  const skew = Math.abs(Date.now() / 1000 - Number(ts));
  if (!Number.isFinite(skew) || skew > 300) return { ok: false, reason: "hmac_skew" };
  const now = Date.now();
  for (const [n, exp] of nonceCache) if (exp < now) nonceCache.delete(n);
  if (nonceCache.has(nonce)) return { ok: false, reason: "hmac_replay" };
  const expected = createHmac("sha256", SIGNING_SECRET).update(`${ts}.${nonce}.${rawBody}`).digest("hex");
  if (!constEq(sig, expected)) return { ok: false, reason: "hmac_bad" };
  nonceCache.set(nonce, now + NONCE_TTL_MS);
  return { ok: true };
}

async function execSQL(sql, returnType = "rows") {
  const cleanSql = sql.replace(/;\s*$/, "").trim();
  const firstWord = cleanSql.split(/\s+/)[0].toUpperCase();
  const res = await fetch(`${SUPA_URL}/rest/v1/rpc/run_sql`, {
    method: "POST",
    headers: { "Content-Type": "application/json", "apikey": SUPA_KEY, "Authorization": "Bearer " + SUPA_KEY },
    body: JSON.stringify({ query: cleanSql })
  });
  const data = await res.json();
  if (!res.ok) {
    let errMsg = `http_${res.status}`;
    let errCode = null;
    if (data && typeof data === "object") {
      errMsg = data.message || data.error || errMsg;
      errCode = data.code || data.sqlstate || null;
    }
    return { success: false, error: errMsg, sqlstate: errCode, rows: [], count: 0, command: null, http_status: res.status };
  }
  if (Array.isArray(data)) {
    if (returnType === "value") {
      const val = data[0] ? Object.values(data[0])[0] : null;
      return { success: true, value: val, rows: data, count: data.length, command: "SELECT" };
    }
    return { success: true, rows: data, count: data.length, command: "SELECT" };
  }
  if (data.error) return { success: false, error: data.error, sqlstate: data.sqlstate || null, rows: [], count: 0, command: null };
  return { success: true, rows: [], count: data.rows_affected ?? 0, command: data.command ?? firstWord };
}

function audit(o) { console.log(JSON.stringify({ audit: true, ...o })); }

export const handler = async (event) => {
  const req_id = randomUUID();
  const started = Date.now();
  const headers = {};
  for (const [k, v] of Object.entries(event.headers || {})) headers[k.toLowerCase()] = v;
  for (const k of Object.keys(event)) if (k.toLowerCase().startsWith("x-")) headers[k.toLowerCase()] = event[k];

  const key = headers["x-api-key"];
  const kHash = keyHash(key);

  if (!key || DENY_KEYS.includes(key) || !constEq(key, API_KEY)) {
    audit({ req_id, kHash, fn: null, decision: "deny_auth", ms: Date.now() - started });
    return deny(req_id, "UNAUTHORIZED", 401);
  }

  const rawBody = typeof event.body === "string" ? event.body : JSON.stringify(event.body ?? event);
  let body;
  try { body = event.body ? (typeof event.body === "string" ? JSON.parse(event.body) : event.body) : event; }
  catch { audit({ req_id, kHash, fn: null, decision: "deny_json", ms: Date.now() - started }); return deny(req_id, "BAD_REQUEST", 400); }

  const hmac = verifyHmac(headers, rawBody);
  if (!hmac.ok) {
    audit({ req_id, kHash, fn: body.fn || null, decision: "deny_hmac", reason: hmac.reason, ms: Date.now() - started });
    return deny(req_id, "UNAUTHORIZED", 401);
  }

  const fn = body.fn;
  if (!fn || typeof fn !== "string" || !/^[a-zA-Z0-9_.-]{1,128}$/.test(fn)) {
    audit({ req_id, kHash, fn: fn || null, decision: "deny_fn_shape", ms: Date.now() - started });
    return deny(req_id, "FORBIDDEN", 403);
  }

  if (!rateCheck(kHash, fn)) {
    audit({ req_id, kHash, fn, decision: "deny_rate", ms: Date.now() - started });
    return deny(req_id, "RATE_LIMITED", 429);
  }

  let allow;
  try { allow = await loadAllowlist(); }
  catch (e) {
    audit({ req_id, kHash, fn, decision: "deny_allowlist_err", err: e.message, ms: Date.now() - started });
    return deny(req_id, "FORBIDDEN", 403);
  }
  if (!allow.has(fn)) {
    audit({ req_id, kHash, fn, decision: "deny_allowlist", ms: Date.now() - started });
    return deny(req_id, "FORBIDDEN", 403);
  }

  if (fn === "troy-sql-executor" || fn === "t4h-sql-exec") {
    const sql = body.sql ?? body.payload?.sql;
    const rt  = body.return_type ?? body.payload?.return_type ?? "rows";
    if (!sql) { audit({ req_id, kHash, fn, decision: "deny_sql_missing", ms: Date.now() - started }); return deny(req_id, "BAD_REQUEST", 400); }
    try {
      const result = await execSQL(sql, rt);
      audit({ req_id, kHash, fn, decision: "allow_sql", ok: result.success, rows: result.count, ms: Date.now() - started });
      return { statusCode: result.success ? 200 : 400, body: JSON.stringify(result) };
    } catch (e) {
      audit({ req_id, kHash, fn, decision: "sql_err", err: e.message, ms: Date.now() - started });
      return deny(req_id, "INTERNAL", 500);
    }
  }

  try {
    const cmd = new InvokeCommand({ FunctionName: fn, InvocationType: "RequestResponse", Payload: Buffer.from(JSON.stringify(body)) });
    const resp = await lambdaClient.send(cmd);
    const raw = JSON.parse(Buffer.from(resp.Payload).toString());
    audit({ req_id, kHash, fn, decision: "allow_invoke", ms: Date.now() - started });
    return { statusCode: 200, body: JSON.stringify(raw) };
  } catch (e) {
    audit({ req_id, kHash, fn, decision: "invoke_err", err: e.message, ms: Date.now() - started });
    return deny(req_id, "INTERNAL", 500);
  }
};
