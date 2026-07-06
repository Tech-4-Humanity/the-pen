# Agora TypeScript Contracts

Status: PARTIAL

```ts
export type AgoraStatus = 'REAL' | 'PARTIAL' | 'BLOCKED' | 'ASPIRATIONAL';

export interface Receipt {
  receipt_id: string;
  status: AgoraStatus;
  action: string;
  object_type: string;
  object_id: string;
  timestamp: string;
  checksum_sha256?: string;
  evidence_refs: string[];
  gaps: string[];
}

export interface Tenant {
  tenant_id: string;
  display_name: string;
  tenant_type: 'standard' | 'research' | 'enterprise' | 'white_label';
  region: string;
  data_residency: string;
  status: string;
}

export interface MediaAsset {
  media_id: string;
  tenant_id: string;
  owner_identity_id?: string;
  title: string;
  media_type: 'video' | 'audio' | 'image' | 'document' | 'text';
  source_uri?: string;
  s3_uri?: string;
  ipfs_cid?: string;
  checksum_sha256?: string;
  visibility: 'private' | 'tenant' | 'public';
  moderation_state: string;
  status: string;
}

export interface TranscriptSegment {
  start: number;
  end: number;
  text: string;
  speaker?: string;
  confidence?: number;
}

export interface Transcript {
  transcript_id: string;
  media_id: string;
  language?: string;
  provider: string;
  model?: string;
  confidence?: number;
  full_text: string;
  segments: TranscriptSegment[];
  status: string;
}

export interface Entity {
  entity_id: string;
  tenant_id: string;
  canonical_name: string;
  aliases: string[];
  entity_type: string;
  confidence?: number;
  source_refs: string[];
  status: string;
}

export interface Relationship {
  relationship_id: string;
  tenant_id: string;
  source_entity_id: string;
  target_entity_id: string;
  relationship_type: string;
  claim_text?: string;
  polarity?: 'positive' | 'negative' | 'neutral' | 'mixed';
  confidence?: number;
  evidence_refs: string[];
  status: string;
}

export interface DebateRound {
  round_index: number;
  speaker: string;
  persona: string;
  content: string;
  citations: string[];
  status: AgoraStatus;
}

export interface Debate {
  debate_id: string;
  tenant_id: string;
  topic: string;
  personas: string[];
  rounds: DebateRound[];
  citations: string[];
  output_summary?: string;
  status: string;
}

export interface EvidencePack {
  evidence_pack_id: string;
  tenant_id: string;
  scope: string;
  artefact_refs: string[];
  checksum_sha256?: string;
  export_format: 'json' | 'markdown' | 'pdf' | 'zip';
  status: string;
}

export interface ApiEnvelope<T> {
  data: T;
  receipt?: Receipt;
  status: AgoraStatus;
  gaps: string[];
}
```
