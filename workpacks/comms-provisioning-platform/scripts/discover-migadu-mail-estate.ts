#!/usr/bin/env ts-node

/**
 * Discover Migadu mail estate.
 *
 * Runtime-only credentials:
 *   MIGADU_USER
 *   MIGADU_TOKEN
 *
 * This script intentionally does not mutate Migadu.
 */

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const MIGADU_USER = process.env.MIGADU_USER;
const MIGADU_TOKEN = process.env.MIGADU_TOKEN;
const OUTPUT_DIR = process.env.OUTPUT_DIR || "dist/comms-provisioning-platform";
const ORG_NAME = process.env.COMMS_ORG_NAME || "Tech4Humanity";

if (!MIGADU_USER || !MIGADU_TOKEN) {
  console.error("BLOCKED: MIGADU_USER and MIGADU_TOKEN are required in runtime environment.");
  process.exit(2);
}

const auth = Buffer.from(`${MIGADU_USER}:${MIGADU_TOKEN}`).toString("base64");

async function migadu(path: string): Promise<any> {
  const res = await fetch(`https://api.migadu.com/v1${path}`, {
    headers: {
      Authorization: `Basic ${auth}`,
      Accept: "application/json",
    },
  });

  const text = await res.text();
  let body: any;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = { raw: text };
  }

  if (!res.ok) {
    throw new Error(`Migadu API ${res.status} ${res.statusText} on ${path}: ${text}`);
  }

  return body;
}

function asArray(payload: any): any[] {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.domains)) return payload.domains;
  if (Array.isArray(payload?.mailboxes)) return payload.mailboxes;
  if (Array.isArray(payload?.aliases)) return payload.aliases;
  if (Array.isArray(payload?.items)) return payload.items;
  return [];
}

function csvEscape(v: unknown): string {
  const s = String(v ?? "");
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

async function main() {
  mkdirSync(OUTPUT_DIR, { recursive: true });

  const generatedAt = new Date().toISOString();
  const warnings: string[] = [];
  const errors: string[] = [];

  const domainPayload = await migadu("/domains");
  const rawDomains = asArray(domainPayload);

  const domains: any[] = [];
  const mailboxes: any[] = [];
  const aliases: any[] = [];
  const forwarders: any[] = [];

  for (const rawDomain of rawDomains) {
    const domain = rawDomain.domain || rawDomain.name || rawDomain.id;
    if (!domain) {
      warnings.push(`Skipped domain record without domain/name/id: ${JSON.stringify(rawDomain)}`);
      continue;
    }

    let domainDetail = rawDomain;
    try {
      domainDetail = await migadu(`/domains/${encodeURIComponent(domain)}`);
    } catch (err: any) {
      warnings.push(`Could not fetch domain detail for ${domain}: ${err.message}`);
    }

    const catchallDestinations = domainDetail.catchall_destinations || rawDomain.catchall_destinations || [];

    domains.push({
      domain,
      source: "migadu",
      status: domainDetail.is_active === false ? "disabled" : "discovered",
      catchall_destinations: catchallDestinations,
      evidence: { provider_record: domainDetail },
      warnings: [],
    });

    try {
      const mailboxPayload = await migadu(`/domains/${encodeURIComponent(domain)}/mailboxes`);
      for (const mb of asArray(mailboxPayload)) {
        const localPart = mb.local_part || mb.name || mb.address?.split("@")[0];
        const address = mb.address || (localPart ? `${localPart}@${domain}` : null);
        if (!address || !localPart) {
          warnings.push(`Skipped mailbox record without address/local_part in ${domain}: ${JSON.stringify(mb)}`);
          continue;
        }
        const forwardingTo = mb.forwarding_to
          ? Array.isArray(mb.forwarding_to) ? mb.forwarding_to : [mb.forwarding_to]
          : Array.isArray(mb.forwardings) ? mb.forwardings.map((f: any) => f.address || f.forwarding_to).filter(Boolean) : [];

        if (forwardingTo.length) {
          forwarders.push({ source: "migadu", domain, mailbox: address, forwarding_to: forwardingTo, evidence: mb });
        }

        mailboxes.push({
          address,
          domain,
          local_part: localPart,
          display_name: mb.name || mb.display_name || address,
          mailbox_type: forwardingTo.length ? "forwarder" : "unknown",
          source: "migadu",
          status: mb.is_active === false ? "disabled" : "discovered",
          may_access_imap: mb.may_access_imap ?? mb.may_access_pop3 ?? null,
          may_access_pop3: mb.may_access_pop3 ?? null,
          may_send: mb.may_send ?? null,
          forwarding_to: forwardingTo,
          forwarding_confirmed_at: Array.isArray(mb.forwardings) ? (mb.forwardings[0]?.confirmed_at || null) : (mb.confirmed_at || null),
          aliases: [],
          quota: mb.quota || mb.storage_limit || null,
          owner: null,
          lifecycle: "active-or-unknown",
          evidence: { provider_record: mb },
          warnings: [],
        });
      }
    } catch (err: any) {
      warnings.push(`Could not fetch mailboxes for ${domain}: ${err.message}`);
    }

    try {
      const aliasPayload = await migadu(`/domains/${encodeURIComponent(domain)}/aliases`);
      for (const al of asArray(aliasPayload)) {
        aliases.push({ source: "migadu", domain, evidence: al, ...al });
      }
    } catch (err: any) {
      warnings.push(`Could not fetch aliases for ${domain}: ${err.message}`);
    }
  }

  const inventory = {
    generated_at: generatedAt,
    provider: "migadu",
    organisation: ORG_NAME,
    domains,
    mailboxes,
    aliases,
    forwarders,
    validation: {
      status: errors.length ? "BLOCKED" : warnings.length ? "PARTIAL" : "REAL",
      warnings,
      errors,
    },
  };

  writeFileSync(join(OUTPUT_DIR, "domains.json"), JSON.stringify(domains, null, 2));
  writeFileSync(join(OUTPUT_DIR, "mailboxes.json"), JSON.stringify(mailboxes, null, 2));
  writeFileSync(join(OUTPUT_DIR, "aliases.json"), JSON.stringify(aliases, null, 2));
  writeFileSync(join(OUTPUT_DIR, "forwarders.json"), JSON.stringify(forwarders, null, 2));
  writeFileSync(join(OUTPUT_DIR, "canonical-inventory.json"), JSON.stringify(inventory, null, 2));

  const csvHeader = ["address", "domain", "local_part", "display_name", "mailbox_type", "status", "forwarding_to", "forwarding_confirmed_at"];
  const csvRows = mailboxes.map((m) => csvHeader.map((k) => csvEscape(Array.isArray(m[k]) ? m[k].join(";") : m[k])).join(","));
  writeFileSync(join(OUTPUT_DIR, "mailboxes.csv"), [csvHeader.join(","), ...csvRows].join("\n"));

  const receipt = {
    status: inventory.validation.status,
    generated_at: generatedAt,
    provider: "migadu",
    counts: {
      domains: domains.length,
      mailboxes: mailboxes.length,
      aliases: aliases.length,
      forwarders: forwarders.length,
      warnings: warnings.length,
      errors: errors.length,
    },
    artefacts: [
      "domains.json",
      "mailboxes.json",
      "aliases.json",
      "forwarders.json",
      "canonical-inventory.json",
      "mailboxes.csv",
    ],
    warnings,
    errors,
  };

  writeFileSync(join(OUTPUT_DIR, "receipt.json"), JSON.stringify(receipt, null, 2));
  console.log(JSON.stringify(receipt, null, 2));
}

main().catch((err) => {
  console.error(`BLOCKED: ${err.message}`);
  process.exit(1);
});
