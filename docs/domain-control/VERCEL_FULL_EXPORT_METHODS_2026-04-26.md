# Vercel Full Export Methods — Domain Control

## Decision
Do not rely on the ChatGPT Vercel connector `list_projects` for full inventory. It returns a capped 50-project list in this session. Use raw Vercel API or CLI for authoritative project export.

## Confirmed team
- Name: troy's projects
- Slug: troys-projects-t4h-machine
- Team ID: team_IKIr2Kcs38KGo8Zs60yNtm7Y

## Recommended method: Vercel REST API

Endpoint:

```http
GET https://api.vercel.com/v9/projects?teamId=team_IKIr2Kcs38KGo8Zs60yNtm7Y&limit=100
Authorization: Bearer $VERCEL_TOKEN
```

Pagination:
- Use `pagination.next` / cursor/timestamp field returned by Vercel API.
- Existing prior project note says local `vercel-sync.js` used:

```http
/v9/projects?teamId=<teamId>&limit=100&since=<next>
```

Loop until there is no next cursor/timestamp.

## CLI fallback

```bash
npm i -g vercel
vercel login
vercel project ls --scope troys-projects-t4h-machine > vercel_projects.txt
```

If JSON output is unavailable, save text and parse into canonical register.

## Domain export

Use project detail and/or Vercel domains endpoint:

```http
GET https://api.vercel.com/v6/domains?teamId=team_IKIr2Kcs38KGo8Zs60yNtm7Y
GET https://api.vercel.com/v9/projects/{idOrName}/domains?teamId=team_IKIr2Kcs38KGo8Zs60yNtm7Y
```

## Fields to capture

| Field | Notes |
|---|---|
| project_id | Vercel project ID |
| project_name | Vercel project slug/name |
| account_id | team/account |
| created_at | timestamp |
| updated_at | if available |
| framework | if available |
| git_repository | repo linkage if available |
| latest_deployment_url | current deployment |
| aliases/domains | production/custom domains |
| env_keys | names only; never export secret values |

## Safety
- Read-only export only.
- Do not delete projects.
- Do not expose environment variable values.
- Store only env key names and evidence refs.

## Use in domain control
- Match Route53 domains to Vercel project domains and aliases.
- Flag domain exists in Route53 but not Vercel = orphan/maybe external.
- Flag Vercel project without custom domain = unbound/prototype.
- Flag multiple Vercel projects claiming same domain = conflict.
