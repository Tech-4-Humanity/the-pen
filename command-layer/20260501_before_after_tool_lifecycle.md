# T4H Command Layer — Before/After Tool Lifecycle Demo

## Purpose
Show how a simple leadership decision used to move slowly through humans, meetings, tickets, procurement, training, and system changes — and how the Command Layer compresses that into one announcement that reaches humans, tools, systems, and agent pods on day one.

## Core Line
A tool should not find out about organisational change after the humans finish talking. The tool should hear the same command on day one, in the language it can act on.

---

## Scenario A — Buying Microsoft Next Month

### Executive Announcement
"We are standardising on Microsoft next month. Prepare teams, systems, procurement, training, security, and support for rollout."

### Before: Human-led transition
| Function | What happens | Typical delay | Failure mode |
|---|---|---:|---|
| Executive | Makes announcement | Day 0 | Assumes action starts |
| Procurement | Schedules vendor meeting | 1-3 weeks | Contract timing slips |
| IT | Waits for approved purchase | 2-6 weeks | Setup begins late |
| Security | Reviews after IT design | 3-8 weeks | Controls bolted on late |
| HR / Training | Creates comms and training late | 4-8 weeks | Users unprepared |
| Finance | Updates budget after procurement | 2-4 weeks | Cost visibility late |
| Support | Learns near go-live | 4-8 weeks | Tickets spike |
| Managers | Wait for instructions | 2-6 weeks | Mixed messaging |
| Staff | First real contact near rollout | 4-8 weeks | Anxiety and resistance |

### After: Command Layer transition
| Function | Day-one system action | Agent pod | Tool/system touched | Outcome |
|---|---|---|---|---|
| Executive | Command parsed into rollout intent, dates, constraints | Executive Translator Pod | Command Layer, HoloWall | Single source of truth created |
| Procurement | Vendor pack and contract checklist generated | Procurement Pod | procurement system, contract register | Purchase path prepared immediately |
| IT | Tenant, identity, migration, device, and integration tasks drafted | IT Rollout Pod | Microsoft admin, IAM, device management, service desk | Technical runway starts day one |
| Security | Conditional access, DLP, audit, and policy review queued | Security Pod | IAM, SIEM, policy register | Controls designed before rollout |
| HR / Training | Training paths, onboarding notes, manager scripts drafted | People Enablement Pod | LMS, HRIS, comms tools | Users prepared early |
| Finance | Budget and licence scenarios modelled | Finance Pod | forecasting, expense, subscription register | Cost understood before purchase |
| Support | Knowledge base, FAQs, support tags, escalation paths created | Support Readiness Pod | helpdesk, KB, SLA tools | Support ready before tickets arrive |
| Managers | Role-specific change brief produced | Manager Coach Pod | email, portal, HoloWall | Managers know what to say |
| Staff | Personalised readiness comms scheduled | Staff Experience Pod | email, LMS, portal | Less anxiety, earlier adoption |

### Time compression
Old path: 6-12 weeks before readiness is visible.
Command Layer path: 24-72 hours for readiness plan, with execution already underway.

---

## Scenario B — Software Patch / Feature Release

### Executive Announcement
"A critical patch is available. Prepare rollout, risk review, testing, training, and communications."

### Before
| Function | What happens | Delay | Failure mode |
|---|---|---:|---|
| IT | Opens ticket and plans maintenance | 2-10 days | Manual coordination |
| Security | Checks risk later | 2-7 days | Patch risk not prioritised |
| Product | Learns if feature affects roadmap | 1-3 weeks | Poor release notes |
| Support | Finds out after users complain | 1-2 weeks | Ticket spike |
| Training | Optional / late | 2-4 weeks | Users confused |

### After
| Function | Day-one system action | Agent pod | Tool/system touched | Outcome |
|---|---|---|---|---|
| IT | Patch window, dependency map, rollback plan generated | Patch Ops Pod | CI/CD, monitoring, asset inventory | Rollout plan ready |
| Security | CVE/risk score and exposure map produced | Security Pod | SIEM, vulnerability scanner | Risk known early |
| Product | Feature impact mapped to roadmap and release notes | Product Pod | roadmap, docs, issue tracker | Product language ready |
| Support | KB draft, macros, tags, escalation rules generated | Support Pod | helpdesk, KB | Support prepared before release |
| Training | Microlearning draft generated | Learning Pod | LMS | Users trained earlier |

---

## Scenario C — Petrol Price Shock

### Executive Announcement
"Fuel costs are rising. Reduce travel, optimise operations, and prepare lower-cost delivery models."

### Before
| Function | What happens | Delay | Failure mode |
|---|---|---:|---|
| Finance | Reforecast after meetings | 1-3 weeks | Cost leakage continues |
| HR | Adjusts travel/hiring policy late | 2-6 weeks | Mixed staff behaviour |
| IT | Reduces system/tool spend reactively | 2-4 weeks | Savings missed |
| Ops | Replans logistics manually | 3-8 weeks | Fuel waste continues |
| Marketing | Updates messaging late | 1-3 weeks | Customer confusion |

### After
| Function | Day-one system action | Agent pod | Tool/system touched | Outcome |
|---|---|---|---|---|
| Finance | Travel, fuel, vendor and margin scenarios run | Finance Control Pod | forecasting, expense, BI | Savings options same day |
| HR | Travel rules, remote work guidance, training updates drafted | People Ops Pod | HRIS, LMS, comms | Staff guidance same day |
| IT | Cloud/tool spend optimisation queued | IT Optimisation Pod | AWS, Vercel, Supabase, monitoring | Non-fuel savings found too |
| Ops | Route and delivery model simulations launched | Ops Efficiency Pod | scheduling, route, procurement | Operational savings prepared |
| Marketing | Staff/customer narrative drafted | Narrative Pod | CMS, email, social | Clear message early |

---

## Day in the Life of a Tool

### Before
A tool finds out late. Humans meet. Someone creates a ticket. The ticket lacks context. A developer or admin interprets it. Another person tests it. Another person writes comms. The tool is updated after weeks of organisational delay.

### After
The tool receives the command on day one in structured form:

```yaml
command: microsoft_standardisation
intent: prepare_rollout
effective_date: next_month
systems:
  identity:
    action: prepare_access_model
  training:
    action: draft_learning_path
  support:
    action: create_kb_and_macros
  finance:
    action: model_license_costs
validation:
  - readiness_plan_created
  - owners_assigned
  - evidence_logged
```

The human still decides where required. But the organisation no longer waits for every team to rediscover the same meaning in a different meeting.

---

## Product Message
This is not another AI chat layer. It is a command translation layer for organisational movement.

One announcement becomes:
- human-readable explanation;
- role-specific action;
- system-specific instruction;
- agent-pod execution;
- evidence-backed readiness state.

## UI Section To Add
Title: From Announcement to Organisational Movement
Subtitle: One leader. Nine translations. Dozens of tools preparing at once.

Panels:
1. Leader announcement
2. Before cascade: meetings, delays, tickets, late system updates
3. After cascade: role pods and tools activated on day one
4. Readiness board: HR, Finance, IT, Ops, Security, Support, Training, Customer

## Reality Status
status: PARTIAL
result: Narrative and implementation spec created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps: UI not yet updated; no runtime system action yet; agent pods not wired to tools.
next_action: Add the Before/After Cascade section to T4H Command Layer and connect scenario YAML cards.
elevation: Reusable product demo narrative for Command Layer, Agent Channel, AHC, and HoloWall.
pressure_flags: UI gap, runtime gap, proof gap.
score: 0.72
