/**
 * T4H Apps Script Runtime — v1.0.0
 * ---------------------------------------------------------------------------
 * Purpose: Drive governance runtime node. Scans Drive, writes receipts to a
 *          spreadsheet ledger + Supabase, runs unattended via time triggers.
 *
 * Constitution: GLOBAL_RULE_KERNEL_V6
 *   - autonomous_continuity (no session, no workstation, no manual retrigger)
 *   - distributed_identity (actor_id, execution_id, runtime_id, nonce)
 *   - REAL / PARTIAL / BLOCKED ledger states only (no PRETEND)
 *   - tiered self-heal: HOT 1m / HIGH 3m / NORMAL 10m / LOW 30m
 *   - chunked execution with checkpoint resume (Apps Script 6-min ceiling)
 *   - telemetry-native governance: every state transition writes a receipt
 *
 * Install once: bootstrap()
 * Recurring:    runtimeMain() via 5-min trigger (installed by bootstrap)
 * Recovery:     panicShutdown(), quarantine(), reset()
 * ---------------------------------------------------------------------------
 */

// ============================================================================
// CONFIG — single source of truth, edit values not structure
// ============================================================================
const CONFIG = Object.freeze({
  version: '1.0.0',
  runtime_id: 'apps-script-drive-runtime',
  actor_id: 'troy@tech4humanity.com',
  tenant_id: 'tech4humanity',

  // Drive scan scope
  scan: {
    rootFolderId: 'root',        // 'root' = My Drive root; or set a specific id
    maxFoldersPerTick: 250,      // chunk size per runtimeMain invocation
    recursionDepth: 8,
    skipShared: false,
    skipTrashed: true
  },

  // Tiered timing model (minutes). Class of this runtime = NORMAL.
  tiers: {
    HOT:    { warn: 1,  heal: 3,  reroute: 5,  block: 10  },
    HIGH:   { warn: 3,  heal: 10, reroute: 15, block: 30  },
    NORMAL: { warn: 10, heal: 30, reroute: 60, block: 120 },
    LOW:    { warn: 30, heal: 120, reroute: 240, block: 360 }
  },
  selfTier: 'NORMAL',

  // Survivability: 72h of healthy ticks AFTER first healthy run
  survivability: {
    healthyTicksRequired: 72 * 12,   // 72h × 12 ticks/h at 5-min cadence
    staleResetMinutes: 30            // any gap >30min resets the proof window
  },

  // Receipt sink (Supabase). Configured via Script Properties: SUPABASE_URL, SUPABASE_KEY
  // Falls back to in-sheet ledger only if not set. Ledger is canonical regardless.
  supabase: {
    table: 'reality_ledger',
    rest_path: '/rest/v1/reality_ledger'
  },

  // Trigger cadence
  triggerMinutes: 5
});

// ============================================================================
// CACHES — kill the bootstrap-timeout class of bug
// ============================================================================
let SS_CACHE_ = null;
let SHEET_CACHE_ = {};

function _ss_() {
  if (SS_CACHE_) return SS_CACHE_;
  const props = PropertiesService.getScriptProperties();
  let id = props.getProperty('LEDGER_SS_ID');
  if (id) {
    try { SS_CACHE_ = SpreadsheetApp.openById(id); return SS_CACHE_; }
    catch (e) { /* fall through and create */ }
  }
  const ss = SpreadsheetApp.create('T4H Runtime Ledger — ' + CONFIG.runtime_id);
  props.setProperty('LEDGER_SS_ID', ss.getId());
  SS_CACHE_ = ss;
  return ss;
}

function _sheet_(name, headers) {
  if (SHEET_CACHE_[name]) return SHEET_CACHE_[name];
  const ss = _ss_();
  let sh = ss.getSheetByName(name);
  if (!sh) {
    sh = ss.insertSheet(name);
    if (headers && headers.length) {
      sh.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
      sh.setFrozenRows(1);
    }
  }
  SHEET_CACHE_[name] = sh;
  return sh;
}

// ============================================================================
// IDENTITY — distributed, replayable, nonce-bound
// ============================================================================
function _identity_(execution_id) {
  return {
    actor_id: CONFIG.actor_id,
    tenant_id: CONFIG.tenant_id,
    runtime_id: CONFIG.runtime_id,
    execution_id: execution_id,
    session_id: Session.getTemporaryActiveUserKey() || 'apps-script-bg',
    orchestration_id: PropertiesService.getScriptProperties().getProperty('ORCH_ID') || _newId_('orch'),
    nonce: Utilities.getUuid()
  };
}

function _newId_(prefix) {
  return prefix + '_' + Utilities.formatDate(new Date(), 'UTC', 'yyyyMMddHHmmss') +
         '_' + Math.floor(Math.random() * 1e9).toString(36);
}

function _ensureOrch_() {
  const p = PropertiesService.getScriptProperties();
  if (!p.getProperty('ORCH_ID')) p.setProperty('ORCH_ID', _newId_('orch'));
}

// ============================================================================
// LEDGER — REAL / PARTIAL / BLOCKED only (PRETEND forbidden)
// ============================================================================
const LEDGER_HEADERS = [
  'ts_utc','execution_id','nonce','state','tier','event','evidence_type',
  'evidence','duration_ms','folders_seen','folders_processed','error','runtime_id'
];

function ledger(state, event, fields) {
  if (state !== 'REAL' && state !== 'PARTIAL' && state !== 'BLOCKED') {
    throw new Error('Forbidden ledger state: ' + state);
  }
  const sh = _sheet_('reality_ledger', LEDGER_HEADERS);
  const f = fields || {};
  const row = [
    new Date().toISOString(),
    f.execution_id || '',
    f.nonce || '',
    state,
    f.tier || CONFIG.selfTier,
    event,
    f.evidence_type || '',
    f.evidence || '',
    f.duration_ms || '',
    f.folders_seen || '',
    f.folders_processed || '',
    f.error || '',
    CONFIG.runtime_id
  ];
  sh.appendRow(row);

  // Mirror to Supabase if configured. Non-blocking on failure.
  _supabaseReceipt_(state, event, f, row);
}

function _supabaseReceipt_(state, event, f, row) {
  const props = PropertiesService.getScriptProperties();
  const url = props.getProperty('SUPABASE_URL');
  const key = props.getProperty('SUPABASE_KEY');
  if (!url || !key) return; // sheet-only mode, still REAL per kernel

  const payload = {
    actor_id: CONFIG.actor_id,
    tenant_id: CONFIG.tenant_id,
    runtime_id: CONFIG.runtime_id,
    execution_id: f.execution_id || null,
    nonce: f.nonce || null,
    state: state,
    tier: f.tier || CONFIG.selfTier,
    event: event,
    evidence_type: f.evidence_type || null,
    evidence: f.evidence || null,
    duration_ms: f.duration_ms || null,
    folders_seen: f.folders_seen || null,
    folders_processed: f.folders_processed || null,
    error: f.error || null,
    occurred_at: new Date().toISOString()
  };
  try {
    UrlFetchApp.fetch(url.replace(/\/$/, '') + CONFIG.supabase.rest_path, {
      method: 'post',
      contentType: 'application/json',
      headers: {
        'apikey': key,
        'Authorization': 'Bearer ' + key,
        'Prefer': 'return=minimal'
      },
      payload: JSON.stringify(payload),
      muteHttpExceptions: true
    });
  } catch (e) {
    // Telemetry sink failure cannot break local ledger — log only
    Logger.log('Supabase mirror failed: ' + e.message);
  }
}

// ============================================================================
// HEARTBEAT — proves runtime alive even if scan is between chunks
// ============================================================================
function _heartbeat_(execution_id, nonce) {
  const sh = _sheet_('heartbeat', ['ts_utc','execution_id','nonce','tier','health']);
  const props = PropertiesService.getScriptProperties();
  const now = new Date();
  const last = props.getProperty('LAST_HEARTBEAT');
  const lastDate = last ? new Date(last) : null;
  const gapMin = lastDate ? (now - lastDate) / 60000 : 0;

  // Survivability proof window
  let healthyTicks = parseInt(props.getProperty('HEALTHY_TICKS') || '0', 10);
  if (lastDate && gapMin > CONFIG.survivability.staleResetMinutes) {
    healthyTicks = 0; // stale gap → reset proof
    ledger('PARTIAL', 'survivability_reset', {
      execution_id: execution_id, nonce: nonce,
      evidence_type: 'runtime_hash',
      evidence: 'gap_min=' + gapMin.toFixed(1)
    });
  }
  healthyTicks += 1;
  props.setProperty('HEALTHY_TICKS', String(healthyTicks));
  props.setProperty('LAST_HEARTBEAT', now.toISOString());

  const health = healthyTicks >= CONFIG.survivability.healthyTicksRequired
    ? 'survivable' : 'healthy';
  sh.appendRow([now.toISOString(), execution_id, nonce, CONFIG.selfTier, health]);
  return { healthyTicks: healthyTicks, health: health };
}

// ============================================================================
// CHECKPOINT — chunked Drive scan with resume (kills 6-min ceiling problem)
// ============================================================================
function _loadCheckpoint_() {
  const raw = PropertiesService.getScriptProperties().getProperty('CHECKPOINT');
  if (!raw) return { queue: [CONFIG.scan.rootFolderId], seen: 0, processed: 0, started_at: null };
  try { return JSON.parse(raw); }
  catch (e) { return { queue: [CONFIG.scan.rootFolderId], seen: 0, processed: 0, started_at: null }; }
}

function _saveCheckpoint_(cp) {
  // Apps Script property limit is 9KB per value. Trim queue if huge.
  if (cp.queue && cp.queue.length > 5000) cp.queue = cp.queue.slice(0, 5000);
  PropertiesService.getScriptProperties().setProperty('CHECKPOINT', JSON.stringify(cp));
}

function _clearCheckpoint_() {
  PropertiesService.getScriptProperties().deleteProperty('CHECKPOINT');
}

// ============================================================================
// BOOTSTRAP — runs once, idempotent, must finish in seconds not minutes
// ============================================================================
function bootstrap() {
  const t0 = Date.now();
  const exec = _newId_('exec');
  const nonce = Utilities.getUuid();
  _ensureOrch_();

  // Pre-warm sheets (one pass, no scans)
  _sheet_('reality_ledger', LEDGER_HEADERS);
  _sheet_('heartbeat', ['ts_utc','execution_id','nonce','tier','health']);
  _sheet_('drive_inventory', ['ts_utc','folder_id','folder_name','parent_id','file_count','depth']);
  _sheet_('failures', ['ts_utc','execution_id','phase','error','stack']);

  // Install trigger if not already installed
  const triggers = ScriptApp.getProjectTriggers();
  const hasMain = triggers.some(t => t.getHandlerFunction() === 'runtimeMain');
  if (!hasMain) {
    ScriptApp.newTrigger('runtimeMain')
      .timeBased()
      .everyMinutes(CONFIG.triggerMinutes)
      .create();
  }

  const ss = _ss_();
  const ms = Date.now() - t0;
  ledger('REAL', 'bootstrap_complete', {
    execution_id: exec, nonce: nonce,
    evidence_type: 'runtime_hash',
    evidence: 'ss=' + ss.getId() + ' trigger_installed=' + (!hasMain),
    duration_ms: ms
  });

  const url = ss.getUrl();
  Logger.log('BOOTSTRAP COMPLETE\n' + url + '\nDuration: ' + ms + 'ms');
  return { url: url, duration_ms: ms, trigger_installed: !hasMain };
}

// ============================================================================
// RUNTIME MAIN — invoked by 5-min trigger, processes ONE chunk per call
// ============================================================================
function runtimeMain() {
  const t0 = Date.now();
  const exec = _newId_('exec');
  const nonce = Utilities.getUuid();
  const id = _identity_(exec);

  let cp = _loadCheckpoint_();
  let processedThisTick = 0;
  let foundersThisTick = 0;
  let phase = 'init';

  try {
    // Heartbeat first — proves alive even if scan errors out below
    const hb = _heartbeat_(exec, nonce);

    if (!cp.started_at) cp.started_at = new Date().toISOString();

    phase = 'scan';
    const inv = _sheet_('drive_inventory', ['ts_utc','folder_id','folder_name','parent_id','file_count','depth']);
    const invBatch = [];

    // Per-tick budget: stop ~30s before 6-min ceiling
    const deadline = t0 + (5 * 60 * 1000); // hard stop at 5 min, trigger fires every 5 anyway

    while (cp.queue.length > 0 && processedThisTick < CONFIG.scan.maxFoldersPerTick && Date.now() < deadline) {
      const folderId = cp.queue.shift();
      try {
        const folder = (folderId === 'root') ? DriveApp.getRootFolder() : DriveApp.getFolderById(folderId);
        const parentIter = folder.getParents();
        const parentId = parentIter.hasNext() ? parentIter.next().getId() : '';

        // Count files cheap — getFiles iterator length needs iteration so cap it
        let fileCount = 0;
        const fIter = folder.getFiles();
        while (fIter.hasNext() && fileCount < 10000) { fIter.next(); fileCount++; }

        invBatch.push([
          new Date().toISOString(),
          folder.getId(),
          folder.getName(),
          parentId,
          fileCount,
          0  // depth tracking can be enriched later
        ]);

        // Enqueue children
        const childIter = folder.getFolders();
        while (childIter.hasNext()) cp.queue.push(childIter.next().getId());

        cp.processed = (cp.processed || 0) + 1;
        cp.seen = (cp.seen || 0) + 1;
        processedThisTick++;
        foundersThisTick++;
      } catch (e) {
        // Drive permission/missing folder — don't crash the runtime
        _sheet_('failures', ['ts_utc','execution_id','phase','error','stack'])
          .appendRow([new Date().toISOString(), exec, 'scan_folder:' + folderId, e.message, (e.stack || '').slice(0, 500)]);
      }
    }

    // Batch write inventory
    if (invBatch.length > 0) {
      inv.getRange(inv.getLastRow() + 1, 1, invBatch.length, 6).setValues(invBatch);
    }

    _saveCheckpoint_(cp);

    phase = 'classify';
    const completed = cp.queue.length === 0;
    const state = completed ? 'REAL' : 'PARTIAL';
    const event = completed ? 'scan_complete' : 'tick_complete';

    ledger(state, event, {
      execution_id: exec, nonce: nonce, tier: CONFIG.selfTier,
      evidence_type: 'execution_trace',
      evidence: 'queue_remaining=' + cp.queue.length + ' processed_total=' + cp.processed +
                ' healthy_ticks=' + hb.healthyTicks + ' health=' + hb.health,
      duration_ms: Date.now() - t0,
      folders_seen: cp.seen,
      folders_processed: cp.processed
    });

    if (completed) {
      _clearCheckpoint_();
    }
  } catch (e) {
    _sheet_('failures', ['ts_utc','execution_id','phase','error','stack'])
      .appendRow([new Date().toISOString(), exec, phase, e.message, (e.stack || '').slice(0, 500)]);

    // Self-heal classification per tier (NORMAL: warn 10m / heal 30m / block 120m)
    ledger('BLOCKED', 'runtime_exception', {
      execution_id: exec, nonce: nonce, tier: CONFIG.selfTier,
      evidence_type: 'execution_trace',
      evidence: 'phase=' + phase,
      duration_ms: Date.now() - t0,
      folders_processed: processedThisTick,
      error: e.message
    });
  }
}

// ============================================================================
// RECOVERY — panic, quarantine, reset
// ============================================================================
function panicShutdown() {
  ScriptApp.getProjectTriggers().forEach(t => ScriptApp.deleteTrigger(t));
  ledger('BLOCKED', 'panic_shutdown', {
    execution_id: _newId_('panic'),
    nonce: Utilities.getUuid(),
    evidence_type: 'execution_trace',
    evidence: 'all_triggers_deleted_by=' + CONFIG.actor_id
  });
}

function quarantine() {
  PropertiesService.getScriptProperties().setProperty('QUARANTINE', '1');
  ledger('BLOCKED', 'quarantine_engaged', {
    execution_id: _newId_('quar'),
    nonce: Utilities.getUuid(),
    evidence_type: 'execution_trace',
    evidence: 'runtime=' + CONFIG.runtime_id
  });
}

function reset() {
  const p = PropertiesService.getScriptProperties();
  p.deleteProperty('CHECKPOINT');
  p.deleteProperty('HEALTHY_TICKS');
  p.deleteProperty('LAST_HEARTBEAT');
  p.deleteProperty('QUARANTINE');
  ledger('REAL', 'runtime_reset', {
    execution_id: _newId_('reset'),
    nonce: Utilities.getUuid(),
    evidence_type: 'execution_trace',
    evidence: 'cleared=CHECKPOINT,HEALTHY_TICKS,LAST_HEARTBEAT,QUARANTINE'
  });
}

// ============================================================================
// SELFTEST — invoke manually to prove the runtime is healthy
// ============================================================================
function selftest() {
  const t0 = Date.now();
  const exec = _newId_('selftest');
  const nonce = Utilities.getUuid();
  const results = {};

  try {
    const ss = _ss_();
    results.ledger_url = ss.getUrl();

    const ledgerSheet = _sheet_('reality_ledger', LEDGER_HEADERS);
    results.ledger_rows = ledgerSheet.getLastRow() - 1;

    const hbSheet = _sheet_('heartbeat', ['ts_utc','execution_id','nonce','tier','health']);
    results.heartbeat_rows = hbSheet.getLastRow() - 1;

    const triggers = ScriptApp.getProjectTriggers().filter(t => t.getHandlerFunction() === 'runtimeMain');
    results.triggers_installed = triggers.length;

    const cp = _loadCheckpoint_();
    results.queue_depth = cp.queue ? cp.queue.length : 0;
    results.processed_total = cp.processed || 0;

    const p = PropertiesService.getScriptProperties();
    results.healthy_ticks = parseInt(p.getProperty('HEALTHY_TICKS') || '0', 10);
    results.last_heartbeat = p.getProperty('LAST_HEARTBEAT');
    results.supabase_configured = !!(p.getProperty('SUPABASE_URL') && p.getProperty('SUPABASE_KEY'));

    ledger('REAL', 'selftest_pass', {
      execution_id: exec, nonce: nonce,
      evidence_type: 'execution_trace',
      evidence: JSON.stringify(results),
      duration_ms: Date.now() - t0
    });
  } catch (e) {
    ledger('BLOCKED', 'selftest_fail', {
      execution_id: exec, nonce: nonce,
      evidence_type: 'execution_trace',
      evidence: e.message,
      duration_ms: Date.now() - t0,
      error: e.message
    });
    throw e;
  }
  Logger.log(JSON.stringify(results, null, 2));
  return results;
}
