export type TruthState =
  | 'ASPIRATIONAL' | 'DRAFT' | 'PARTIAL' | 'REAL' | 'DEGRADED'
  | 'BLOCKED' | 'QUARANTINED' | 'DEPRECATED' | 'ARCHIVED';

export type TriggerType =
  | 'MANUAL' | 'API' | 'WEBHOOK' | 'SCHEDULED' | 'SYSTEM'
  | 'AI' | 'CRM' | 'PORTAL' | 'PAYMENT' | 'MESSAGE' | 'BATCH';

export type PartyType =
  | 'PROSPECT' | 'CUSTOMER' | 'PARTNER' | 'SUPPLIER' | 'EMPLOYEE'
  | 'CANDIDATE' | 'INVESTOR' | 'REGULATOR' | 'HUMAN' | 'AI_AGENT'
  | 'SYSTEM' | 'TEAM' | 'ORGANISATION';

export type OutputType =
  | 'EMAIL' | 'SMS' | 'PUSH' | 'PORTAL' | 'LETTER' | 'VOICE'
  | 'AI_CHAT' | 'TASK' | 'DOCUMENT' | 'INVOICE' | 'CONTRACT'
  | 'CALENDAR_EVENT' | 'CRM_UPDATE' | 'SUPPORT_TICKET' | 'WEBHOOK'
  | 'ANALYTICS_EVENT' | 'LEDGER_ENTRY';

export interface PartyBinding {
  partyType: PartyType;
  role: string;
  personaId?: string;
  segmentId?: string;
  language?: string;
  timezone?: string;
  accessibilityProfile?: string;
}

export interface EventTrigger {
  type: TriggerType;
  sourceSystem: string;
  sourceEvent?: string;
  entryCriteria: string[];
  preconditions?: string[];
  idempotencyScope?: string;
}

export interface EventOutput {
  outputKey: string;
  outputType: OutputType;
  channel: string;
  templateId?: string;
  required: boolean;
  recipientRole: string;
  consentBasis?: string;
  deliverySlaSeconds?: number;
  personalisationFields?: string[];
}

export interface EvidencePolicy {
  evidenceRequired: boolean;
  receiptRequired: boolean;
  ledgerRequired: boolean;
  telemetryRequired: boolean;
  replayRequired: boolean;
  verificationMethod: string;
  evidenceTypes: string[];
  retentionDays: number;
}

export interface AiPolicy {
  agentId: string;
  decisionAuthority: string;
  toolScopes: string[];
  knowledgeSourceIds: string[];
  confidenceThreshold: number;
  humanReviewRule: string;
  guardrailIds: string[];
  memoryPolicy: string;
}

export interface CanonicalEnterpriseEvent {
  eventId: string;
  eventKey: string;
  canonicalName: string;
  displayName?: string;
  description: string;
  eventFamily: string;
  domain: string;
  capability?: string;
  businessProcess?: string;
  lifecycleStage: string;
  journeyIds?: string[];
  status: TruthState;
  version: `${number}.${number}.${number}`;
  priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  criticality?: 'NON_CRITICAL' | 'BUSINESS_CRITICAL' | 'MISSION_CRITICAL' | 'SAFETY_CRITICAL';
  businessOwner: string;
  operationalOwner: string;
  technicalOwner?: string;
  dataSteward?: string;
  trigger: EventTrigger;
  actors: PartyBinding[];
  audiences: PartyBinding[];
  requiredActionSummary: string;
  approvalRequired: boolean;
  approvalRole?: string;
  retryPolicy: string;
  timeoutSeconds: number;
  fallbackEventKey: string;
  rollbackEventKey?: string;
  outputs: EventOutput[];
  evidencePolicy: EvidencePolicy;
  aiPolicy?: AiPolicy;
  successMetricKey: string;
  slaSeconds: number;
  defaultNextEventKey?: string;
  exceptionEventKey: string;
  securityClassification: 'PUBLIC' | 'INTERNAL' | 'CONFIDENTIAL' | 'RESTRICTED';
  effectiveAt: string;
  reviewAt: string;
  expiresAt?: string | null;
  tags?: string[];
  sourceRefs?: string[];
}

export interface RuntimeEventEnvelope<TPayload = unknown> {
  occurrenceId: string;
  eventKey: string;
  eventVersion: string;
  occurredAt: string;
  receivedAt: string;
  actorRef?: string;
  subjectRef?: string;
  organisationRef?: string;
  correlationId: string;
  causationId?: string;
  idempotencyKey: string;
  sourceSystem: string;
  authorityRef?: string;
  payload: TPayload;
  status: TruthState;
  verificationStatus?: string;
  receiptRef?: string;
  ledgerRef?: string;
  telemetryRef?: string;
  error?: Record<string, unknown>;
}

export const isPromotableToReal = (event: RuntimeEventEnvelope): boolean =>
  Boolean(
    event.eventKey &&
    event.eventVersion &&
    event.correlationId &&
    event.idempotencyKey &&
    event.sourceSystem &&
    event.verificationStatus === 'VERIFIED' &&
    event.receiptRef &&
    event.telemetryRef
  );
