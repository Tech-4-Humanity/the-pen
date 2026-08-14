# T4H Agent OS V1

A provider-neutral governed workforce runtime with 39 specialist agents, 26 independent evaluation arenas, 6 playbooks and a receipt-backed job ledger.

## What changed from the preview

The product is no longer named after Qwen. Qwen and Ollama are optional model providers behind the neutral `AGENT_OS_COMMAND` contract. The registry uses execution profiles rather than model-brand labels, and installation now lives under T4H-owned paths.

## Build and validate

```bash
python3 build_agent_os.py
python3 build_dossier.py
python3 validate.py
python3 -m unittest discover -s tests -v
```

Open `dossier/index.html` for the project website and `dist/site/index.html` for the detailed generated catalogue.

## Install and activate

Run from a child shell so a bootstrap failure cannot close the parent terminal:

```bash
bash bootstrap.sh
```

The bootstrap rebuilds and validates the package, installs the catalogue, configures a persistent worker, detects Qwen CLI or Ollama, runs a real canary and prints the terminal job with receipts.

## Call work

```bash
agent-os doctor
agent-os invoke python --task "Analyse the repository"
agent-os status JOB_ID
agent-os finish JOB_ID
```

The configured provider command must contain `{prompt}`:

```bash
export AGENT_OS_COMMAND='/usr/local/bin/ollama run qwen2.5-coder:7b {prompt}'
```

## Canonical paths

- catalogue: `~/.t4h-agent-os/catalog`
- runtime and ledger: `~/.local/share/t4h-agent-os`
- CLI: `~/.local/bin/agent-os`
- macOS service: `au.com.tech4humanity.t4h-agent-os`
- Linux service: `t4h-agent-os.service`

See `docs/PRODUCT.md`, `docs/MIGRATION.md` and `docs/NEXT_ITERATIONS.md`.
