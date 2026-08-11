import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";

const root=path.resolve(import.meta.dirname,"..");
test("normalizes workbook-shaped data and preserves exact relationships",()=>{
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),"atlas-normalize-"));
  const output=path.join(dir,"atlas.json");
  const receipt=path.join(dir,"receipt.json");
  const run=spawnSync(process.execPath,["compiler/normalize.mjs","tests/fixtures/workbook-export.json",output,receipt],{cwd:root,encoding:"utf8"});
  assert.equal(run.status,0,run.stderr);
  const graph=JSON.parse(fs.readFileSync(output));
  const proof=JSON.parse(fs.readFileSync(receipt));
  assert.deepEqual(proof.counts,{themes:1,topics:1,subtopics:1,evidence:0,stories:0,candidates:0});
  assert.equal(proof.normalization_status,"PASS");
  assert.deepEqual(proof.errors,[]);
  assert.equal(graph.subtopics[0].theme_id,"THE-01");
  assert.equal(graph.subtopics[0].topic_id,"TOP-001");
});

test("blocks unresolved relationship drift",()=>{
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),"atlas-normalize-bad-"));
  const source=path.join(dir,"bad.json");
  fs.writeFileSync(source,JSON.stringify({sheets:{Themes:[{Theme_ID:"THE-01",Theme_Name:"One"}],Topics:[],Subtopics:[{Theme_ID:"THE-01",Topic_ID:"TOP-999",Subtopic_ID:"SUB-0001",Subtopic_Name:"Broken"}]}}));
  const receipt=path.join(dir,"receipt.json");
  const run=spawnSync(process.execPath,["compiler/normalize.mjs",source,path.join(dir,"out.json"),receipt],{cwd:root,encoding:"utf8"});
  assert.equal(run.status,2);
  const proof=JSON.parse(fs.readFileSync(receipt));
  assert.equal(proof.classification,"BLOCKED");
  assert.match(proof.errors.join("\n"),/unresolved topic TOP-999/);
});


test("derives hierarchy from flat canonical CSV and scopes repeated Topic IDs by Theme",()=>{
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),"atlas-normalize-flat-"));
  const output=path.join(dir,"atlas.json");
  const receipt=path.join(dir,"receipt.json");
  const run=spawnSync(process.execPath,["compiler/normalize.mjs","tests/fixtures/flat-taxonomy.csv",output,receipt],{cwd:root,encoding:"utf8"});
  assert.equal(run.status,0,run.stderr);
  const graph=JSON.parse(fs.readFileSync(output));
  const proof=JSON.parse(fs.readFileSync(receipt));
  assert.deepEqual(proof.counts,{themes:2,topics:2,subtopics:2,evidence:0,stories:0,candidates:0});
  assert.equal(proof.source_mode,"FLAT_CANONICAL_TAXONOMY");
  assert.equal(proof.identity_rules.topic,"Theme_ID + Topic_ID");
  assert.deepEqual(graph.topics.map(x=>x.key),["THE-01::TOP-01","THE-02::TOP-01"]);
  assert.equal(graph.subtopics[0].title,"Learning Foundations");
  assert.equal(graph.subtopics[0].hypothesis,"Practice improves recall");
  assert.deepEqual(graph.subtopics[0].frameworks,["Learning science"]);
  assert.equal(graph.subtopics[0].credential.learning_hours,4);
});
