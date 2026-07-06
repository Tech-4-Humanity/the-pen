# package.json

```json
{
  "name": "agora-intelligence-platform",
  "version": "0.1.0",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test",
    "typecheck": "turbo typecheck",
    "validate": "node tools/validate-manifest.mjs"
  },
  "devDependencies": {
    "turbo": "latest",
    "typescript": "latest",
    "eslint": "latest",
    "prettier": "latest"
  },
  "engines": {
    "node": ">=20"
  }
}
```
