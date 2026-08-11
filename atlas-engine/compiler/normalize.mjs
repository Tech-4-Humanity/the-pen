import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import {fileURLToPath} from "node:url";
import * as XLSX from "xlsx";

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),"..");
const input=process.argv[2];
const output=path.resolve(process.argv[3]||path.join(root,"data","normalized-atlas.json"));
const receiptPath=path.resolve(process.argv[4]||path.join(root,"data","normalization-receipt.json"));
if(!input) throw new Error("Usage: npm run normalize -- <workbook.xlsx|csv|json> [output.json] [receipt.json]");

const sourcePath=path.resolve(input);
const sourceBytes=fs.readFileSync(sourcePath);
const sourceHash=crypto.createHash("sha256").update(sourceBytes).digest("hex");
const warnings=[],errors=[];
const key=x=>String(x??"").trim().toLowerCase().replace(/[^a-z0-9]+/g,"_").replace(/^_|_$/g,"");
const text=x=>x==null?"":String(x).trim();
const index=row=>Object.fromEntries(Object.entries(row).map(([k,v])=>[key(k),v]));
const value=(row,...names)=>{const i=index(row);for(const n of names){const v=i[key(n)];if(v!==undefined&&v!=="")return v}return ""};
const list=x=>Array.isArray(x)?x.map(text).filter(Boolean):text(x).split(/\s*(?:\n|;|\|)\s*/).filter(Boolean);
const slug=x=>text(x).toLowerCase().replace(/&/g," and ").replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
const state=x=>text(x||"UNVERIFIED").toUpperCase().replace(/\s+/g,"_");
const topicKey=(themeId,topicId)=>`${text(themeId)}::${text(topicId)}`;
const uniqueBy=(rows,identity)=>[...new Map(rows.filter(Boolean).map(row=>[identity(row),row])).values()];

function sheetsFromSource(){
  if(sourcePath.endsWith(".json")){
    const parsed=JSON.parse(sourceBytes);
    if(Array.isArray(parsed))return{Subtopics:parsed};
    if(parsed.sheets)return parsed.sheets;
    return Object.fromEntries(Object.entries(parsed).filter(([,v])=>Array.isArray(v)));
  }
  if(sourcePath.endsWith(".csv")){
    const workbook=XLSX.read(sourceBytes,{type:"buffer"});
    return{Canonical_Taxonomy:XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]],{defval:"",raw:false})};
  }
  const workbook=XLSX.read(sourceBytes,{type:"buffer",cellDates:true});
  return Object.fromEntries(workbook.SheetNames.map(name=>[name,XLSX.utils.sheet_to_json(workbook.Sheets[name],{defval:"",raw:false})]));
}

const sheets=sheetsFromSource();
const allRows=Object.values(sheets).flat();
const rowsFor=pattern=>Object.entries(sheets).filter(([name])=>pattern.test(key(name))).flatMap(([,rows])=>rows);
const explicitThemeRows=rowsFor(/(^|_)theme(s|_progress|_register)?$/);
const explicitTopicRows=rowsFor(/(^|_)topic(s|_progress|_register)?$/);
const explicitSubtopicRows=rowsFor(/subtopic/);
const taxonomyRows=allRows.filter(row=>text(value(row,"Theme_ID","Theme ID"))&&text(value(row,"Topic_ID","Topic ID"))&&text(value(row,"Subtopic_ID","Subtopic ID")));
const themeRows=explicitThemeRows.length?explicitThemeRows:taxonomyRows;
const topicRows=explicitTopicRows.length?explicitTopicRows:taxonomyRows;
const subtopicRows=explicitSubtopicRows.length?explicitSubtopicRows:taxonomyRows;
const evidenceRows=rowsFor(/evidence|stud(y|ies)|research_recovery/);
const storyRows=rowsFor(/story|stories/);
const candidateRows=rowsFor(/candidate|future.*research|pipeline/);

const themes=uniqueBy(themeRows.map(row=>{
  const id=text(value(row,"Theme_ID","Theme ID"));
  const title=text(value(row,"Theme","Theme_Name","Theme Title","Title"));
  return id?{id,slug:slug(value(row,"Theme_Path","Canonical_Path","Theme_Slug","Slug")||title||id),title:title||id,summary:text(value(row,"Theme_Summary","Summary","Introduction","Opening_Chapter")),status:state(value(row,"Theme_Status","Status","Lifecycle_Stage")),confidence:state(value(row,"Theme_Confidence","Confidence"))}:null;
}),x=>x.id);

const topics=uniqueBy(topicRows.map(row=>{
  const id=text(value(row,"Topic_ID","Topic ID"));
  const theme_id=text(value(row,"Theme_ID","Theme ID"));
  const title=text(value(row,"Topic","Topic_Name","Topic Title","Title"));
  return id&&theme_id?{id,key:topicKey(theme_id,id),theme_id,slug:slug(value(row,"Topic_Path","Canonical_Path","Topic_Slug","Slug")||title||id),title:title||id,summary:text(value(row,"Topic_Summary","Summary","Introduction")),status:state(value(row,"Topic_Status","Status","Lifecycle_Stage"))}:null;
}),x=>x.key);

const subtopics=uniqueBy(subtopicRows.map(row=>{
  const id=text(value(row,"Subtopic_ID","Subtopic ID"));
  const theme_id=text(value(row,"Theme_ID","Theme ID"));
  const topic_id=text(value(row,"Topic_ID","Topic ID"));
  const title=text(value(row,"Subtopic","Subtopic_Name","Subtopic Title","Title"));
  const summary=text(value(row,"Subtopic_Summary","Summary","Definition","Description"));
  return id?{
    id,theme_id,topic_id,topic_key:topicKey(theme_id,topic_id),
    slug:slug(value(row,"Subtopic_Path","Canonical_Path","Subtopic_Slug","Slug")||title||id),
    title:title||id,summary,
    problem:text(value(row,"Problem","Problem_Statement","Research_Problem")),
    why_it_matters:text(value(row,"Why_This_Matters","Why It Matters","Importance")),
    research_questions:list(value(row,"Research_Questions","Research Questions")),
    hypothesis:text(value(row,"Hypotheses","Hypothesis")),
    population:text(value(row,"Population")),
    methods:list(value(row,"Methods","Method")),
    variables:list(value(row,"Variables","Variable")),
    measures:list(value(row,"Measures","Measure")),
    frameworks:list(value(row,"Frameworks","Framework")),
    findings:list(value(row,"Findings","Finding")),
    contradictions:list(value(row,"Contradictions","Contradiction")),
    research_gaps:list(value(row,"Research_Gaps","Research Gaps","Gaps")),
    practical_implications:list(value(row,"Practical_Implications","Practical Implications")),
    commercial_opportunities:list(value(row,"Commercialisation","Commercial_Opportunities","Commercial Opportunities")),
    policy_implications:list(value(row,"Policy_Areas","Policy_Implications","Policy Implications")),
    story_ids:list(value(row,"Story_IDs","Story IDs","Story_ID","Story ID")),
    products:list(value(row,"Products","Product")),
    credential:{id:`T4H-MC-${id}`,level:"SUBTOPIC",learning_hours:4,assessment_required:true,issue_state:"NOT_ISSUED"},
    learning:{executive_brief:summary||text(value(row,"Problem","Problem_Statement")),duration_minutes:240,outcome:text(value(row,"Learning_Outcome","What_the_Learner_Can_Do_Afterward"))},
    status:state(value(row,"Subtopic_Status","Status","Lifecycle_Stage")),
    confidence:state(value(row,"Subtopic_Confidence","Confidence")),
    source_fields:Object.fromEntries(Object.entries(row).filter(([,v])=>text(v)))
  }:null;
}),x=>x.id);

const evidence=evidenceRows.map((row,n)=>{
  const id=text(value(row,"Evidence_ID","Study_ID","Record_ID","ID"))||`EVI-UNRESOLVED-${String(n+1).padStart(4,"0")}`;
  if(id.startsWith("EVI-UNRESOLVED"))warnings.push(`${id}: source row has no evidence/study ID`);
  return{id,subtopic_id:text(value(row,"Subtopic_ID")),slug:slug(value(row,"Canonical_Path","Slug",id)),title:text(value(row,"Study_Name","Title"))||id,hypothesis:text(value(row,"Hypotheses","Hypothesis")),population:text(value(row,"Population")),sample:text(value(row,"Sample","Sample_Size")),country:text(value(row,"Country")),method:text(value(row,"Method","Methods")),variables:list(value(row,"Variables")),findings:text(value(row,"Findings")),effect_size:text(value(row,"Effect_Size")),confidence:state(value(row,"Confidence")),limitations:text(value(row,"Limitations")),implications:text(value(row,"Implications")),novel_contribution:text(value(row,"Novel_Contribution")),source:text(value(row,"Source","References","URLs","DOI")),stance:state(value(row,"Stance","Evidence_Result")),status:state(value(row,"Status","Lifecycle_Stage"))};
});
const stories=storyRows.map((row,n)=>({id:text(value(row,"Story_ID","ID"))||`STO-SLOT-${String(n+1).padStart(3,"0")}`,slug:slug(value(row,"Slug","Title","Story_Title"))||`story-slot-${n+1}`,title:text(value(row,"Story_Title","Title"))||`Story slot ${n+1}`,summary:text(value(row,"Summary")),narrative:text(value(row,"Narrative","Story")),subtopic_ids:list(value(row,"Subtopic_IDs","Subtopic_ID")),source:text(value(row,"Source","Provenance")),status:state(value(row,"Status","Lifecycle_Stage"))}));
const candidates=candidateRows.map((row,n)=>({id:text(value(row,"Candidate_ID","ID"))||`CAN-${String(n+1).padStart(4,"0")}`,slug:slug(value(row,"Slug","Title")),title:text(value(row,"Title","Candidate_Name")),summary:text(value(row,"Summary")),research_questions:list(value(row,"Research_Questions")),dependencies:list(value(row,"Dependencies")),next_gate:text(value(row,"Next_Gate")),status:state(value(row,"Status","Lifecycle_Stage"))}));

for(const [kind,rows,identity] of [
  ["theme",themes,x=>x.id],["topic",topics,x=>x.key],["subtopic",subtopics,x=>x.id],
  ["evidence",evidence,x=>x.id],["story",stories,x=>x.id],["candidate",candidates,x=>x.id]
]){
  const seen=new Set();
  for(const row of rows){const id=identity(row);if(!id)errors.push(`${kind}: missing identity`);else if(seen.has(id))errors.push(`${kind}: duplicate identity ${id}`);seen.add(id)}
}
const themeIds=new Set(themes.map(x=>x.id));
const topicKeys=new Set(topics.map(x=>x.key));
const subtopicIds=new Set(subtopics.map(x=>x.id));
for(const row of topics)if(!themeIds.has(row.theme_id))errors.push(`${row.key}: unresolved theme ${row.theme_id||"(blank)"}`);
for(const row of subtopics){
  if(!themeIds.has(row.theme_id))errors.push(`${row.id}: unresolved theme ${row.theme_id||"(blank)"}`);
  if(!topicKeys.has(row.topic_key))errors.push(`${row.id}: unresolved topic ${row.topic_id||"(blank)"} under ${row.theme_id||"(blank)"}`);
}
for(const row of evidence)if(row.subtopic_id&&!subtopicIds.has(row.subtopic_id))errors.push(`${row.id}: unresolved subtopic ${row.subtopic_id}`);
for(const row of stories)for(const id of row.subtopic_ids)if(!subtopicIds.has(id))errors.push(`${row.id}: unresolved subtopic ${id}`);

const atlas={atlas:{title:"Tech4Humanity Research Atlas",description:"A living evidence compiler for human-centred research intelligence.",identity_rules:{theme:"Theme_ID",topic:"Theme_ID + Topic_ID",subtopic:"Subtopic_ID"}},themes,topics,subtopics,evidence,stories,candidates};
const receipt={
  classification:errors.length?"BLOCKED":warnings.length?"PARTIAL":"REAL",
  normalization_status:errors.length?"FAIL":"PASS",
  source:path.basename(sourcePath),source_sha256:sourceHash,
  identity_rules:atlas.atlas.identity_rules,
  source_mode:taxonomyRows.length?"FLAT_CANONICAL_TAXONOMY":"MULTI_SHEET",
  sheets:Object.fromEntries(Object.entries(sheets).map(([name,rows])=>[name,rows.length])),
  counts:{themes:themes.length,topics:topics.length,subtopics:subtopics.length,evidence:evidence.length,stories:stories.length,candidates:candidates.length},
  warnings,errors,
  output_sha256:crypto.createHash("sha256").update(JSON.stringify(atlas)).digest("hex")
};
fs.mkdirSync(path.dirname(output),{recursive:true});
fs.writeFileSync(output,JSON.stringify(atlas,null,2));
fs.writeFileSync(receiptPath,JSON.stringify(receipt,null,2));
console.log(JSON.stringify(receipt,null,2));
if(errors.length)process.exitCode=2;
