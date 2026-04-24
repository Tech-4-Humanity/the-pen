# User Instructions

## How to use
- Do not run SQL directly
- Do not ask workers to do manual tasks
- Express intent or enqueue jobs only

## Pattern
Intent → enqueue_job → worker executes → receipt verifies

## Definition of Done
- receipt exists
- audit events present
- output verified

If any missing → system requeues or repairs
