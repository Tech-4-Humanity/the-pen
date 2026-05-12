/**
 * 40_ram_command-centre_widgets.tsx
 *
 * RAM widgets for the MCP Command Centre. All widgets are read-only views
 * on Supabase. Writes go through the bridge, never directly from the UI.
 *
 * Registration pattern follows t4h_ui_snippet (slug-unique).
 */

import React from "react";

// ---- Widget contract (shared) -------------------------------------------------
export type RamWidgetProps = {
  fetcher: (path: string, query?: Record<string, any>) => Promise<any>;
  refreshMs?: number;
};

const fmtPct = (n: number) => `${Math.round(n * 100)}%`;

// ---- 1. RAM Health -----------------------------------------------------------
// Total assets + REAL/PARTIAL/BLOCKED split + last scan time
export function RamHealth({ fetcher, refreshMs = 60000 }: RamWidgetProps) {
  const [data, setData] = React.useState<any>(null);
  React.useEffect(() => {
    const load = () => fetcher("/ram/assets", { aggregate: "evidence_state" }).then(setData);
    load();
    const id = setInterval(load, refreshMs);
    return () => clearInterval(id);
  }, [fetcher, refreshMs]);
  if (!data) return <div className="ram-health">Loading…</div>;
  return (
    <div className="ram-health">
      <h3>RAM Health</h3>
      <div>Total: {data.total}</div>
      <div>REAL: {data.real} ({fmtPct(data.real / Math.max(1, data.total))})</div>
      <div>PARTIAL: {data.partial}</div>
      <div>BLOCKED: {data.blocked}</div>
      <small>Last scan: {data.last_scan_at}</small>
    </div>
  );
}

// ---- 2. RAM Ghost Radar -------------------------------------------------------
// Orphan assets, missing receipts, dead links
export function RamGhostRadar({ fetcher, refreshMs = 300000 }: RamWidgetProps) {
  const [events, setEvents] = React.useState<any[]>([]);
  React.useEffect(() => {
    const load = () => fetcher("/ram/watch", { types: ["orphan", "dead_link", "missing_receipt"] }).then(setEvents);
    load();
    const id = setInterval(load, refreshMs);
    return () => clearInterval(id);
  }, [fetcher, refreshMs]);
  return (
    <div className="ram-ghost-radar">
      <h3>RAM Ghost Radar</h3>
      <ul>
        {events.map((e) => (
          <li key={e.id}>
            <span className={`sev-${e.severity}`}>{e.severity}</span> {e.event_type}: {e.message}
          </li>
        ))}
      </ul>
    </div>
  );
}

// ---- 3. RAM Evidence Gauge ----------------------------------------------------
export function RamEvidenceGauge({ fetcher, refreshMs = 120000 }: RamWidgetProps) {
  const [g, setG] = React.useState<any>(null);
  React.useEffect(() => {
    const load = () => fetcher("/ram/assets", { aggregate: "evidence_score" }).then(setG);
    load();
    const id = setInterval(load, refreshMs);
    return () => clearInterval(id);
  }, [fetcher, refreshMs]);
  if (!g) return null;
  return (
    <div className="ram-evidence-gauge">
      <h3>RAM Evidence Coverage</h3>
      <div className="bar" style={{ width: `${g.coverage * 100}%` }} />
      <div>{fmtPct(g.coverage)} of assets have typed evidence</div>
    </div>
  );
}

// ---- 4. RAM Reuse Mine --------------------------------------------------------
export function RamReuseMine({ fetcher }: RamWidgetProps) {
  const [items, setItems] = React.useState<any[]>([]);
  React.useEffect(() => {
    fetcher("/ram/reuse", {}).then(setItems);
  }, [fetcher]);
  return (
    <div className="ram-reuse-mine">
      <h3>Reusable Components Found</h3>
      <table>
        <thead><tr><th>Type</th><th>Name</th><th>Target</th><th>Confidence</th></tr></thead>
        <tbody>
          {items.map((c) => (
            <tr key={c.id}>
              <td>{c.component_type}</td>
              <td>{c.component_name}</td>
              <td>{c.reuse_target}</td>
              <td>{c.confidence}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ---- 5. RAM Portfolio Map -----------------------------------------------------
export function RamPortfolioMap({ fetcher }: RamWidgetProps) {
  const [cards, setCards] = React.useState<any[]>([]);
  React.useEffect(() => {
    fetcher("/ram/portfolio/v_ram_portfolio_real", {}).then(setCards);
  }, [fetcher]);
  return (
    <div className="ram-portfolio-map">
      <h3>Portfolio (REAL evidence only)</h3>
      <ul>
        {cards.map((c) => (
          <li key={c.id}><b>{c.brand}</b> — {c.capability} <em>({c.audience})</em><br /><small>{c.summary}</small></li>
        ))}
      </ul>
    </div>
  );
}

// ---- 6. RAM Package Queue -----------------------------------------------------
export function RamPackageQueue({ fetcher, refreshMs = 60000 }: RamWidgetProps) {
  const [pkgs, setPkgs] = React.useState<any[]>([]);
  React.useEffect(() => {
    const load = () => fetcher("/ram/packages", {}).then(setPkgs);
    load();
    const id = setInterval(load, refreshMs);
    return () => clearInterval(id);
  }, [fetcher, refreshMs]);
  return (
    <div className="ram-package-queue">
      <h3>RAM Package Queue</h3>
      <table>
        <thead><tr><th>Package</th><th>Status</th><th>Receipt</th></tr></thead>
        <tbody>
          {pkgs.map((p) => (
            <tr key={p.id}>
              <td>{p.package_name}</td>
              <td>{p.status}</td>
              <td>{p.receipt_uri || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ---- 7. RAM Drift Watch -------------------------------------------------------
export function RamDriftWatch({ fetcher }: RamWidgetProps) {
  const [drift, setDrift] = React.useState<any[]>([]);
  React.useEffect(() => {
    fetcher("/ram/watch", { types: ["schema_drift", "identity_drift", "naming_drift", "dependency_drift"] }).then(setDrift);
  }, [fetcher]);
  return (
    <div className="ram-drift-watch">
      <h3>RAM Drift Watch</h3>
      <ul>{drift.map((d) => <li key={d.id}><b>{d.event_type}</b>: {d.message}</li>)}</ul>
    </div>
  );
}

// ---- 8. RAM Dev Inspection Status ---------------------------------------------
export function RamDevInspectionStatus({ fetcher }: RamWidgetProps) {
  const [rows, setRows] = React.useState<any[]>([]);
  React.useEffect(() => {
    fetcher("/ram/dev/inspections", {}).then(setRows);
  }, [fetcher]);
  return (
    <div className="ram-dev-inspection">
      <h3>RAM Dev Inspection</h3>
      <table>
        <thead><tr><th>Package</th><th>Status</th><th>Receipt</th></tr></thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id}>
              <td>{r.package_stem}</td>
              <td>{r.status}</td>
              <td>{r.receipt_uri || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ---- 9. RAM Prod Promotion Gate -----------------------------------------------
export function RamProdPromotionGate({ fetcher }: RamWidgetProps) {
  const [rows, setRows] = React.useState<any[]>([]);
  React.useEffect(() => {
    fetcher("/ram/prod/promotions", {}).then(setRows);
  }, [fetcher]);
  return (
    <div className="ram-prod-promotion-gate">
      <h3>RAM Prod Promotion Gate</h3>
      <table>
        <thead><tr><th>Package</th><th>Gate</th><th>Receipt</th></tr></thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id}>
              <td>{r.package_stem}</td>
              <td>{r.status}</td>
              <td>{r.receipt_uri || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ---- Registry export (matches t4h_ui_snippet shape) ---------------------------
export const RAM_WIDGETS = [
  { slug: "ram-health",                component: RamHealth },
  { slug: "ram-ghost-radar",           component: RamGhostRadar },
  { slug: "ram-evidence-gauge",        component: RamEvidenceGauge },
  { slug: "ram-reuse-mine",            component: RamReuseMine },
  { slug: "ram-portfolio-map",         component: RamPortfolioMap },
  { slug: "ram-package-queue",         component: RamPackageQueue },
  { slug: "ram-drift-watch",           component: RamDriftWatch },
  { slug: "ram-dev-inspection-status", component: RamDevInspectionStatus },
  { slug: "ram-prod-promotion-gate",   component: RamProdPromotionGate },
];
