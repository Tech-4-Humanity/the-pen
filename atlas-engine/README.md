# Tech4Humanity Atlas Engine

Executable static research-knowledge compiler. Structured objects own content; renderers create projections.

## Build

```bash
npm test
npm run build
```

The build writes an S3-ready site to `dist/` and an auditable receipt to
`dist/build-receipt.json`. The included fixture proves the Theme 1 vertical
slice without presenting seeded material as validated evidence.

## Workbook contract

The canonical workbook remains the editorial ledger. Its normalized export
must supply stable Theme, Topic, Subtopic, Evidence and Story objects. Missing
editorial content is reported as a warning and rendered as visibly incomplete;
it is never fabricated.

The renderer contract lives in `config/pages.json`, the workbook-to-object
contract in `config/field-map.json`, and component failure behaviour in
`components/registry.json`. Executed studies, stories and candidate research
remain distinct object collections and projections.

## Normalize workbook content

```bash
npm run normalize -- workbook.xlsx data/normalized-atlas.json data/normalization-receipt.json
node compiler/build.mjs data/normalized-atlas.json
```

The normalizer accepts `.xlsx`, `.csv` and workbook-shaped `.json`, reads all
matching sheets, preserves supplied identifiers and blocks unresolved or
duplicate relationships. It emits the canonical graph and a source-hashed
normalization receipt before rendering begins.

## Governed host fallback

If GitHub-hosted runners are unavailable, the identical gate can run on a
governed host:

```bash
ATLAS_WORKBOOK=/path/to/workbook.xlsx npm run ci:atlas
```

It emits runtime metadata, test/normalization/build logs, canonical JSON, the
complete static output, `SHA256SUMS` and `final-receipt.json` under
`receipts/<run-id>/`.
