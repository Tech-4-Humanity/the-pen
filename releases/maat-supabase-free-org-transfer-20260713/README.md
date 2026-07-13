# MAAT Supabase Free Organisation Transfer

Project: `lzfgigiyqpuuxslsygjt`
Target: new Supabase Free organisation dedicated to T4H Evidence / MAAT
Tracking issue: #224

## Scope

This package prepares a whole-project transfer. It does not recreate MAAT and does not delete the source project.

## Required owner action in Supabase

1. Create or select the target Free organisation.
2. Confirm an available Free project slot.
3. Open project `lzfgigiyqpuuxslsygjt`.
4. Resolve transfer blockers shown by Supabase, including overdue billing restrictions, GitHub integration, log drains, or project-scoped roles.
5. Select **Project Settings → General → Transfer project**.
6. Select the target Free organisation and confirm.

## Post-transfer verification

Do not close as REAL until all checks pass:

- project reference remains `lzfgigiyqpuuxslsygjt`;
- database tables/views present;
- row counts captured;
- Auth users present;
- Storage buckets and object counts present;
- Edge Functions present;
- API health check passes;
- FY24/25 R&D total reconciles to `$2,136,791`;
- bank/cloud R&D reconciles to `$544,541`;
- 299 timesheet entries and 3,184.52 hours reconcile;
- 40 invoices reconcile;
- backup exported outside Supabase;
- post-transfer receipt committed.

## Classification

GitHub transfer package: REAL
Supabase transfer: PENDING OWNER ACTION
Post-transfer data verification: PENDING
