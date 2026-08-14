# T4H Agent OS V1

T4H Agent OS is a provider-neutral governed workforce runtime. It turns a catalogue of specialist prompts into callable jobs with durable lifecycle state, strict output validation, receipts and readback.

## Product boundary

V1 supplies 39 specialist agents, 26 independent evaluation arenas and 6 governed playbooks. It is not 39 permanently running processes. A worker claims queued jobs and invokes the configured model command only when work exists.

## Engagement contract

`EVENT → QUEUE → CLAIM → EXECUTE → VALIDATE → RECEIPT → READBACK`

Jobs can be created by a person, CLI, API adapter, scheduled worker, webhook, another agent or a playbook. V1 ships the local CLI and worker. API, event-bus and customer-facing adapters are planned extensions.

## Internal and external use

- Internal: engineering, research, governance, audit, release and operations.
- External: customer workflows only through a signed adapter with tenant, consent, budget and authority controls.
- Shared: the registry and runtime are reusable across T4H products; customer data and credentials are never shared between tenants.

## Cost model

The runtime records provider, model, duration and exit code. V1 does not yet calculate token or third-party tool charges. Until V1.1, local Ollama work has low marginal model cost but still consumes electricity and host capacity; external commands must be costed by the calling adapter.

## Truth boundary

REAL means the requested job completed, passed schema validation and produced lifecycle receipts. It does not mean the underlying answer is automatically factually correct. High-risk work should use an arena or independent verifier.
