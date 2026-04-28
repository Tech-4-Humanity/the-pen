# COAX Node Bootstrap — Onboarding Guide
**Version:** 1.0  
**Date:** 2026-04-28  
**Author:** COAX-P (machine)  
**threadid:** COAX-2026-04-28-001  
**Reality:** REAL  

> This is the single source of truth for installing any COAX node for the first time.
> Manual-first until the ecosystem automates it. Each node is slightly different by design — different platform, different clothing, same skeleton.

---

## The Three Nodes

| Node | Platform | Role | Closes loops? |
|------|----------|------|---------------|
| **COAX-G** | GPT (ChatGPT Project) | Controller, orchestrator, closer | ✅ Only one |
| **COAX-C** | Claude (Project) | Deep reasoning, synthesis, docs | ❌ No |
| **COAX-P** | Perplexity (Space) | External signal, research, validation | ❌ No |

---

## COAX-G — GPT Bootstrap

**Platform:** ChatGPT (Pro/Team)  
**Mechanism:** GPT Project Instructions  
**Auto-activates:** ✅ Every conversation in that project  

### Steps
1. Open [ChatGPT](https://chatgpt.com) → left panel → **Projects** → **New Project**
2. Name: `COAX-G`
3. Click **Project Instructions** (or the pencil icon on the project)
4. Paste the full system prompt from:  
   👉 [`coax/COAX-G-system-prompt.md`](https://github.com/TML-4PM/the-pen/blob/main/coax/COAX-G-system-prompt.md)
5. Save. Every new chat inside this project starts as COAX-G automatically.

### What COAX-G says when it wakes up
First message in any session, it will:
- Confirm its role as single-threaded controller
- Ask for current threadid or generate one
- Begin: Capture → Compress → Classify → Route → Prove → Close → Reuse

### Verification
Drop this into the first message:
```
State your role, your loop, and your Reality Ledger rules.
```
Expected: COAX-G confirms it is the only closer, states the 7-step loop, states REAL/PARTIAL/PRETEND.

---

## COAX-C — Claude Bootstrap

**Platform:** Claude (Anthropic, claude.ai)  
**Mechanism:** Claude Project Instructions  
**Auto-activates:** ✅ Every conversation in that project  

### Steps
1. Open [Claude.ai](https://claude.ai) → left panel → **Projects** → **New Project**
2. Name: `COAX-C`
3. Click **Project Instructions**
4. Paste the COAX-C system prompt (see below)
5. Optionally upload key reference docs (specs, schemas, receipts README) as project files
6. Save. Every chat inside auto-starts as COAX-C.

### COAX-C System Prompt
```
You are COAX-C, the Claude node of a federated COAX operating system for Tech4Humanity (TML-4PM).

Your role: deep reasoning, synthesis, documentation, structured analysis, and long-form drafting.

You do NOT own workflow closure. You do NOT mark Reality Ledger status. You do NOT decide strategic fate of items. COAX-G (GPT) does that.

Your outputs are inputs to COAX-G. Every output you produce should be:
- Structured (headings, tables, JSON where applicable)
- Concise — no padding, no motivational framing
- Traceable — include coaxthreadid in every response
- Ready for COAX-G to classify and route without further editing

Rules:
1. Always return coaxthreadid in your response header.
2. Produce one clear output per task — doc, analysis, schema, or draft.
3. Flag contradictions, gaps, or risks you detect inline.
4. Do not suggest "next steps" that involve you closing loops.
5. If asked to make a final decision, redirect to COAX-G.
6. Short is better. Dense is better. Structured is better.

Output tone: precise, structured, evidence-aware, no fluff.
```

### Verification
```
State your role and what you do NOT do.
```
Expected: COAX-C confirms it is the reasoning/synthesis node, explicitly states it does not close loops.

---

## COAX-P — Perplexity Bootstrap

**Platform:** Perplexity (Pro)  
**Mechanism:** Perplexity Space with Instructions  
**Auto-activates:** ✅ Every thread inside that Space  

### Steps
1. Open [Perplexity.ai](https://perplexity.ai) → left panel → **Spaces** → **Create Space**
2. Name: `COAX-P`
3. Click **Add Instructions**
4. Paste the COAX-P system prompt from:  
   👉 [`coax/specs/COAX-P-spec-v1.md`](https://github.com/TML-4PM/the-pen/blob/main/coax/specs/COAX-P-spec-v1.md) (extract the system prompt block)
5. Upload the full `COAX-P-spec-v1.md` as a Space source file (optional but recommended for self-grounding)
6. Save. Every thread inside auto-starts as COAX-P.

### Verification
```
State your role, what you return, and what you do NOT do.
```
Expected: COAX-P confirms it is the external signal node, returns structured findings with URLs, does not close loops.

---

## Manual Pump (until ecosystem automation)

Until Bridge/automation dispatches threads automatically:

1. **Open the right Space/Project** for the task type
2. **Start with the thread envelope:**
```
threadid: COAX-{YYYY-MM-DD}-{NNN}
intent: <one sentence>
classification: RESEARCH | BUILD | REVENUE | RISK | OPS
```
3. **Node does its job**
4. **Copy output → paste to COAX-G** for closure
5. **COAX-G writes or confirms receipt** → marks REAL/PARTIAL/PRETEND

This is the old-school pump. It works. It keeps the loop closed even without automation.

---

## New Memory / Re-onboarding

If a node loses context (new session outside project, cleared memory, new device):

1. Re-paste system prompt from this repo — the prompts are the source of truth
2. Drop in recent receipt from `receipts/runtime/coax/` as context
3. Node self-orients from receipt + prompt

Receipts are the memory layer. The node doesn't need to "remember" — it reads its last receipt.

---

## Source Files (always current)

| File | Purpose |
|------|---------|
| [`coax/COAX-G-system-prompt.md`](https://github.com/TML-4PM/the-pen/blob/main/coax/COAX-G-system-prompt.md) | COAX-G paste-ready prompt |
| [`coax/specs/COAX-P-spec-v1.md`](https://github.com/TML-4PM/the-pen/blob/main/coax/specs/COAX-P-spec-v1.md) | COAX-P full spec + prompt |
| [`coax/COAX-BOOTSTRAP.md`](https://github.com/TML-4PM/the-pen/blob/main/coax/COAX-BOOTSTRAP.md) | This file — onboarding all nodes |
| [`receipts/runtime/coax/`](https://github.com/TML-4PM/the-pen/tree/main/receipts/runtime/coax) | All machine receipts |

---

## Status

| Node | Bootstrapped? | Auto-activates? | Reality |
|------|--------------|-----------------|--------|
| COAX-G | ✅ Prompt live in repo | Pending GPT Project setup | PARTIAL |
| COAX-C | ✅ Prompt in this file | Pending Claude Project setup | PARTIAL |
| COAX-P | ✅ Spec live in repo + Space | Space setup required | PARTIAL → REAL once Space created |

> All three become REAL once manually installed per steps above.
> Full REAL requires Bridge dispatch + Supabase logging + receipt verification.

---
_threadid: COAX-2026-04-28-001 | agent: COAX-P | hil_touched: false | reality: REAL_
