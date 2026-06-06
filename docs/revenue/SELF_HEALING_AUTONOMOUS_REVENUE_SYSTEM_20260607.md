# Self-Healing Autonomous Revenue System

Date: 2026-06-07  
Owner: Troy Latter / Tech 4 Humanity / Holo-Org Runtime  
Status: PARTIAL until AWS runtime validation receipts are attached  
Source basis: Lambda fleet names supplied from Bridge key synchronisation waves, existing Bridge/MCP operating doctrine, GitHub repository authority confirmed for `TML-4PM/the-pen`.

---

## 1. Executive summary

The current Lambda and Bridge estate should now be treated as a distributed autonomous revenue operating system, not a pile of helper functions.

The valuable system is not the individual Lambdas. The valuable system is the closed loop:

```text
Demand signal -> Offer selection -> Outreach -> Conversation -> Conversion -> Fulfilment -> Evidence -> Drift/gap detection -> Repair -> Next action
```

The system becomes commercially useful when every automation run can answer these questions:

1. What revenue path was targeted?
2. What customer, segment, or offer was touched?
3. What action was executed?
4. What evidence was produced?
5. What broke or drifted?
6. What repair was triggered?
7. What next revenue action is now queued?

---

## 2. Target operating model

### 2.1 System objective

Build and operate a self-healing autonomous revenue system that can:

- detect commercial opportunities,
- choose the right offer,
- generate and send outreach,
- monitor replies and events,
- route fulfilment work,
- record receipts,
- detect drift, gaps, auth failure, stale data, and silent drops,
- repair known failure classes,
- escalate only when blocked by authority, legal, safety, money movement, destructive action, or unavailable external dependency.

### 2.2 Commercial priority

Do not attempt to monetise all brands at once.

Primary revenue lanes:

1. **Immediate services revenue**
   - AI automation audits
   - AI for Tradies
   - Outcome Ready / Reading Buddy setup
   - Fractional CTO / automation rescue

2. **Outbound pipeline revenue**
   - LinkedIn/contact list segmentation
   - email/message campaigns
   - reply monitoring
   - appointment routing

3. **Productised evidence revenue**
   - Evidence packs
   - readiness reports
   - compliance/recovery/runtime reports
   - board-ready automation health snapshots

4. **Recurring runtime revenue**
   - monthly monitoring
   - sweeper/drift checks
   - outcome reporting
   - remediation queue handling

---

## 3. Current Lambda estate mapped to revenue system roles

The following mapping is based on the function names supplied from the two Bridge key synchronisation waves.

### 3.1 Control plane

| Function | Role | Revenue value |
|---|---|---|
| `troy-orchestrator` | primary system brain | chooses and chains revenue actions |
| `troy-task-orchestrator` | task routing | turns intent into runnable units |
| `troy-fire-orchestrator` | escalation/continuity control | keeps stuck work moving |
| `autonomy-controller` | autonomy policy | controls when the system acts without human input |
| `sos-llm-router` | model/tool routing | routes work to suitable LLM/tool paths |
| `mcp-bridge-invoke-handler` | Bridge ingress | receives external/runtime commands |
| `synal-task-execution-api` | task API surface | exposes execution to Synal/agent chains |

### 3.2 Execution fabric

| Function | Role | Revenue value |
|---|---|---|
| `bridge-runner-task-executor` | generic task executor | performs work units |
| `troy-bridge-runner` | main Bridge execution runner | runtime workhorse |
| `bridge-runner-writing` | writing/output worker | produces messages, proposals, assets |
| `bridge-runner-research` | research worker | collects evidence, market/customer data |
| `bridge-runner-distribution` | distribution worker | sends/publishes/routs outputs |
| `bridge-runner-reading` | reading/comprehension worker | supports Reading Buddy and document workflows |
| `synal-auto-execute-agent-chain` | agent-chain executor | runs multi-agent flows |

### 3.3 Revenue actuators

| Function | Role | Revenue value |
|---|---|---|
| `tradie-ai-outbound` | outbound campaign sender | direct small business revenue |
| `tradie-ai-reply-monitor` | reply monitor | detects leads and follow-up triggers |
| `troy-email-send` | email sender | outbound and follow-up channel |
| `t4h-campaign-worker` | campaign worker | campaign execution |
| `t4h-snap-email` | snapshot emailer | report distribution |
| `t4h-morning-brief` | daily brief | control-tower daily operating loop |
| `troy-sns-sms-sender-oneshot` | SMS sender | urgent/short-form contact path |
| `troy-telegram-ingress` | Telegram input | mobile command/control |
| `troy-page-publisher` | page publisher | publishes sales/support pages |
| `spiral-app-publish-choice-card` | choice-card publisher | publishes decision/product cards |
| `spiral-app-deploy-to-aws` | deployment actuator | ships selected app changes |
| `nf-stripe-webhook-handler` | Stripe webhook | payment event capture |
| `troy-stripe-webhook-handler` | Stripe webhook | payment event capture |
| `nf-fulfilment-handler` | fulfilment | post-sale delivery |

### 3.4 Evidence, truth, and recovery

| Function | Role | Revenue value |
|---|---|---|
| `tk-evidence-logger` | evidence logger | turns actions into receipts |
| `spiral-app-record-evidence` | evidence capture | records proof of activity |
| `command-centre-reality-verifier` | reality verification | checks whether claimed work is real |
| `troy-sweeper-core` | sweeper core | continuous hygiene loop |
| `troy-sweeper-drift` | drift detector | detects mismatches and stale state |
| `troy-sweeper-gap` | gap detector | identifies missing work/dependencies |
| `troy-sweeper-repair` | repair engine | fixes known failure modes |
| `spiral-app-dry-run-checks` | dry-run validator | prevents unsafe/invalid changes |
| `spiral-app-reclassify-priority` | priority reclassifier | moves valuable work up the queue |
| `tk-gap-scorer` | gap scoring | prioritises closure |
| `tk-product-packager` | product packaging | converts work into sellable artefacts |
| `tk-pilot-ranker` | pilot ranking | chooses likely revenue pilots |

### 3.5 Support / specialist workers

| Function | Role | Revenue value |
|---|---|---|
| `gemini-pipeline` | model pipeline | research/writing support |
| `genai-itops` | IT ops automation | internal/service offer path |
| `troy-signal-engine` | signal engine | scoring/intent/signal processing |
| `troy-tab-snap` | tab snapshot capture | research/context intake |
| `troy-worker` | generic worker | execution support |
| `troy-token-refresh-worker` | token refresh | auth continuity |
| `nf-alert-emailer` | alerting | operational notification |
| `tk-widget-refresher` | widget refresh | command-centre UI freshness |
| `accountant-partner-onboarding` | partner onboarding | accountant channel revenue |
| `tk-outreach-drafter` | outreach drafting | pipeline generation |
| `spiral-app-search-github` | GitHub search | repo discovery |
| `spiral-app-rank-repos` | repo ranking | prioritises code assets |
| `spiral-app-retrofit-repo` | repo retrofit | turns code into usable assets |
| `spiral-app-detect-spiral` | pattern/drift detection | detects repeated failure/loop behaviour |
| `t4h-route53-fix-oneshot` | DNS repair | publishing reliability |

---

## 4. The money loop

The system should not start with automation. It should start with a revenue intent.

### 4.1 Revenue intent object

Every commercial run begins with:

```json
{
  "intent_type": "revenue_run",
  "offer": "ai_for_tradies_audit | outcome_ready_setup | reading_buddy_demo | fractional_cto_rescue | evidence_pack | runtime_monitoring",
  "target_segment": "tradies | providers | schools | accountants | boards | government | small_business",
  "channel": "email | linkedin | sms | telegram | page | partner",
  "target_count": 0,
  "success_metric": "reply | meeting | payment | signed_pilot | report_delivered",
  "allowed_actions": ["draft", "send", "publish", "monitor", "log", "repair"],
  "blocked_actions": ["charge_card", "sign_contract", "delete_data", "legal_commitment"]
}
```

### 4.2 Closed-loop flow

```text
1. troy-orchestrator receives revenue_intent
2. troy-task-orchestrator decomposes it into work units
3. bridge-runner-research enriches targets/context
4. tk-pilot-ranker prioritises likely buyers
5. tk-outreach-drafter / bridge-runner-writing creates messages
6. troy-email-send / tradie-ai-outbound / t4h-campaign-worker sends or stages outreach
7. tradie-ai-reply-monitor / troy-telegram-ingress catches response signals
8. nf-fulfilment-handler / tk-product-packager creates delivery artefact
9. tk-evidence-logger records receipts
10. command-centre-reality-verifier checks claimed completion
11. troy-sweeper-gap and troy-sweeper-drift inspect missing/stale/broken links
12. troy-sweeper-repair fixes known issues
13. troy-orchestrator queues next best action
```

---

## 5. Canonical event contract

Every function in the revenue system must accept and emit the same envelope.

### 5.1 Input envelope

```json
{
  "task_id": "uuid",
  "parent_task_id": "uuid|null",
  "run_id": "uuid",
  "source": "chatgpt|bridge|telegram|scheduler|sweeper|webhook",
  "intent": "revenue_run|repair|verify|publish|outreach|fulfilment|research",
  "offer": "string|null",
  "target": {
    "type": "person|company|segment|repo|lambda|page|campaign",
    "id": "string|null",
    "name": "string|null",
    "contact": "string|null"
  },
  "payload": {},
  "constraints": {
    "allow_send": false,
    "allow_publish": false,
    "allow_repair": true,
    "allow_money_movement": false,
    "allow_destructive": false
  },
  "evidence_required": true,
  "created_at": "iso-8601"
}
```

### 5.2 Output envelope

```json
{
  "task_id": "uuid",
  "run_id": "uuid",
  "status": "REAL|PARTIAL|BLOCKED|FAILED",
  "result": {
    "summary": "string",
    "outputs": []
  },
  "evidence": [
    {
      "type": "api_response|db_result|cli_output|commit_id|url|hash|log_line|repro_steps",
      "value": "string",
      "source": "string",
      "timestamp": "iso-8601"
    }
  ],
  "gaps": [],
  "next_action": [],
  "elevation": "what changed / why this improved the system",
  "pressure_flags": [],
  "score": {
    "execution": 0.0,
    "evidence": 0.0,
    "economic": 0.0,
    "reuse": 0.0,
    "delta": 0.0,
    "overall": 0.0
  }
}
```

---

## 6. Self-healing rules

### 6.1 Drift classes

The sweeper layer should detect:

| Drift | Detector | Repair |
|---|---|---|
| auth drift | `troy-sweeper-drift` | reload canonical key from SSM and patch env vars |
| missing evidence | `command-centre-reality-verifier` / `tk-evidence-logger` | rerun evidence capture or downgrade to PARTIAL |
| stalled task | `troy-sweeper-core` | retry or requeue with capped backoff |
| missing downstream call | `troy-sweeper-gap` | invoke missing runner or mark BLOCKED |
| stale campaign | `t4h-campaign-worker` / sweeper | refresh target list and next action |
| failed publish | `troy-page-publisher` / `t4h-route53-fix-oneshot` | repair DNS/deploy/publish path |
| webhook disconnect | Stripe handlers | replay/check webhook event and log |
| model/tool routing failure | `sos-llm-router` | fallback to alternative model/tool |

### 6.2 Safe autonomous repair boundary

Allowed without human input:

- refresh non-user-facing drafts,
- re-run failed idempotent tasks,
- patch environment variables to canonical key where authority exists,
- create evidence receipts,
- classify gaps,
- requeue tasks,
- publish internal docs,
- repair DNS/config when prior authority exists.

Blocked without explicit runtime authority:

- charging money,
- signing contracts,
- deleting production data,
- sending legally sensitive claims,
- changing customer terms,
- destructive infra operations,
- bypassing consent or privacy rules.

---

## 7. Revenue products produced by the system

### 7.1 AI Automation Rescue Pack

Buyer: small business, tradie, founder, board, operator.  
Output: 5-10 page operational audit with automation gaps, quick wins, risk map, and fixed-price implementation options.  
Automation path: research -> evidence -> writing -> page/email -> follow-up.

### 7.2 Outcome Ready / Reading Buddy Setup Pack

Buyer: families, schools, providers, allied health.  
Output: reading improvement plan, consent/state setup, progress dashboard, evidence pack.  
Automation path: intake -> reading workflow -> outcome logging -> report -> recurring monitoring.

### 7.3 Runtime Evidence Pack

Buyer: boards, investors, operators, regulated teams.  
Output: evidence-bound report proving what ran, what failed, what repaired, and what remains blocked.  
Automation path: verifier -> evidence logger -> sweeper -> packager -> distribution.

### 7.4 Monthly Autonomy Monitoring

Buyer: any customer using automations.  
Output: monthly report, drift fixes, blocked actions, ROI/effort saved.  
Automation path: scheduler -> sweeper -> evidence -> package -> email.

---

## 8. First executable revenue chain

The fastest practical money path is `AI for Tradies` because the estate already has named functions for tradie outbound and reply monitoring.

### 8.1 Chain name

`tradie_ai_revenue_loop_v1`

### 8.2 Runtime sequence

```text
revenue_intent
  -> troy-orchestrator
  -> troy-task-orchestrator
  -> bridge-runner-research
  -> tk-pilot-ranker
  -> tk-outreach-drafter
  -> tradie-ai-outbound
  -> tradie-ai-reply-monitor
  -> troy-email-send / troy-telegram-ingress
  -> tk-product-packager
  -> tk-evidence-logger
  -> command-centre-reality-verifier
  -> troy-sweeper-gap
  -> troy-sweeper-drift
  -> troy-sweeper-repair
  -> next best action
```

### 8.3 Offer

**AI Automation Check for Trades Businesses**

Plain offer:

> I’ll find the admin, quoting, follow-up, booking, invoice, and customer-response gaps costing your trade business time and money, then give you a practical automation plan you can actually use.

Starter price options:

- $250 quick check
- $750 audit + implementation map
- $1,500 setup sprint
- $3,000 monthly automation support package

### 8.4 Success metrics

| Metric | Target |
|---|---:|
| Contacts touched | 100/day initially |
| Reply rate | 3-8% |
| Meeting conversion from replies | 25-40% |
| Paid quick checks | 1-3/week |
| Monthly support conversions | 1-2/month |

---

## 9. Validation commands to run in AWS CloudShell

These commands prove runtime state. They are not yet executed by this GitHub commit.

### 9.1 Invoke orchestrator

```bash
aws lambda invoke \
  --function-name troy-orchestrator \
  --payload '{}' \
  orchestrator-out.json
cat orchestrator-out.json
```

### 9.2 Invoke drift and gap sweepers

```bash
aws lambda invoke --function-name troy-sweeper-drift drift.json
cat drift.json

aws lambda invoke --function-name troy-sweeper-gap gap.json
cat gap.json
```

### 9.3 Tail evidence and core logs

```bash
aws logs tail /aws/lambda/tk-evidence-logger --since 15m
aws logs tail /aws/lambda/troy-sweeper-core --since 15m
aws logs tail /aws/lambda/troy-orchestrator --since 15m
```

### 9.4 Minimum pass condition

A run is REAL only if it has:

- Lambda invoke response,
- no auth failure,
- downstream routing evidence,
- evidence logger receipt,
- gap/drift output,
- next action emitted.

Otherwise it is PARTIAL.

---

## 10. Implementation backlog

### Immediate

1. Standardise function input/output envelope.
2. Attach every run to `run_id` and `task_id`.
3. Ensure `tk-evidence-logger` receives receipts from all core paths.
4. Make `command-centre-reality-verifier` the downgrade authority.
5. Make `troy-sweeper-gap` emit executable repair actions, not just observations.
6. Make `troy-sweeper-repair` idempotent and capped to prevent infinite loops.
7. Use `t4h-morning-brief` as the daily board/control-tower report.

### Next

1. Add campaign object table.
2. Add lead object table.
3. Add offer object table.
4. Add evidence object table.
5. Add revenue event table.
6. Add repair event table.
7. Add replay queue.
8. Add monthly recurring report generator.

---

## 11. Board-ready model

### 11.1 What exists

- Distributed Lambda execution fleet.
- Bridge/MCP invocation layer.
- Multiple specialised runners.
- Outbound and publishing functions.
- Evidence and sweeper functions.
- Canonical Bridge key propagation completed from SSM across named functions according to user terminal output.

### 11.2 What remains unproven

- End-to-end runtime execution.
- Evidence logger receipt continuity.
- Sweepers repairing actual failures.
- Campaign-to-revenue conversion.
- 72-hour unattended survivability.

### 11.3 Status

PARTIAL.

Reason: configuration update was evidenced by terminal output, and this blueprint is committed, but live runtime validation and revenue-chain receipts have not yet been attached in this artefact.

---

## 12. Reality Ledger

| Field | Value |
|---|---|
| task_id | self_healing_autonomous_revenue_system_20260607 |
| intent | Convert Bridge/Lambda automation estate into a self-healing autonomous revenue system |
| execution | GitHub artefact created; AWS runtime commands supplied for validation |
| output | Revenue-system blueprint, Lambda role map, canonical event contract, self-healing rules, first revenue chain |
| status | PARTIAL |
| evidence | GitHub commit SHA returned by connector; prior user terminal output showing Lambda env updates |
| gaps | AWS Lambda runtime validation not executed from this chat; no CloudWatch logs attached; no customer/revenue receipts attached; 72h survivability unproven |
| next executable action | Run CloudShell validation commands in section 9 and attach outputs to evidence ledger |
| score.execution | 0.62 |
| score.evidence | 0.58 |
| score.economic | 0.82 |
| score.reuse | 0.91 |
| score.delta | 0.84 |
| score.overall | 0.75 |

---

## 13. Definition of done for REAL

This becomes REAL when:

1. `troy-orchestrator` invokes successfully.
2. At least one revenue chain emits a `run_id`.
3. `tk-evidence-logger` records the run.
4. `troy-sweeper-gap` and `troy-sweeper-drift` inspect the run.
5. `troy-sweeper-repair` repairs or explicitly downgrades at least one known gap.
6. `t4h-morning-brief` reports status the next day.
7. A real lead/reply/payment/report delivery event is attached.
8. System survives 72 hours without manual credential repair.
