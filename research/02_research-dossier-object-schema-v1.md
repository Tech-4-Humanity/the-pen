# Research Dossier Object Schema v1.0

Objects:

1. Theme
2. Question
3. Uncertainty
4. Hypothesis
5. Activity
6. Experiment
7. Evidence
8. Asset
9. Product
10. Revenue
11. Claim
12. Reuse

Relationships:

Theme -> Question
Question -> Uncertainty
Uncertainty -> Hypothesis
Hypothesis -> Activity
Activity -> Experiment
Experiment -> Evidence
Evidence -> Asset
Asset -> Product
Product -> Revenue
Evidence -> Claim
Asset -> Reuse

Required fields:

object_id
name
description
owner
created_date
status
linked_objects
receipts
cost_trace
customer_value
business_value

Status values:
REAL
PARTIAL
BLOCKED

Primary operating rule:
Research is only valuable when it produces reusable evidence-bearing assets that can improve outcomes, support decisions, and create economic value.
