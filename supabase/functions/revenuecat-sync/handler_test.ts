import { createHandler, type SyncDependencies } from "./handler.ts";
import { entitlement } from "./validation.ts";
const now = Date.parse("2026-09-27T16:00:00Z");
function setup() {
  const calls: string[] = [];
  const deps: SyncDependencies = {
    enabled: true, reviewAllowed: async () => false, now: () => now,
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

function sandboxBody() {
  return { request_date_ms: now, subscriber: {
    entitlements: { [entitlement]: { product_identifier: "Luma_Anesthesia_App_Monthly",
      purchase_date: new Date(now - 60_000).toISOString(),
      expires_date: new Date(now + 60_000).toISOString() } },
    subscriptions: { Luma_Anesthesia_App_Monthly: { store: "app_store",
      is_sandbox: true, expires_date: new Date(now + 60_000).toISOString() } },
  } };
}
Deno.test("sandbox never writes production; ordinary accounts receive no test lease", async () => {
  for (const reviewer of [false,true]) {
    const { deps } = setup();
    deps.reviewAllowed = async () => reviewer;
    deps.subscriber = async () => sandboxBody();
    const writes: boolean[] = [];
    deps.record = async (_,snapshot,sandbox) => { assert(snapshot.active); writes.push(sandbox); };
    assert((await createHandler(deps)(request())).status === 200);
    assert(JSON.stringify(writes) === (reviewer ? "[true]" : "[]"));
  }
});
Deno.test("empty response clears a test lease, never promotes it to production", async () => {
  const { deps } = setup(); deps.reviewAllowed = async () => true;
  const writes: boolean[] = [];
  deps.record = async (_,snapshot,sandbox) => { assert(!snapshot.active); writes.push(sandbox); };
  assert((await createHandler(deps)(request())).status === 200);
  assert(writes.join(",") === "false,true");
});
Deno.test("policy errors fail closed before any RevenueCat reads or writes", async () => {
  const { deps,calls } = setup();
  deps.reviewAllowed = async () => { throw new Error("offline"); };
  assert((await createHandler(deps)(request())).status === 503 && calls.length === 0);
});
Deno.test("expired sandbox clears only its own lease", async () => {
  const { deps } = setup(); deps.reviewAllowed = async () => true;
  const body = sandboxBody();
  body.subscriber.entitlements[entitlement].expires_date = new Date(now - 1).toISOString();
  deps.subscriber = async () => body;
  const writes: boolean[] = [];
  deps.record = async (_,snapshot,sandbox) => { assert(!snapshot.active); writes.push(sandbox); };
  assert((await createHandler(deps)(request())).status === 200);
  assert(writes.join(",") === "true");
});
