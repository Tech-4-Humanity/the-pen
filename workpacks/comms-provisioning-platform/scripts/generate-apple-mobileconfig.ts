#!/usr/bin/env ts-node

/**
 * Generate macOS/iOS Mail .mobileconfig from canonical Migadu inventory.
 *
 * This profile does not embed passwords. macOS/iOS will prompt on install or first use.
 */

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { randomUUID } from "node:crypto";

const OUTPUT_DIR = process.env.OUTPUT_DIR || "dist/comms-provisioning-platform";
const INVENTORY_PATH = process.env.INVENTORY_PATH || join(OUTPUT_DIR, "canonical-inventory.json");
const IMAP_HOST = process.env.IMAP_HOST || "imap.migadu.com";
const SMTP_HOST = process.env.SMTP_HOST || "smtp.migadu.com";

function escXml(input: unknown): string {
  return String(input ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function payloadForMailbox(m: any, device: "macos" | "ios"): string {
  const uuid = randomUUID().toUpperCase();
  const description = `${m.display_name || m.address} (${m.address})`;
  const accountName = m.display_name || m.address;
  return `
  <dict>
    <key>PayloadType</key><string>com.apple.mail.managed</string>
    <key>PayloadVersion</key><integer>1</integer>
    <key>PayloadIdentifier</key><string>com.tech4humanity.mail.${escXml(device)}.${escXml(m.address)}</string>
    <key>PayloadUUID</key><string>${uuid}</string>
    <key>PayloadDisplayName</key><string>${escXml(description)}</string>
    <key>EmailAccountDescription</key><string>${escXml(description)}</string>
    <key>EmailAccountName</key><string>${escXml(accountName)}</string>
    <key>EmailAccountType</key><string>EmailTypeIMAP</string>
    <key>EmailAddress</key><string>${escXml(m.address)}</string>
    <key>IncomingMailServerAuthentication</key><string>EmailAuthPassword</string>
    <key>IncomingMailServerHostName</key><string>${escXml(IMAP_HOST)}</string>
    <key>IncomingMailServerPortNumber</key><integer>993</integer>
    <key>IncomingMailServerUseSSL</key><true/>
    <key>IncomingMailServerUsername</key><string>${escXml(m.address)}</string>
    <key>OutgoingMailServerAuthentication</key><string>EmailAuthPassword</string>
    <key>OutgoingMailServerHostName</key><string>${escXml(SMTP_HOST)}</string>
    <key>OutgoingMailServerPortNumber</key><integer>465</integer>
    <key>OutgoingMailServerUseSSL</key><true/>
    <key>OutgoingMailServerUsername</key><string>${escXml(m.address)}</string>
    <key>OutgoingPasswordSameAsIncomingPassword</key><true/>
  </dict>`;
}

function buildProfile(inventory: any, device: "macos" | "ios"): string {
  const mailboxes = (inventory.mailboxes || []).filter((m: any) => m.address && m.status !== "disabled");
  const payloads = mailboxes.map((m: any) => payloadForMailbox(m, device)).join("\n");
  const profileUuid = randomUUID().toUpperCase();
  const profileName = device === "macos" ? "T4H Migadu Apple Mail Accounts" : "T4H Migadu iOS Mail Accounts";

  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>${payloads}
  </array>
  <key>PayloadDisplayName</key><string>${escXml(profileName)}</string>
  <key>PayloadIdentifier</key><string>com.tech4humanity.comms.${device}</string>
  <key>PayloadOrganization</key><string>${escXml(inventory.organisation || "Tech4Humanity")}</string>
  <key>PayloadRemovalDisallowed</key><false/>
  <key>PayloadType</key><string>Configuration</string>
  <key>PayloadUUID</key><string>${profileUuid}</string>
  <key>PayloadVersion</key><integer>1</integer>
</dict>
</plist>`;
}

function main() {
  mkdirSync(OUTPUT_DIR, { recursive: true });
  const inventory = JSON.parse(readFileSync(INVENTORY_PATH, "utf8"));
  const mailboxes = inventory.mailboxes || [];

  if (!mailboxes.length) {
    console.error("BLOCKED: no mailboxes found in canonical inventory.");
    process.exit(2);
  }

  writeFileSync(join(OUTPUT_DIR, "apple-mail.mobileconfig"), buildProfile(inventory, "macos"));
  writeFileSync(join(OUTPUT_DIR, "ios-mail.mobileconfig"), buildProfile(inventory, "ios"));

  const receipt = {
    status: "PARTIAL",
    generated_at: new Date().toISOString(),
    input: INVENTORY_PATH,
    generated_profiles: ["apple-mail.mobileconfig", "ios-mail.mobileconfig"],
    mailbox_accounts_included: mailboxes.filter((m: any) => m.address && m.status !== "disabled").length,
    note: "Profiles generated without embedded passwords. Installation and credential verification must occur on Mac/iOS endpoint before marking REAL.",
  };

  writeFileSync(join(OUTPUT_DIR, "mobileconfig-receipt.json"), JSON.stringify(receipt, null, 2));
  console.log(JSON.stringify(receipt, null, 2));
}

main();
