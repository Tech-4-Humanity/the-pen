# SSM Broker Leak Fix + Repo Inventory — 2026-05-31

ledger_evts:
  - ca9d61a1-92df-4473-9f43-8f71d1b82b29  (inventory + cred cleanup, PARTIAL)
  - 8a4ad518-9cfb-4f42-b133-946926a0f4f8  (broker fix, REAL)
  - 1c6c1be2-7b02-4a7a-9468-abe3394eb35b  (bridge staleness, investigated/explained)

## Trigger
"Make all repos private — watchers concern me." Investigated rather than executed.

## Findings
- 82 repos, all public. Classified: 29 safe-to-privatize, 23 Vercel-coupled, 30 homepage-review.
- 7 repos with committed .env: ONLY VITE_SUPABASE_PUBLISHABLE_KEY (client-side, RLS-guarded).
  No service_role / AWS / PAT / Stripe secrets. NOT a leak. Watcher concern was not a security risk.
- Privatization is an IP/noise decision, not security. No bulk flip done.

## Real issue found + fixed: troy-ssm-broker plaintext leak
- get branch returned decrypted Parameter.Value in response body → re-exposed every secret read
  (burned 2 GitHub tokens this session). console.log(event) also wrote put values to CloudWatch.
- Patched to v2.0.0-no-plaintext-leak: get defaults metadata-only; value returned ONLY if
  SSM_BROKER_ALLOW_VALUE_RETURN=true env AND caller internalCaller:true. Diagnostic logs booleans only.
- Verified live: direct aws lambda invoke → 2.0.0, value_return_enabled:false.
  CodeSha256 Z4PiTd+O+KTcClEfd2161z+eBFDmw5qiaV12KuNbFVM=
- Both exposed tokens REVOKED. SSM param /t4h/github/inventory-pat-readonly DELETED.

## NEW PROCESS RULE (earned this session)
After any Lambda deploy, verify via DIRECT aws lambda invoke and trust the executing code's
own version string. Do NOT trust:
  - CodeSha256 change as proof (changed twice while old code still ran — zip packed stale file)
  - bridge health (routes via cap_secrets; propagation lag)
Require the function to echo its own version before logging a deploy REAL.

## Bridge note
t4h_bridge_invoke resolves via cap_secrets, not direct lambda:Invoke. Tracks live state correctly
once propagated — earlier 1.1.0 reads were failed-deploy old code, not bridge drift. No bridge code changed.
