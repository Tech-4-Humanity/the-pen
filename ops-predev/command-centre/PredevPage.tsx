// src/pages/PredevPage.tsx
// ops.predev v1.0 — Command Centre page
// Route: /predev
// Bridge queries: ops_predev, v_predev_ready, v_predev_blocked

import { useState, useEffect, useCallback } from 'react';

const BRIDGE_URL = 'https://m5oqj21chd.execute-api.ap-southeast-2.amazonaws.com/lambda/invoke';
const PROMOTE_URL = `${BRIDGE_URL}`;

type PredevStatus = 'parked' | 'blocked' | 'ready' | 'promoted' | 'cancelled';
type ItemType = 'wip' | 'pen';

interface PredevItem {
  id: string;
  title: string;
  item_type: ItemType;
  status: PredevStatus;
  priority: number;
  pillar: string | null;
  business_key: string | null;
  source_type: string;
  source_ref: string | null;
  blocked_by: string[];
  block_ref: string | null;
  promote_to: string | null;
  auto_promote: boolean;
  notes: string | null;
  is_rd: boolean;
  created_at: string;
  blocker_details?: { id: string; title: string; status: string }[];
}

async function bridgeSQL(sql: string): Promise<PredevItem[]> {
  const res = await fetch(BRIDGE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fn: 'troy-sql-executor', sql, debug: true }),
  });
  const data = await res.json();
  return data?.rows ?? data?.data ?? [];
}

async function bridgeInvoke(fn: string, payload: object): Promise<unknown> {
  const res = await fetch(BRIDGE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fn, ...payload }),
  });
  return res.json();
}

const PILLAR_COLOR: Record<string, string> = {
  '01_MCP':      '#EEEDFE',
  '02_JOBS':     '#E1F5EE',
  '04_RESEARCH': '#E6F1FB',
  '03_BUSINESS': '#FAEEDA',
  '05_PERSONAL': '#F1EFE8',
};
const TYPE_COLOR: Record<ItemType, string> = {
  pen: '#7F77DD',
  wip: '#1D9E75',
};
const STATUS_COLOR: Record<PredevStatus, string> = {
  parked:    '#888780',
  blocked:   '#D85A30',
  ready:     '#1D9E75',
  promoted:  '#378ADD',
  cancelled: '#B4B2A9',
};

function PriorityDot({ p }: { p: number }) {
  const colors = ['', '#E24B4A', '#EF9F27', '#888780', '#888780', '#B4B2A9'];
  return (
    <span style={{
      display: 'inline-block', width: 8, height: 8, borderRadius: '50%',
      background: colors[p] || '#888780', marginRight: 6, flexShrink: 0,
    }} title={`Priority ${p}`} />
  );
}

function Badge({ text, color }: { text: string; color: string }) {
  return (
    <span style={{
      fontSize: 10, fontWeight: 600, padding: '2px 6px',
      borderRadius: 4, background: color + '22', color, letterSpacing: '0.04em',
      border: `1px solid ${color}33`,
    }}>
      {text.toUpperCase()}
    </span>
  );
}

function ItemCard({ item, onPromote, onAssess }: {
  item: PredevItem;
  onPromote?: (item: PredevItem) => void;
  onAssess?: (item: PredevItem) => void;
}) {
  const age = Math.floor((Date.now() - new Date(item.created_at).getTime()) / 86400000);

  return (
    <div style={{
      background: '#fff', border: '0.5px solid #e0e0dc',
      borderLeft: `3px solid ${TYPE_COLOR[item.item_type]}`,
      borderRadius: 8, padding: '10px 12px', marginBottom: 8,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 6, marginBottom: 4 }}>
        <PriorityDot p={item.priority} />
        <span style={{ fontSize: 13, fontWeight: 600, color: '#2C2C2A', flex: 1, lineHeight: 1.35 }}>
          {item.title}
        </span>
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginBottom: item.notes || item.block_ref ? 6 : 0 }}>
        <Badge text={item.item_type} color={TYPE_COLOR[item.item_type]} />
        {item.pillar && (
          <span style={{ fontSize: 10, padding: '2px 6px', borderRadius: 4, background: PILLAR_COLOR[item.pillar] || '#f1efe8', color: '#5F5E5A' }}>
            {item.pillar}
          </span>
        )}
        {item.business_key && (
          <span style={{ fontSize: 10, padding: '2px 6px', borderRadius: 4, background: '#f8f8f6', color: '#888780', border: '0.5px solid #e0e0dc' }}>
            {item.business_key}
          </span>
        )}
        {item.is_rd && <Badge text="R&D" color="#534AB7" />}
        <span style={{ fontSize: 10, color: '#B4B2A9', marginLeft: 'auto' }}>{age}d ago</span>
      </div>
      {item.block_ref && (
        <div style={{ fontSize: 11, color: '#D85A30', marginBottom: 4 }}>
          ↳ {item.block_ref}
        </div>
      )}
      {item.blocker_details?.length ? (
        <div style={{ fontSize: 11, color: '#888780', marginBottom: 4 }}>
          Blocked by: {item.blocker_details.map(b => (
            <span key={b.id} style={{ marginRight: 6, color: b.status === 'promoted' ? '#1D9E75' : '#D85A30' }}>
              {b.title.slice(0, 40)}
            </span>
          ))}
        </div>
      ) : null}
      {item.notes && (
        <div style={{ fontSize: 11, color: '#888780', marginTop: 4, lineHeight: 1.4 }}>
          {item.notes.slice(0, 120)}{item.notes.length > 120 ? '…' : ''}
        </div>
      )}
      <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
        {onPromote && item.status === 'ready' && (
          <button onClick={() => onPromote(item)} style={{
            fontSize: 11, padding: '3px 10px', border: '0.5px solid #1D9E75',
            borderRadius: 5, background: '#EAF3DE', color: '#1D9E75', cursor: 'pointer',
          }}>
            Promote ↗
          </button>
        )}
        {onAssess && (
          <button onClick={() => onAssess(item)} style={{
            fontSize: 11, padding: '3px 10px', border: '0.5px solid #e0e0dc',
            borderRadius: 5, background: 'transparent', color: '#888780', cursor: 'pointer',
          }}>
            Assess
          </button>
        )}
      </div>
    </div>
  );
}

function Panel({ title, count, children, accent }: {
  title: string; count: number; children: React.ReactNode; accent: string;
}) {
  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
        <span style={{ fontSize: 11, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.06em', color: '#888780' }}>
          {title}
        </span>
        <span style={{
          fontSize: 11, background: accent + '22', color: accent,
          borderRadius: 10, padding: '1px 8px', border: `0.5px solid ${accent}44`,
        }}>
          {count}
        </span>
      </div>
      {children}
    </div>
  );
}

export default function PredevPage() {
  const [blocked, setBlocked]     = useState<PredevItem[]>([]);
  const [ready, setReady]         = useState<PredevItem[]>([]);
  const [parked, setParked]       = useState<PredevItem[]>([]);
  const [loading, setLoading]     = useState(true);
  const [promoting, setPromoting] = useState<PredevItem | null>(null);
  const [promoteFn, setPromoteFn] = useState('');
  const [promoteMsg, setPromoteMsg] = useState('');
  const [error, setError]         = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [b, r, p] = await Promise.all([
        bridgeSQL(`SELECT p.*, (SELECT json_agg(json_build_object('id',b.id,'title',b.title,'status',b.status)) FROM ops_predev b WHERE b.id = ANY(p.blocked_by)) AS blocker_details FROM ops_predev p WHERE p.status='blocked' ORDER BY p.priority ASC, p.created_at ASC LIMIT 50`),
        bridgeSQL(`SELECT * FROM v_predev_ready LIMIT 50`),
        bridgeSQL(`SELECT * FROM ops_predev WHERE status='parked' ORDER BY priority ASC, created_at DESC LIMIT 50`),
      ]);
      setBlocked(b); setReady(r); setParked(p);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const handlePromote = (item: PredevItem) => {
    setPromoting(item);
    setPromoteFn(item.promote_to || '');
    setPromoteMsg('');
  };

  const confirmPromote = async () => {
    if (!promoting) return;
    try {
      await bridgeInvoke('predev-promote', {
        id: promoting.id,
        promote_to: promoteFn || undefined,
        force: false,
      });
      setPromoting(null);
      await load();
    } catch (e: any) {
      setPromoteMsg(`Error: ${e.message}`);
    }
  };

  return (
    <div style={{ padding: '24px 32px', fontFamily: 'system-ui, sans-serif', maxWidth: 1400 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 600, color: '#2C2C2A', margin: 0 }}>Pre-dev workspace</h1>
          <p style={{ fontSize: 13, color: '#888780', margin: '4px 0 0' }}>
            ops.predev — dependency-aware pre-development queue
          </p>
        </div>
        <button onClick={load} disabled={loading} style={{
          fontSize: 12, padding: '6px 14px', border: '0.5px solid #e0e0dc',
          borderRadius: 6, background: 'transparent', color: '#5F5E5A', cursor: 'pointer',
        }}>
          {loading ? 'Loading…' : 'Refresh'}
        </button>
      </div>

      {error && (
        <div style={{ background: '#FCEBEB', border: '0.5px solid #F09595', borderRadius: 8, padding: '10px 14px', marginBottom: 16, fontSize: 13, color: '#A32D2D' }}>
          Bridge error: {error}
        </div>
      )}

      {/* Three-panel layout */}
      <div style={{ display: 'flex', gap: 20, alignItems: 'flex-start' }}>
        <Panel title="Blocked" count={blocked.length} accent="#D85A30">
          {blocked.length === 0
            ? <p style={{ fontSize: 12, color: '#B4B2A9' }}>None blocked</p>
            : blocked.map(i => <ItemCard key={i.id} item={i} />)
          }
        </Panel>

        <Panel title="Ready" count={ready.length} accent="#1D9E75">
          {ready.length === 0
            ? <p style={{ fontSize: 12, color: '#B4B2A9' }}>Nothing ready yet</p>
            : ready.map(i => <ItemCard key={i.id} item={i} onPromote={handlePromote} />)
          }
        </Panel>

        <Panel title="Parked" count={parked.length} accent="#888780">
          {parked.length === 0
            ? <p style={{ fontSize: 12, color: '#B4B2A9' }}>Queue clear</p>
            : parked.map(i => <ItemCard key={i.id} item={i} />)
          }
        </Panel>
      </div>

      {/* Promote modal */}
      {promoting && (
        <div style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 50,
        }} onClick={() => setPromoting(null)}>
          <div onClick={e => e.stopPropagation()} style={{
            background: '#fff', border: '0.5px solid #e0e0dc', borderRadius: 12,
            padding: 24, width: 440, maxWidth: '90vw',
          }}>
            <h3 style={{ fontSize: 15, fontWeight: 600, margin: '0 0 4px' }}>Promote to queue</h3>
            <p style={{ fontSize: 12, color: '#888780', margin: '0 0 16px' }}>{promoting.title}</p>
            <label style={{ fontSize: 12, color: '#5F5E5A', display: 'block', marginBottom: 4 }}>Lambda fn name (optional)</label>
            <input
              value={promoteFn}
              onChange={e => setPromoteFn(e.target.value)}
              placeholder="e.g. troy-ec2-manager"
              style={{ width: '100%', fontSize: 13, marginBottom: 16 }}
            />
            {promoteMsg && <p style={{ fontSize: 12, color: '#D85A30', marginBottom: 12 }}>{promoteMsg}</p>}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8 }}>
              <button onClick={() => setPromoting(null)} style={{ fontSize: 13, padding: '6px 14px', border: '0.5px solid #e0e0dc', borderRadius: 6, background: 'transparent', cursor: 'pointer' }}>
                Cancel
              </button>
              <button onClick={confirmPromote} style={{ fontSize: 13, padding: '6px 14px', border: '0.5px solid #1D9E75', borderRadius: 6, background: '#EAF3DE', color: '#1D9E75', cursor: 'pointer' }}>
                Confirm promote ↗
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
