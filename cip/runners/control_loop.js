// cip/runners/control_loop.js
// CTO in Your Pocket — reference control loop (Solo CTO Control Layer)
// Closes: detect -> decide -> remediate -> validate -> log -> escalate
//
// Runtime: any Node 20 surface (Lambda, edge, local).
// DB:      Supabase S1 (lzfgigiyqpuuxslsygjt) via PostgREST or run_sql RPC.
// Doctrine:
//   - One asset, one loop, one ledger row per pass.
//   - REAL only when validation = pass. PARTIAL otherwise. Never PRETEND.
//   - No alerts unless validation fails AND severity in (P0, P1).
//
// First wired: 2026-05-07 against asset 19ad0634-1fdd-41eb-a0ef-ee142500eeb2
// (consentx.org) — see handoffs/CTO_In_Your_Pocket_Pilot_Receipt_20260507.md

import { createClient } from "@supabase/supabase-js";

const SB_URL = process.env.SB_URL;
const SB_KEY = process.env.SB_SERVICE_ROLE_KEY;
const db = createClient(SB_URL, SB_KEY, { auth: { persistSession: false } });

// --- 1. PROBE -----------------------------------------------------------
async function probe(url, timeoutMs = 8000) {
  const t0 = Date.now();
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: ctrl.signal });
    return {
      url,
      http_status: res.status,
      ok: res.ok,
      latency_ms: Date.now() - t0,
      checked_at: new Date().toISOString(),
    };
  } catch (e) {
    return {
      url,
      http_status: 0,
      ok: false,
      latency_ms: Date.now() - t0,
      error: String(e.message || e),
      checked_at: new Date().toISOString(),
    };
  } finally {
    clearTimeout(timer);
  }
}

// --- 2. INCIDENT --------------------------------------------------------
async function openIncident(asset, probeResult) {
  const { data, error } = await db
    .from("incidents")
    .insert({
      asset_id: asset.id,
      status: "detected",
      severity: asset.criticality,
      probe_payload: probeResult,
      detected_http_status: probeResult.http_status,
      attempts: 1,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

// --- 3. REMEDIATE -------------------------------------------------------
async function remediate(asset, incident) {
  const { data: pb } = await db
    .from("playbooks")
    .select("*")
    .eq("action_type", "failover")
    .eq("safe", true)
    .limit(1)
    .single();

  const action = pb?.config?.strategy || "noop";
  let log = { action, attempt: 1, safe: true };
  let status = "skipped";

  if (action === "swap_url_to_fallback" && asset.fallback_url) {
    log.from = asset.url;
    log.to = asset.fallback_url;
    status = "success";
  }

  const { data: ex } = await db
    .from("executions")
    .insert({
      incident_id: incident.id,
      playbook_id: pb.id,
      status,
      completed_at: new Date().toISOString(),
      logs: log,
    })
    .select()
    .single();

  return { execution: ex, playbook: pb, validate_url: asset.fallback_url };
}

// --- 4. VALIDATE --------------------------------------------------------
async function validate(asset, incident, validateUrl) {
  const result = await probe(validateUrl);
  const passed = result.ok && result.http_status === 200;
  await db.from("validations").insert({
    incident_id: incident.id,
    result: passed ? "pass" : "fail",
    http_status: result.http_status,
    latency_ms: result.latency_ms,
    evidence: result,
  });
  await db
    .from("incidents")
    .update({
      status: passed ? "recovered" : "escalated",
      resolved_at: passed ? new Date().toISOString() : null,
    })
    .eq("id", incident.id);
  return { passed, result };
}

// --- 5. LEDGER ----------------------------------------------------------
async function logReality(asset, incident, exec, val) {
  const status = val.passed ? "REAL" : "PARTIAL";
  await db.from("reality_ledger").insert({
    system: "CTO_IN_POCKET",
    component: `loop_${asset.business_key || asset.id}`,
    status,
    cluster_id: "CL_CTO_POCKET",
    last_verified: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    evidence: {
      asset_id: asset.id,
      incident_id: incident.id,
      execution_id: exec.execution?.id,
      probe: incident.probe_payload,
      remediation: exec.execution?.logs,
      validation: val.result,
    },
  });
}

// --- 6. ESCALATE (low-noise) -------------------------------------------
function shouldEscalate(asset, val) {
  return !val.passed && (asset.criticality === "P0" || asset.criticality === "P1");
}

// --- 7. LOOP ------------------------------------------------------------
export async function controlLoop(assetId) {
  const { data: asset } = await db
    .from("assets")
    .select("*")
    .eq("id", assetId)
    .eq("active", true)
    .single();
  if (!asset) return { skipped: "asset_not_found_or_inactive" };

  const probeResult = await probe(asset.url);
  if (probeResult.ok && probeResult.http_status === 200) {
    return { healthy: true, asset_id: assetId, probe: probeResult };
  }

  const incident = await openIncident(asset, probeResult);
  const exec = await remediate(asset, incident);
  const val = await validate(asset, incident, exec.validate_url || asset.url);
  await logReality(asset, incident, exec, val);

  return {
    incident_id: incident.id,
    recovered: val.passed,
    escalate: shouldEscalate(asset, val),
    probe: probeResult,
    validation: val.result,
  };
}
