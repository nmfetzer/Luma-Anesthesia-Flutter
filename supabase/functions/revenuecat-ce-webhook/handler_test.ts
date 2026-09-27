import { type Dependencies, handle } from "./handler.ts";
import { assert, fixture } from "./fixtures_test.ts";
const secret = "test-only-not-a-real-secret-0123456789";
function request(body: unknown = fixture(), auth = `Bearer ${secret}`) {
  return new Request("https://example.invalid/webhook", {
    method: "POST",
    headers: { Authorization: auth },
    body: JSON.stringify(body),
  });
}
function setup() {
  const calls: Record<string, unknown>[] = [];
  const deps: Dependencies = {
    config: { enabled: true, secret, appId: "apple-app" },
    record: async (args) => {
      calls.push(args);
      return { error: null };
    },
  };
  return { calls, deps };
}
Deno.test("writes only normalized authenticated server fields", async () => {
  const { deps, calls } = setup();
  const response = await handle(request(), deps);
  assert(response.status === 200 && calls.length === 1);
  assert(
    calls[0].p_product_id === "Medication_Review_for_the_Experienced_CRNA",
  );
  assert(Object.keys(calls[0]).length === 8);
});
Deno.test("disabled configuration cannot write", async () => {
  const { deps, calls } = setup();
  deps.config.enabled = false;
  assert((await handle(request(), deps)).status === 503 && calls.length === 0);
});
Deno.test("missing secret cannot write", async () => {
  const { deps, calls } = setup();
  deps.config.secret = "";
  assert((await handle(request(), deps)).status === 503 && calls.length === 0);
});
Deno.test("forged authorization cannot write", async () => {
  const { deps, calls } = setup();
  assert(
    (await handle(request(fixture(), "Bearer wrong"), deps)).status === 401 &&
      calls.length === 0,
  );
});
Deno.test("sandbox and subscriptions cannot write", async () => {
  const { deps, calls } = setup();
  for (
    const overrides of [{ environment: "SANDBOX" }, {
      product_id: "Luma_Anesthesia_App_Monthly",
    }]
  ) {
    assert((await handle(request(fixture(overrides)), deps)).status === 200);
  }
  assert(calls.length === 0);
});
Deno.test("database errors are retried not acknowledged", async () => {
  const { deps } = setup();
  deps.record = async () => ({ error: new Error("fixture failure") });
  assert((await handle(request(), deps)).status === 503);
});
Deno.test("manual review is visible as failed delivery", async () => {
  const { deps, calls } = setup();
  assert(
    (await handle(request(fixture({ type: "TRANSFER" })), deps)).status === 422,
  );
  assert(calls.length === 0);
});
Deno.test("oversized and invalid body cannot write", async () => {
  const { deps, calls } = setup();
  assert(
    (await handle(request({ padding: "x".repeat(70000) }), deps)).status ===
      413,
  );
  assert((await handle(request({}), deps)).status === 400);
  assert(calls.length === 0);
});
Deno.test("GET not accepted", async () => {
  const { deps, calls } = setup();
  assert(
    (await handle(new Request("https://example.invalid/"), deps)).status ===
      405,
  );
  assert(calls.length === 0);
});
