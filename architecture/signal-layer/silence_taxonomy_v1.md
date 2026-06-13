# Silence Taxonomy v1

Parent: #170
Issue: #174
Status: PARTIAL

## Principle
Absence is a signal.

## Silence Types
### Agent Silence
Expected heartbeat missing.

### Domain Silence
Expected signals missing from a business domain.
Examples:
- sales
- finance
- delivery
- support

### Runtime Silence
Execution activity missing.

### Decision Silence
No decisions recorded within expected window.

### Evidence Silence
Signals exist but evidence does not.

### Economic Silence
Activity exists but value signals do not.

## Severity Guidance
- low
- medium
- high
- critical

Severity depends on duration, impact, and affected systems.

## Required Attributes
- silence_type
- detected_at
- expected_signal
- affected_scope
- duration
- severity
- recovery_required

## Escalation Path
SILENCE_DETECTED
-> ESCALATION_REQUIRED
-> RECOVERY_STARTED
-> RECOVERY_CHECKED
-> RECOVERY_CLOSED

## Consumers
- spine
- synal
- orchestrator
- runtime_truth

Ledger:
- task_id: signal-silence-174
- status: PARTIAL
