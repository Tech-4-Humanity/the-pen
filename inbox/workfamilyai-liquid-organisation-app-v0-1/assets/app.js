const variables=[
['purpose_alignment','Purpose Alignment','Clarity and legitimacy of outcomes.'],['pressure_load','Pressure Load','Demand, volatility, urgency and complexity.'],['human_capacity','Human Capacity','Skills, wellbeing, judgement and attention.'],['ai_fit','AI Fit','Suitability, reversibility and evidence richness.'],['authority_clarity','Authority Clarity','Decision, approval, override and appeal rights.'],['artefact_integrity','Artefact Integrity','Freshness, provenance and completeness of data and documents.'],['flow_tempo','Flow and Tempo','Queues, handoffs, cycle time and synchronisation.'],['dependency_resilience','Dependency Resilience','Bottlenecks, substitutes and recovery paths.'],['learning_memory','Learning and Memory','Feedback, retention, selection and reuse.'],['trust_flourishing','Trust and Flourishing','Safety, fairness, dignity and stakeholder value.']
];
const scenarios={
 demand_doubles:{name:'Demand doubles in 30 days',effects:{pressure_load:-28,flow_tempo:-22,dependency_resilience:-16,human_capacity:-14},focus:['capacity','queues','safe augmentation']},
 key_person_leaves:{name:'Key person leaves unexpectedly',effects:{human_capacity:-26,learning_memory:-30,dependency_resilience:-24,authority_clarity:-12},focus:['handover','succession','institutional memory']},
 ai_adoption_surge:{name:'AI use rises rapidly',effects:{ai_fit:18,flow_tempo:14,authority_clarity:-18,artefact_integrity:-12,trust_flourishing:-14},focus:['governance','evidence','review rights']},
 critical_ai_error:{name:'Critical AI error enters a process',effects:{trust_flourishing:-32,artefact_integrity:-25,authority_clarity:-18,learning_memory:-10},focus:['containment','appeal','failure learning']},
 regulatory_change:{name:'Major regulatory change',effects:{pressure_load:-18,authority_clarity:-18,artefact_integrity:-22,learning_memory:-12},focus:['controls','training','evidence']},
 system_outage:{name:'Major system outage',effects:{dependency_resilience:-35,flow_tempo:-30,artefact_integrity:-18},focus:['fallback','restoration','recovery proof']},
 budget_reduction:{name:'Operating budget reduced',effects:{human_capacity:-18,flow_tempo:-14,trust_flourishing:-12,purpose_alignment:-8},focus:['value protection','low-value work','augmentation']},
 merger_restructure:{name:'Merger or major restructure',effects:{purpose_alignment:-18,authority_clarity:-28,artefact_integrity:-20,dependency_resilience:-15,trust_flourishing:-20},focus:['authority','harmonisation','trust']},
 cognitive_diversity:{name:'Redesign for cognitive diversity',effects:{human_capacity:20,ai_fit:12,flow_tempo:10,trust_flourishing:18},focus:['work patterns','cognitive load','strengths']},
 partner_failure:{name:'Critical partner fails',effects:{dependency_resilience:-34,artefact_integrity:-14,authority_clarity:-10,flow_tempo:-18},focus:['substitution','obligations','recovery']}
};
const state={scores:Object.fromEntries(variables.map(v=>[v[0],60])),receipt:null};
const clamp=n=>Math.max(0,Math.min(100,Math.round(n)));
function renderVariables(){
 const grid=document.querySelector('#variableGrid');grid.innerHTML='';
 variables.forEach(([id,name,desc])=>{const el=document.createElement('div');el.className='variable';el.innerHTML=`<header><h3>${name}</h3><span class="score" id="score-${id}">${state.scores[id]}</span></header><input aria-label="${name}" data-id="${id}" type="range" min="0" max="100" value="${state.scores[id]}"><small>${desc}</small>`;grid.appendChild(el)});
 grid.querySelectorAll('input').forEach(i=>i.addEventListener('input',e=>{state.scores[e.target.dataset.id]=Number(e.target.value);document.querySelector(`#score-${e.target.dataset.id}`).textContent=e.target.value}));
}
function renderScenarios(){const s=document.querySelector('#scenarioSelect');Object.entries(scenarios).forEach(([id,v])=>s.add(new Option(v.name,id)))}
function predict(){
 const scenario=scenarios[document.querySelector('#scenarioSelect').value];const intensity=Number(document.querySelector('#intensity').value);const multiplier=.55+(intensity*.15);const projected={...state.scores};
 Object.entries(scenario.effects).forEach(([k,v])=>projected[k]=clamp(projected[k]+v*multiplier));
 const sweet=[];const black=[];const adapt=[];
 const safeAI=(state.scores.ai_fit+state.scores.authority_clarity+state.scores.artefact_integrity+state.scores.trust_flourishing)/4;
 if(safeAI>=65)sweet.push('Evidence-backed AI preparation and option generation with accountable human approval.');
 if(state.scores.ai_fit>=65&&state.scores.flow_tempo<65)sweet.push('AI can reduce queue age, cognitive switching and repetitive coordination work.');
 if(state.scores.learning_memory>=60)sweet.push('Prediction outcomes can be retained and reused as institutional learning.');
 if(state.scores.human_capacity<55&&state.scores.ai_fit>=55)sweet.push('Target augmentation at fatigue-heavy tasks while retaining human judgement and relationships.');
 if(state.scores.authority_clarity<55)black.push('Authority, override and appeal rights are too weak for consequential automation.');
 if(state.scores.artefact_integrity<55)black.push('Stale or incomplete artefacts create confident but unreliable outputs.');
 if(state.scores.trust_flourishing<55)black.push('Efficiency gains may conceal reduced dignity, trust or meaningful contribution.');
 if(projected.dependency_resilience<45)black.push('A concentrated dependency creates cascading operational failure risk.');
 if(projected.flow_tempo<45)black.push('Scenario pressure pushes queues and handoffs beyond sustainable tempo.');
 if(!black.length)black.push('No critical blackspot detected; continue monitoring reversibility, evidence and stakeholder impact.');
 const weakest=Object.entries(projected).sort((a,b)=>a[1]-b[1]).slice(0,3);
 weakest.forEach(([id])=>adapt.push(recommendation(id)));
 adapt.push(`Run a focused ${scenario.focus.join(', ')} tabletop exercise and record predicted versus observed outcomes.`);
 const readiness=clamp(Object.values(projected).reduce((a,b)=>a+b,0)/10);const risk=clamp(100-readiness+(black.length*4));const confidence=clamp((state.scores.artefact_integrity+state.scores.learning_memory+state.scores.authority_clarity)/3);
 state.receipt={id:`WFAI-${Date.now()}`,created_at:new Date().toISOString(),scenario:scenario.name,intensity,baseline:{...state.scores},projected,sweetspots:sweet,blackspots:black,adaptations:adapt,readiness,risk,confidence,human_rule:'No human eliminated; accountable human authority, appeal and meaningful contribution preserved.',method:'Transparent weighted scenario deltas; coefficients are hypotheses until calibrated against observed telemetry.'};
 renderResult(state.receipt);
}
function recommendation(id){return ({purpose_alignment:'Clarify protected outcomes and remove work that exists only to serve legacy process.',pressure_load:'Create demand thresholds, triage rules and surge-capacity options.',human_capacity:'Redesign workload around human strengths, recovery and reduced cognitive switching.',ai_fit:'Separate AI preparation from accountable human decisions and test reversibility.',authority_clarity:'Document decision, approval, override, appeal and incident authority.',artefact_integrity:'Create canonical artefacts with ownership, provenance, freshness and validation.',flow_tempo:'Reduce handoffs, expose queues and define safe operating tempo.',dependency_resilience:'Add substitutes, fallbacks and recovery tests for concentrated dependencies.',learning_memory:'Capture outcomes, exceptions and selection decisions in institutional memory.',trust_flourishing:'Add affected-person review, explanation, challenge and wellbeing measures.'})[id]}
function renderResult(r){
 document.querySelector('#results').hidden=false;document.querySelector('#predictionSummary').textContent=`${r.scenario} produces readiness ${r.readiness}/100 with risk ${r.risk}/100. Prediction confidence is ${r.confidence}/100.`;
 document.querySelector('#metrics').innerHTML=[['Readiness',r.readiness],['Risk',r.risk],['Confidence',r.confidence],['Blackspots',r.blackspots.length]].map(([n,v])=>`<div class="metric"><span>${n}</span><strong>${v}</strong></div>`).join('');
 for(const [id,items] of [['sweetspots',r.sweetspots],['blackspots',r.blackspots],['adaptations',r.adaptations]])document.querySelector(`#${id}`).innerHTML=items.map(x=>`<li>${x}</li>`).join('');
 document.querySelector('#movement').innerHTML=variables.map(([id,name])=>{const d=r.projected[id]-r.baseline[id];return `<div class="bar-row"><span>${name}</span><div class="bar ${d<0?'negative':''}"><span style="width:${Math.abs(d)*2.5}%"></span></div><strong>${d>0?'+':''}${d}</strong></div>`}).join('');
 document.querySelector('#explainability').textContent=JSON.stringify({method:r.method,baseline:r.baseline,projected:r.projected,human_rule:r.human_rule},null,2);document.querySelector('#results').scrollIntoView({behavior:'smooth'});
}
function download(){if(!state.receipt)return;const blob=new Blob([JSON.stringify(state.receipt,null,2)],{type:'application/json'});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=`${state.receipt.id}.json`;a.click();URL.revokeObjectURL(a.href)}
document.querySelector('#runBtn').addEventListener('click',predict);document.querySelector('#downloadBtn').addEventListener('click',download);document.querySelector('#intensity').addEventListener('input',e=>document.querySelector('#intensityValue').textContent=e.target.value);document.querySelector('#exampleBtn').addEventListener('click',()=>{Object.assign(state.scores,{purpose_alignment:72,pressure_load:44,human_capacity:58,ai_fit:78,authority_clarity:49,artefact_integrity:52,flow_tempo:47,dependency_resilience:55,learning_memory:61,trust_flourishing:64});renderVariables()});
renderVariables();renderScenarios();