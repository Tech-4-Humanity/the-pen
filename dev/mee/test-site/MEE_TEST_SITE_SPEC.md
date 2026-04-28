# MEE — My Employment Engine Test Site Spec

Reality: PARTIAL. This is a dev/test-site handoff, not production.

## Objective
Build and test a personalised employment command centre that reuses PLMOS recovered assets and extends them into MEE.

## Required pages
- Dashboard
- Role Universe
- Skills Matrix
- Applications
- Analytics
- Learning Engine
- Templates
- Evidence
- MCP Connections

## Seed KPIs
- Canonical roles: 28
- Skills tracked: 37
- Applications: 6
- Win rate: 33%
- Average fit score: 90%
- Accelerating roles: 15
- Sourced: 127
- Matched: 45
- Applied: 6
- Interview: 3
- Won: 2

## Recent applications
| Role | Company | Status | Fit |
|---|---|---|---:|
| Chief AI Officer | Telstra | pending | 92 |
| Head of AI Platforms | ANZ Bank | pending | 88 |
| Field CTO | Salesforce | won | 95 |
| Director AI Strategy | NSW Gov | pending | 90 |
| Chief Architect | CommBank | lost | 85 |
| Head of Responsible AI | Qantas | won | 91 |

## MCP connection stack
Core job sources: LinkedIn Jobs, Seek, Indeed, Glassdoor, Jora, Adzuna, Wellfound.
Enterprise/gov: APS Jobs, NSW Government Jobs, Defence Jobs Australia, AWS Careers, Microsoft Careers, Google Careers, Oracle Careers.
Recruiters: Hays, Robert Half, Michael Page, Randstad, Hudson.
Skill signals: Coursera, Udemy, GitHub, Kaggle, Stack Overflow.
Salary intel: Payscale, Salary.com, Seek Salary Insights.
Personalisation: Supabase, GitHub, Google Drive, Gmail/SES, Calendar.
Execution: Bridge, GitHub Pen inbox, Supabase runtime, Email, Dashboard cc.

## Template registry
Input templates:
- target_role
- user_profile
- job_signal
- application_request
- recruiter_signal
- learning_event

Output templates:
- cover_letter
- outreach_message
- fit_analysis
- role_brief
- daily_command
- weekly_report
- pipeline_state
- application_log
- interview_prep
- board_bio
- linkedin_rewrite
- 30_60_90_plan

## Test actions
All actions are mock-only in dev site:
- ingest
- score
- generate output
- write evidence receipt
- export JSON

## No-go
- no real credentials
- no payments
- no destructive actions
- no production deploy without gate

## Definition of done for test site
- UI loads
- seed data visible
- all pages reachable
- template registry visible
- mock generate action creates output preview
- evidence panel marks state PARTIAL unless runtime receipt exists
- export JSON works
