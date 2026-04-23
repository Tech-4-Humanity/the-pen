# DRIVE + REGISTRY — T4H Closed Loop

## Objective
Ensure all documentation is:
- generated
- written to Google Drive
- linked
- stored in Supabase
- surfaced in Command Centre

## Drive Write Contract

Input:

{
  "action": "write_drive_doc",
  "documents": [
    { "name": "README", "content": "..." }
  ]
}

Output:

{
  "documents": [
    {
      "name": "README",
      "url": "https://drive.google.com/..."
    }
  ]
}

## Supabase Registry

Table: doc_registry

Columns:
- id
- name
- url
- system
- created_at

## Rules

- No document exists without a URL.
- No URL exists without being stored.
- No stored document exists without being surfaced.

## Command Centre

Must show:
- README
- Runbook
- Architecture
- Execution Contract

## Failure Condition

If any doc is:
- not written
- not linked
- not stored

System is PARTIAL.

## Completion Condition

All docs exist in Drive with URLs returned and stored.
