# PEN Canonical Worker and Capability Registry

This registry is the live map that complements the Canonical Worker Contract.

The contract states how workers must behave. This registry states what capabilities currently exist, who provides and owns them, how they are invoked, what authority they require, what they cost, how reliable they are, how they resume, what evidence they emit, and how failure recovery works.

## Canonical files

- `capability-manifest.yaml` — boot manifest and routing entry point.
- `capabilities.yaml` — normalized capability definitions and maturity samples.
- `workers.yaml` — human and machine worker instances and capability bindings.
- `providers.yaml` — provider, runtime and alternate-provider definitions.
- `operations.yaml` — invocation, health, failure, recovery, resume and receipt contracts.

## Truth rules

1. Registration is not execution.
2. A declaration without benchmark or runtime evidence is `ASPIRATIONAL`.
3. A GitHub commit proves that the registry artefact exists, not that a provider works.
4. `REAL` requires execution, live readback, telemetry, a durable receipt and ledger confirmation.
5. Stale mutable claims must be revalidated before routing.
6. Alternate providers are selected by capability, authority, cost, reliability, residency and health—not brand preference.
7. Hidden model memory is advisory only and never canonical state.
8. Every registry entry has an owner, evidence state, lifecycle and revalidation date.

## Maturity convention

- **Expected** — minimum routable implementation with explicit inputs, outputs, authority and receipt.
- **Advanced** — benchmarked, resumable, observable and recoverable implementation with alternate routes.
- **Best** — independently verified, policy-aware, dynamically routed, replayable and continuously reconciled implementation.

## Boot sequence

A worker boots by reading `capability-manifest.yaml`, validates its own worker record, resolves the required capability, checks provider health and authority, selects an invocation route, leases the job, emits a started receipt, executes, verifies live state, writes the final receipt and updates the ledger.

No worker should need a chat message to discover the next valid action.