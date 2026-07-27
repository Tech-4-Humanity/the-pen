import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import {fileURLToPath} from "node:url";
import * as XLSX from "xlsx";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const input = process.argv[2];
const output = path.resolve(process.argv[3] || path.join(root, "data", "normalized-atlas.json"));
const receiptPath = path.resolve(process.argv[4] || path.join(root, "data", "normalization-receipt.json"));
if (!input) throw new Error("Usage: npm run normalize -- <workbook.xlsx|csv|json> [output.json] [receipt.json]");

const sourcePath = path.resolve(input);
const sourceBytes = fs.readFileSync(sourcePath);
const sourceHash = crypto.createHash("sha256").update(sourceBytes).digest("hex");
const warnings = [];
const errors = [];

const key = value => String(value || "").trim().toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
const value = (row, ...names) => {
  const indexed = Object.fromEntries(Object.entries(row).map(([k,v]) => [key(k), v]));
  for (const name of names) if (indexed[key(name)] !== undefined && indexed[key(name)] !== "") return indexed[key(name)];
  return "";
};
const text = x => x === null || x === undefined ? "" : String(x).trim();
const list = x => Array.isArray(x) ? x.map(text).filter(Boolean) : text(x).split(/\s*(?:\n|;|\|)\s*/).filter(Boolean);
const slug = x => text(x).toLowerCase().replace(/&/g," and ").replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
const state = x => text(x || "UNVERIFIED").toUpperCase().replace(/\s+/g,"_");

function sheetsFromSource() {
  if (sourcePath.endsWith(".json")) {
    const parsed = JSON.parse(sourceBytes);
    if (Array.isArray(parsed)) return {Subtopics: parsed};
    if (parsed.sheets) return parsed.sheets;
    return Object.fromEntries(Object.entries(parsed).filter(([,v]) => Array.isArray(v)));
  }
  if (sourcePath.endsWith(".csv")) return {Subtopics: XLSX.utils.sheet_to_json(XLSX.read(sourceBytes, {type:"buffer"}).Sheets.Sheet1, {defval:""})};
  const workbook = XLSX.read(sourceBytes, {type:"buffer", cellDates:true});
  return Object.fromEntries(workbook.SheetNames.map(name => [name, XLSX.utils.sheet_to_json(workbook.Sheets[name], {defval:"", raw:false})]));
}

const sheets = sheetsFromSource();
const rowsFor = pattern => Object.entries(sheets).filter(([name]) => pattern.test(key(name))).flatMap(([,rows]) => rows);
const themeRows = rowsFor(/(^|_)theme(s|_progress|_register)?$/);
const topicRows = rowsFor(/(^|_)topic(s|_progress|_register)?$/);
const subtopicRows = rowsFor(/subtopic/);
const evidenceRows = rowsFor(/evidence|stud(y|ies)|research_recovery/);
const storyRows = rowsFor(/story|stories/);
const candidateRows = rowsFor(/candidate|future.*research|pipeline/);

const themes = themeRows.map(row => {
  const id=text(value(row,"Theme_ID","Theme ID"));
  return {id,slug:slug(value(row,"Canonical_Path","Slug","Theme_Name","Theme Title","Title")),title:text(value(row,"Theme_Name","Theme Title","Title")),summary:text(value(row,"Summary","Introduction","Opening_Chapter")),status:state(value(row,"Status","Lifecycle_Stage")),confidence:state(value(row,"Confidence"))};
}).filter(x => x.id);
const topics = topicRows.map(row => {
  const id=text(value(row,"Topic_ID","Topic ID"));
  return {id,theme_id:text(value(row,"Theme_ID","Theme ID")),slug:slug(value(row,"Canonical_Path","Slug","Topic_Name","Topic Title","Title")),title:text(value(row,"Topic_Name","Topic Title","Title")),summary:text(value(row,"Summary","Introduction")),status:state(value(row,"Status","Lifecycle_Stage"))};
}).filter(x => x.id);
const subtopics = subtopicRows.map(row => {
  const id=text(value(row,"Subtopic_ID","Subtopic ID"));
  return {
    id,theme_id:text(value(row,"Theme_ID","Theme ID")),topic_id:text(value(row,"Topic_ID","Topic ID")),
    slug:slug(value(row,"Canonical_Path","Slug","Subtopic_Name","Subtopic Title","Title")),
    title:text(value(row,"Subtopic_Name","Subtopic Title","Title")),
    problem:text(value(row,"Problem","Problem_Statement")),hypothesis:text(value(row,"Hypothesis")),
    population:text(value(row,"Population")),methods:list(value(row,"Methods")),variables:list(value(row,"Variables")),
    measures:list(value(row,"Measures")),frameworks:list(value(row,"Frameworks")),findings:list(value(row,"Findings")),
    contradictions:list(value(row,"Contradictions")),research_gaps:list(value(row,"Research_Gaps","Gaps")),
    practical_implications:list(value(row,"Practical_Implications")),commercial_opportunities:list(value(row,"Commercialisation","Commercial_Opportunities")),
    policy_implications:list(value(row,"Policy_Areas","Policy_Implications")),status:state(value(row,"Status","Lifecycle_Stage")),confidence:state(value(row,"Confidence"))
  };
}).filter(x => x.id);
const evidence = evidenceRows.map((row,index) => {
  const id=text(value(row,"Evidence_ID","Study_ID","Record_ID","ID")) || `EVI-UNRESOLVED-${String(index+1).padStart(4,"0")}`;
  if (id.startsWith("EVI-UNRESOLVED")) warnings.push(`${id}: source row has no evidence/study ID`);
  return {id,subtopic_id:text(value(row,"Subtopic_ID")),slug:slug(value(row,"Canonical_Path","Slug",id)),title:text(value(row,"Study_Name","Title")) || id,hypothesis:text(value(row,"Hypothesis")),population:text(value(row,"Population")),sample:text(value(row,"Sample","Sample_Size")),country:text(value(row,"Country")),method:text(value(row,"Method","Methods")),variables:list(value(row,"Variables")),findings:text(value(row,"Findings")),effect_size:text(value(row,"Effect_Size")),confidence:state(value(row,"Confidence")),limitations:text(value(row,"Limitations")),implications:text(value(row,"Implications")),novel_contribution:text(value(row,"Novel_Contribution")),source:text(value(row,"Source","References","URLs","DOI")),stance:state(value(row,"Stance","Evidence_Result")),status:state(value(row,"Status","Lifecycle_Stage"))};
});
const stories = storyRows.map((row,index) => ({id:text(value(row,"Story_ID","ID")) || `STO-SLOT-${String(index+1).padStart(3,"0")}`,slug:slug(value(row,"Slug","Title","Story_Title")) || `story-slot-${index+1}`,title:text(value(row,"Story_Title","Title")) || `Story slot ${index+1}`,summary:text(value(row,"Summary")),narrative:text(value(row,"Narrative","Story")),subtopic_ids:list(value(row,"Subtopic_IDs","Subtopic_ID")),source:text(value(row,"Source","Provenance")),status:state(value(row,"Status","Lifecycle_Stage"))}));
const candidates = candidateRows.map((row,index) => ({id:text(value(row,"Candidate_ID","ID")) || `CAN-${String(index+1).padStart(4,"0")}`,slug:slug(value(row,"Slug","Title")),title:text(value(row,"Title","Candidate_Name")),summary:text(value(row,"Summary")),research_questions:list(value(row,"Research_Questions")),dependencies:list(value(row,"Dependencies")),next_gate:text(value(row,"Next_Gate")),status:state(value(row,"Status","Lifecycle_Stage"))}));

const ids = new Set();
for (const [kind,rows] of Object.entries({theme:themes,topic:topics,subtopic:subtopics,evidence,story:stories,candidate:candidates})) for (const row of rows) {
  if (ids.has(row.id)) errors.push(`${kind}: duplicate ID ${row.id}`);
  ids.add(row.id);
}
const themeIds = new Set(themes.map(x=>x.id));
const topicIds = new Set(topics.map(x=>x.id));
const subtopicIds = new Set(subtopics.map(x=>x.id));
for (const row of topics) if (!themeIds.has(row.theme_id)) errors.push(`${row.id}: unresolved theme ${row.theme_id || "(blank)"}`);
for (const row of subtopics) {
  if (!themeIds.has(row.theme_id)) errors.push(`${row.id}: unresolved theme ${row.theme_id || "(blank)"}`);
  if (!topicIds.has(row.topic_id)) errors.push(`${row.id}: unresolved topic ${row.topic_id || "(blank)"}`);
}
for (const row of evidence) if (row.subtopic_id && !subtopicIds.has(row.subtopic_id)) errors.push(`${row.id}: unresolved subtopic ${row.subtopic_id}`);
for (const row of stories) for (const id of row.subtopic_ids) if (!subtopicIds.has(id)) errors.push(`${row.id}: unresolved subtopic ${id}`);

const atlas = {atlas:{title:"Tech4Humanity Research Atlas",description:"A living evidence compiler for human-centred research intelligence."},themes,topics,subtopics,evidence,stories,candidates};
const receipt = {
  classification: errors.length ? "BLOCKED" : warnings.length ? "PARTIAL" : "REAL",
  normalization_status: errors.length ? "FAIL" : "PASS",
  source:path.basename(sourcePath),source_sha256:sourceHash,
  sheets:Object.fromEntries(Object.entries(sheets).map(([name,rows])=>[name,rows.length])),
  counts:{themes:themes.length,topics:topics.length,subtopics:subtopics.length,evidence:evidence.length,stories:stories.length,candidates:candidates.length},
  warnings,errors,
  output_sha256:crypto.createHash("sha256").update(JSON.stringify(atlas)).digest("hex")
};
fs.mkdirSync(path.dirname(output),{recursive:true});
fs.writeFileSync(output,JSON.stringify(atlas,null,2));
fs.writeFileSync(receiptPath,JSON.stringify(receipt,null,2));
console.log(JSON.stringify(receipt,null,2));
if (errors.length) process.exitCode=2;
