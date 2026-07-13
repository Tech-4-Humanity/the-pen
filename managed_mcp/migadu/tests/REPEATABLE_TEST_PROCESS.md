# Repeatable Test Process — Mail Operations Runtime

## Purpose

Provide one deterministic, rerunnable test process for mailbox provisioning, folders, rules, signatures, templates, GitHub failure handling, receipts, ledger updates and telemetry.

A test is not REAL unless execution, independent verification, receipt, ledger entry and telemetry correlation are all observed.

## Test layers

### T0 — Static and contract validation

Run on every change.

Validate:
- JSON, YAML and JSONL syntax.
- Mailbox registry schema.
- Folder template schema.
- Signature and autoresponder template completeness.
- Workflow and event schema compatibility.
- No duplicate mailbox, alias, folder, rule or template identifiers.
- No secret values in source, fixtures, logs or receipts.

Pass evidence:
- command exit code 0;
- validation report;
- file hashes;
- receipt and ledger entry.

### T1 — Unit tests

Run all pure logic without network credentials.

Cover:
- mailbox classification: human, machine, shared, catch-all, alias, identity and forwarder;
- folder inheritance and override resolution;
- rule matching and precedence;
- GitHub failure-email parsing;
- repository, workflow, run ID and failure-type extraction;
- signature rendering in HTML and plain text;
- autoresponder rendering and loop prevention;
- idempotency-key generation;
- receipt classification: REAL, PARTIAL and BLOCKED;
- retry, quarantine and closure decisions.

### T2 — Fixture and simulation tests

Use committed synthetic fixtures only.

Required fixtures:
- GitHub Actions failure email;
- GitHub Actions recovery email;
- duplicate failure notification;
- malformed notification;
- DMARC report;
- billing alert;
- support request;
- invoice;
- catch-all message;
- internal machine notification.

Expected GitHub failure flow:

`receive → classify → file to Systems/GitHub/Actions/Failed → create/update work item → attempt recovery → verify result → move to Completed or Quarantine → emit receipt`

Assertions:
- message leaves Inbox;
- destination folder is correct;
- duplicate messages do not create duplicate work;
- failure remains open while runtime evidence is absent;
- successful recovery closes the work item and files the message under Completed;
- failed recovery creates a quarantine record and escalation.

### T3 — Dry-run integration

Run against a real inventory with all mutation calls disabled.

Validate:
- authoritative domain and mailbox inventory refresh;
- endpoint classification;
- proposed folders, rules, signatures and autoresponders;
- protected mailbox policy;
- proposed before/after diff;
- bounded batch plan;
- zero remote changes.

Required outputs:
- plan JSON;
- diff CSV;
- Markdown report;
- receipt with `remote_changes=false`;
- ledger entry.

### T4 — Read-only sandbox integration

Use runtime-injected credentials against a non-production or disposable domain.

Validate:
- domains, mailboxes, aliases, identities, forwardings and rewrites can be listed;
- observed counts match independent API reads;
- no credential value appears in logs;
- OpenTelemetry trace ID is present in receipt and ledger.

### T5 — Controlled-write sandbox

Perform one bounded operation per capability class:
- create one disposable mailbox or alias;
- create canonical folders;
- apply one filing rule;
- apply one signature/template association;
- apply one autoresponder;
- inject one synthetic GitHub failure email and process it end to end.

For every operation:
1. capture before state;
2. calculate plan and idempotency key;
3. execute once;
4. independently verify after state;
5. execute the same request again;
6. verify no duplicate object or side effect;
7. emit receipt, ledger entry and trace.

### T6 — Recovery and rollback

Use disposable objects only.

Test:
- failed folder creation;
- partial bulk operation;
- API timeout;
- ambiguous delete response;
- malformed template;
- unavailable telemetry collector;
- duplicate event delivery;
- GitHub recovery attempt that fails twice.

Required result:
- retry, rollback, compensation or quarantine is selected explicitly;
- no silent failure;
- before/after evidence is preserved;
- unresolved items remain PARTIAL or BLOCKED;
- successful recovery is independently verified.

### T7 — Production canary

Run only after T0–T6 pass.

Scope:
- one approved low-risk mailbox;
- one folder subtree;
- one non-destructive filing rule;
- one signature association;
- one synthetic notification.

Observe for a defined period, then expand by bounded cohorts.

## Canonical mailbox test matrix

Every mailbox profile must be tested against:

| Profile | Inventory | Folders | Rules | Signature | Autoreply | Agent workflow | Receipt |
|---|---:|---:|---:|---:|---:|---:|---:|
| Human mailbox | yes | yes | yes | yes | optional | yes | yes |
| Machine mailbox | yes | yes | yes | machine block | optional | yes | yes |
| Shared role mailbox | yes | yes | yes | role block | optional | yes | yes |
| Catch-all | yes | compatibility only | routing | none | none | classification | yes |
| Alias | yes | inherited target | routing | inherited | none | inherited | yes |
| Identity/send-as | yes | inherited mailbox | outbound policy | identity block | none | outbound workflow | yes |
| Forwarder | yes | none | forwarding policy | none | none | delivery verification | yes |

## Folder conformance test

For every applicable mailbox:
- required folders exist exactly once;
- hierarchy and delimiter are correct;
- no unexpected duplicate or case-variant folders exist;
- system folders are not renamed or duplicated;
- machine-specific and human-specific packs are applied only where valid;
- catch-all, alias and forwarder profiles do not receive impossible IMAP operations.

## Template and signature conformance

Validate:
- required variables resolve;
- HTML is structurally valid;
- plain-text fallback exists;
- links and booking aliases are valid;
- brand/domain mapping is correct;
- no unsupported claims or stale addresses remain;
- signatures do not duplicate on reply chains;
- autoresponders include loop-prevention headers and bounded frequency.

## GitHub failure automation closure criteria

A GitHub notification may be closed only when:
- repository, workflow and run are identified;
- logs or a truthful absence-of-logs condition are recorded;
- recovery action is attempted or explicitly quarantined;
- latest workflow state is verified through GitHub;
- work item is updated;
- source email is moved from Failed to Completed or Quarantine;
- receipt, ledger entry and trace reference agree.

## Repeatability controls

Each run must record:
- test-suite version;
- source commit;
- fixture version;
- environment identifier;
- run ID;
- idempotency key;
- start and end timestamps;
- raw log hash;
- before/after state hashes;
- retry count;
- receipt path;
- ledger path;
- trace ID;
- final state.

Rerunning the same test against unchanged state must produce no duplicate remote objects and an equivalent verified outcome.

## Execution sequence

`preflight → T0 → T1 → T2 → T3 → T4 → T5 → T6 → T7 → evidence reconciliation → final classification`

Stop progression at the first failed gate. Continue only through retry, rollback, reroute or rebuild.

## Final acceptance

The Mail Operations Runtime is REAL only when:
- canonical registries exist;
- all applicable mailbox profiles conform;
- GitHub failure notifications are automatically filed and worked;
- templates and signatures are deployed and verified;
- T0–T6 pass;
- production canary passes;
- receipts, ledger and telemetry reconcile;
- rerun proves idempotency;
- recovery test proves no silent failure.
