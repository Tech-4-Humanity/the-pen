-- ============================================================================
-- Content Signal OS — Smoke Test
-- Input: "This is a good article. Turn this into a normal LinkedIn article for
--  Tech 4 Humanity about why AI companion devices need consent, signal
--  boundaries, and human-centred governance."
-- Proves: ingest -> escalation -> package -> HITL gates -> HELD queue.
-- Transactional + rolled back so it leaves no residue. Asserts via RAISE.
-- Verified PASS on S1 2026-05-18.
-- ============================================================================
begin;
do $$
declare
  v_sig content_signal.conversation_signal;
  v_topic content_signal.topic_registry;
  v_pkg content_signal.content_package;
  v_gates int; v_queue text;
begin
  insert into content_signal.conversation_signal (source_type, raw_text, detected_intent, thread_ref)
  values ('live_llm',
     'This is a good article. Turn this into a normal LinkedIn article for Tech 4 Humanity about why AI companion devices need consent, signal boundaries, and human-centred governance.',
     'create_linkedin_article','smoke-test')
  returning * into v_sig;
  v_topic := content_signal.fn_register_topic_occurrence('ai-companion-consent','AI companion devices: consent + signal boundaries', v_sig.id);
  if v_topic.occurrence_count < 1 or v_topic.escalation_state <> 'one_off' then
    raise exception 'SMOKE FAIL escalation: % (%)', v_topic.escalation_state, v_topic.occurrence_count;
  end if;
  v_pkg := content_signal.fn_generate_package(v_sig.id,'Why AI companion devices need consent and human-centred governance','normal','tech4humanity','linkedin');
  select count(*) into v_gates from content_signal.approval_gate where content_package_id = v_pkg.id;
  select state into v_queue from content_signal.publishing_queue where content_package_id = v_pkg.id;
  if v_gates <> 3 then raise exception 'SMOKE FAIL gates: %', v_gates; end if;
  if v_queue <> 'held' then raise exception 'SMOKE FAIL queue: %', v_queue; end if;
  if v_pkg.status <> 'awaiting_approval' then raise exception 'SMOKE FAIL pkg: %', v_pkg.status; end if;
  raise notice 'SMOKE PASS: signal=% topic=%/% package=% gates=% queue=%', v_sig.id, v_topic.escalation_state, v_topic.occurrence_count, v_pkg.id, v_gates, v_queue;
end $$;
rollback;
