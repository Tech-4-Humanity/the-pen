# CDAP P0 Binary Artefacts Manifest

Status: PARTIAL for native XLSX commit via connector; REAL for local generation and hash verification.

Native XLSX artefacts generated in chat runtime:

| Artefact | Local file | SHA256 |
|---|---|---|
| Expanded CDAP master workbook | `/mnt/data/CDAP_Master_Workbook_Full_Implementation_v2.xlsx` | `d88cba4e6ec490c4e2ffff147381324d5adfb193eef3a35a15078b5466c04ac5` |
| Regulatory obligation mapping workbook | `/mnt/data/regulatory_obligation_mapping.xlsx` | `cb540569931c75d62dd1c2827badb29c68eb2786a3795277a7d4d35603452597` |
| Generated artefact inventory workbook | `/mnt/data/generated_artefact_inventory.xlsx` | `31a24754e1d652cef17268fefe9d04b50418bcd9d2bc9d13db5c04a4d10f3185` |

Text artefacts generated in chat runtime:

| Artefact | Local file | SHA256 |
|---|---|---|
| Training assignment rules | `/mnt/data/training_assignment_rules.json` | `2b433b0aba4a551e16e7d8b4d535caeb243b58af1a85f8ed403dac7f18292c31` |
| CDAP schema v2 | `/mnt/data/cdap_schema_v2.json` | `06e0fb0cd48028439a63ce42d29b897e5ac7de2d0cbcafe1f0be8a78d1f5a272` |

Connector limitation:

- Native `.xlsx` byte upload is not available through the current UTF-8 `create_file` connector path.
- CSV equivalents and source/manifest artefacts have been committed.
- Binary XLSX files require a binary-capable route or bridge/CLI commit.
