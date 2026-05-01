# Doolittles — Tool Mesh Build Spec

## Core thesis
No tool is isolated, just like no person is isolated. A leadership command should reach people, tools, and agent pods at the same time. Slack, ServiceNow, Salesforce, SAP, Microsoft, HRIS, LMS, payroll, IAM, call centre, TVs, rooms, dashboards, and procurement systems all sit inside the same organisational language problem.

Doolittles is the layer that translates one command into:
- person-specific communication;
- role-specific action;
- tool-specific payloads;
- cross-tool orchestration;
- evidence-backed completion.

## Working product line
Talk to the animals. Then make the animals talk to each other.

---

## Key distinction — change in-system vs out-of-system

Every command must be classified by where the change occurs.

| Change type | Meaning | Example | Risk | Execution mode |
|---|---|---|---|---|
| In-system change | The target tool is the thing being changed | Configure ServiceNow queue, update Salesforce field, change SAP workflow | Medium/high | gated automation with rollback |
| Out-of-system change | The tool communicates or prepares around a change elsewhere | Slack announces SAP change; LMS trains users before SAP rollout | Low/medium | faster automation |
| Cross-system change | One system action triggers another system action | ServiceNow ticket posts to Slack; Microsoft rollout creates LMS training | Medium/high | orchestration with evidence chain |
| Physical-world change | Digital command affects physical environment | turn off TVs, change room booking, reduce desks, reroute deliveries | High | policy-gated execution |
| Human-behaviour change | The main impact is people adopting new behaviour | staff cuts, new travel policy, new Microsoft workflow | Medium | personalised communication + training |

---

## Tool mesh priority — systems needing most agentic interaction

| System | Why it matters | Agentic power | Best Doolittles use |
|---|---|---:|---|
| ServiceNow | Work, change, incident, request, support and governance rail | Very high | Create/change tickets, KBs, macros, workflows, approvals, service actions |
| Slack | Human/team communication and escalation rail | Very high | Personalised alerts, pod coordination, status broadcasts, neuroinclusive comms |
| Microsoft 365 / Teams / Entra | Identity, docs, collaboration, rooms, devices | Very high | Tenant/IAM readiness, Teams comms, SharePoint docs, access changes |
| Salesforce | Customer/revenue system | High | Account impact, messaging, churn risk, sales enablement, customer tasks |
| SAP | Finance, procurement, supply, HR, operations core | High | Model cost, procurement, supply and downstream process impact |
| Workday / HRIS | People structure, onboarding, org chart, workforce lifecycle | High | Role changes, onboarding/offboarding, training triggers |
| LMS | Training and adoption | High | Generate and assign training before rollout hits users |
| Payroll / Finance tools | Cost, wages, workforce impact | Medium/high | Payroll modelling, cost scenarios, change impact |
| IAM / Security tools | Access, identity, controls | Very high | Revoke/grant access, conditional access, compliance evidence |
| Call centre / CCaaS | Customer operations | High | Routing, scripts, macros, escalation flows |
| Facilities / IoT / AV / TVs | Physical environment | Medium/high | Room readiness, signage, screen notices, energy reduction, emergency response |
| BI / dashboards | Visibility and readiness | High | Show who heard, what moved, what is blocked, what proof exists |

---

## Example — ServiceNow as instrument for doing things

Leadership command:
"Reduce call centre complaints by improving Microsoft support readiness before rollout."

Doolittles translation:
```yaml
command: improve_call_centre_readiness
source: executive_announcement
systems:
  servicenow:
    create:
      - change_record: microsoft_rollout_support_readiness
      - knowledge_base_article: common_user_questions
      - ticket_macros: password_reset_teams_sharepoint_onedrive
      - escalation_rule: microsoft_rollout_p1_support
    update:
      - assignment_group: microsoft_rollout_support
      - service_catalog_item: request_m365_help
    notify:
      - slack_channel: support-readiness
  slack:
    send:
      - channel: support-readiness
        message: ServiceNow support readiness workflow created.
  lms:
    create:
      - module: Microsoft First Week Support Training
validation:
  - servicenow_records_created
  - slack_message_sent
  - lms_module_created
  - evidence_logged
```

## Example — physical command

Leadership command:
"Energy prices are rising. Reduce non-essential office screen usage after hours."

Doolittles translation:
```yaml
command: reduce_after_hours_screen_energy
systems:
  facilities_iot:
    action: turn_off_nonessential_tvs_after_7pm
  room_booking:
    action: mark_after_hours_screen_policy_active
  slack:
    action: notify_office_managers
  servicenow:
    action: create_change_record_for_av_policy
human_gate:
  required: true
  reason: physical_world_change
validation:
  - policy_approved
  - devices_targeted
  - rollback_available
  - evidence_logged
```

---

## Nine roles with richer system maps

### 1. Executive / CEO
Systems: Command Layer, HoloWall, board dashboard, KPI dashboard, risk register, strategy docs, decision log, stakeholder map, Reality Ledger.
Agent pods: Executive Translator Pod, Decision Evidence Pod, Board Narrative Pod.

### 2. HR / People
Systems: HRIS, recruitment, onboarding, LMS, payroll, org chart, performance, engagement survey, wellbeing/EAP, identity joiner/mover/leaver, internal comms.
Agent pods: People Ops Pod, Neuroinclusive Comms Pod, Training Pod, Workforce Impact Pod.

### 3. Finance / CFO
Systems: ERP, budgeting, forecasting, payroll, procurement, expense, subscription register, vendor contracts, BI, pricing tools, cashflow.
Agent pods: Finance Control Pod, Procurement Pod, Vendor Impact Pod, Payroll Impact Pod.

### 4. IT / CIO
Systems: AWS, Azure, Microsoft 365, Entra/IAM, ServiceNow, monitoring, device management, GitHub, Vercel, Supabase, API gateway, data warehouse, backup/DR.
Agent pods: IT Optimisation Pod, IAM Pod, Infra Cost Pod, Change Execution Pod.

### 5. Product / CTO
Systems: GitHub, roadmap, issue tracker, CI/CD, feature flags, docs, test automation, observability, product analytics, design system.
Agent pods: Product Impact Pod, Release Readiness Pod, Code Memory Pod, QA Pod.

### 6. Operations / Logistics
Systems: scheduling, route optimisation, fleet, warehouse, procurement, facilities, field service, inventory, IoT, room booking.
Agent pods: Ops Efficiency Pod, Facilities Pod, Supply Resilience Pod, Route Optimisation Pod.

### 7. Sales / Revenue
Systems: Salesforce/CRM, pricing, CPQ, proposals, account plans, customer success, renewal, partner portal, revenue dashboards.
Agent pods: Revenue Response Pod, Account Impact Pod, Proposal Pod, Customer Risk Pod.

### 8. Marketing / Comms
Systems: CMS, email platform, social scheduler, brand library, campaign manager, analytics, PR/media list, design tools, webinar/events.
Agent pods: Narrative Pod, Campaign Pod, Audience Personalisation Pod, Content Repurposing Pod.

### 9. Governance / Risk / Legal
Systems: policy register, risk register, contract repository, compliance tools, audit logs, privacy register, incident register, board packs, evidence store.
Agent pods: Governance Pod, Compliance Evidence Pod, Legal Triage Pod, Risk Simulation Pod.

### 10. Customer / Support
Systems: ServiceNow/Zendesk, CCaaS, knowledge base, chatbot, SLA tracker, QA recordings, customer feedback, customer comms, escalation system.
Agent pods: Support Readiness Pod, KB Pod, Script Pod, Escalation Pod.

---

## Tools talking better than people

Doolittles should visually show cross-tool propagation:

1. Executive command enters.
2. Command object created.
3. Slack receives personalised human messages.
4. ServiceNow creates workflow and support artefacts.
5. LMS creates training.
6. Salesforce receives customer-impact updates.
7. SAP models financial/procurement effects.
8. Microsoft/Entra prepares access and collaboration changes.
9. BI/HoloWall shows readiness.
10. Reality Ledger records proof.

The point is not more automation. The point is less translation drag.

---

## Possible tool reduction thesis

Doolittles may remove or reduce a class of tools: change coordination middleware, status-reporting tools, manual project update layers, and internal comms rework tools.

Candidate categories to compress:
- manual status reporting;
- change comms drafting;
- meeting-based interpretation;
- duplicated training/documentation effort;
- internal ticket triage;
- spreadsheet-based readiness tracking.

Doolittles does not replace Slack, SAP, ServiceNow or Salesforce. It may replace the waste layer between them.

---

## Maximum-impact demo scenarios

### Scenario 1 — Microsoft rollout
Best for showing broad enterprise change, training, identity, support, finance and communication.

### Scenario 2 — SAP process change
Best for showing in-system vs out-of-system change. SAP changes internally, but Slack, LMS, ServiceNow and Finance all prepare before most users touch SAP.

### Scenario 3 — Call centre performance improvement
Best for showing ServiceNow + Slack + KB + training + CCaaS improving operations autonomously.

### Scenario 4 — Staff reduction or hiring freeze
Best for showing sensitivity, governance, HRIS, payroll, IAM, comms, manager support and neuroinclusive clarity.

### Scenario 5 — Physical workplace command
Best for showing digital-to-physical action: TVs, rooms, desks, access, facilities, energy policy.

---

## Marketing/comms reality
Marketing is easier because the core job often remains stable: build the sales pitch, tailor the audience, distribute it, measure response.

Doolittles improves marketing by bringing it forward:
- narrative created on day one;
- customer segments mapped from Salesforce;
- internal FAQs drafted;
- partner comms prepared;
- campaign assets queued;
- language personalised;
- proof logged.

Marketing is not the hardest demo, but it is one of the clearest demos.

---

## What to build first
Build one live scenario with Slack + ServiceNow + LMS + fake SAP/Salesforce stubs.

Minimum visible proof:
- command entered;
- Slack message generated;
- ServiceNow ticket/KB generated;
- LMS training draft generated;
- Salesforce account-impact stub generated;
- SAP cost/procurement stub generated;
- HoloWall readiness board updated;
- evidence log written.

---

## Reality Ledger
status: PARTIAL
result: Tool mesh build spec created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - no live Slack integration yet
  - no ServiceNow integration yet
  - no SAP/Salesforce live integration yet
  - UI not updated
  - physical-world action gates not wired
next_action: Build live Microsoft rollout scenario with Slack + ServiceNow + LMS + stubbed SAP/Salesforce.
elevation: Moves Doolittles from naming/narrative to tool-mesh orchestration spec.
pressure_flags:
  - integration gap
  - live proof gap
  - partner proof gap
score: 0.86
