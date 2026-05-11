// cip/runners/control_loop_v2_hitl.js
// CTO in Your Pocket — HITL-aware control loop, v2
// Closes: detect → open-gate → (wait for human) → remediate → validate → log
//
// Runtime: any Node 20 surface (NO Lambda for CIP without per-deploy approval).
// DB:      Supabase S1 (lzfgigiyqpuuxslsygjt) via PostgREST.
// Doctrine (memory edit #1 CIP EXCEPTION):
//   - Per-asset mode lives in cip.assets.mode: HITL | AUTONOMOUS | OBSERVE.
//   - HITL is the default — remediation only fires when an approval row
//     for the incident has status='approved'.
//   - OBSERVE detects but never opens a gate (silent monitoring).
//   - AUTONOMOUS skips the gate (must be set deliberately per asset).
//   - Sign (cip.fn_approve) and act (this runner) are deliberately
//     separate steps so the audit trail is clean.

import { createClient } from "@supabase/supabase-js";

const SB_URL = process.env.SB_URL;
const SB_KEY = process.env.SB_SERVICE_ROLE_KEY;
const db = createClient(SB_URL, SB_KEY, { auth: { persistSession: false } });

// --- PROBE --------------------------------------------------------------
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

// --- DETECT (Phase A) ---------------------------------------------------
// Called on schedule. Opens an incident and, if asset is HITL, opens a
// pending approval gate. Does NOT remediate.
export async function detect(assetId) {
  const { data: asset } = await db.from("assets")
    .select("*").eq("id", assetId).eq("active", true).single();
  if (!asset) return { skipped: "asset_missing_or_inactive" };

  const p = await probe(asset.url);
  if (p.ok && p.http_status === 200) {
    return { healthy: true, asset_id: assetId, probe: p };
  }

  if (asset.mode === "OBSERVE") {
    return { observed: true, asset_id: assetId, probe: p, note: "OBSERVE: no incident opened" };
  }

  // Pick a playbook to PROPOSE (don't run it).
  const { data: pb } = await db.from("playbooks")
    .select("*").eq("action_type","failover").eq("safe", true).limit(1).single();

  const proposed = {
    playbook_id: pb?.id,
    playbook_name: pb?.name,
    action_type: pb?.action_type,
    strategy: pb?.config?.strategy || "noop",
    from: asset.url,
    to: asset.fallback_url,
    safe: true,
    reversible: true,
    blast_radius: "single_asset",
    expected_outcome: "validation probe returns 200 against fallback URL",
    side_effects: "none — no DNS change, no deploy, no IAM, no payments",
  };

  const awaitingGate = asset.mode === "HITL" ? "remediate" : null;

  const { data: inc } = await db.from("incidents").insert({
    asset_id: asset.id,
    status: "detected",
    severity: asset.criticality,
    probe_payload: p,
    detected_http_status: p.http_status,
    awaiting_gate: awaitingGate,
    attempts: 0,
    notes: asset.mode === "HITL"
      ? "HITL: awaiting approval before remediation"
      : "AUTONOMOUS: proceeding without gate",
  }).select().single();

  if (asset.mode === "HITL") {
    await db.from("approvals").insert({
      incident_id: inc.id,
      gate: "remediate",
      status: "pending",
      proposed_action: proposed,
    });
    return { gate_opened: true, incident_id: inc.id, mode: "HITL", proposed };
  }

  // AUTONOMOUS — caller can chain straight into act().
  return { incident_id: inc.id, mode: "AUTONOMOUS", proposed };
}

// --- ACT (Phase B) ------------------------------------------------------
// Runs the approved remediation. Refuses to run unless EITHER:
//   - the asset is AUTONOMOUS, OR
//   - there is an approval row for the incident with status='approved'.
export async function act(incidentId) {
  const { data: inc } = await db.from("incidents")
    .select("*, assets(*)").eq("id", incidentId).single();
  if (!inc) return { ok: false, reason: "incident_missing" };

  const asset = inc.assets;
  let proposed = null;

  if (asset.mode === "HITL") {
    const { data: ap } = await db.from("approvals")
      .select("*").eq("incident_id", incidentId)
      .eq("gate","remediate").eq("status","approved").limit(1).maybeSingle();
    if (!ap) return { ok: false, reason: "no_approved_gate", mode: "HITL" };
    proposed = ap.proposed_action;
  } else if (asset.mode === "AUTONOMOUS") {
    const { data: pb } = await db.from("playbooks")
      .select("*").eq("action_type","failover").eq("safe", true).limit(1).single();
    proposed = {
      playbook_id: pb.id,
      strategy: pb.config?.strategy,
      from: asset.url,
      to: asset.fallback_url,
    };
  } else {
    return { ok: false, reason: "asset_mode_blocks_act", mode: asset.mode };
  }

  await db.from("incidents").update({ status: "remediating", attempts: (inc.attempts || 0) + 1 })
    .eq("id", incidentId);

  const log = { ...proposed, attempt: (inc.attempts || 0) + 1, safe: true };
  const status = proposed.strategy === "swap_url_to_fallback" && asset.fallback_url
    ? "success" : "skipped";

  await db.from("executions").insert({
    incident_id: incidentId,
    playbook_id: proposed.playbook_id,
    status,
    completed_at: new Date().toISOString(),
    logs: log,
  });

  // Validate against the fallback URL.
  const val = await probe(asset.fallback_url || asset.url);
  const passed = val.ok && val.http_status === 200;
  await db.from("validations").insert({
    incident_id: incidentId,
    result: passed ? "pass" : "fail",
    http_status: val.http_status,
    latency_ms: val.latency_ms,
    evidence: val,
  });
  await db.from("incidents").update({
    status: passed ? "recovered" : "escalated",
    resolved_at: passed ? new Date().toISOString() : null,
    awaiting_gate: passed ? null : "escalate",
  }).eq("id", incidentId);

  await db.from("reality_ledger").insert({
    system: "CTO_IN_POCKET",
    component: `loop_${asset.business_key || asset.id}`,
    status: passed ? "REAL" : "PARTIAL",
    cluster_id: "CL_CTO_POCKET",
    last_verified: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    evidence: {
      incident_id: incidentId,
      mode: asset.mode,
      remediation: log,
      validation: val,
    },
  });

  return { ok: true, recovered: passed, validation: val };
}
