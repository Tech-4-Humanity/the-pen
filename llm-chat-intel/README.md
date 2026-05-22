# LLM Chat Intelligence — v1.0

Forensic console over 4,074 cross-LLM conversations stored in Supabase `public.chat_conversations`.

Live at **https://the-pen-six.vercel.app/llm-chat-intel/**

## Purpose
Built to support the **Tech 4 Humanity ATO compliance review (10 June 2026)**. Answers questions like:
- Which chats discuss the bridge but show no code?
- Which chats have code but no receipt — i.e. RDTI evidence gaps?
- How many times was "novel" claimed across all LLM conversations?
- Where did we change plans, pivot, or revise approach?
- Which chats touch ATO/RDTI directly?

## Architecture
- **Front end**: single static `index.html`, deployed under `/llm-chat-intel/` on the-pen Vercel project
- **Back end**: Supabase RPC `public.fn_llm_chat_intel_query` (security definer, read-only)
- **Auth**: Supabase publishable key (frontend-safe, restricted to this RPC)
- **Sources indexed**: claude (630), gpt (3027), grok (417)

## Signal derivation (all done server-side in SQL)
| Signal       | Detection                                                                |
|--------------|--------------------------------------------------------------------------|
| has_code     | ``` blocks OR SELECT/INSERT/UPDATE/DELETE/def/import/const/function      |
| has_receipt  | receipt/confirmation/confirmed/invoice OR ✅                              |
| has_bridge   | "bridge" anywhere                                                        |
| has_novel    | "novel" anywhere                                                         |
| has_plan_change | pivot/changed plan/new plan/revised plan/new direction/scrap that     |
| has_ato      | ato/rdti/r&d tax/tax office/audit/austrade                               |

## Query modes
1. **Pills** — toggle each signal +/−/any
2. **Text query** — natural language parsed: "bridge but no code", "missing receipt"
3. **Voice** — Australian English via Web Speech API
4. **Saved queries** — 8 one-tap presets for the most-asked questions
5. **Service catalog surfaces** — derived business-line view (ConsentX, OutcomeReady, SmartPark, etc.)

## Exports
- JSON of full query result
- CSV of rows
- Share link (filters round-trip via URL params)
- Receipt JSON (forensic evidence artifact)

## Receipts
See `/llm-chat-intel/receipts/` for deployment receipts.
