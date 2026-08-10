# T4H AIDA Local

AIDA is the T4H human-facing local browser workspace. It uses Open WebUI as the browser UI and Ollama as the local model runtime. The canonical operating shortcut is `aida`, maintained in `docs/operations/t4h-shell.sh`.

## Runtime

- Ollama API: `http://localhost:11434`
- Open WebUI: `http://localhost:8080/`
- Primary model: `qwen3:8b`
- Coding model: `qwen2.5-coder:7b`
- Local Open WebUI environment: `~/.t4h-open-webui/`

Open WebUI is the external software component: https://github.com/open-webui/open-webui

## Operator contract

`aida` means **make AIDA ready**. It:

1. verifies Ollama is installed and starts the Ollama app if its API is unavailable;
2. waits for `localhost:11434`;
3. ensures `qwen3:8b` and `qwen2.5-coder:7b` are available through Ollama;
4. creates the isolated Open WebUI Python environment if needed;
5. installs Open WebUI only when the launcher is absent;
6. starts Open WebUI only when port `8080` is not already listening;
7. waits for the browser endpoint to respond;
8. performs a real Qwen inference acceptance test;
9. opens `http://localhost:8080/`;
10. emits a receipt with `REAL` only after the checks succeed.

There is no separate AIDA tunnel or second-terminal ritual. Everything is local to the Mac.

## Installation / refresh

From a Mac shell:

```bash
cd ~/projects/TML-4PM/the-pen && git pull --ff-only origin main && cp docs/operations/t4h-shell.sh ~/.t4h-shell.sh && source ~/.t4h-shell.sh && type aida && aida
```

Do not copy secrets into this file. Ollama and Open WebUI use the local runtime; credentials, if later required by an integration, must use the established secure credential mechanism.

## Truth states

- `REAL`: readiness and inference were observed by the launcher.
- `PARTIAL`: a component exists but an acceptance check has not completed.
- `BLOCKED`: a required component or readiness check failed.

The GitHub repository is canonical for the launcher and operating documentation. The Mac installation is a synchronized checkout/consumer of that canonical helper.
