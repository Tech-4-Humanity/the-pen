import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const inputPath = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, "data", "atlas.json");
const out = process.argv[3] ? path.resolve(process.argv[3]) : path.join(root, "dist");
const source = fs.readFileSync(inputPath);
const graph = JSON.parse(source);
graph.stories ||= [];
graph.candidates ||= [];
const projections = JSON.parse(fs.readFileSync(path.join(root, "config", "projections.json"), "utf8"));

const esc = (value = "") => String(value).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const slug = value => String(value).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
const warnings = [];
const errors = [];
const ids = new Set();

for (const [kind, rows] of Object.entries({theme: graph.themes, topic: graph.topics, subtopic: graph.subtopics, evidence: graph.evidence})) {
  for (const row of rows) {
    if (!row.id || ids.has(row.id)) errors.push(`${kind}: missing or duplicate id ${row.id || "(blank)"}`);
    ids.add(row.id);
  }
}
const themeIds = new Set(graph.themes.map(x => x.id));
const topicIds = new Set(graph.topics.map(x => x.id));
for (const topic of graph.topics) if (!themeIds.has(topic.theme_id)) errors.push(`${topic.id}: unknown theme ${topic.theme_id}`);
for (const sub of graph.subtopics) {
  if (!themeIds.has(sub.theme_id)) errors.push(`${sub.id}: unknown theme ${sub.theme_id}`);
  if (!topicIds.has(sub.topic_id)) errors.push(`${sub.id}: unknown topic ${sub.topic_id}`);
  if (!sub.findings?.length) warnings.push(`${sub.id}: no verified findings`);
  if (!graph.stories.some(story => (story.subtopic_ids || []).includes(sub.id))) warnings.push(`${sub.id}: story slot pending`);
}
for (const evidence of graph.evidence) {
  if (!graph.subtopics.some(x => x.id === evidence.subtopic_id)) errors.push(`${evidence.id}: unknown subtopic ${evidence.subtopic_id}`);
  if (!evidence.source) warnings.push(`${evidence.id}: missing source`);
}
for (const story of graph.stories) {
  for (const id of story.subtopic_ids || []) if (!graph.subtopics.some(x => x.id === id)) errors.push(`${story.id}: unknown subtopic ${id}`);
}
if (errors.length) throw new Error(`Atlas validation failed:\n${errors.join("\n")}`);

fs.rmSync(out, {recursive: true, force: true});
fs.mkdirSync(out, {recursive: true});
fs.cpSync(path.join(root, "styles"), path.join(out, "assets"), {recursive: true});
if (fs.existsSync(path.join(root, "ip"))) fs.cpSync(path.join(root, "ip"), path.join(out, "ip"), {recursive: true});

const nav = `<nav><a href="/">Atlas</a><a href="/themes/">Themes</a><a href="/topics/">Topics</a><a href="/insights/">Insights</a><a href="/analytics/">Analytics</a><a href="/search/">Search</a><a class="ip-nav" href="/ip/">T4H IP</a></nav>`;
const footer = `<footer><div class="footer-grid"><div><h3>Explore the research</h3><a href="/evidence/">Evidence</a><a href="/stories/">Stories</a><a href="/hypotheses/">Hypotheses</a><a href="/findings/">Findings</a><a href="/outcomes/">Outcomes</a><a href="/problems-solved/">Problems solved</a><a href="/applications/">Applications</a><a href="/opportunities/">Opportunities</a><a href="/policy/">Policy</a><a href="/gaps/">Research gaps</a></div><div><h3>Atlas guidance</h3><a href="/instructions/">How to use the Atlas</a><a href="/instructions/#methodology">Methodology</a><a href="/instructions/#confidence">Evidence & confidence</a><a href="/instructions/#editorial">Editorial instructions</a><a href="/status/">Data status & audit trail</a></div><div><h3>Tech4Humanity</h3><a href="/ip/">T4H IP</a><a href="/pipeline/">Future research</a><p>One shell. Many governed projections.</p></div></div><div class="footer-base">Tech4Humanity Research Atlas · governed knowledge objects</div></footer>`;
function shell(title, eyebrow, body) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${esc(title)} · T4H Atlas</title><link rel="stylesheet" href="/assets/atlas.css"></head><body>${nav}<main><header class="hero"><p class="eyebrow">${esc(eyebrow)}</p><h1>${esc(title)}</h1></header>${body}</main>${footer}</body></html>`;
}
function card(label, title, text, href = "") {
  const inner = `<p class="eyebrow">${esc(label)}</p><h3>${esc(title)}</h3><p>${esc(text || "Editorial content pending reconciliation.")}</p>`;
  return href ? `<a class="card" href="${href}">${inner}</a>` : `<article class="card">${inner}</article>`;
}
function write(route, html) {
  const target = path.join(out, route, "index.html");
  fs.mkdirSync(path.dirname(target), {recursive: true});
  fs.writeFileSync(target, html);
}
function list(title, values) {
  return `<section><h2>${esc(title)}</h2>${values?.length ? `<ul>${values.map(x => `<li>${esc(typeof x === "string" ? x : x.title || x.id)}</li>`).join("")}</ul>` : `<p class="missing">No verified objects attached.</p>`}</section>`;
}
const values = value => value == null || value === "" ? [] : Array.isArray(value) ? value.filter(Boolean) : [value];
const subRoute = sub => {
  const topic = graph.topics.find(x => x.id === sub.topic_id);
  const theme = graph.themes.find(x => x.id === sub.theme_id);
  return `/themes/${theme.slug}/topics/${topic.slug}/${sub.slug}/`;
};
const maturity = sub => {
  const value = String(sub.confidence || sub.status || "").toUpperCase();
  if (["HIGH","VALIDATED","VERIFIED","REAL"].some(x => value.includes(x))) return "validated";
  if (["MEDIUM","MIXED","EMERGING","PARTIAL","IN PROGRESS"].some(x => value.includes(x))) return "emerging";
  return "exploratory";
};
function viewToggle(id) {
  return `<div class="surface-bar"><span>Research surface</span><div class="legend"><i class="dot validated"></i>Validated <i class="dot emerging"></i>Emerging <i class="dot exploratory"></i>Exploration</div><div class="toggles"><button onclick="atlasView('${id}','cards')" class="active">Cards</button><button onclick="atlasView('${id}','table')">Table</button></div></div>`;
}
function subtopicSurface(subs, id = "surface") {
  const cards = subs.map(sub => {
    const topic = graph.topics.find(x => x.id === sub.topic_id);
    return `<a class="oct-card ${maturity(sub)}" href="${subRoute(sub)}"><div class="oct-image"><span>${esc(sub.id)}</span></div><div class="oct-body"><div class="oct-meta">${esc(topic?.title || "")}<span>${esc(sub.status || "PENDING")}</span></div><h3>${esc(sub.title)}</h3><p>${esc(sub.problem || "Research summary pending.")}</p><div class="chips">${[...values(sub.findings).slice(0,2),...values(sub.research_gaps).slice(0,2)].map(x=>`<b>${esc(x)}</b>`).join("") || "<b>Content pending</b>"}</div><div class="hook"><strong>Research entry</strong> ${esc(sub.hypothesis || "Hypothesis pending.")}</div></div></a>`;
  }).join("");
  const rows = subs.map(sub => {
    const topic = graph.topics.find(x => x.id === sub.topic_id);
    const evidence = graph.evidence.filter(x => x.subtopic_id === sub.id).length;
    const stories = graph.stories.filter(x => (x.subtopic_ids || []).includes(sub.id)).length;
    return `<tr><td><a href="${subRoute(sub)}">${esc(sub.title)}</a><small>${esc(sub.id)}</small></td><td>${esc(topic?.title || "")}</td><td><span class="state ${maturity(sub)}">${esc(sub.confidence || sub.status)}</span></td><td>${evidence}</td><td>${stories || "Slot"}</td></tr>`;
  }).join("");
  return `${viewToggle(id)}<div id="${id}" class="atlas-surface"><div class="surface-cards">${cards || '<p class="missing">No Subtopics loaded.</p>'}</div><div class="surface-table"><table><thead><tr><th>Subtopic</th><th>Topic</th><th>Confidence</th><th>Evidence</th><th>Story</th></tr></thead><tbody>${rows}</tbody></table></div></div><script>function atlasView(id,mode){const el=document.getElementById(id);el.classList.toggle("show-table",mode==="table");const bar=el.previousElementSibling;bar.querySelectorAll("button").forEach(b=>b.classList.toggle("active",b.textContent.toLowerCase()===mode));}</script>`;
}
function themeMatrix(topics, subs) {
  const max = Math.max(1, ...topics.map(t => subs.filter(s => s.topic_id === t.id).length));
  const heads = Array.from({length:Math.min(8,max)},(_,i)=>`<th>Subtopic ${i+1}</th>`).join("");
  const rows = topics.map(topic => {
    const topicSubs = subs.filter(s => s.topic_id === topic.id).slice(0,8);
    const cells = Array.from({length:Math.min(8,max)},(_,i) => {
      const sub = topicSubs[i];
      return sub ? `<td><a href="${subRoute(sub)}"><i class="dot ${maturity(sub)}"></i>${esc(sub.title)}</a></td>` : "<td></td>";
    }).join("");
    return `<tr><th><small>${esc(topic.id)}</small>${esc(topic.title)}</th>${cells}</tr>`;
  }).join("");
  return `<section class="matrix"><div class="surface-bar"><span>Theme research surface</span><div class="legend"><i class="dot validated"></i>Validated <i class="dot emerging"></i>Emerging <i class="dot exploratory"></i>Exploration</div></div><div class="matrix-scroll"><table><thead><tr><th>Topic</th>${heads}</tr></thead><tbody>${rows}</tbody></table></div></section>`;
}
function sliceFooter(sub) {
  const q = `?subtopic=${encodeURIComponent(sub.id)}`;
  return `<aside class="slice-footer"><strong>Explore this Subtopic</strong><a href="/evidence/${q}">Evidence</a><a href="/stories/${q}">Story</a><a href="/hypotheses/${q}">Hypothesis</a><a href="/findings/${q}">Findings</a><a href="/outcomes/${q}">Outcomes</a><a href="/applications/${q}">Applications</a><a href="/opportunities/${q}">Opportunities</a><a href="/gaps/${q}">Gaps</a></aside>`;
}
function projectionRows(key, def) {
  if (def.kind === "evidence") return graph.evidence.map(e => ({id:e.id,title:e.title||e.id,text:e.findings||e.source||"",subtopic_id:e.subtopic_id,status:e.confidence||e.status||"UNASSESSED",href:`/studies/${e.slug||slug(e.id)}/`}));
  if (def.kind === "story") return graph.subtopics.map(sub => { const story=graph.stories.find(x=>(x.subtopic_ids||[]).includes(sub.id)); return {id:story?.id||`STORY-${sub.id}`,title:story?.title||`${sub.title}: Human Story`,text:story?.summary||"Governed story slot awaiting editorial content.",subtopic_id:sub.id,status:story?.status||"PENDING",href:`${subRoute(sub)}story/`}; });
  return graph.subtopics.flatMap(sub => def.fields.flatMap(field => values(sub[field]).map((text,i)=>({id:`${sub.id}-${field}-${i+1}`,title:sub.title,text,subtopic_id:sub.id,status:sub.confidence||sub.status||"UNASSESSED",href:subRoute(sub)}))));
}
function projectionPage(key, def) {
  const rows=projectionRows(key,def).map(row => {
    const sub=graph.subtopics.find(x=>x.id===row.subtopic_id);
    const topic=graph.topics.find(x=>x.id===sub?.topic_id);
    const theme=graph.themes.find(x=>x.id===sub?.theme_id);
    return {...row,topic:topic?.title||"",theme:theme?.title||"",theme_id:theme?.id||"",topic_id:topic?.id||""};
  });
  const cards=rows.map(row=>`<a class="projection-card" data-subtopic="${esc(row.subtopic_id)}" data-theme="${esc(row.theme_id)}" data-topic="${esc(row.topic_id)}" href="${row.href}"><span class="state">${esc(row.status)}</span><small>${esc(row.theme)} · ${esc(row.topic)}</small><h3>${esc(row.title)}</h3><p>${esc(row.text)}</p></a>`).join("");
  const table=rows.map(row=>`<tr data-subtopic="${esc(row.subtopic_id)}"><td><a href="${row.href}">${esc(row.title)}</a></td><td>${esc(row.theme)}</td><td>${esc(row.topic)}</td><td>${esc(row.status)}</td></tr>`).join("");
  return `<p class="lede">${esc(def.description)}</p><div class="metrics editorial"><strong>${rows.length}</strong> items <strong>${new Set(rows.map(x=>x.subtopic_id)).size}</strong> Subtopics <strong>${new Set(rows.map(x=>x.topic_id)).size}</strong> Topics</div><div class="projection-tools"><input id="projectionSearch" placeholder="Search this view"><button onclick="projectionMode('cards')">Cards</button><button onclick="projectionMode('table')">Table</button></div><div id="projection" class="projection"><div class="projection-cards">${cards||'<p class="missing">No verified items are available in this projection.</p>'}</div><div class="projection-table"><table><thead><tr><th>Item</th><th>Theme</th><th>Topic</th><th>Status</th></tr></thead><tbody>${table}</tbody></table></div></div><script>const params=new URLSearchParams(location.search),wanted=params.get("subtopic"),search=document.getElementById("projectionSearch");function applyProjection(){const term=(search.value||"").toLowerCase();document.querySelectorAll("#projection [data-subtopic]").forEach(el=>{el.hidden=!!((wanted&&el.dataset.subtopic!==wanted)||(term&&!el.textContent.toLowerCase().includes(term)));});}function projectionMode(mode){document.getElementById("projection").classList.toggle("show-table",mode==="table");}search.addEventListener("input",applyProjection);applyProjection();</script>`;
}

const stance = rows => rows.reduce((a, row) => {
  const key = String(row.stance || row.status || "UNCLASSIFIED").toUpperCase();
  a[key] = (a[key] || 0) + 1;
  return a;
}, {});
const rollup = subs => ({
  subtopics: subs.length,
  evidence: graph.evidence.filter(e => subs.some(s => s.id === e.subtopic_id)).length,
  gaps: subs.flatMap(s => s.research_gaps || []),
  contradictions: subs.flatMap(s => s.contradictions || []),
  frameworks: [...new Set(subs.flatMap(s => s.frameworks || []))],
  variables: [...new Set(subs.flatMap(s => s.variables || []))],
  measures: [...new Set(subs.flatMap(s => s.measures || []))],
  opportunities: subs.flatMap(s => s.commercial_opportunities || [])
});

write("", shell(graph.atlas.title, "Research intelligence", `<p class="lede">${esc(graph.atlas.description)}</p><div class="metrics editorial"><strong>${graph.themes.length}</strong> Themes <strong>${graph.topics.length}</strong> Topics <strong>${graph.subtopics.length}</strong> Subtopics <strong>${graph.evidence.length}</strong> Evidence objects <strong>${graph.subtopics.length}</strong> Story slots</div><section><h2>What has Tech4Humanity discovered?</h2><div class="grid">${graph.themes.map(t => card("Theme", t.title, t.summary, `/themes/${t.slug}/`)).join("")}</div></section>${subtopicSurface(graph.subtopics,"home-surface")}`));
write("themes", shell("Research Themes", "Atlas structure", `<p class="lede">Eight governed research narratives containing Topics and Subtopics.</p><div class="grid">${graph.themes.map(t=>card(t.id,t.title,t.summary,`/themes/${t.slug}/`)).join("")}</div>`));
write("topics", shell("Research Topics", "Atlas structure", `<p class="lede">Topic-level synthesis across the Atlas.</p><div class="grid">${graph.topics.map(t=>{const theme=graph.themes.find(x=>x.id===t.theme_id);return card(t.id,t.title,t.summary,`/themes/${theme.slug}/topics/${t.slug}/`)}).join("")}</div>`));
for (const theme of graph.themes) {
  const topics = graph.topics.filter(x => x.theme_id === theme.id);
  const subs = graph.subtopics.filter(x => x.theme_id === theme.id);
  const synthesis = rollup(subs);
  write(`themes/${theme.slug}`, shell(theme.title, theme.id, `<p class="lede">${esc(theme.summary)}</p><div class="metrics editorial"><strong>${topics.length}</strong> Topics <strong>${subs.length}</strong> Subtopics <strong>${synthesis.evidence}</strong> Evidence objects <strong>${subs.length}</strong> Story slots</div>${themeMatrix(topics,subs)}${subtopicSurface(subs,`theme-${theme.id}`)}${list("Research gaps", synthesis.gaps)}${list("Contradictions", synthesis.contradictions)}${list("Framework coverage", synthesis.frameworks)}${list("Opportunity signals", synthesis.opportunities)}`));
}
for (const topic of graph.topics) {
  const theme = graph.themes.find(x => x.id === topic.theme_id);
  const subs = graph.subtopics.filter(x => x.topic_id === topic.id);
  const synthesis = rollup(subs);
  write(`themes/${theme.slug}/topics/${topic.slug}`, shell(topic.title, `${theme.title} · ${topic.id}`, `<p class="lede">${esc(topic.summary)}</p><div class="metrics editorial"><strong>${synthesis.subtopics}</strong> Subtopics <strong>${synthesis.evidence}</strong> Evidence objects <strong>${subs.length}</strong> Story slots</div>${subtopicSurface(subs,`topic-${topic.id}`)}${list("Synthesis: gaps", synthesis.gaps)}${list("Synthesis: contradictions", synthesis.contradictions)}${list("Variables", synthesis.variables)}${list("Measures", synthesis.measures)}`));
}
for (const sub of graph.subtopics) {
  const topic = graph.topics.find(x => x.id === sub.topic_id);
  const theme = graph.themes.find(x => x.id === sub.theme_id);
  const evidence = graph.evidence.filter(x => x.subtopic_id === sub.id);
  const stories = graph.stories.filter(x => (x.subtopic_ids || []).includes(sub.id));
  const story = stories[0];
  const base = `themes/${theme.slug}/topics/${topic.slug}/${sub.slug}`;
  const passport = `<aside class="passport"><h2>Research passport</h2><dl><dt>Status</dt><dd>${esc(sub.status)}</dd><dt>Confidence</dt><dd>${esc(sub.confidence)}</dd><dt>Evidence objects</dt><dd>${evidence.length}</dd><dt>Population</dt><dd>${esc(sub.population)}</dd></dl></aside>`;
  write(base, shell(sub.title, `${theme.title} · ${topic.title}`, `${passport}<section><h2>Problem</h2><p>${esc(sub.problem)}</p></section><section><h2>Hypothesis</h2><p>${esc(sub.hypothesis)}</p></section>${list("Findings", sub.findings)}${list("Practical implications", sub.practical_implications)}${list("Commercial opportunities", sub.commercial_opportunities)}${list("Policy implications", sub.policy_implications)}<p><a class="button" href="/${base}/evidence/">Open scientific evidence dossier</a><a class="button story" href="/${base}/story/">Read the human story</a></p>${sliceFooter(sub)}`));
  write(`${base}/evidence`, shell(`${sub.title}: Evidence`, `${sub.id} · scientific dossier`, `${passport}${list("Methods", sub.methods)}${list("Variables", sub.variables)}${list("Measures", sub.measures)}${list("Frameworks", sub.frameworks)}${list("Evidence register", evidence)}${list("Research gaps", sub.research_gaps)}<section><h2>Audit trail</h2><p>Rendered from canonical object ${esc(sub.id)}. Missing objects remain visible.</p></section>`));
  const storyTitle = story?.title || `${sub.title}: Human Story`;
  const storyStatus = story?.status || "PENDING";
  const storySummary = story?.summary || "A governed story slot exists for this subtopic. Narrative content is pending editorial delivery.";
  write(`${base}/story`, shell(storyTitle, `${sub.id} · ${storyStatus}`, `<p class="lede">${esc(storySummary)}</p>${list("Narrative", [story?.narrative].filter(Boolean))}${list("Research connection", [sub.title])}<section><h2>Provenance</h2><p>${esc(story?.source || "Not yet supplied")}</p></section><p><a class="button" href="/${base}/">Return to research brief</a></p>`));
}
write("ip", shell("T4H IP", "Intellectual property", `<p class="lede">A separate control surface for understanding, governing and protecting Tech4Humanity intellectual property.</p><div class="metrics"><strong>2</strong> starting tools <strong>1</strong> governed IP section</div><div class="grid">${card("IP catalogue", "What is the IP?", "Every surfaced IP asset in plain language: who it helps, why it matters and its current protection form.", "/ip/what-is-ip.html")}${card("Portfolio control", "IP Portfolio Dashboard", "Research alignment, portfolio health, protection pathways, cost modelling and action priorities.", "/ip/portfolio-dashboard.html")}</div><section><h2>Governance boundary</h2><p>IP objects remain separate from the research taxonomy while retaining links to evidence, products, owners and lifecycle state.</p></section>`));
write("studies", shell("Evidence register", "Evidence compiler", `<div class="metrics"><strong>${graph.evidence.length}</strong> evidence objects</div><div class="grid">${graph.evidence.map(e => card(e.stance || e.status, e.title || e.id, e.findings || e.source, `/studies/${e.slug || slug(e.id)}/`)).join("") || card("Pending", "No evidence objects loaded", "The compiler is ready; content has not arrived.")}</div>`));
for (const e of graph.evidence) write(`studies/${e.slug || slug(e.id)}`, shell(e.title || e.id, "Evidence object", `<div class="metrics"><strong>${esc(e.confidence)}</strong> confidence <strong>${esc(e.stance || e.status)}</strong> stance</div>${list("Hypothesis", [e.hypothesis].filter(Boolean))}${list("Population", [e.population, e.sample, e.country].filter(Boolean))}${list("Methods", [e.method].filter(Boolean))}${list("Variables", Array.isArray(e.variables) ? e.variables : [e.variables].filter(Boolean))}${list("Findings", [e.findings].filter(Boolean))}${list("Limitations", [e.limitations].filter(Boolean))}${list("Implications", [e.implications].filter(Boolean))}<section><h2>Provenance</h2><p>${esc(e.source)}</p></section>`));
const storyCards = graph.subtopics.map(sub => { const story = graph.stories.find(s => (s.subtopic_ids || []).includes(sub.id)); const topic = graph.topics.find(t => t.id === sub.topic_id); const theme = graph.themes.find(t => t.id === sub.theme_id); return card(story?.status || "Pending", story?.title || `${sub.title}: Human Story`, story?.summary || "Governed story slot awaiting editorial content.", `/themes/${theme.slug}/topics/${topic.slug}/${sub.slug}/story/`); });
write("stories", shell("Human stories", "Story layer", `<div class="metrics"><strong>${graph.subtopics.length}</strong> story slots <strong>${graph.stories.length}</strong> completed objects</div><div class="grid">${storyCards.join("")}</div>`));
for (const s of graph.stories) write(`stories/${s.slug}`, shell(s.title, `${s.id} · ${s.status}`, `<p class="lede">${esc(s.summary)}</p>${list("Narrative", [s.narrative].filter(Boolean))}${list("Related research", s.subtopic_ids || [])}<section><h2>Provenance</h2><p>${esc(s.source || "Not supplied")}</p></section>`));
for (const [key,def] of Object.entries(projections)) write(key, shell(def.title, def.eyebrow, projectionPage(key,def)));
write("instructions", shell("How to Use the Atlas", "Instructions", `<p class="lede">The Atlas compiles governed research objects into multiple public views. Pages are generated; claims remain attached to sources, confidence and lifecycle state.</p><section><h2>Atlas hierarchy</h2><p>Theme → Topic → Subtopic → Evidence Object and Story. Cross-Atlas views extract fields without duplicating content.</p></section><section id="methodology"><h2>Methodology</h2><p>Structured objects are validated for identifiers and relationships before publication. Missing content remains visible and is never fabricated.</p></section><section id="confidence"><h2>Evidence and confidence</h2><p>Validated, emerging and exploratory states describe the strength and maturity of the attached evidence—not the visual polish of a page.</p></section><section id="editorial"><h2>Editorial instructions</h2><p>Writers update canonical objects. Every claim must identify its Theme, Topic, Subtopic, source, confidence, owner, version and updated date.</p></section><section><h2>Using the views</h2><p>Use Cards for narrative scanning, Table for comparison, and the Theme research surface for hierarchy. Footer views collect Evidence, Stories, Hypotheses, Findings, Outcomes, Applications, Opportunities, Policy and Gaps across all Subtopics.</p></section>`));
write("pipeline", shell("Future research pipeline", "Candidate research", `<div class="metrics"><strong>${graph.candidates.length}</strong> candidates</div><div class="grid">${graph.candidates.map(c => card(c.status, c.title, c.summary, `/pipeline/${c.slug}/`)).join("") || card("Pending", "No candidates loaded", "Candidate research remains separate from executed studies.")}</div>`));
for (const c of graph.candidates) write(`pipeline/${c.slug}`, shell(c.title, `${c.id} · ${c.status}`, `<p class="lede">${esc(c.summary)}</p>${list("Research questions", c.research_questions || [])}${list("Dependencies", c.dependencies || [])}${list("Next gate", [c.next_gate].filter(Boolean))}`));
const evidenceByStatus = graph.evidence.reduce((a, e) => ((a[e.status] = (a[e.status] || 0) + 1), a), {});
write("analytics", shell("Global Research View", "Analytics", `<div class="metrics"><strong>${graph.evidence.length}</strong> studies <strong>${graph.subtopics.length}</strong> subtopics <strong>${graph.topics.length}</strong> topics</div><h2>Evidence status</h2><pre>${esc(JSON.stringify(evidenceByStatus, null, 2))}</pre><h2>Evidence stance</h2><pre>${esc(JSON.stringify(stance(graph.evidence), null, 2))}</pre>${list("Countries", [...new Set(graph.evidence.map(e => e.country).filter(Boolean))])}${list("Methods", [...new Set(graph.evidence.map(e => e.method).filter(Boolean))])}`));
write("insights", shell("Atlas Intelligence", "Synthesis", `<p class="lede">Generated knowledge-strength and gap signals.</p>${list("Known gaps", graph.subtopics.flatMap(s => s.research_gaps || []))}${list("Contradictions", graph.subtopics.flatMap(s => s.contradictions || []))}${list("Opportunities", graph.subtopics.flatMap(s => s.commercial_opportunities || []))}`));
write("search", shell("Search the Atlas", "Discovery", `<p class="lede">Search is generated from every governed object.</p><input class="search-box" id="atlasSearch" placeholder="Search Themes, Topics, Subtopics and evidence"><div id="searchResults" class="projection-cards"></div><script>fetch("/search-index.json").then(r=>r.json()).then(rows=>{const q=document.getElementById("atlasSearch"),out=document.getElementById("searchResults");function draw(){const term=q.value.toLowerCase();out.innerHTML=term?rows.filter(x=>(x.title+" "+x.text).toLowerCase().includes(term)).slice(0,50).map(x=>`<article class="projection-card"><small>${x.id}</small><h3>${x.title}</h3><p>${x.text}</p></article>`).join(""):"";}q.addEventListener("input",draw);});</script>`));
write("status", shell("Compiler status", "Build telemetry", `<div class="metrics"><strong>${errors.length ? "FAIL" : "PASS"}</strong> validation <strong>${warnings.length}</strong> warnings</div><p>This page is generated inside the enumerated build and is therefore covered by the manifest.</p>${list("Warnings", warnings)}${list("Errors", errors)}`));

const htmlFiles = [];
const walk = dir => fs.readdirSync(dir, {withFileTypes:true}).flatMap(e => e.isDirectory() ? walk(path.join(dir,e.name)) : [path.join(dir,e.name)]);
for (const f of walk(out)) if (f.endsWith(".html")) htmlFiles.push(f);
const manifest = htmlFiles.map(f => ({path:path.relative(out,f), sha256:crypto.createHash("sha256").update(fs.readFileSync(f)).digest("hex")}));
const searchable = [...graph.themes, ...graph.topics, ...graph.subtopics, ...graph.evidence, ...graph.stories, ...graph.candidates];
fs.writeFileSync(path.join(out, "search-index.json"), JSON.stringify(searchable.map(x => ({id:x.id,title:x.title || x.id,text:[x.summary,x.problem,x.hypothesis,x.findings].filter(Boolean).join(" ")})), null, 2));
fs.writeFileSync(path.join(out, "build-manifest.json"), JSON.stringify(manifest, null, 2));
const relationships = [
  ...graph.topics.map(x => ({from:x.theme_id,to:x.id,type:"CONTAINS"})),
  ...graph.subtopics.flatMap(x => [{from:x.theme_id,to:x.id,type:"CONTAINS"},{from:x.topic_id,to:x.id,type:"CONTAINS"}]),
  ...graph.evidence.map(x => ({from:x.subtopic_id,to:x.id,type:"SUPPORTED_BY"})),
  ...graph.stories.flatMap(x => (x.subtopic_ids || []).map(id => ({from:id,to:x.id,type:"ILLUSTRATED_BY"})))
];
fs.writeFileSync(path.join(out, "relationship-graph.json"), JSON.stringify({nodes:searchable.map(x => ({id:x.id,type:x.id?.split("-")[0] || "OBJECT"})),edges:relationships}, null, 2));
fs.writeFileSync(path.join(out, "sitemap.xml"), `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${manifest.map(x => `<url><loc>/${x.path.replace(/index\.html$/,"")}</loc></url>`).join("")}</urlset>`);
const linked = [...fs.readFileSync(path.join(out,"index.html"),"utf8").matchAll(/href="(\/[^"#?]*)"/g)].map(x => x[1]);
const brokenLinks = linked.filter(href => !fs.existsSync(path.join(out, href, "index.html")) && !fs.existsSync(path.join(out, href)));
if (brokenLinks.length) errors.push(...brokenLinks.map(x => `broken link ${x}`));
const receipt = {
  classification: warnings.length ? "PARTIAL" : "REAL",
  build_status: "PASS",
  deployment_status: "NOT_DEPLOYED",
  source: path.basename(inputPath),
  source_sha256: crypto.createHash("sha256").update(source).digest("hex"),
  counts: {themes:graph.themes.length, topics:graph.topics.length, subtopics:graph.subtopics.length, evidence:graph.evidence.length, stories:graph.stories.length, story_slots:graph.subtopics.length, ip_pages:3, projection_pages:Object.keys(projections).length, candidates:graph.candidates.length, html_pages:htmlFiles.length, relationships:relationships.length},
  warnings, errors, broken_links:brokenLinks, manifest_sha256: crypto.createHash("sha256").update(JSON.stringify(manifest)).digest("hex")
};
fs.writeFileSync(path.join(out, "build-receipt.json"), JSON.stringify(receipt, null, 2));
console.log(JSON.stringify(receipt, null, 2));
