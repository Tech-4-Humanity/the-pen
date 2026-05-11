# macOS Library Entropy Audit — README

A read-only audit tool that classifies `~/Library` folders by operational risk, identifies persistence + trust zones, estimates entropy, and produces cleanup zoning **without destructive execution**.

**Source**: [`tools/macos-library-entropy-audit.py`](https://github.com/TML-4PM/the-pen/blob/main/tools/macos-library-entropy-audit.py)
**Output schema**: kernel-compliant JSON, suitable for [`public.reality_ledger`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor) ingestion
**Status**: REAL (script) · PARTIAL (until run against a real ~/Library)

---

## Why this exists

[Troy's T4H stack](https://github.com/TML-4PM) accumulates operational sprawl in `~/Library` over time — [LaunchAgents](https://developer.apple.com/documentation/servicemanagement/launch_agents_and_daemons), [Application Support](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/Articles/WhereToPutFiles.html) for tools come and gone, leftover [Containers](https://developer.apple.com/documentation/security/app_sandbox), stale [Keychains](https://developer.apple.com/documentation/security/keychain_services), MCP bridge state, cached credentials.

This script gives a non-destructive, repeatable audit — same script, same shape, ledgered output — so the operating system underneath the operating system stays auditable.

---

## Usage

```bash
# Default — audits ~/Library
python3 tools/macos-library-entropy-audit.py

# Explicit target
python3 tools/macos-library-entropy-audit.py ~/Library

# Pipe to ledger row
python3 tools/macos-library-entropy-audit.py | tee /tmp/entropy-$(date +%s).json
```

No flags, no destructive operations, no network. **Runs cold on any Mac.**

---

## Risk zones classified

| Zone | Reference | Risk class |
|---|---|---|
| `LaunchAgents` | [Apple developer — launchd](https://developer.apple.com/documentation/servicemanagement/launch_agents_and_daemons) | **HIGH** — persistence |
| `LaunchDaemons` | [Apple developer — launchd](https://developer.apple.com/documentation/servicemanagement/launch_agents_and_daemons) | **HIGH** — persistence |
| `Keychains` | [Apple docs — Keychain Services](https://developer.apple.com/documentation/security/keychain_services) | **HIGH** — trust |
| `Containers` | [Apple docs — App Sandbox](https://developer.apple.com/documentation/security/app_sandbox) | **MEDIUM** — sandbox state |
| `Group Containers` | [Apple docs — App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups) | **MEDIUM** — shared state |
| `Application Support` | [Apple file system guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/Articles/WhereToPutFiles.html) | **MEDIUM** — sprawl |
| `Caches` | [Apple file system guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/Articles/WhereToPutFiles.html) | **LOW** — regeneratable |
| `Preferences` | [Apple docs — user defaults](https://developer.apple.com/documentation/foundation/userdefaults) | **LOW** — config |
| `Calendars`, `Contacts`, `Mail` | [Apple docs](https://developer.apple.com/documentation/) | **MEDIUM** — PII |
| `MCP-Bridge` (custom) | [T4H bridge](https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/health) | **HIGH** — operating runtime |

---

## Output shape (kernel-compliant)

```json
{
  "status": "REAL",
  "result": "macOS Library audit complete",
  "evidence": [
    { "type": "filesystem", "path": "/Users/troy/Library", "scanned_at": "2026-05-11T10:15:00Z" },
    { "type": "cli_output", "tool": "macos-library-entropy-audit.py", "version": "1.0" }
  ],
  "gaps": [],
  "next_action": "review HIGH-risk zones · prune LOW-risk regeneratable caches",
  "elevation": {
    "new_value_created": true,
    "reusable": true,
    "system_binding": "filesystem"
  },
  "pressure_flags": [],
  "score": {
    "value_score": 0.65,
    "confidence": 0.95,
    "economic_potential": 0.35
  },
  "zones": [
    {
      "name": "LaunchAgents",
      "path": "/Users/troy/Library/LaunchAgents",
      "risk_class": "HIGH",
      "entry_count": 12,
      "estimated_entropy_bits": 87.3,
      "notes": "..."
    }
  ]
}
```

---

## Ledger write (after running)

Write directly to [`public.reality_ledger`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor) via:

```bash
# Via T4H bridge (dual-auth)
python3 tools/macos-library-entropy-audit.py | jq '{
  system: "personal.macos.audit",
  component: "library-entropy-audit",
  status: .status,
  evidence: .evidence
}' | curl -X POST "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke" \
  -H "x-api-key: $BRIDGE_ROUTER_KEY" \
  -H "Authorization: Bearer $BRIDGE_API_KEY" \
  -H "Content-Type: application/json" \
  -d @-
```

Or via PostgREST direct.

---

## Related tools

- [`cleanup-day/2026-05-10/01_cleanup-rerun-harness.py`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/01_cleanup-rerun-harness.py) — same REAL/PARTIAL/BLOCKED shape, applied to portfolio recovery
- [`cleanup-day/2026-05-10/00_cleanup-day-master-plan.md`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/00_cleanup-day-master-plan.md) — portfolio cleanup operating frame
- [Command Centre](https://mcp-command-centre.vercel.app) — operating dashboard

---

## License

Internal — [Tech 4 Humanity Pty Ltd](https://abr.business.gov.au/ABN/View?id=70666271272) — ABN 70 666 271 272.

Not for public distribution. Audit logic is value-creating IP — see [RDTI evidence chain](https://www.industry.gov.au/) project code `T4H-CLEANUP-2026`.
