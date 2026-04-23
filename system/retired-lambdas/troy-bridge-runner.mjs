// troy-bridge-runner — RETIRED STUB
// Original ImportModuleError (missing index.mjs) verified 2026-04-21.
// Wave21 lane teardown 2026-04-24; registry is_callable=false, invocation_count=0.
// Purpose of this stub: replace prior JSON-as-code garbage with a coherent 410 Gone response
// so any accidental caller gets a clear retirement signal and a pointer at the canonical path.

export const handler = async (event) => {
  return {
    statusCode: 410,
    body: JSON.stringify({
      retired: true,
      lambda: "troy-bridge-runner",
      as_of: "2026-04-24",
      reason: "Lambda retired as part of Wave21 teardown. Prior role superseded by troy-sql-executor via the MCP bridge.",
      canonical_path: {
        url: "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke",
        envelope: {
          fn: "troy-sql-executor",
          payload: {
            sql: "SELECT public.fn_github_push(...) AS result;"
          }
        }
      },
      see: "TML-4PM/the-pen — global/ENFORCEMENT_LIVE.md",
      event_echo: event || null
    })
  };
};
