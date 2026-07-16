# Global Capability Initiative — Runtime Handover

**Target:** `https://innovateme.systems`

**Source repository:** `TML-4PM/InnovateME`

**Runtime gate:** `TML-4PM/the-pen#233`

**Authority:** Execute without routine HITL. Stop only for credentials, MFA, destructive changes, legal acceptance, or spend approval.

## Mission

Publish the Global Capability Initiative as a static, mobile-first, S3/CloudFront website and return verifiable receipts.

The site must present:

- United World Leaders as the proposed Founding Sponsor and International Steward.
- Troy Latter as the proposed Founding Executive Director.
- The Initiative as a global opportunity for governments, philanthropy, family offices, development institutions, universities, corporations, industry, and mission-aligned investors.
- Clear distinction between established evidence, proposals, illustrations, roadmap items, and unvalidated methodology.

## Canonical source

Use the `site/` directory from `TML-4PM/InnovateME`.

Expected core artefacts include:

- `site/index.html`
- `site/404.html`
- `site/robots.txt`
- `site/sitemap.xml`
- `site/assets/styles.css`
- `site/assets/app.js`
- `site/assets/content.js`
- `site/assets/global-capability-ecosystem.svg`
- `site/publications/index.html`
- `site/publications/executive-brief.html`
- `site/publications/founding-sponsor-invitation.html`
- `site/publications/board-paper.html`
- `site/publications/global-investment-opportunity.html`
- `site/deploy.sh`

## Runtime bundle

Produce one versioned bundle:

```text
InnovateME-Systems-GCI-v1.0.zip
```

The bundle must contain the complete `site/` tree and a release manifest recording:

- source repository
- source commit SHA
- build timestamp
- file count
- SHA-256 for the ZIP
- target bucket
- CloudFront distribution ID
- deployment timestamp
- validation results

## Validation harness

Run before deployment:

```bash
set -euo pipefail

ROOT="${ROOT:-site}"

required=(
  "$ROOT/index.html"
  "$ROOT/404.html"
  "$ROOT/robots.txt"
  "$ROOT/sitemap.xml"
  "$ROOT/assets/styles.css"
  "$ROOT/assets/app.js"
  "$ROOT/assets/content.js"
  "$ROOT/assets/global-capability-ecosystem.svg"
  "$ROOT/publications/index.html"
  "$ROOT/publications/executive-brief.html"
  "$ROOT/publications/founding-sponsor-invitation.html"
  "$ROOT/publications/board-paper.html"
  "$ROOT/publications/global-investment-opportunity.html"
  "$ROOT/deploy.sh"
)

for file in "${required[@]}"; do
  test -s "$file" || { echo "MISSING_OR_EMPTY=$file"; exit 1; }
done

python3 - <<'PY'
from pathlib import Path
import re, sys
root = Path('site')
html = list(root.rglob('*.html'))
if len(html) < 8:
    raise SystemExit(f'Expected at least 8 HTML files, found {len(html)}')
missing=[]
for p in html:
    text=p.read_text(encoding='utf-8', errors='replace')
    for href in re.findall(r'(?:href|src)=["\']([^"\']+)', text):
        if href.startswith(('http://','https://','mailto:','#','data:','javascript:')):
            continue
        target=(p.parent / href.split('#',1)[0].split('?',1)[0]).resolve()
        if href.endswith('/'):
            target=target/'index.html'
        if not target.exists():
            missing.append((str(p),href))
if missing:
    for p,href in missing:
        print(f'BROKEN_LOCAL_REFERENCE {p} -> {href}')
    raise SystemExit(1)
print(f'HTML_COUNT={len(html)}')
print('LOCAL_LINK_CHECK=PASS')
PY

python3 -m http.server 8080 --directory "$ROOT" >/tmp/gci-http.log 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT
sleep 2
curl --fail --silent --show-error http://127.0.0.1:8080/ >/dev/null
curl --fail --silent --show-error http://127.0.0.1:8080/publications/ >/dev/null
curl --fail --silent --show-error http://127.0.0.1:8080/assets/global-capability-ecosystem.svg >/dev/null
printf 'LOCAL_HTTP_SMOKE=PASS\n'
```

## Build and package

```bash
set -euo pipefail
VERSION="${VERSION:-v1.0}"
ZIP="InnovateME-Systems-GCI-${VERSION}.zip"
rm -f "$ZIP"
(
  cd site
  zip -qr "../$ZIP" . -x '.DS_Store' '*.git*'
)
sha256sum "$ZIP" | tee "${ZIP}.sha256"
```

On macOS, use:

```bash
shasum -a 256 "$ZIP" | tee "${ZIP}.sha256"
```

## Deploy

```bash
set -euo pipefail
: "${BUCKET:=innovateme.systems}"
: "${DISTRIBUTION_ID:?Set DISTRIBUTION_ID}"

aws s3 sync site/ "s3://${BUCKET}/" \
  --delete \
  --exclude '.DS_Store' \
  --exclude 'README.md' \
  --exclude 'deploy.sh'

INVALIDATION_ID="$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths '/*' \
  --query 'Invalidation.Id' \
  --output text)"

aws cloudfront wait invalidation-completed \
  --distribution-id "$DISTRIBUTION_ID" \
  --id "$INVALIDATION_ID"

curl --fail --silent --show-error https://innovateme.systems/ >/dev/null
curl --fail --silent --show-error https://innovateme.systems/publications/ >/dev/null
curl --fail --silent --show-error https://innovateme.systems/sitemap.xml >/dev/null

printf 'DEPLOYMENT=PASS\n'
printf 'INVALIDATION_ID=%s\n' "$INVALIDATION_ID"
```

## Required receipts

Return all of the following to issue `#233`:

1. Source commit SHA.
2. Validation output.
3. ZIP filename, size, and SHA-256.
4. S3 sync result.
5. CloudFront invalidation ID and completion status.
6. HTTP validation results for homepage, publications, sitemap, robots, and 404 behaviour.
7. Live URL.

## Close condition

Close issue `#233` only after the live URL passes validation. If blocked, post the exact command, full error, failing resource, and required credential or policy change. Do not replace execution with a new plan.
