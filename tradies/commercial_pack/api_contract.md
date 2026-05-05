# API Contract (AI Tradies)

## Base
/ai-tradies/v1

## Endpoints

POST /intake
- input: channel, raw_payload
- output: structured_job

POST /quote
- input: job_id
- output: quote

POST /book
- input: job_id, timeslot
- output: booking confirmation

POST /followup
- input: job_id, type
- output: message sent

GET /metrics
- output: pipeline, conversion, revenue

POST /agent/run
- input: agent_code, payload
- output: result

## Events
- job_created
- job_qualified
- quote_sent
- job_booked
- job_completed
- invoice_paid

## Status
PARTIAL until deployed and tested
