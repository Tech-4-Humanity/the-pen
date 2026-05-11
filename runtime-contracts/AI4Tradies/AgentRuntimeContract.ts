// AI4Tradies Agent Runtime Contract
// Generated: 2026-05-11
// Bound to: bridge-payloads/2026-05-11/AI4Tradies-Convergence-Bridge-Payload-20260511.md
// Parent commit: a54bc93d98c62e6bd793d88bbe2e22090c1d5a60
// Task: AI4TRADIES-CONVERGENCE-EXEC-20260511
//
// Surfaces bound (public.agent_runtime_registry):
//   - AI4Tradies Matrix Map (matrix_map)        id d460c30f-bc01-4627-8807-f2ec2df2898a
//   - t4h-agent-orchestrator (orchestrator)     id 1b744cb2-70ff-4170-8eb0-4d55ee7d64f8
//   - agent-channel (channel)                   id bb864b90-49e4-4982-b19a-79c14eca8481

export type AgentEventType =
  | 'DISCOVER'
  | 'TRIAGE'
  | 'EXECUTE'
  | 'VERIFY'
  | 'MONETISE'
  | 'ESCALATE'
  | 'ARCHIVE';

export type RealityStatus = 'REAL' | 'PARTIAL' | 'BLOCKED';

export type AgentRuntimeEvent = {
  task_id: string;
  brand: 'AI4TRADIES';
  source_surface: string;
  target_surface?: string;
  agent_key?: 'matrix_map' | 'orchestrator' | 'channel';
  event_type: AgentEventType;
  payload: Record<string, unknown>;
  reality_required: boolean;
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'CRITICAL';
  is_rd?: boolean;
  project_code?: 'AI4TRADIES';
};

export type EvidenceItem = {
  type:
    | 'api_response'
    | 'database_result'
    | 'cli_output'
    | 'commit_id'
    | 'url'
    | 'hash'
    | 'reproducible_steps';
  value: string;
};

export type RealityLedgerResult = {
  task_id: string;
  status: RealityStatus;
  result: Record<string, unknown>;
  evidence: EvidenceItem[];
  gaps: string[];
  next_action: string;
  elevation: string;
  pressure_flags: string[];
  score: number;
  parent_ledger_id?: string;
};

export type EventBusReceipt = {
  event_id: string;
  task_id: string;
  status: 'QUEUED' | 'RUNNING' | 'COMPLETED' | 'FAILED' | 'BLOCKED';
  processed_at?: string;
  evidence_ref?: string;
};

// Canonical execution contract for any AI4Tradies-bound worker
export interface AI4TradiesRuntime {
  emit(event: AgentRuntimeEvent): Promise<EventBusReceipt>;
  process(event_id: string): Promise<RealityLedgerResult>;
  verify(task_id: string): Promise<RealityLedgerResult[]>;
}

// Schema bindings
export const SCHEMA = {
  registry: 'public.agent_runtime_registry',
  event_bus: 'public.agent_event_bus',
  memory: 'public.agent_memory_items',
  telemetry: 'public.agent_telemetry_events',
  ledger_events: 'public.reality_ledger_events',
  parent_ledger: 'public.reality_ledger',
  brand_map: 'public.t4h_brand_map',
} as const;

export const CANONICAL_BRAND = 'AI4TRADIES' as const;
export const PROJECT_CODE = 'AI4TRADIES' as const;
export const CLUSTER_ID = 'CL_BRIDGE_PEN' as const;
