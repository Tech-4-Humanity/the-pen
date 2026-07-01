# Agora Design System and UX Catalogue

Status: PARTIAL  
Runtime: not deployed  
Purpose: Define frontend structure without blocking on runtime credentials.

## Product surfaces

| Surface | Primary user | Purpose |
|---|---|---|
| Media Hub | Creator, analyst, researcher | Upload, browse, review, publish media artefacts |
| Debate Arena | Analyst, student, public viewer | View and replay evidence-backed debates |
| Community Explorer | Researcher, government, enterprise | Explore communities, narratives, entities, and relationships |
| Evidence Vault | Compliance, legal, research | Inspect receipts, exports, provenance, and evidence packs |
| Creator Studio | Creator, educator | Manage uploads, transcripts, summaries, rights, and distribution |
| Enterprise Console | Tenant admin | Manage users, tenants, white-label settings, roles, and reports |
| Admin Console | Platform operator | Observe runtime, jobs, queues, receipts, failures, and deployments |

## Navigation model

```text
/
├── dashboard
├── media
│   ├── upload
│   ├── library
│   ├── transcripts
│   └── moderation
├── debates
│   ├── new
│   ├── running
│   ├── archive
│   └── replay
├── graph
│   ├── entities
│   ├── relationships
│   ├── communities
│   └── narratives
├── evidence
│   ├── receipts
│   ├── packs
│   ├── exports
│   └── audit
├── studio
├── enterprise
└── settings
```

## Core components

### Shell
- `AppShell`
- `TenantSwitcher`
- `PrimaryNav`
- `BreadcrumbTrail`
- `RuntimeStatusBadge`
- `ReceiptStatusBadge`

### Media
- `UploadDropzone`
- `MediaCard`
- `MediaTimeline`
- `TranscriptViewer`
- `SegmentInspector`
- `CommentImportPanel`
- `ModerationBanner`

### Graph
- `EntityCard`
- `RelationshipTable`
- `GraphCanvas`
- `CommunityClusterCard`
- `NarrativeTrajectoryChart`
- `EvidenceCitationDrawer`

### Debate
- `DebateComposer`
- `PersonaSelector`
- `RoundTimeline`
- `DebateMessageCard`
- `CitationList`
- `ReplayControls`
- `DebateExportPanel`

### Evidence
- `ReceiptCard`
- `ReceiptChain`
- `EvidencePackBuilder`
- `ChecksumDisplay`
- `ExportFormatSelector`
- `SupersessionNotice`

### Admin
- `ServiceHealthGrid`
- `JobQueueTable`
- `FailureInspector`
- `CostMeter`
- `TenantPolicyEditor`
- `AuditLogTable`

## Design tokens

```yaml
spacing:
  xs: 4
  sm: 8
  md: 16
  lg: 24
  xl: 32
radius:
  sm: 4
  md: 8
  lg: 16
status:
  REAL: verified runtime receipt and telemetry
  PARTIAL: built or configured but lacking full runtime proof
  BLOCKED: awaiting required credential, permission, or external dependency
  ASPIRATIONAL: design intent only
```

## Accessibility rules

- Keyboard navigation for all primary actions.
- Transcript and debate outputs must be readable without graph visuals.
- Graph visuals require tabular fallback.
- Colour cannot be the only status indicator.
- Evidence and receipts must expose copyable IDs.
- Exports must preserve text alternatives for media-derived content.

## White-label theming

Tenant theme object:

```yaml
theme:
  tenant_id:
  logo_uri:
  primary_colour:
  accent_colour:
  font_family:
  public_name:
  support_email:
  footer_disclaimer:
  enabled_surfaces:
    - media
    - debates
    - graph
    - evidence
```

## UX principles

- Every generated output must show evidence state.
- Every object page must show owner, dependencies, lifecycle, and receipt status.
- Every failure must show recovery path.
- Every public export must include source and confidence metadata.
- Runtime proof must be visually distinct from design intent.
