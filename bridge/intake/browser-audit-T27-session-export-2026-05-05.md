# T27 — Browser Session Export Audit Row

Date: 2026-05-05
Source: `Pasted text(260).txt`
Citation in ChatGPT: `turn24file0`

## What this is

A large browser/bookmark/session export showing 955 total items and multiple dated tab groups across Claude, GitHub, Supabase, Vercel, Google Drive, Gmail, Lovable, Grok, Perplexity, research docs, product sites and execution threads.

This must be treated as an occurrence-level recovery source, not a title list.

## Key evidence from source

The source explicitly shows:

- `All 955`
- category buckets including Claude, Unknown, HOB, Tech/MCP, 727, Books/IP, Grants MAAT, JET, AI Sweet Spots, Rhythm Method, Trash
- latest shared group: 40 tabs at `01/05/2026 10:55:04`
- major dated groups from April and March 2026
- many execution-related Claude tabs: Bridge, Pen, Command Centre, cron, deployment, validation, completion, payloads, receipts
- many research/product tabs: AI Sweet Spots, IA SS + DRUGS, ADHD, Outcome Ready, Reading Buddy, GCBAT, MyNeuralSignal, AHC, HoloOrg, Apex, All-Chemist, OwnMyAI, AI Oopsies, Rhythm Method

## Classification

status: PARTIAL
result: Browser export indexed as T27 and appended to workbook.
evidence:
- uploaded file `Pasted text(260).txt`
- workbook updated to `/mnt/data/session_browser_page_audit_closeout_T20_T27.xlsx`
gaps:
- no row-level extraction of all 955 occurrences yet
- no connector fetch of linked Google Docs / chats / repos yet
- no execution receipt cross-check yet
next_action:
- parse full export into occurrence register
- preserve same URL occurrences separately
- classify top 40 latest tabs first
- route execution-related tabs to Bridge/Pen audit queue
score: 0.96

## Bridge payload

```json
{
  "task_id": "T27_BROWSER_EXPORT_OCCURRENCE_REGISTER",
  "intent": "parse_browser_export_and_create_occurrence_level_register",
  "target_system": "bridge_or_dev",
  "status": "READY",
  "inputs": ["Pasted text(260).txt"],
  "outputs": [
    "browser-audit/browser_occurrence_register.csv",
    "browser-audit/browser_export_parser.py",
    "browser-audit/top_40_priority_queue.md",
    "browser-audit/bridge_claim_crosscheck.md"
  ],
  "success_criteria": [
    "955 source items parsed or explicitly accounted for",
    "same URL occurrences preserved",
    "dated tab groups retained",
    "execution-related tabs routed to Bridge/Pen queue",
    "research/product tabs routed to appropriate registers"
  ]
}
```

## Workbook update

Updated workbook generated in session:

`/mnt/data/session_browser_page_audit_closeout_T20_T27.xlsx`

Sheets updated:

- Dashboard
- Session_Master_Index
- Ideas_Register
- Actions_Register
- Unfinished_Work
- Assets_Code_Needed
- Opportunities
- Bridge_Payloads

## Next session instruction

```text
Recover T27 Browser Session Export.
Read bridge/intake/browser-audit-T27-session-export-2026-05-05.md.
Parse Pasted text(260).txt into occurrence-level register.
Do not dedupe by URL.
Process latest 40-tab group first, then dated groups in reverse chronological order.
Append outputs to workbook and push receipts.
```
