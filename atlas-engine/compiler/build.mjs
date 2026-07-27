import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const inputPath = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, "data", "atlas.json");
const out = process.argv[3] ? path.resolve(process.argv[3]) : path.join(root, "dist");
const source = fs.readFileSync(inputPath);
const graph = JSON.parse(source);

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
}
if (errors.length) throw new Error(`Atlas validation failed:\n${errors.join("\n")}`);

fs.rmSync(out, {recursive: true, force: true});
fs.mkdirSync(out, {recursive: true});
fs.cpSync(path.join(root, "styles"), path.join(out, "assets"), {recursive: true});

const nav = `<nav><a href="/">Atlas</a><a href="/insights/">Insights</a><a href="/analytics/">Analytics</a></nav>`;
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

write("", shell(graph.atlas.title, "Research intelligence", `<p class="lede">${esc(graph.atlas.description)}</p><section><h2>What has Tech4Humanity discovered?</h2><div class="grid">${graph.themes.map(t => card("Theme", t.title, t.summary, `/themes/${t.slug}/`)).join("")}</div></section>`));
for (const theme of graph.themes) {
  const topics = graph.topics.filter(x => x.theme_id === theme.id);
  const subs = graph.subtopics.filter(x => x.theme_id === theme.id);
  write(`themes/${theme.slug}`, shell(theme.title, theme.id, `<p class="lede">${esc(theme.summary)}</p><div class="metrics"><strong>${topics.length}</strong> topics <strong>${subs.length}</strong> subtopics <strong>${graph.evidence.filter(e => subs.some(s => s.id === e.subtopic_id)).length}</strong> evidence objects</div><div class="grid">${topics.map(t => card("Topic", t.title, t.summary, `/themes/${theme.slug}/topics/${t.slug}/`)).join("")}</div>${list("Research gaps", subs.flatMap(s => s.research_gaps || []))}`));
}
for (const topic of graph.topics) {
  const theme = graph.themes.find(x => x.id === topic.theme_id);
  const subs = graph.subtopics.filter(x => x.topic_id === topic.id);
  write(`themes/${theme.slug}/topics/${topic.slug}`, shell(topic.title, `${theme.title} · ${topic.id}`, `<p class="lede">${esc(topic.summary)}</p><div class="grid">${subs.map(s => card("Subtopic", s.title, s.problem, `/themes/${theme.slug}/topics/${topic.slug}/${s.slug}/`)).join("")}</div>`));
}
for (const sub of graph.subtopics) {
  const topic = graph.topics.find(x => x.id === sub.topic_id);
  const theme = graph.themes.find(x => x.id === sub.theme_id);
  const evidence = graph.evidence.filter(x => x.subtopic_id === sub.id);
  const base = `themes/${theme.slug}/topics/${topic.slug}/${sub.slug}`;
  const passport = `<aside class="passport"><h2>Research passport</h2><dl><dt>Status</dt><dd>${esc(sub.status)}</dd><dt>Confidence</dt><dd>${esc(sub.confidence)}</dd><dt>Evidence objects</dt><dd>${evidence.length}</dd><dt>Population</dt><dd>${esc(sub.population)}</dd></dl></aside>`;
  write(base, shell(sub.title, `${theme.title} · ${topic.title}`, `${passport}<section><h2>Problem</h2><p>${esc(sub.problem)}</p></section><section><h2>Hypothesis</h2><p>${esc(sub.hypothesis)}</p></section>${list("Findings", sub.findings)}${list("Practical implications", sub.practical_implications)}${list("Commercial opportunities", sub.commercial_opportunities)}${list("Policy implications", sub.policy_implications)}<p><a class="button" href="/${base}/evidence/">Open scientific evidence dossier</a></p>`));
  write(`${base}/evidence`, shell(`${sub.title}: Evidence`, `${sub.id} · scientific dossier`, `${passport}${list("Methods", sub.methods)}${list("Variables", sub.variables)}${list("Measures", sub.measures)}${list("Frameworks", sub.frameworks)}${list("Evidence register", evidence)}${list("Research gaps", sub.research_gaps)}<section><h2>Audit trail</h2><p>Rendered from canonical object ${esc(sub.id)}. Missing objects remain visible.</p></section>`));
}
const evidenceByStatus = graph.evidence.reduce((a, e) => ((a[e.status] = (a[e.status] || 0) + 1), a), {});
write("analytics", shell("Global Research View", "Analytics", `<div class="metrics"><strong>${graph.evidence.length}</strong> studies <strong>${graph.subtopics.length}</strong> subtopics <strong>${graph.topics.length}</strong> topics</div><pre>${esc(JSON.stringify(evidenceByStatus, null, 2))}</pre>`));
write("insights", shell("Atlas Intelligence", "Synthesis", `<p class="lede">Generated knowledge-strength and gap signals.</p>${list("Known gaps", graph.subtopics.flatMap(s => s.research_gaps || []))}`));

const htmlFiles = [];
const walk = dir => fs.readdirSync(dir, {withFileTypes:true}).flatMap(e => e.isDirectory() ? walk(path.join(dir,e.name)) : [path.join(dir,e.name)]);
for (const f of walk(out)) if (f.endsWith(".html")) htmlFiles.push(f);
const manifest = htmlFiles.map(f => ({path:path.relative(out,f), sha256:crypto.createHash("sha256").update(fs.readFileSync(f)).digest("hex")}));
fs.writeFileSync(path.join(out, "search-index.json"), JSON.stringify([...graph.themes, ...graph.topics, ...graph.subtopics].map(x => ({id:x.id,title:x.title,text:[x.summary,x.problem,x.hypothesis].filter(Boolean).join(" ")})), null, 2));
fs.writeFileSync(path.join(out, "build-manifest.json"), JSON.stringify(manifest, null, 2));
const receipt = {
  classification: warnings.length ? "PARTIAL" : "REAL",
  build_status: "PASS",
  deployment_status: "NOT_DEPLOYED",
  source: path.basename(inputPath),
  source_sha256: crypto.createHash("sha256").update(source).digest("hex"),
  counts: {themes:graph.themes.length, topics:graph.topics.length, subtopics:graph.subtopics.length, evidence:graph.evidence.length, stories:graph.stories.length, html_pages:htmlFiles.length},
  warnings, errors, manifest_sha256: crypto.createHash("sha256").update(JSON.stringify(manifest)).digest("hex")
};
fs.writeFileSync(path.join(out, "build-receipt.json"), JSON.stringify(receipt, null, 2));
console.log(JSON.stringify(receipt, null, 2));
