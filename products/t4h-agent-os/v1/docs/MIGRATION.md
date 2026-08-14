# Migration from the Qwen-labelled preview

The previous package coupled the product identity and installation paths to Qwen. V1 makes Qwen or Ollama an optional provider rather than the product.

## New canonical locations

- catalogue: `~/.t4h-agent-os/catalog`
- runtime: `~/.local/share/t4h-agent-os`
- CLI: `~/.local/bin/agent-os`
- macOS service: `au.com.tech4humanity.t4h-agent-os`
- Linux service: `t4h-agent-os.service`

## Remove the 71 legacy managed definitions safely

Preview the exact match set:

```bash
python3 migrate_from_qwen.py
```

Back up and remove only the matched 39 agent, 26 arena and 6 playbook files:

```bash
python3 migrate_from_qwen.py --apply
```

Unrelated files in `~/.qwen` are never removed. Historical GitHub releases remain as provenance and are marked superseded rather than rewritten.
