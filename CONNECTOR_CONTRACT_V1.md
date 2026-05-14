# CONNECTOR_CONTRACT_V1

Source of truth: GLOBAL_RULE.md

Runtime behavior:
- load_on_startup
- cache_with_hash
- reject_unknown_schema
- fail_closed

Fields:
- Name
- Trigger
- Input
- Validation
- Processing
- Output
- Failure
- Evidence
- Authority

Runtime Enforcement:
- validate_contract
- validate_authority
- validate_dependencies
- telemetry_stream
- receipt_generation
- write_reality_ledger
- attach_evidence
- publish_status

Failure Policy:
- invalid_schema=BLOCK
- unknown_authority=BLOCK
- missing_evidence=PARTIAL
- runtime_exception=RETRY
- repeated_failure=ESCALATE
