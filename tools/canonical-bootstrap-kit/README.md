# Canonical Bootstrap Kit v0.1

The Canonical Bootstrap Kit (CBK) creates and validates governed Tech 4 Humanity projects from a common canonical foundation.

## Truth boundary

A generated repository proves only that the project structure and canonical configuration exist. Runtime operation becomes REAL only after an independent execution receipt is produced and read back.

## Commands

```bash
python3 tools/canonical-bootstrap-kit/cbk.py new research ai-sweet-spots --output /tmp
python3 tools/canonical-bootstrap-kit/cbk.py validate /tmp/ai-sweet-spots
python3 tools/canonical-bootstrap-kit/cbk.py compile /tmp/ai-sweet-spots
python3 tools/canonical-bootstrap-kit/prove.py
```

Supported project types:

- research
- product
- business
- website
- experiment
- policy
- service

## Generated baseline

Every project receives:

- canonical `project.yaml`
- governance and evidence controls
- runtime configuration
- lifecycle and receipt state
- documentation
- Docker configuration
- GitHub validation workflow
- smoke tests

## Lifecycle

`IDEA -> DISCOVERY -> RESEARCH -> BUILD -> VALIDATE -> PILOT -> PRODUCTION -> OPERATE -> ARCHIVE`

## Completion state

CBK v0.1 is complete when the proof script:

1. creates a research project;
2. validates its canonical structure;
3. compiles deterministic documentation and manifest outputs;
4. verifies generated tests;
5. emits a content-addressed execution receipt;
6. independently reads the receipt back.
