# PEN HANDOFF — Augmented-Humanity GitHub Org Profile

**Date:** 2026-04-30  
**Target:** `https://github.com/Augmented-Humanity`  
**Execution intent:** make the Augmented-Humanity GitHub organisation look like a serious AI product, orchestration, governance and human-centred systems studio.  
**User instruction:** all enhancements yes, no questions, Mac is endpoint only, complete and send via connector.

## Reality Ledger status

**Classification:** PARTIAL → READY FOR EXECUTION

Why PARTIAL: this connector currently has write access to `TML-4PM/the-pen`, but the installed GitHub connector account list only exposes `TML-4PM`; it does not expose the `Augmented-Humanity` organisation as an installed/write-enabled account. The full pack is therefore written to `TML-4PM/the-pen` as an execution-ready handoff. Once the GitHub App is installed on `Augmented-Humanity`, the same files can be pushed directly to `Augmented-Humanity/.github` and sibling repos.

## Connector evidence

- GitHub connector writable account available: `TML-4PM`.
- Target org `Augmented-Humanity` not listed in installed accounts.
- Handoff repository used: `TML-4PM/the-pen`.

## Files included in this handoff path

```text
handoffs/augmented-humanity-github-org-profile/2026-04-30/
  PEN_HANDOFF.md
  github/.github/profile/README.md
  github/.github/profile/assets/augmented-humanity-operating-model.svg
  github/.github/profile/assets/ecosystem-map.svg
  github/repos/ahc-starter-kits/README.md
  github/repos/holoorg-patterns/README.md
  github/repos/workfamilyai-scenarios/README.md
  github/repos/gcbat-frameworks/README.md
  github/repos/augmented-humanity-assets/README.md
  scripts/deploy_augmented_humanity_github.sh
  bridge_payload_augmented_humanity_github.json
```

## Desired live GitHub state

For a GitHub **organisation**, the org profile must live here:

```text
Augmented-Humanity/.github/profile/README.md
Augmented-Humanity/.github/profile/assets/augmented-humanity-operating-model.svg
Augmented-Humanity/.github/profile/assets/ecosystem-map.svg
```

Recommended public repos:

```text
Augmented-Humanity/ahc-starter-kits
Augmented-Humanity/holoorg-patterns
Augmented-Humanity/workfamilyai-scenarios
Augmented-Humanity/gcbat-frameworks
Augmented-Humanity/augmented-humanity-assets
```

## Execution options

### Option A — direct connector execution

Install/enable the GitHub connector on the `Augmented-Humanity` organisation. Then use the included files to create/update the target repos directly.

### Option B — Mac endpoint execution

Run:

```bash
bash scripts/deploy_augmented_humanity_github.sh
```

The script creates/updates the `.github` org profile repo and the recommended public repos, then pushes all README and SVG assets.

## Close condition

This is closed when GitHub returns commit receipts for:

1. `Augmented-Humanity/.github/profile/README.md`
2. `Augmented-Humanity/.github/profile/assets/augmented-humanity-operating-model.svg`
3. `Augmented-Humanity/.github/profile/assets/ecosystem-map.svg`
4. The five repo README files.

## Visual and positioning intent

The GitHub profile must visually communicate:

- **Augmented Humanity** as the parent studio.
- **AHC** as adoption and capability engine.
- **HoloOrg** as organisational/agent architecture.
- **WorkFamilyAI** as human-life, family, care and daily-support surface.
- **GC-BAT** as governance, foresight and high-risk technology control layer.

The page should read as: senior AI product orchestration, not generic dev portfolio.
