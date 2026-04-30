// bridgeSql.mjs — canonical bridge client for troy-sql-executor.
// Fail-fast on command:null, non-OK HTTP, and PostgREST/pg error envelopes.
// Mirrors bridge_sql.py contract.

const BRIDGE_URL_DEFAULT =
  "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke";

const PG_FIELDS = ["code", "message", "details", "hint"];

export class BridgeSqlError extends Error {
  constructor({ where, http_status, code, message, details, hint, sql, raw }) {
    const tag = `BridgeSqlError[${where || "?"}]`;
    const parts = [tag];
    if (http_status != null) parts.push(`http=${http_status}`);
    if (code) parts.push(`code=${code}`);
    if (message) parts.push(`msg=${message}`);
    if (details) parts.push(`details=${details}`);
    if (hint) parts.push(`hint=${hint}`);
    super(parts.join(" | "));
    this.name = "BridgeSqlError";
    this.where = where;
    this.http_status = http_status;
    this.code = code;
    this.pgMessage = message;
    this.details = details;
    this.hint = hint;
    this.sql = sql;
    this.raw = raw;
  }
  toJSON() {
    return {
      name: this.name,
      where: this.where,
      http_status: this.http_status,
      code: this.code,
      message: this.pgMessage,
      details: this.details,
      hint: this.hint,
      sql: this.sql,
    };
  }
}

function pickPg(obj) {
  if (!obj || typeof obj !== "object") return {};
  const out = {};
  for (const f of PG_FIELDS) if (obj[f] != null) out[f] = obj[f];
  return out;
}

function trunc(s, n = 240) {
  return s.length <= n ? s : s.slice(0, n) + "...[truncated]";
}

/**
 * runSql(sql, opts?) -> { rows, command, rowcount, raw }
 * Throws BridgeSqlError on any failure, including command:null.
 */
export async function runSql(sql, opts = {}) {
  const bridgeUrl = opts.bridgeUrl || process.env.BRIDGE_URL || BRIDGE_URL_DEFAULT;
  const apiKey = opts.apiKey || process.env.BRIDGE_API_KEY;
  const fn = opts.fn || "troy-sql-executor";
  const timeoutMs = opts.timeoutMs ?? 30000;

  if (!apiKey) {
    throw new BridgeSqlError({
      where: "config",
      message: "BRIDGE_API_KEY not set",
    });
  }

  const ctl = new AbortController();
  const timer = setTimeout(() => ctl.abort(), timeoutMs);

  let r, rawText;
  try {
    r = await fetch(bridgeUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-api-key": apiKey },
      body: JSON.stringify({ fn, payload: { sql } }),
      signal: ctl.signal,
    });
    rawText = await r.text();
  } catch (e) {
    throw new BridgeSqlError({
      where: "transport",
      message: `${e.name}: ${e.message}`,
      sql: trunc(sql),
    });
  } finally {
    clearTimeout(timer);
  }

  // Non-2xx — try to surface pg fields from body
  if (!r.ok) {
    let parsed = {};
    try { parsed = JSON.parse(rawText); } catch { /* ignore */ }
    const pg = pickPg(parsed);
    throw new BridgeSqlError({
      where: "http",
      http_status: r.status,
      message: pg.message || `HTTP ${r.status}`,
      code: pg.code,
      details: pg.details,
      hint: pg.hint,
      sql: trunc(sql),
      raw: { body: rawText.slice(0, 4000) },
    });
  }

  let outer;
  try { outer = JSON.parse(rawText); }
  catch (e) {
    throw new BridgeSqlError({
      where: "parse_outer",
      http_status: r.status,
      message: `non-JSON bridge response: ${e.message}`,
      sql: trunc(sql),
      raw: { body: rawText.slice(0, 4000) },
    });
  }

  // Unwrap API Gateway envelope { statusCode, body }
  let inner = outer;
  if (outer && typeof outer === "object" && "statusCode" in outer && "body" in outer) {
    if (outer.statusCode >= 400) {
      const pg = pickPg(outer);
      throw new BridgeSqlError({
        where: "bridge_envelope",
        http_status: outer.statusCode,
        message: pg.message || `bridge statusCode=${outer.statusCode}`,
        code: pg.code, details: pg.details, hint: pg.hint,
        sql: trunc(sql), raw: outer,
      });
    }
    try {
      inner = typeof outer.body === "string" ? JSON.parse(outer.body) : outer.body;
    } catch (e) {
      throw new BridgeSqlError({
        where: "parse_inner",
        message: `non-JSON Lambda body: ${e.message}`,
        sql: trunc(sql), raw: outer,
      });
    }
  }

  if (!inner || typeof inner !== "object") {
    throw new BridgeSqlError({
      where: "shape",
      message: "Lambda body is not an object",
      sql: trunc(sql), raw: { body: inner },
    });
  }

  // Explicit error fields (incl. legacy `sql_error` mask)
  const explicit = inner.error ?? inner.sql_error;
  if (explicit) {
    const pg = typeof explicit === "object"
      ? { ...pickPg(explicit), ...pickPg(inner) }
      : pickPg(inner);
    const msg = typeof explicit === "object"
      ? (explicit.message || JSON.stringify(explicit))
      : String(explicit);
    throw new BridgeSqlError({
      where: "lambda_error",
      message: pg.message || msg,
      code: pg.code, details: pg.details, hint: pg.hint,
      raw: inner, sql: trunc(sql),
    });
  }

  // THE FIX: command:null is failure
  const cmd = inner.command;
  if (cmd == null || cmd === "" || cmd === "null") {
    const pg = pickPg(inner);
    throw new BridgeSqlError({
      where: "command_null",
      message: pg.message || "command is null (pg execution did not produce a tag)",
      code: pg.code,
      details: pg.details,
      hint: pg.hint || "split multi-statement SQL; BEGIN/COMMIT chains not supported",
      raw: inner, sql: trunc(sql),
    });
  }

  if (!("rows" in inner)) {
    throw new BridgeSqlError({
      where: "shape",
      message: "response missing `rows` field",
      raw: inner, sql: trunc(sql),
    });
  }

  const rows = inner.rows ?? [];
  return {
    rows,
    command: String(cmd).toUpperCase(),
    rowcount: inner.rowcount ?? (Array.isArray(rows) ? rows.length : 0),
    raw: inner,
  };
}
