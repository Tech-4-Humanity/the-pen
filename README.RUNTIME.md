# T4H Runtime Bootstrap

This repository now exposes the required five-command deployment surface:

```bash
git pull
npm ci
npm run doctor
npm run bringup
npm run runtime:auto-advance
```

A caller may also execute `BOOTSTRAP.command` from any directory. It locates an existing `TML-4PM/the-pen` checkout or clones it to `~/projects/TML-4PM/the-pen`, enters the repository, refuses to overwrite uncommitted work, fast-forwards the configured branch and executes the five stages.

## Environment overrides

- `T4H_REPO_DIR`: known local checkout
- `T4H_INSTALL_ROOT`: clone parent directory
- `T4H_BRANCH`: branch to run; defaults to `main`
- `T4H_DEPLOY_SOURCE`: local directory to publish
- `T4H_TARGET_BUCKET`: selected S3 bucket
- `T4H_TARGET_PREFIX`: selected S3 prefix
- `T4H_WEBSITE_BUCKET`: marks public website mode
- `T4H_CLOUDFRONT_DISTRIBUTION`: distribution to invalidate
- `T4H_LIVE_URL`: endpoint to verify
- `T4H_SYNC_DELETE=1`: permit removal of obsolete target objects

## Classifications

- `REAL`: execution, upload, independent S3 readback, SHA-256 equality and any required endpoint check succeeded.
- `PARTIAL`: useful execution occurred but at least one acceptance gate remains absent.
- `BLOCKED`: dependency, authority or safety control prevented execution.

Receipts are emitted under `.runtime/receipts/` and are not intended for raw private transaction data.
