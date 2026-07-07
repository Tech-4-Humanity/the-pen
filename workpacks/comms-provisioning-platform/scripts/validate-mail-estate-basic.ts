#!/usr/bin/env ts-node

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const OUTPUT_DIR = process.env.OUTPUT_DIR || "dist/comms-provisioning-platform";
const INVENTORY_PATH = process.env.INVENTORY_PATH || join(OUTPUT_DIR, "canonical-inventory.json");

function main() {
  mkdirSync(OUTPUT_DIR, { recursive: true });
  const inventory = JSON.parse(readFileSync(INVENTORY_PATH, "utf8"));
  const domains = inventory.domains || [];
  const mailboxes = inventory.mailboxes || [];
  const aliases = inventory.aliases || [];
  const forwarders = inventory.forwarders || [];

  const warnings: string[] = [...(inventory.validation?.warnings || [])];
  const errors: string[] = [...(inventory.validation?.errors || [])];
  const domainSet = new Set(domains.map((d: any) => d.domain));
  const mailboxSet = new Set(mailboxes.map((m: any) => m.address));

  for (const d of domains) {
    if (!d.domain) errors.push("Domain record missing domain value.");
    for (const dest of d.catchall_destinations || []) {
      if (!mailboxSet.has(dest)) warnings.push(`Catchall target not discovered as mailbox: ${dest}`);
    }
  }

  for (const m of mailboxes) {
    if (!m.address) errors.push("Mailbox record missing address.");
    if (!domainSet.has(m.domain)) warnings.push(`Mailbox references undiscovered domain: ${m.address}`);
    if (m.may_access_imap === false) warnings.push(`IMAP disabled or unavailable: ${m.address}`);
    if (m.may_send === false) warnings.push(`Sending disabled or unavailable: ${m.address}`);
  }

  for (const f of forwarders) {
    if (f.mailbox && !mailboxSet.has(f.mailbox)) warnings.push(`Forwarder source not discovered as mailbox: ${f.mailbox}`);
  }

  const status = errors.length ? "BLOCKED" : warnings.length ? "PARTIAL" : "REAL";
  const generatedAt = new Date().toISOString();
  const report = {
    status,
    generated_at: generatedAt,
    counts: {
      domains: domains.length,
      mailboxes: mailboxes.length,
      aliases: aliases.length,
      forwarders: forwarders.length,
      warnings: warnings.length,
      errors: errors.length
    },
    warnings,
    errors
  };

  const html = [
    "<!doctype html>",
    "<html><head><meta charset='utf-8'><title>Mail Estate Validation</title></head><body>",
    `<h1>Mail Estate Validation</h1>`,
    `<p>Status: ${status}</p>`,
    `<p>Generated: ${generatedAt}</p>`,
    `<p>Domains: ${domains.length}</p>`,
    `<p>Mailboxes: ${mailboxes.length}</p>`,
    `<p>Aliases: ${aliases.length}</p>`,
    `<p>Forwarders: ${forwarders.length}</p>`,
    `<h2>Warnings</h2><pre>${warnings.join("\n") || "None"}</pre>`,
    `<h2>Errors</h2><pre>${errors.join("\n") || "None"}</pre>`,
    "</body></html>"
  ].join("\n");

  writeFileSync(join(OUTPUT_DIR, "validation-report.json"), JSON.stringify(report, null, 2));
  writeFileSync(join(OUTPUT_DIR, "validation-report.html"), html);
  writeFileSync(join(OUTPUT_DIR, "inventory.html"), html);
  console.log(JSON.stringify(report, null, 2));
}

main();
