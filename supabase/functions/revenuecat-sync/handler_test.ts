import { createHandler, type SyncDependencies } from "./handler.ts";
const now = Date.parse("2026-09-27T16:00:00Z");
function setup() {
  const calls: string[] = [];
  const deps: SyncDependencies = {
    enabled: true, allowSandbox: false, now: () => now,
    user: async () => "verified-user",
    subscriber: async (id) => {
      calls.push(`read:${id}`);
      return { request_date_ms: now, subscriber: { entitlements: {}, subscriptions: {} } };
    },
    record: async (id) => { calls.push(`write:${id}`); },
    access: async () => false,
  };
  return { deps, calls };
}
function request(body = "{}") {
  return new Request("https://example.test", {
    method: "POST", headers: { Authorization: "Bearer test-token" }, body,
  });
}
function assert(value: unknown) { if (!value) throw new Error("Assertion failed"); }
Deno.test("disabled endpoint never reads identity or provider", async () => {
  const { deps, calls } = setup(); deps.enabled = false;
  assert((await createHandler(deps)(request())).status === 503);
  assert(calls.length === 0);
});
Deno.test("anonymous and missing authorization rejected", async () => {
  const { deps, calls } = setup();
  assert((await createHandler(deps)(new Request("https://example.test", { method: "POST" }))).status === 401);
  deps.user = async () => null;
  assert((await createHandler(deps)(request())).status === 401);
  assert(calls.length === 0);
});
Deno.test("client cannot select another identity or grant access", async () => {
  const { deps, calls } = setup();
  const response = await createHandler(deps)(request('{"user_id":"victim","active":true}'));
  const body = await response.json();
  assert(response.status === 200 && body.active === false && body.user_id === "verified-user");
  assert(calls.join(",") === "read:verified-user,write:verified-user");
});
Deno.test("provider failure never writes entitlement", async () => {
  const { deps, calls } = setup();
  deps.subscriber = async () => { throw new Error("offline"); };
  assert((await createHandler(deps)(request())).status === 503);
  assert(calls.length === 0);
});
Deno.test("write failures are not reported as verified", async () => {
  const { deps } = setup();
  deps.record = async () => { throw new Error("offline"); };
  assert((await createHandler(deps)(request())).status === 503);
});
Deno.test("independent owner or CE access remains effective", async () => {
  const { deps } = setup(); deps.access = async () => true;
  assert((await (await createHandler(deps)(request())).json()).active === true);
});
Deno.test("method guard and preflight", async () => {
  const { deps, calls } = setup();
  assert((await createHandler(deps)(new Request("https://example.test"))).status === 405);
  assert((await createHandler(deps)(new Request("https://example.test", { method: "OPTIONS" }))).status === 200);
  assert(calls.length === 0);
});
