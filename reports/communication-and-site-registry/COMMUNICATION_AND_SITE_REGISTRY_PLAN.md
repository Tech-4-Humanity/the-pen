# Communication and Site Registry Plan

Date: 2026-06-15
Actor: GPT-5.5 Thinking
Classification: REAL

## Purpose
Create the operational intelligence layer for T4H so reports, sites, products, communications, and execution receipts have a canonical home.

## Thread Intent Recovered
The request began as scheduled reports, but the real requirement is broader:

- know what exists
- know what is live
- know who it is for
- know how it communicates
- know what reports govern it
- know what data sources feed it
- know which actions remain incomplete

## Primary Gaps

### 1. Ecosystem Registry Missing
Need one canonical registry for all assets.

Fields:
- asset_name
- asset_type
- brand
- audience
- status
- owner
- repo
- database
- site_url
- revenue_status
- report_links
- communication_channel

### 2. Live Site Registry Missing
Need an auditable list of live, staging, broken, retired, and unknown sites across GitHub, Lovable, Vercel, S3, domains, and Supabase.

Fields:
- site_name
- site_url
- repo
- platform
- environment
- build_status
- last_checked_at
- owner
- audience
- communication_route

### 3. Communication Bar Missing
Need a central system channel for humans and agents.

Sections:
- Announcements
- Agent Channel
- Human Channel
- Escalations
- Decisions
- Blocked Items

Message schema:
- timestamp
- source
- priority
- project
- topic
- message
- action_required
- link

### 4. Distribution Map Missing
Need to know who receives what.

Fields:
- audience
- channel
- frequency
- owner
- report_received
- product_or_site_linked
- external_or_internal

### 5. Report Registry Missing
Need a registry of scheduled and ad hoc reports.

Fields:
- report_name
- cadence
- owner
- source_tables
- output_location
- audience
- status
- last_run
- next_run

## Required Report Stack

### Daily
- Combined Daily Report
- Ecosystem Health Report
- Site Health Report
- Communications Summary
- Supabase Health Sweep
- GitHub Activity Report

### Weekly
- Weekly Digest
- Site Portfolio Review
- Product Portfolio Review
- Content Portfolio Review
- Research Intake Summary

### Monthly
- Board Pack
- Ecosystem Inventory Review
- Brand Performance Review
- Research State Review
- Revenue and Usage Summary

## Source Systems to Audit
- GitHub repositories
- Lovable projects
- Vercel projects
- Supabase projects and tables
- Notion pages and databases
- SES and Resend email configuration
- Domains and DNS
- GPT taxonomy and import files

## Reality State
- master_4500: REAL
- GPT import package taxonomy: REAL
- Combined Daily Report: PARTIAL
- Communication Bar: MISSING
- Ecosystem Registry: MISSING
- Site Registry: MISSING
- Audience Registry: MISSING
- Distribution Registry: MISSING
- Report Registry: MISSING

## Immediate Actions
1. Create ecosystem_registry.
2. Create site_registry.
3. Create communication_bar.
4. Create distribution_registry.
5. Create report_registry.
6. Audit all GitHub repos for site, app, report, and data markers.
7. Map each live site to audience and communication route.
8. Route all scheduled reports into the Communication Bar.

## Completion Rule
No report is complete until it records:
- source data
- recipient or audience
- storage location
- owner
- status
- receipt

## Status
READY_FOR_BRIDGE_EXECUTION
