# House Rules Engine Production Package

Production-ready bootstrap and control layer for agents, sessions, service catalogue products, and runtime execution.

## What this is
A self-loading operating environment. Every agent/session/product loads rules, knowledge, execution contracts, service catalogue context, and receipt requirements before acting.

## Production tonight path
1. Commit this folder to `TML-4PM/the-pen` or deploy as standalone repo.
2. Run `sql/001_house_rules_engine.sql` in Supabase.
3. Deploy `app/` to Vercel.
4. Set environment variables:
   - `NEXT_PUBLIC_HRE_VERSION=1.0.0`
   - `NEXT_PUBLIC_HRE_MODE=production`
5. Use `bootstrap/BOOTSTRAP.md` as mandatory session entry point.

## Reality state
PARTIAL until deployed, database migration executed, and runtime receipts captured.
