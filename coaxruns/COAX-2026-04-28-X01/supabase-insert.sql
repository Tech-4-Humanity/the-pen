-- coaxexecutionlog INSERT for COAX-X/COAX-2026-04-28-X01
INSERT INTO coaxexecutionlog (
  coaxthreadid, agent, sourcesystem, layer, intent,
  requestpayload, rawresponse, normalizedresponse,
  schemavalid, receiptid, receiptsurface,
  githubrepo, githubpath, status, reality, createdat
) VALUES (
  'COAX-2026-04-28-X01', 'COAX-X', 'Grok', 'RISK',
  'Validate BASIQ CDR consent flow against production API surface',
  '{"coaxthreadid":"COAX-2026-04-28-X01"}'::jsonb,
  '{"coaxagent":"COAX-X","sourcesystem":"Grok","reality":"PARTIAL"}'::jsonb,
  '{"normalised_by":"COAX-G","reality":"PARTIAL"}'::jsonb,
  true,
  'RCP-COAXX-20260428-X01', 'the-pen',
  'TML-4PM/the-pen',
  'coaxruns/COAX-2026-04-28-X01/receipt.json',
  'pending-verifier', 'PARTIAL',
  NOW()
);

-- coaxreceipts INSERT
INSERT INTO coaxreceipts (
  receiptid, coaxthreadid, agent, machineemitter,
  emitsurface, prooftype, proofuri,
  githubcommitsha, createdat, payload
) VALUES (
  'RCP-COAXX-20260428-X01', 'COAX-2026-04-28-X01', 'COAX-X',
  'bridge-worker-intake', 'the-pen',
  'external-api-research-completion',
  'https://github.com/TML-4PM/the-pen/tree/main/coaxruns/COAX-2026-04-28-X01/receipt.json',
  'PENDING_WRITE', NOW(),
  '{"receiptid":"RCP-COAXX-20260428-X01","hiltouched":false}'::jsonb
);