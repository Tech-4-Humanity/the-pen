# Adaptive Ambient Access — Audit Scripts

**Project:** OR-AAA-001 | **Agent:** AAA-008

## Script Suite

### 1. Schema Health Check
```sql
-- Verify all AAA tables exist and have expected columns
SELECT table_name, COUNT(*) as col_count
FROM information_schema.columns
WHERE table_name LIKE 'aaa_%'
GROUP BY table_name
ORDER BY table_name;
```
**Expected:** 5 tables (participants, ambient_windows, trigger_rules, support_log, subscriptions)

### 2. RLS Verification
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename LIKE 'aaa_%';
```
**Expected:** rowsecurity = true for all 5 tables

### 3. Support Log Completeness
```sql
SELECT 
  COUNT(*) as total_logs,
  COUNT(ndis_line_item) as with_line_item,
  COUNT(ended_at) as completed_sessions
FROM aaa_support_log
WHERE initiated_at > now() - interval '30 days';
```
**NDIS pass:** with_line_item = total_logs

### 4. Subscription Coverage
```sql
SELECT p.ndis_number, s.tier, s.status
FROM aaa_participants p
LEFT JOIN aaa_subscriptions s ON s.participant_id = p.id
WHERE p.active = true AND (s.id IS NULL OR s.status != 'active');
```
**Expected:** 0 rows (all active participants have active subscription)

### 5. Ambient Window Validation
```sql
SELECT id, start_time, end_time
FROM aaa_ambient_windows
WHERE start_time >= end_time AND active = true;
```
**Expected:** 0 rows (no invalid time ranges)

## Execution

Run via `troy-sql-executor` Lambda or Supabase direct REST.  
Write results to `receipts/or-aaa-001-audit-YYYYMMDD.json`.
