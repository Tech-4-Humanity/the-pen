# Predictive Capacity Activation Engine — Build Spec

**Issue:** TML-4PM/the-pen#31
**Status:** PARTIAL — awaiting runtime proof
**Lodged:** 2026-04-28 by Comet autonomous agent (no-HITL)
**Domain:** Blood donation pilot → generalise to organ/tissue/plasma/volunteers
**Regulatory:** TGA-compliant, Australian Red Cross Lifeblood context

---

## Objective

Build an Australian-first Predictive Capacity Activation Engine using blood donation as the proving ground, then generalise to cross-donor platform (organs, tissue, plasma, volunteers). Adapt Uber liquidity orchestration patterns to voluntary public-good systems.

---

## Data Model

```sql
-- Core tables
create table donor_pool (
  id uuid primary key default gen_random_uuid(),
  donor_type text, -- blood | organ | plasma | tissue | volunteer
  eligibility_status text, -- eligible | deferred | pending
  last_donation_date date,
  blood_group text,
  location_postcode text,
  consent_activated_at timestamptz,
  created_at timestamptz default now()
);

create table demand_signal (
  id uuid primary key default gen_random_uuid(),
  signal_type text, -- campaign | shortage | surge | scheduled
  urgency_level int check (urgency_level between 1 and 5),
  target_donor_type text,
  region text,
  units_needed int,
  deadline timestamptz,
  created_at timestamptz default now()
);

create table activation_event (
  id uuid primary key default gen_random_uuid(),
  donor_id uuid references donor_pool(id),
  signal_id uuid references demand_signal(id),
  channel text, -- sms | email | app | push
  sent_at timestamptz,
  responded_at timestamptz,
  outcome text -- booked | declined | no_response
);

create table capacity_forecast (
  id uuid primary key default gen_random_uuid(),
  forecast_date date,
  donor_type text,
  predicted_supply int,
  predicted_demand int,
  confidence_score numeric(3,2),
  created_at timestamptz default now()
);
```

---

## Trigger Engine (Pseudocode)

```python
def evaluate_activation_trigger(signal: DemandSignal) -> list[Donor]:
    """
    Uber-style liquidity matching for voluntary public-good systems.
    """
    forecast = get_capacity_forecast(signal.target_donor_type, signal.deadline)
    
    if forecast.predicted_supply >= signal.units_needed:
        return []  # Sufficient capacity, no activation needed
    
    gap = signal.units_needed - forecast.predicted_supply
    eligible_donors = query_eligible_donors(
        donor_type=signal.target_donor_type,
        region=signal.region,
        exclude_recently_activated=True,
        consent_active=True
    )
    
    # Score and rank donors by proximity, recency, response history
    ranked = score_donors(eligible_donors, signal)
    target_pool = ranked[:int(gap * 2.5)]  # 2.5x overselect for dropout
    
    return target_pool

def score_donors(donors, signal):
    return sorted(donors, key=lambda d: (
        -response_rate(d),     # Higher response rate = higher priority
        proximity(d, signal),  # Closer = higher priority
        days_since_last_donation(d)  # More rested = higher priority
    ))
```

---

## Message Library

| Scenario | Channel | Message Template |
|---|---|---|
| Low supply surge | SMS | "Hi [first_name], your blood type is needed at [centre] this week. Book in 2 min: [link]" |
| Scheduled campaign | Email | "Your next donation window opens [date]. [centre] needs [type] donors." |
| Emergency shortfall | Push | "URGENT: [type] shortage at [hospital]. Eligible donors needed now." |
| Recovery reminder | Email | "You're eligible to donate again. Your last donation helped X patients." |

**Non-negotiables:**
- No blood type prediction from ethnicity
- No buying or selling of blood/organs
- No individual accident or injury targeting
- Forecast system strain only — not individual risk
- Opt-in, consented activation only
- No creepy individual targeting

---

## Bridge-Ready Payload

```json
{
  "engine": "predictive-capacity-activation",
  "version": "0.1.0-pilot",
  "domain": "blood-donation",
  "jurisdiction": "AU",
  "regulator": "TGA",
  "status": "PARTIAL",
  "build_artefacts": [
    "handoffs/predictive-capacity-activation/BUILD_SPEC.md",
    "handoffs/predictive-capacity-activation/PRODUCT_PLAN.md",
    "handoffs/predictive-capacity-activation/REALITY_LEDGER.md"
  ],
  "handoff_target": "bridge/dev",
  "no_hitl": true,
  "acceptance_gate": "runtime_proof_required"
}
```

---

## Acceptance Criteria

- [ ] Data model deployed to Supabase (dev environment)
- [ ] Trigger engine simulator produces capacity gap report
- [ ] Message library wired to activation event table
- [ ] First pilot: 1 demand signal → 1 activation batch → 1 receipt
- [ ] Reality Ledger proof: classification changes from PARTIAL → LIVE
- [ ] No TGA violations
- [ ] No blood type / ethnicity inference
- [ ] Opt-in consent gate functional

---

*Classify as PARTIAL until runtime proof received.*
