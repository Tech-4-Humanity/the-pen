import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";

const root = path.resolve(import.meta.dirname, "..");
test("builds a reproducible Theme 1 vertical slice", () => {
  const result = spawnSync(process.execPath, ["compiler/build.mjs"], {cwd: root, encoding:"utf8"});
  assert.equal(result.status, 0, result.stderr);
  const receipt = JSON.parse(fs.readFileSync(path.join(root, "dist/build-receipt.json")));
  assert.equal(receipt.build_status, "PASS");
  assert.equal(receipt.counts.html_pages, 7);
  assert.equal(receipt.classification, "PARTIAL");
  for (const route of [
    "index.html",
    "themes/human-ai-cognition-performance/index.html",
    "themes/human-ai-cognition-performance/topics/cognitive-augmentation/index.html",
    "themes/human-ai-cognition-performance/topics/cognitive-augmentation/decision-quality/index.html",
    "themes/human-ai-cognition-performance/topics/cognitive-augmentation/decision-quality/evidence/index.html",
    "analytics/index.html",
    "insights/index.html"
  ]) assert.ok(fs.existsSync(path.join(root, "dist", route)), route);
});
