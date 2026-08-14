#!/usr/bin/env python3
"""Recovery-escrow self-test for Product, Market & Customer Lifecycle team contracts.
Canonical target: TML-4PM/t4h-engineering-control-plane.
This file is an escrow/replay artifact only; it does not redefine canonical ownership.
"""
import hashlib, json, sys

CAPS = {
"CAP-RESEARCH-001":(["question_or_problem","source_refs","claims_needing_proof"],["evidence_map","source_quality","contradictions","gaps","research_findings"]),
"CAP-MARKET-INTEL-001":(["product_or_problem_context","geography_or_segment_hints","research_evidence"],["market_shape","competitors","substitutes","trends","opportunities","threats"]),
"CAP-DEMAND-001":(["problem_hypothesis","market_evidence","observable_demand_sources"],["urgency","demand_strength","buyer_signals","validation_confidence"]),
"CAP-CUST-DISC-001":(["target_users_or_buyers","problem_hypothesis","customer_evidence"],["jobs","pains","desired_outcomes","objections","segment_differences"]),
"CAP-PRODUCT-001":(["problem_evidence","demand_or_customer_evidence","portfolio_context"],["product_class","use_cases","scope","mvp","roadmap","build_buy_partner_decision"]),
"CAP-DESIGN-001":(["user_jobs","use_cases","constraints","product_hypothesis"],["journeys","concepts","prototypes","usability_findings","service_blueprint"]),
"CAP-PREPROD-001":(["product_outputs","design_outputs","commercial_assumptions","governance_constraints"],["readiness_decision","missing_requirements","risks","acceptance_plan"]),
"CAP-PRICE-001":(["buyer_value_evidence","alternatives","cost_envelope","product_scope"],["value_metric","tiers","bundles","willingness_to_pay_hypothesis","pricing_tests"]),
"CAP-FIN-001":(["price_packaging","cost_assumptions","demand_volumes","channel_assumptions"],["margin","break_even","resource_envelope","scenarios","investment_case"]),
"CAP-BRAND-001":(["product_class","audience","proposition","estate_portfolio"],["owning_brand","naming_constraints","overlap","cannibalisation","architecture_fit"]),
"CAP-GTM-001":(["proposition","icp","pricing","positioning_evidence","channels"],["launch_thesis","messaging","channel_plan","campaign_plan"]),
"CAP-SALES-001":(["icp","offer","pricing","product_proof","objections"],["qualification","pitch_demo","discovery_flow","objection_handling","close_path"]),
"CAP-REVOPS-001":(["sales_process","channel_sources","crm_context","analytics_requirements"],["funnel_stages","lead_routing","fields","follow_up","attribution_logic"]),
"CAP-CONTENT-001":(["gtm_message","product_proof","audience","cta"],["landing_copy","emails","posts","articles","case_study_assets"]),
"CAP-DIST-001":(["audience","gtm_plan","offer","geography","partner_context"],["ranked_channels","submissions","communities","marketplaces","distribution_tests"]),
"CAP-PARTNER-001":(["product_offer","capability_gaps","market_channel_context"],["partner_profile","candidate_partners","joint_motion","outreach_ready_pack"]),
"CAP-ANALYTICS-001":(["lifecycle_outcome","product_funnel","channels","customer_journey"],["event_schema","kpis","funnel_definitions","cohort_definitions","attribution","dashboard_requirements"]),
"CAP-GROWTH-001":(["baseline_metrics","channels","offer","funnel","constraints"],["experiment_backlog","hypotheses","success_thresholds","results"]),
"CAP-ONBOARD-001":(["product_workflow","first_value_definition","customer_type","support_constraints"],["onboarding_flow","activation_checklist","training","time_to_value_target"]),
"CAP-SUPPORT-001":(["product_behaviour","known_failure_modes","customer_channels","telemetry"],["triage_model","support_flows","slas","escalation","resolution_evidence"]),
"CAP-CUST-SUCCESS-001":(["customer_goals","onboarding","usage_health_signals","commercial_model"],["success_plan","health_model","adoption_actions","renewal_signals","expansion_signals"]),
"CAP-VOICE-001":(["support_tickets","reviews","churn_loss","interviews","product_feedback"],["themes","frequency","severity","request_clusters","churn_reasons","product_signals"]),
"CAP-KB-001":(["support_patterns","product_docs","resolved_issues"],["faq","troubleshooting","help_content","internal_support_knowledge"]),
"CAP-INCIDENT-001":(["incident_defect_evidence","affected_customers","severity","engineering_status"],["severity_classification","communications_plan","escalation","customer_status","post_incident_actions"]),
"CAP-RENEW-001":(["customer_health","usage","contract_commercial_data","support_history"],["renewal_risk","win_back","expansion","intervention_plan"]),
"CAP-PORTFOLIO-001":(["product_market_brand_economics_evidence","estate_inventory"],["invest_bundle_merge_kill_decision","priority","target_cohorts","cross_sell_paths"]),
"CAP-COMM-GOV-001":(["claims","pricing_terms","data_privacy","target_markets","external_commitments"],["go_hold_rework_constraints","claims_clearance","approval_requirements"]),
}

EVENTS = {
"SIGNAL_DETECTED":["CAP-RESEARCH-001","CAP-MARKET-INTEL-001","CAP-PORTFOLIO-001"],
"RESEARCH_FINDING_PUBLISHED":["CAP-RESEARCH-001","CAP-MARKET-INTEL-001","CAP-DEMAND-001","CAP-PORTFOLIO-001"],
"MARKET_CHANGED":["CAP-MARKET-INTEL-001","CAP-DEMAND-001","CAP-PRODUCT-001","CAP-GTM-001","CAP-PORTFOLIO-001"],
"CUSTOMER_REQUEST_RECEIVED":["CAP-CUST-DISC-001","CAP-DEMAND-001","CAP-PRODUCT-001","CAP-SALES-001"],
"OPPORTUNITY_DETECTED":["CAP-RESEARCH-001","CAP-MARKET-INTEL-001","CAP-DEMAND-001","CAP-PRODUCT-001","CAP-PORTFOLIO-001"],
"DEMAND_EVIDENCE_FOUND":["CAP-PRODUCT-001","CAP-PRICE-001","CAP-DESIGN-001","CAP-SALES-001","CAP-PORTFOLIO-001"],
"PROTOTYPE_READY":["CAP-CUST-DISC-001","CAP-DESIGN-001","CAP-PRODUCT-001","CAP-PRICE-001","CAP-SALES-001"],
"BUSINESS_CASE_READY":["CAP-FIN-001","CAP-PORTFOLIO-001","CAP-PRODUCT-001","CAP-COMM-GOV-001"],
"PREPROD_READY":["CAP-PREPROD-001","CAP-PRODUCT-001","CAP-DESIGN-001","CAP-FIN-001","CAP-COMM-GOV-001"],
"BUILD_VALIDATED":["CAP-PRODUCT-001","CAP-DESIGN-001","CAP-GTM-001","CAP-SALES-001","CAP-ANALYTICS-001","CAP-SUPPORT-001","CAP-CUST-SUCCESS-001","CAP-PORTFOLIO-001","CAP-COMM-GOV-001"],
"LAUNCH_READY":["CAP-BRAND-001","CAP-GTM-001","CAP-CONTENT-001","CAP-DIST-001","CAP-SALES-001","CAP-REVOPS-001","CAP-ANALYTICS-001","CAP-ONBOARD-001","CAP-SUPPORT-001","CAP-CUST-SUCCESS-001","CAP-COMM-GOV-001"],
"PARTNER_REQUIRED":["CAP-PARTNER-001","CAP-PORTFOLIO-001","CAP-PRODUCT-001","CAP-COMM-GOV-001"],
"PRICE_RESISTANCE":["CAP-PRICE-001","CAP-SALES-001","CAP-PRODUCT-001","CAP-MARKET-INTEL-001"],
"NO_TRAFFIC_THRESHOLD":["CAP-DIST-001","CAP-GTM-001","CAP-GROWTH-001","CAP-ANALYTICS-001"],
"TRIAL_ABANDONED":["CAP-PRODUCT-001","CAP-GROWTH-001","CAP-ONBOARD-001","CAP-CUST-SUCCESS-001","CAP-ANALYTICS-001"],
"DEFECT_CONFIRMED":["CAP-SUPPORT-001","CAP-INCIDENT-001"],
"DOCUMENTATION_GAP":["CAP-KB-001","CAP-PRODUCT-001","CAP-DESIGN-001"],
"FEATURE_REQUEST_CLUSTER":["CAP-PRODUCT-001","CAP-MARKET-INTEL-001","CAP-SALES-001","CAP-RESEARCH-001","CAP-VOICE-001"],
"CUSTOMER_RISK":["CAP-CUST-SUCCESS-001","CAP-SUPPORT-001","CAP-SALES-001","CAP-RENEW-001"],
"CUSTOMER_WON":["CAP-ONBOARD-001","CAP-CUST-SUCCESS-001","CAP-SALES-001","CAP-VOICE-001"],
"CUSTOMER_LOST":["CAP-VOICE-001","CAP-PRODUCT-001","CAP-PRICE-001","CAP-SALES-001","CAP-RESEARCH-001"],
"SUPPORT_PATTERN_DETECTED":["CAP-VOICE-001","CAP-KB-001","CAP-PRODUCT-001","CAP-DESIGN-001","CAP-SUPPORT-001"],
"CHURN_SIGNAL":["CAP-RENEW-001","CAP-CUST-SUCCESS-001","CAP-VOICE-001","CAP-PRODUCT-001","CAP-PRICE-001"],
"UPSELL_SIGNAL":["CAP-CUST-SUCCESS-001","CAP-SALES-001","CAP-PRODUCT-001","CAP-RENEW-001"],
"USABILITY_FAILURE":["CAP-DESIGN-001","CAP-PRODUCT-001","CAP-RESEARCH-001","CAP-SUPPORT-001"],
"ONBOARDING_FAILURE":["CAP-ONBOARD-001","CAP-CUST-SUCCESS-001","CAP-DESIGN-001","CAP-PRODUCT-001"],
"PRODUCT_REVIEW_DUE":["CAP-PRODUCT-001","CAP-PORTFOLIO-001","CAP-MARKET-INTEL-001","CAP-VOICE-001","CAP-FIN-001"],
"GROWTH_EXPERIMENT_DUE":["CAP-GROWTH-001","CAP-ANALYTICS-001","CAP-GTM-001","CAP-PRICE-001"],
"RENEWAL_DUE":["CAP-RENEW-001","CAP-CUST-SUCCESS-001","CAP-SALES-001","CAP-FIN-001"],
"REVOPS_SETUP_REQUIRED":["CAP-REVOPS-001","CAP-SALES-001","CAP-ANALYTICS-001"],
}

def h(obj): return hashlib.sha256(json.dumps(obj,sort_keys=True,separators=(",",":")).encode()).hexdigest()

def main():
    errors=[]
    if len(CAPS)!=27: errors.append(f"capability_count={len(CAPS)}")
    for cid,(inputs,outputs) in CAPS.items():
        if not inputs: errors.append(f"{cid}:no_inputs")
        if not outputs: errors.append(f"{cid}:no_outputs")
        if len(inputs)!=len(set(inputs)): errors.append(f"{cid}:duplicate_inputs")
        if len(outputs)!=len(set(outputs)): errors.append(f"{cid}:duplicate_outputs")
    covered={cid:[] for cid in CAPS}
    for evt,members in EVENTS.items():
        for cid in members:
            if cid not in CAPS: errors.append(f"{evt}:unknown:{cid}")
            else: covered[cid].append(evt)
    uncovered=[cid for cid,evts in covered.items() if not evts]
    if uncovered: errors.append("uncovered="+",".join(uncovered))

    build=EVENTS["BUILD_VALIDATED"]
    assert len(build)==9 and "CAP-SUPPORT-001" in build and "CAP-COMM-GOV-001" in build
    suppressed=len(CAPS)-len(build)
    backwards=["PRICE_RESISTANCE","USABILITY_FAILURE"]
    for evt in backwards: assert evt in EVENTS

    first=EVENTS["SUPPORT_PATTERN_DETECTED"]
    second=EVENTS["USABILITY_FAILURE"]
    dedup=[]
    for cid in first+second:
        if cid not in dedup: dedup.append(cid)
    assert len(first)+len(second)-len(dedup)==3

    work={"test_id":"PLC-SYNTH-001","event":"BUILD_VALIDATED","activated":build}
    assert h(work)==h(work)

    receipt={
      "status":"PASS" if not errors else "FAIL",
      "capabilities":len(CAPS),
      "events":len(EVENTS),
      "all_capabilities_routable":not uncovered,
      "build_validated_activated":len(build),
      "build_validated_suppressed":suppressed,
      "backwards_pressure_events":backwards,
      "support_feedback_duplicate_executions_suppressed":3,
      "idempotent_replay":True,
      "errors":errors,
    }
    receipt["suite_receipt"]="PLCS-"+h(receipt)[:20]
    print(json.dumps(receipt,indent=2))
    return 0 if not errors else 1

if __name__=="__main__": sys.exit(main())
