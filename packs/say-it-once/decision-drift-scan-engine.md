# Decision Drift Scan — Engine Logic

## Objective

Take one decision and quantify:
- who heard it
- how they interpreted it
- who was missed
- what it cost

---

## Core concept

Drift = difference between:

- original intent
- interpreted actions across roles

---

## Step 1 — Intent parsing

Extract:

- goal
- constraints
- timing
- risk signals
- ambiguity markers

Example:

"Keep it lean" → ambiguity
"No new hires" → constraint
"By Friday" → time boundary

---

## Step 2 — Role mapping

Map decision to roles using HoloOrg model:

- HR
- Finance
- IT
- Ops
- Legal
- Sales
- Support

Each role gets:

- expected interpretation
- expected action set

---

## Step 3 — Interpretation variance

For each role:

Compare:
- expected interpretation
- likely real-world interpretation

Score variance:

LOW / MEDIUM / HIGH

---

## Step 4 — Coverage analysis

Determine:

- who should receive the message
- who would receive it (email / meeting)

Calculate:

miss_rate_pct = (missed / total) * 100

---

## Step 5 — Drift scoring

Composite score:

Drift Score =

(weight_interpretation * variance)
+
(weight_coverage * miss_rate)
+
(weight_complexity * system_count)


Output:

LOW / MEDIUM / HIGH

---

## Step 6 — Cost estimation

Estimate:

- delay cost (time to alignment)
- rework cost
- missed action cost

Example:

- 3 meetings x 6 people x hourly rate
- delayed revenue recognition
- duplicated effort

---

## Step 7 — Simulation

Generate two paths:

### Without Say It Once
- delayed alignment
- misinterpretation
- drift increases over time

### With Say It Once
- immediate role clarity
- tool outputs generated
- execution begins instantly

---

## Step 8 — Output report

### Decision Drift Report

- input decision
- blast radius
- role interpretations
- missed roles
- drift score
- cost estimate
- simulation summary

---

## Sample output JSON

{
  "decision_id": "atlas_demo",
  "drift_score": "HIGH",
  "miss_rate_pct": 41,
  "interpretation_variance": {
    "HR": "MEDIUM",
    "Finance": "HIGH",
    "IT": "LOW"
  },
  "estimated_cost": {
    "meetings": 6,
    "delay_days": 5,
    "rework_hours": 32
  }
}

---

## Positioning

This is not analytics.

This is proof that:

> your business is guessing

and exactly how much that costs.

---

## Output usage

- sales wedge
- demo engine
- onboarding tool
- executive reporting

---

## Result

Decision Drift Scan becomes:

- diagnostic
- visual
- monetisable

and the fastest way to convert customers.
