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

const nav = `<nav><a href="/">Atlas</a><a href="/studies/">Evidence</a><a href="/stories/">Stories</a><a href="/pipeline/">Future research</a><a href="/insights/">Insights</a><a href="/analytics/">Analytics</a></nav>`;
function shell(title, eyebrow, body) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${esc(title)} · T4H Atlas</title><link rel="stylesheet" href="/assets/atlas.css"></head><body>${nav}<main><header class="hero"><p class="eyebrow">${esc(eyebrow)}</p><h1>${esc(title)}</h1></header>${body}</main><footer>Tech4Humanity Research Atlas · governed knowledge objects</footer></body></html>`;
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

write("", shell(graph.atlas.title, "Research intelligence", `<p class="lede">${esc(graph.atlas.description)}</p><section><h2>What has Tech4Humanity discovered?</h2><div class="grid">${graph.themes.map(t => card("Theme", t.title, t.summary, `/themes/${t.slug}/`)).join("")}</div></section>`));
for (const theme of graph.themes) {
  const topics = graph.topics.filter(x => x.theme_id === theme.id);
  const subs = graph.subtopics.filter(x => x.theme_id === theme.id);
  const synthesis = rollup(subs);
  write(`themes/${theme.slug}`, shell(theme.title, theme.id, `<p class="lede">${esc(theme.summary)}</p><div class="metrics"><strong>${topics.length}</strong> topics <strong>${subs.length}</strong> subtopics <strong>${synthesis.evidence}</strong> evidence objects</div><div class="grid">${topics.map(t => card("Topic", t.title, t.summary, `/themes/${theme.slug}/topics/${t.slug}/`)).join("")}</div>${list("Research gaps", synthesis.gaps)}${list("Contradictions", synthesis.contradictions)}${list("Framework coverage", synthesis.frameworks)}${list("Opportunity signals", synthesis.opportunities)}`));
}
for (const topic of graph.topics) {
  const theme = graph.themes.find(x => x.id === topic.theme_id);
  const subs = graph.subtopics.filter(x => x.topic_id === topic.id);
  const synthesis = rollup(subs);
  write(`themes/${theme.slug}/topics/${topic.slug}`, shell(topic.title, `${theme.title} · ${topic.id}`, `<p class="lede">${esc(topic.summary)}</p><div class="metrics"><strong>${synthesis.subtopics}</strong> subtopics <strong>${synthesis.evidence}</strong> evidence objects</div><div class="grid">${subs.map(s => card("Subtopic", s.title, s.problem, `/themes/${theme.slug}/topics/${topic.slug}/${s.slug}/`)).join("")}</div>${list("Synthesis: gaps", synthesis.gaps)}${list("Synthesis: contradictions", synthesis.contradictions)}${list("Variables", synthesis.variables)}${list("Measures", synthesis.measures)}`));
}
for (const sub of graph.subtopics) {
  const topic = graph.topics.find(x => x.id === sub.topic_id);
  const theme = graph.themes.find(x => x.id === sub.theme_id);
  const evidence = graph.evidence.filter(x => x.subtopic_id === sub.id);
  const stories = graph.stories.filter(x => (x.subtopic_ids || []).includes(sub.id));
  const story = stories[0];
  const base = `themes/${theme.slug}/topics/${topic.slug}/${sub.slug}`;
  const passport = `<aside class="passport"><h2>Research passport</h2><dl><dt>Status</dt><dd>${esc(sub.status)}</dd><dt>Confidence</dt><dd>${esc(sub.confidence)}</dd><dt>Evidence objects</dt><dd>${evidence.length}</dd><dt>Population</dt><dd>${esc(sub.population)}</dd></dl></aside>`;
  write(base, shell(sub.title, `${theme.title} · ${topic.title}`, `${passport}<section><h2>Problem</h2><p>${esc(sub.problem)}</p></section><section><h2>Hypothesis</h2><p>${esc(sub.hypothesis)}</p></section>${list("Findings", sub.findings)}${list("Practical implications", sub.practical_implications)}${list("Commercial opportunities", sub.commercial_opportunities)}${list("Policy implications", sub.policy_implications)}<p><a class="button" href="/${base}/evidence/">Open scientific evidence dossier</a><a class="button story" href="/${base}/story/">Read the human story</a></p>`));
  write(`${base}/evidence`, shell(`${sub.title}: Evidence`, `${sub.id} · scientific dossier`, `${passport}${list("Methods", sub.methods)}${list("Variables", sub.variables)}${list("Measures", sub.measures)}${list("Frameworks", sub.frameworks)}${list("Evidence register", evidence)}${list("Research gaps", sub.research_gaps)}<section><h2>Audit trail</h2><p>Rendered from canonical object ${esc(sub.id)}. Missing objects remain visible.</p></section>`));
  const storyTitle = story?.title || `${sub.title}: Human Story`;
  const storyStatus = story?.status || "PENDING";
  const storySummary = story?.summary || "A governed story slot exists for this subtopic. Narrative content is pending editorial delivery.";
  write(`${base}/story`, shell(storyTitle, `${sub.id} · ${storyStatus}`, `<p class="lede">${esc(storySummary)}</p>${list("Narrative", [story?.narrative].filter(Boolean))}${list("Research connection", [sub.title])}<section><h2>Provenance</h2><p>${esc(story?.source || "Not yet supplied")}</p></section><p><a class="button" href="/${base}/">Return to research brief</a></p>`));
}
write("studies", shell("Evidence register", "Evidence compiler", `<div class="metrics"><strong>${graph.evidence.length}</strong> evidence objects</div><div class="grid">${graph.evidence.map(e => card(e.stance || e.status, e.title || e.id, e.findings || e.source, `/studies/${e.slug || slug(e.id)}/`)).join("") || card("Pending", "No evidence objects loaded", "The compiler is ready; content has not arrived.")}</div>`));
for (const e of graph.evidence) write(`studies/${e.slug || slug(e.id)}`, shell(e.title || e.id, "Evidence object", `<div class="metrics"><strong>${esc(e.confidence)}</strong> confidence <strong>${esc(e.stance || e.status)}</strong> stance</div>${list("Hypothesis", [e.hypothesis].filter(Boolean))}${list("Population", [e.population, e.sample, e.country].filter(Boolean))}${list("Methods", [e.method].filter(Boolean))}${list("Variables", Array.isArray(e.variables) ? e.variables : [e.variables].filter(Boolean))}${list("Findings", [e.findings].filter(Boolean))}${list("Limitations", [e.limitations].filter(Boolean))}${list("Implications", [e.implications].filter(Boolean))}<section><h2>Provenance</h2><p>${esc(e.source)}</p></section>`));
const storyCards = graph.subtopics.map(sub => { const story = graph.stories.find(s => (s.subtopic_ids || []).includes(sub.id)); const topic = graph.topics.find(t => t.id === sub.topic_id); const theme = graph.themes.find(t => t.id === sub.theme_id); return card(story?.status || "Pending", story?.title || `${sub.title}: Human Story`, story?.summary || "Governed story slot awaiting editorial content.", `/themes/${theme.slug}/topics/${topic.slug}/${sub.slug}/story/`); });
write("stories", shell("Human stories", "Story layer", `<div class="metrics"><strong>${graph.subtopics.length}</strong> story slots <strong>${graph.stories.length}</strong> completed objects</div><div class="grid">${storyCards.join("")}</div>`));
for (const s of graph.stories) write(`stories/${s.slug}`, shell(s.title, `${s.id} · ${s.status}`, `<p class="lede">${esc(s.summary)}</p>${list("Narrative", [s.narrative].filter(Boolean))}${list("Related research", s.subtopic_ids || [])}<section><h2>Provenance</h2><p>${esc(s.source || "Not supplied")}</p></section>`));
write("pipeline", shell("Future research pipeline", "Candidate research", `<div class="metrics"><strong>${graph.candidates.length}</strong> candidates</div><div class="grid">${graph.candidates.map(c => card(c.status, c.title, c.summary, `/pipeline/${c.slug}/`)).join("") || card("Pending", "No candidates loaded", "Candidate research remains separate from executed studies.")}</div>`));
for (const c of graph.candidates) write(`pipeline/${c.slug}`, shell(c.title, `${c.id} · ${c.status}`, `<p class="lede">${esc(c.summary)}</p>${list("Research questions", c.research_questions || [])}${list("Dependencies", c.dependencies || [])}${list("Next gate", [c.next_gate].filter(Boolean))}`));
const evidenceByStatus = graph.evidence.reduce((a, e) => ((a[e.status] = (a[e.status] || 0) + 1), a), {});
write("analytics", shell("Global Research View", "Analytics", `<div class="metrics"><strong>${graph.evidence.length}</strong> studies <strong>${graph.subtopics.length}</strong> subtopics <strong>${graph.topics.length}</strong> topics</div><h2>Evidence status</h2><pre>${esc(JSON.stringify(evidenceByStatus, null, 2))}</pre><h2>Evidence stance</h2><pre>${esc(JSON.stringify(stance(graph.evidence), null, 2))}</pre>${list("Countries", [...new Set(graph.evidence.map(e => e.country).filter(Boolean))])}${list("Methods", [...new Set(graph.evidence.map(e => e.method).filter(Boolean))])}`));
write("insights", shell("Atlas Intelligence", "Synthesis", `<p class="lede">Generated knowledge-strength and gap signals.</p>${list("Known gaps", graph.subtopics.flatMap(s => s.research_gaps || []))}${list("Contradictions", graph.subtopics.flatMap(s => s.contradictions || []))}${list("Opportunities", graph.subtopics.flatMap(s => s.commercial_opportunities || []))}`));
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
  counts: {themes:graph.themes.length, topics:graph.topics.length, subtopics:graph.subtopics.length, evidence:graph.evidence.length, stories:graph.stories.length, story_slots:graph.subtopics.length, candidates:graph.candidates.length, html_pages:htmlFiles.length, relationships:relationships.length},
  warnings, errors, broken_links:brokenLinks, manifest_sha256: crypto.createHash("sha256").update(JSON.stringify(manifest)).digest("hex")
};
fs.writeFileSync(path.join(out, "build-receipt.json"), JSON.stringify(receipt, null, 2));
console.log(JSON.stringify(receipt, null, 2));
