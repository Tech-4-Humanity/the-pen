# Canonical Reality Library

Status: ACTIVE
Owner: The Pen
Parent doctrine: `../SESSION_REQUIREMENTS.md` §4
Root index: `../MACHINE_REALITY_INDEX.yaml`

This directory is the operational reference layer for every onboarded machine. It is not documentation — it is the substrate machines bind against before acting.

## Folder map

| Folder | Domain | Authoritative for |
|--------|--------|-------------------|
| systems/ | operational systems | system ownership, environments, runtime authority |
| businesses/ | business entities | business identity, group, monetisation owner |
| products/ | products and services | product → runtime mapping, MVP/prod state |
| assets/ | prompts, schemas, dashboards, widgets | canonical location, supersession state |
| atomic-elements/ | reusable execution primitives | bridge patterns, evidence envelopes, escalation rules, workflow templates, recovery loops |
| runtime-environments/ | dev / prod / sandbox / restricted | write permissions, criticality, rollback rules |
| repos/ | authoritative repositories | canonical repo, forbidden duplicates, migration state |
| domains/ | sites, apps, APIs, MCP endpoints | runtime ownership, telemetry state, environment mapping |
| doctrine/ | active operational doctrine | version, supersession, enforcement scope |
| receipts/ | evidence types and rules | typed evidence catalogue, supersession, replayability |
| telemetry/ | telemetry blocks and bindings | metric ownership, retention, alert routing |
| relationships/ | cross-registry topology | system↔repo, business↔domain, product↔runtime, etc. |

## Hard rules

- Machines NEVER infer system ownership, business identity, canonical repo, or environment trust from naming or recency alone.
- Every registry entry has explicit `status` ∈ {REAL, PARTIAL, BLOCKED, INVALID}.
- Deprecated entries are marked, never deleted.
- Cross-registry references use stable IDs, never display names.

## Seed status

This is the v1 scaffold. Most subdirectories are placeholder. Active seeding is task-driven via the Reality Ledger — registries grow as the machines that operate against them write their bindings back.
