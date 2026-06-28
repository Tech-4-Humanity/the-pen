# Tranche 2 AML/CTF Compliance Data Acquisition Pack (CDAP)

**Status:** PARTIAL operational blueprint; GitHub-posted artefact created for execution intake.  
**Date:** 2026-06-28  
**Owner:** Tech 4 Humanity / TML-4PM  
**Repository:** TML-4PM/the-pen  
**Purpose:** Define the industrialised onboarding model required to move thousands of Australian Tranche 2 customers from unmanaged compliance exposure to structured, evidenced AML/CTF readiness.

---

## 1. Core Thesis

The market is likely to misunderstand Tranche 2 readiness as a training problem.

That is wrong.

Tranche 2 readiness is an organisational capability uplift involving:

- data acquisition;
- ownership and control mapping;
- customer and transaction risk assessment;
- policies and procedures;
- staff training and personnel due diligence;
- evidence collection;
- governance activation;
- ongoing customer due diligence;
- monitoring;
- record keeping;
- annual review;
- independent evaluation; and
- audit-ready evidence retention.

Training is visible, but it is only one part of the workload.

The correct implementation model is:

```text
CUSTOMER
  ↓
Compliance Data Acquisition Pack (CDAP)
  ↓
Validation Engine
  ↓
Gap Analysis
  ↓
Risk Engine
  ↓
Control Engine
  ↓
Document Generator
  ↓
Training Assignment Engine
  ↓
Evidence Pack Generator
  ↓
Executive Signoff
  ↓
Annual Review Runtime
```

The CDAP is therefore not a form. It is the canonical customer data model from which all compliance artefacts, registers, policies, training allocations, reviews, dashboards and evidence packs are generated.

---

## 2. Regulatory Basis and Guidance Sources

This blueprint is anchored to AUSTRAC guidance areas including:

- AML/CTF training for personnel performing functions relevant to AML/CTF obligations;
- AML/CTF program development;
- governance framework;
- risk assessment;
- policies to manage and mitigate risk;
- review and update of the AML/CTF program;
- independent evaluation;
- record keeping;
- customer due diligence;
- enhanced customer due diligence;
- ongoing customer due diligence;
- politically exposed persons;
- persons designated for targeted financial sanctions;
- source of funds and source of wealth;
- transitioning existing customers; and
- AUSTRAC program starter kits for accountants, conveyancers, legal professionals, real estate and other sectors.

Source anchors for implementation research:

- AUSTRAC AML/CTF training guidance: https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/your-amlctf-program/personnel-due-diligence-and-training/amlctf-training
- AUSTRAC program starter kits: same guidance tree includes starter kits for accounting, conveyancing, legal profession, jewellers and real estate.
- AUSTRAC customer due diligence guidance tree: includes initial CDD, enhanced CDD, ongoing CDD, PEPs, sanctions, source of funds/source of wealth and transitioning existing customers.

---

## 3. Design Principle

### One Customer → One Intake → Everything Generated

The customer should answer each question once.

Every response must have a downstream purpose.

Every evidence item must map to one or more obligations.

Every output must trace back to source data.

No duplicate forms.  
No manual policy drafting at scale.  
No bespoke compliance rebuilds per customer.  
No untraceable evidence.  
No unsupported claim of completion.

---

## 4. CDAP Design Rules

### 4.1 Ask Once

Example:

```text
Director name
  ↓
Beneficial Ownership Register
  ↓
PEP Screening List
  ↓
AML Program Governance Section
  ↓
Board Resolution
  ↓
Annual Review Reminder
```

One data point, multiple generated artefacts.

### 4.2 Evidence First

| Data Claim | Evidence Required |
|---|---|
| Directors | ASIC extract |
| Trust structure | Trust deed |
| Staff | Payroll/HR export |
| Training | Certificates or LMS export |
| Banking controls | Trust/banking procedure |
| Policies | Existing document upload |
| Governance | Minutes, resolutions, delegations |

No evidence means status remains PARTIAL, not complete.

### 4.3 Import Before Build

The system must first ask what exists.

Existing policies, training, registers, procedures and systems should be imported, mapped, scored, upgraded or retired.

### 4.4 Progressive Disclosure

Irrelevant sections should be hidden.

Example:

- If no trust account: hide trust banking questions.
- If trust account exists: trigger reconciliations, approvals, delegations, controls, training, evidence and monitoring.

### 4.5 Human Effort Reserved for Judgment

Humans should spend time on:

- risk appetite;
- leadership workshop;
- governance decisions;
- exception handling;
- executive signoff; and
- independent review.

Automation should handle:

- document generation;
- register creation;
- training allocation;
- reminders;
- evidence indexing;
- gap analysis;
- dashboards; and
- annual schedules.

---

## 5. Complete CDAP Intake Architecture

The intake pack should be organised into 12 customer-facing packs.

---

# Pack A — Organisational Identity

**Estimated customer effort:** 20–30 minutes.

## A1. Legal Identity

Fields:

- Legal entity name
- Trading names
- ABN
- ACN
- GST status
- Entity type
- Date established
- Registered address
- Principal place of business
- Postal address
- Website
- Industry classification
- Employee count
- Contractor count
- Annual turnover band
- Number of offices
- States and territories of operation
- International operations

## A2. Regulatory and Professional Standing

Fields:

- Professional memberships
- Registration numbers
- Licensing authorities
- Licence expiry dates
- Franchise affiliation
- Professional indemnity insurer
- External accountant
- External lawyer
- Existing compliance adviser

## A3. Related Entities

Fields:

- Parent company
- Subsidiaries
- Trusts
- Partnerships
- Joint ventures
- Offshore entities
- Related-party businesses
- Shared-service entities

## Required Evidence

- ASIC extract
- Constitution
- Professional licences
- Franchise agreements
- Organisation chart
- Group structure chart

## Generated Outputs

- Business profile
- AML/CTF program header data
- regulatory profile
- dashboard metadata
- entity relationship map
- evidence checklist

---

# Pack B — Ownership and Beneficial Control

**Estimated customer effort:** 15–45 minutes depending on complexity.

For each controlling person:

## Identity

- Full legal name
- Date of birth
- Nationality
- Country of residence
- Tax residency
- Occupation
- Contact details

## Role and Control

- Director
- Shareholder
- Beneficial owner
- Trustee
- Appointor
- Settlor
- Protector
- Senior manager
- Authorised signatory
- Voting rights
- Economic interest
- Control rights
- Direct ownership percentage
- Indirect ownership percentage

## Risk Declarations

- PEP status
- Family member or close associate of a PEP
- Foreign official status
- Sanctions exposure
- Bankruptcy history
- Criminal conviction declaration
- Adverse media declaration

## Required Evidence

- ID documents
- ASIC records
- trust deeds
- ownership diagrams
- directorship evidence

## Generated Outputs

- beneficial ownership register
- ownership and control map
- PEP register
- sanctions screening queue
- enhanced due diligence flags
- governance risk profile

---

# Pack C — People, Staff and Roles

**Estimated customer effort:** 30 minutes to several hours depending on headcount.

This is one of the largest hidden workloads.

For every person:

## Identity

- Full name
- Preferred name
- Email
- Mobile
- Office location
- Manager
- Employment type
- Start date
- Contractor status

## Authority

- Customer onboarding authority
- Financial delegation
- Trust account access
- Contract signing authority
- Refund approval authority
- International client authority
- Customer risk override authority

## Risk Exposure

- Customer-facing role
- Handles ID documents
- Handles source of funds/source of wealth information
- Handles foreign customers
- Handles cash
- Handles settlements
- Handles trust account activity
- Handles suspicious matter escalations

## Existing Controls

- Police check date
- Working with Children check, if relevant
- AML/CTF training completed
- CPD records
- professional registration
- staff declaration status

## Generated Outputs

- training matrix
- staff due diligence register
- annual refresher schedule
- induction checklist
- staff declaration pack
- role-based control matrix
- CPD evidence register

---

# Pack D — Service Catalogue

**Estimated customer effort:** 20–40 minutes.

This drives inherent risk scoring.

## Real Estate Activities

- Residential sales
- Commercial sales
- Rural property
- Industrial property
- Luxury property
- Auctions
- Property management
- Buyers agency
- Foreign purchasers
- Developers
- Off-the-plan sales
- Commercial leasing
- Project marketing

## Accounting Activities

- Tax preparation
- Bookkeeping
- SMSFs
- Trust establishment
- Company formation
- Corporate advisory
- Insolvency
- Mergers and acquisitions
- Payroll
- Virtual CFO
- Wealth-adjacent advice

## Legal Activities

- Conveyancing
- Trust accounts
- Estate planning
- Commercial law
- Corporate law
- Family law
- Litigation support
- International matters
- Property transactions

## Trust and Company Services

- Registered office services
- company formation
- shelf companies
- nominee directors
- trust administration
- corporate secretarial work

## Generated Outputs

- service risk score
- required policies
- required controls
- role training requirements
- CDD/EDD triggers
- monitoring requirements
- industry overlay selection

---

# Pack E — Customer Base Analysis

**Estimated customer effort:** 30–90 minutes.

This is frequently where customers discover they do not understand their own risk profile.

## Volumes

- Number of active customers
- Number of new customers per year
- Number of transactions per year
- average transaction value
- largest transaction value
- growth rate
- dormant customer count
- legacy customer count

## Customer Composition

Approximate percentage split:

- individuals
- companies
- trusts
- SMSFs
- partnerships
- foreign entities
- developers
- investors
- charities
- government bodies
- high-net-worth individuals
- politically exposed persons

## Behavioural Risk Indicators

Do customers:

- use third parties to pay?
- buy remotely?
- use nominee arrangements?
- have offshore ownership?
- use complex trusts?
- make rapid transactions?
- request unusual settlement arrangements?
- avoid face-to-face contact?
- resist providing information?

## Generated Outputs

- customer risk profile
- customer segmentation model
- EDD trigger list
- ongoing monitoring rules
- high-risk customer register
- transition plan for existing customers

---

# Pack F — Geographic Exposure

**Estimated customer effort:** 10–30 minutes.

## Geography Fields

- countries where customers reside
- countries where owners reside
- countries where funds originate
- countries where suppliers operate
- countries where related entities operate
- foreign investment corridors
- high-risk jurisdictions
- sanctioned jurisdictions
- tax havens or secrecy jurisdictions

## Generated Outputs

- geographic risk heatmap
- sanctions screening requirements
- EDD workflow triggers
- ongoing monitoring frequency
- country risk register

---

# Pack G — Transactions and Money Movement

**Estimated customer effort:** 20–60 minutes.

This is one of the highest-value sections.

## Money Flow Questions

Do you:

- accept cash?
- hold trust money?
- operate client accounts?
- facilitate settlements?
- accept international transfers?
- accept cryptocurrency?
- accept third-party payments?
- process refunds?
- move funds between related entities?
- receive funds from family members or associates?
- operate escrow-like arrangements?

## Transaction Metrics

- annual transaction volume
- average transaction value
- maximum transaction value
- total trust account balances
- number of trust accounts
- international percentage
- cash percentage
- third-party payment percentage
- refund frequency

## Required Evidence

- trust account procedures
- banking authorities
- settlement process
- refund procedure
- delegation matrix
- reconciliation evidence

## Generated Outputs

- transaction risk score
- enhanced control requirements
- monitoring thresholds
- escalation workflows
- suspicious matter escalation matrix
- monthly monitoring schedule

---

# Pack H — Technology Landscape

**Estimated customer effort:** 20–45 minutes.

## Systems Inventory

CRM:

- Salesforce
- HubSpot
- Agentbox
- PropertyMe
- VaultRE
- other

Practice/accounting systems:

- Xero
- MYOB
- QuickBooks
- APS
- XPM
- LEAP
- Smokeball
- Actionstep

Document systems:

- SharePoint
- Google Drive
- Dropbox
- S3
- local server

Identity/screening:

- GreenID
- Frankie
- Trulioo
- manual checks
- none

Communications:

- Microsoft 365
- Google Workspace
- Teams
- Slack
- email only

## Generated Outputs

- integration map
- evidence repository map
- retention plan
- data access risk profile
- automation opportunities
- monitoring implementation plan

---

# Pack I — Existing Controls

**Estimated customer effort:** 30–60 minutes.

The purpose is to avoid rebuilding what already exists.

## Policies

- AML/CTF policy
- privacy policy
- information security policy
- training policy
- complaints policy
- incident policy
- breach policy
- record retention policy
- sanctions policy
- client onboarding procedure

## Governance

- board oversight
- risk committee
- compliance officer
- internal audit
- external audit
- risk register
- board reporting
- annual review process

## Staff Controls

- induction training
- compliance training
- annual refreshers
- police checks
- CPD tracking
- staff declarations

## Generated Outputs

- control maturity score
- gap analysis
- remediation plan
- policy reuse map
- control uplift plan

---

# Pack J — Executive Risk Workshop

**Estimated customer effort:** 90–120 minutes.

This is the only genuinely irreplaceable human component.

Participants:

- principal/director;
- compliance officer;
- practice manager;
- operations lead;
- finance/trust account lead; and
- nominated risk owner.

## Workshop Questions

Strategic risk:

- What keeps leadership awake at night?
- Which parts of the business feel most exposed?
- What would AUSTRAC criticise if it reviewed the business today?

Customer risk:

- Which customers create discomfort?
- Which customers are hard to understand?
- Which clients are complex, opaque or foreign-owned?

Transaction risk:

- Which transactions feel unusual?
- Where do third-party payments occur?
- Where could source of funds/source of wealth be unclear?

Reputational risk:

- What headline would damage the firm?
- What would cause loss of client trust?
- What would professional bodies criticise?

Control maturity:

- Which controls work well?
- Which controls are informal?
- Which controls depend on one person?
- Which controls are not evidenced?

## Generated Outputs

- enterprise AML/CTF risk assessment
- risk appetite statement
- board priorities
- annual compliance objectives
- EDD priority list
- executive signoff pack

---

# Pack K — Evidence Collection

**Estimated customer effort:** 30 minutes to several hours.

## Corporate Evidence

- ASIC extracts
- constitutions
- trust deeds
- partnership agreements
- franchise agreements
- professional licences
- related entity diagrams

## People Evidence

- staff list
- organisation chart
- police checks
- training records
- contractor list
- role descriptions

## Financial Evidence

- trust account procedures
- settlement procedures
- refund procedures
- banking authority matrix
- reconciliation process
- financial delegations

## Governance Evidence

- policies
- board minutes
- risk registers
- audit reports
- compliance reports
- incident logs
- complaint registers

## Technology Evidence

- system inventory
- CRM export
- document repository list
- user access list
- ID verification tools
- screening tools

## Generated Outputs

- evidence completeness score
- audit-ready evidence pack
- evidence gap register
- validation status
- expiry/reminder schedule

---

# Pack L — Declarations and Signoff

**Estimated customer effort:** 15–45 minutes.

## Required Declarations

- principal declaration
- compliance officer declaration
- director/board declaration
- staff declarations
- evidence completeness declaration
- annual renewal declaration

## Generated Outputs

- attestation pack
- board resolution
- annual review trigger
- customer completion certificate
- residual risk statement

---

## 6. Input → Output Dependency Matrix

| Input | Outputs Generated |
|---|---|
| Legal entity details | AML/CTF program, business profile, dashboard metadata |
| ABN/ACN | ASIC evidence request, identity validation, entity profile |
| Directors | governance map, board resolution, PEP/sanctions screening |
| Beneficial owners | BO register, EDD triggers, ownership risk score |
| Trust structures | trust risk score, CDD requirements, evidence checklist |
| Staff list | training matrix, staff register, induction plan |
| Roles and authorities | delegation matrix, training level, control assignment |
| Services | activity risk score, required policies, monitoring rules |
| Customer types | customer risk model, CDD/EDD triggers, register setup |
| Countries | geographic risk score, sanctions review, monitoring frequency |
| Transaction values | transaction risk score, thresholds, escalation rules |
| Cash handling | cash controls, suspicious activity indicators, training emphasis |
| Trust accounts | enhanced controls, reconciliation evidence, role training |
| Technology systems | integration plan, evidence repository, retention policy |
| Existing policies | gap analysis, reuse map, policy update schedule |
| Existing training | training gap register, refresher schedule, CPD evidence |
| Evidence uploads | audit pack, completeness score, validation status |
| Executive risk answers | formal risk assessment, risk appetite, annual objectives |

---

## 7. Customer Effort Model

Customers must be given realistic expectations.

## Sole Practitioner

| Stream | Hours |
|---|---:|
| Corporate discovery | 0.5 |
| Evidence gathering | 0.5 |
| Risk workshop/signoff | 0.5 |
| Training | 2.0 |
| Final declaration | 0.5 |
| Total | 4.0 |

## Small Firm — 5 Staff

| Stream | Hours |
|---|---:|
| Corporate discovery | 1.0 |
| Staff mapping | 1.0 |
| Customer/transaction profile | 2.0 |
| Evidence gathering | 2.0 |
| Governance workshop | 1.5 |
| Training | 6.0 |
| Final signoff | 0.5 |
| Total | 14.0 |

## Medium Firm — 20 Staff

| Stream | Hours |
|---|---:|
| Corporate discovery | 3.0 |
| Staff mapping | 3.0 |
| Customer profile | 3.0 |
| Transaction/money flow profile | 3.0 |
| Technology inventory | 2.0 |
| Evidence gathering | 4.0 |
| Governance workshop | 3.0 |
| Training | 20.0 |
| Final signoff | 1.0 |
| Total | 42.0 |

## Large Multi-Office Organisation — 50 Staff

| Stream | Hours |
|---|---:|
| Corporate discovery | 8.0 |
| Staff mapping | 8.0 |
| Customer profile | 6.0 |
| Transaction/money flow profile | 6.0 |
| Technology inventory | 4.0 |
| Evidence gathering | 10.0 |
| Governance workshops | 6.0 |
| Training | 60.0 |
| Final signoff | 2.0 |
| Total | 110.0 |

## Enterprise Group

Expected organisational effort can exceed 200 hours because of multi-entity ownership, legacy systems, inconsistent training records, complex evidence gathering and distributed approvals.

---

## 8. Implementation Factory Stages

## Stage 0 — Pre-Population

Where possible, import from:

- ASIC;
- CRM;
- practice management systems;
- accounting systems;
- HR/payroll;
- LMS;
- document management;
- existing policy repositories.

Target: 70–90% of intake pre-populated for existing customers.

## Stage 1 — Customer Validation

Customer reviews and confirms:

- organisation data;
- ownership;
- staff;
- services;
- customers;
- transactions;
- technology;
- existing controls.

## Stage 2 — Evidence Sprint

Single upload exercise.

Outputs:

- evidence completeness score;
- missing evidence list;
- validation status;
- expiry tracking.

## Stage 3 — Automated Generation

Generate:

- AML/CTF program;
- risk assessment;
- policies;
- registers;
- role matrix;
- training matrix;
- annual review calendar;
- independent review schedule;
- board reporting pack.

## Stage 4 — Executive Risk Workshop

Human-led 90–120 minute workshop.

Outputs:

- final risk assessment;
- risk appetite;
- executive priorities;
- signoff pack.

## Stage 5 — Training Deployment

Automated role-based training assignment:

| Role | Level | Typical Duration |
|---|---:|---:|
| Reception/admin | Level 1 | 1 hour |
| Customer-facing staff | Level 2 | 3 hours |
| Practitioners | Level 2 | 3–4 hours |
| Principals/managers | Level 3 | 6–8 hours |
| Compliance officer | Level 3+ | 8–12 hours |

## Stage 6 — Final Assurance Pack

Generate customer pack:

- completion status;
- residual gaps;
- evidence index;
- registers;
- policies;
- review calendar;
- board signoff;
- annual maintenance plan.

---

## 9. Generated Artefact Library

## Governance

1. AML/CTF Program Part A
2. AML/CTF Program Part B
3. Enterprise AML/CTF Risk Assessment
4. Risk Appetite Statement
5. Compliance Charter
6. Compliance Officer Appointment
7. Board/Director Resolution
8. Delegation Matrix
9. Executive Signoff Pack
10. Annual Compliance Plan

## Registers

11. Beneficial Ownership Register
12. Staff Training Register
13. Staff Due Diligence Register
14. Customer Due Diligence Register
15. High-Risk Customer Register
16. PEP Register
17. Sanctions Register
18. Source of Funds/Source of Wealth Register
19. Incident Register
20. Breach Register
21. Suspicious Matter Escalation Register
22. Third-Party Payment Register
23. Independent Review Register
24. Evidence Register

## Policies and Procedures

25. AML/CTF Policy
26. Customer Due Diligence Procedure
27. Enhanced Due Diligence Procedure
28. Ongoing Monitoring Procedure
29. PEP and Sanctions Procedure
30. Source of Funds/Source of Wealth Procedure
31. Record Retention Policy
32. Staff Training Policy
33. Escalation Procedure
34. Third-Party Payments Policy
35. Trust Account AML Controls Procedure
36. Incident and Breach Procedure

## Operations

37. Staff Induction Pack
38. New Starter Checklist
39. Annual Refresher Schedule
40. Monthly Monitoring Schedule
41. Quarterly Board Report Template
42. Annual Review Checklist
43. Independent Review Readiness Checklist
44. Customer Completion Certificate
45. Residual Risk Statement

---

## 10. Annual Operating Model

After onboarding, the aim is low-friction compliance maintenance.

| Activity | Frequency | Customer Effort | Automation Target |
|---|---:|---:|---:|
| Sanctions screening | Ongoing/daily | Minimal | 100% |
| PEP review | Ongoing/triggered | Exception only | 90%+ |
| Adverse media | Monthly/triggered | Exception only | 90%+ |
| Staff refresher training | Annual | 1–2 hrs/person | 80%+ |
| Enterprise risk review | Annual | 2 hrs | Guided |
| Policy update | Annual/triggered | Review only | 90%+ |
| Board reporting | Quarterly | 30 mins | 80%+ |
| Independent evaluation | 1–3 years | 1 day+ | Assisted |
| Evidence refresh | Annual | Exception only | 80%+ |

---

## 11. Customer Message

Customer-facing explanation:

> Becoming Tranche 2 ready is not a one-hour course. It requires one concentrated organisational effort to document who you are, who controls the business, what services you provide, who your customers are, how money moves, what systems you use, what controls already exist, what evidence supports those controls, and how staff are trained. Most of that effort occurs once. After implementation, ongoing compliance becomes a structured operating rhythm supported by automation, annual reviews, refresher training, monitoring, evidence retention and independent assurance.

---

## 12. Build Requirements

## P0 — Required Now

1. Master XLSX intake workbook with 20 sheets.
2. Canonical JSON schema for all CDAP objects.
3. Input → output dependency matrix.
4. Regulatory obligation mapping matrix.
5. Evidence request pack.
6. Customer effort calculator.
7. Generated artefact inventory.
8. Gap analysis scoring model.
9. Training assignment rules.
10. Executive risk workshop guide.

## P1 — Industry Overlays

1. Accounting overlay.
2. Real estate overlay.
3. Legal overlay.
4. Conveyancing overlay.
5. Property developer overlay.
6. Trust/company service provider overlay.
7. Precious metals/stones overlay.

## P2 — Runtime

1. Automated document generator.
2. Evidence upload and validation engine.
3. Annual compliance calendar.
4. Monitoring queue.
5. Dashboard.
6. Board reporting pack.
7. Independent review toolkit.
8. Customer renewal workflow.
9. Exception management.
10. Audit export pack.

---

## 13. Success Metrics

| Metric | Target |
|---|---:|
| Questions answered once | 100% |
| Intake pre-populated for existing customers | 70–90% |
| Artefacts generated automatically | 90%+ |
| Manual policy drafting | 0% target |
| Staff training allocation automated | 100% |
| Evidence items indexed | 100% |
| Annual reminders automated | 100% |
| Completion status visible | 100% |
| Residual gaps explicit | 100% |
| Regulatory traceability | 100% |

---

## 14. Execution Status

Current status: PARTIAL.

Reason:

- Blueprint written and posted.
- GitHub receipt required for REAL status.
- Master workbook not yet generated.
- JSON schema not yet generated.
- regulatory mapping not yet generated.
- runtime automation not yet built.
- evidence upload engine not yet built.
- no customer pilot receipt yet.

Next action:

1. Generate Master XLSX workbook.
2. Generate canonical JSON schema.
3. Generate Input → Output Dependency Matrix.
4. Generate Evidence Request Pack.
5. Generate Customer Effort Calculator.
6. Create implementation issue/PR chain for build execution.
