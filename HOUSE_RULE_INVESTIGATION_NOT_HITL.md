# HOUSE RULE — INVESTIGATION IS NEVER HITL

```yaml
doc:
  version: "1.0"
  parent: "GLOBAL_RULE.md"
  related: ["MCP_EXECUTION_CONTRACT.md", "ENFORCEMENT_LIVE.md"]
  scope: "Defines the boundary between autonomous investigation and human-in-the-loop action"
  established: "2026-05-29"
  origin: "Director directive after a session where the agent repeatedly escalated read-only diagnosis (asking for pasted logs / billing reads) that it could have performed itself."
```

## The rule

**Investigation is never HITL.** Reading, analysing, diagnosing, cross-checking, and tracing the state of the system are autonomous acts. The agent exhausts every available read-only path before surfacing anything to the director, and never hands the director a task the agent could have performed itself.

HITL attaches **only at the mutation boundary** — and only for the classes the kernel already names:

- credential issuance / rotation
- IAM changes
- billing / spend changes
- destructive actions (DELETE / DROP / data loss)
- financial authority above threshold
- regulatory submission
- ethical override

If an action is not one of those, it does not require the director.

## What this forbids

- Ending a turn with "paste me the log" / "check the billing page" / "tell me what X says" when the agent has a tool that can read it.
- Treating one blocked read (e.g. a `job_logs` call that 401s through a redirect) as grounds to push the *entire* investigation to the director. The move is to **route around the blocked read with another tool**, not to hand over the flashlight.
- Confusing "I cannot *change* X" with "I cannot *see* X." Read access and write authority are separate. Lacking the second never restricts the first.

## What this requires

- Before asking the director for any fact, the agent asks: *is there a tool that can read this?* (bridge run/job/file reads, registry, Supabase read-only SQL, web_fetch, curl-via-bridge, repo inspect, etc.) If yes, the agent reads it.
- The director is asked only for: (a) values the agent structurally cannot read (live secret values, billing page state behind auth the agent lacks), (b) decisions of intent (which function a pipeline *should* call), or (c) approval to cross the mutation boundary above.
- When a read path is blocked, the agent records the blocked path and tries an alternate before escalating.

## Witnessed failure that established this rule

2026-05-29 session: the agent diagnosed a fleet of red CI checks across `the-pen`, `symbio-dev-control-plane`, `mcp-command-centre`, and `t4h-remote-mcp-server-clean`. It repeatedly ended turns asking the director to paste job logs or read the GitHub billing page — both of which were either reachable by the agent's own tools or unnecessary. The actual answer ("This check has no steps" → skipped checks rendering as failures, cosmetic) was a read the agent could and should have performed. The director's correction: *"No HITL needed to look, analyse, investigate ever."*

End.
