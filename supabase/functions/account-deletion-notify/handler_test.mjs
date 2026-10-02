import test from "node:test";
import assert from "node:assert/strict";
import { createHandler, sendMail } from "./handler.mjs";

const job = {
  id: "job-1", lease_token: "lease", recipient: "learner@example.test",
  subject: "Request received", body: "A saved request, not completed deletion.",
};
function fixture(overrides = {}) {
  const calls = { claim: 0, sent: [], finished: [], healthy: 0 };
  const handler = createHandler({
    authorize: async key => key === "server-key", configured: true,
    claim: async () => { calls.claim++; return [job]; },
    send: async j => { calls.sent.push(j); return "provider-id"; },
    finish: async (...args) => { calls.finished.push(args); return true; },
    healthy: async () => { calls.healthy++; },
    ...overrides,
  });
  return { handler, calls };
}
function request(key = "server-key", body = "{}") {
  return new Request("https://example.test/worker", {
    method: "POST", headers: { "x-deletion-worker-token": key }, body,
  });
}
test("unauthorized caller cannot read the queue or send email", async () => {
  const { handler, calls } = fixture();
  assert.equal((await handler(request("user-jwt"))).status, 401);
  assert.equal(calls.claim, 0);
});
test("missing configuration fails closed", async () => {
  const { handler, calls } = fixture({ configured: false });
  assert.equal((await handler(request())).status, 503);
  assert.equal(calls.claim, 0);
});
test("authorization storage failure cannot dispatch", async () => {
  const { handler, calls } = fixture({ authorize: async () => { throw Error("db"); } });
  assert.equal((await handler(request())).status, 503);
  assert.equal(calls.claim, 0);
});
test("caller payload cannot redirect mail or delete an account", async () => {
  const { handler, calls } = fixture();
  const res = await handler(request("server-key", '{"to":"attacker@test","action":"delete"}'));
  assert.equal(res.status, 200);
  assert.equal(calls.sent[0].recipient, job.recipient);
  assert.equal(calls.healthy, 1);
});
test("provider failure is stored, not announced as delivery or deletion", async () => {
  const { handler, calls } = fixture({ send: async () => { throw Error("PII"); } });
  const res = await handler(request());
  assert.equal(res.status, 503);
  assert.equal(calls.finished[0][1], null);
  assert.equal(calls.finished[0][2], "provider_send_failed");
  assert.equal(calls.healthy, 0);
  assert.equal((await res.text()).includes("PII"), false);
});
test("lease mismatch does not record a successful run", async () => {
  const { handler, calls } = fixture({ finish: async () => false });
  assert.equal((await handler(request())).status, 503);
  assert.equal(calls.healthy, 0);
});
test("database error fails closed without leaking raw error", async () => {
  const { handler } = fixture({ claim: async () => { throw Error("secret"); } });
  const res = await handler(request());
  assert.equal(res.status, 503);
  assert.deepEqual(await res.json(), { error: "queue_unavailable" });
});
test("Resend uses frozen body and stable idempotency key", async () => {
  let observed;
  const fetcher = async (url, options) => {
    observed = { url, options };
    return Response.json({ id: "accepted-not-delivered" });
  };
  assert.equal(await sendMail(job, "test-only", fetcher), "accepted-not-delivered");
  assert.equal(observed.url, "https://api.resend.com/emails");
  assert.equal(observed.options.headers["Idempotency-Key"], "luma-deletion-job-1");
  const payload = JSON.parse(observed.options.body);
  assert.equal(payload.from, "CE HALO <info@cehalo.com>");
  assert.equal(payload.reply_to, "info@cehalo.com");
  assert.deepEqual(payload.to, [job.recipient]);
  assert.equal(payload.text, job.body);
});
test("bad provider status or missing receipt never counts as accepted", async () => {
  await assert.rejects(sendMail(job, "test", async () => new Response("", { status: 429 })));
  await assert.rejects(sendMail(job, "test", async () => Response.json({})));
});
