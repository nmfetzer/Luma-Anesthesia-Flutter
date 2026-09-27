import {
  authorized,
  InvalidEvent,
  parseEvent,
  ReviewRequired,
} from "./validation.ts";
export type Config = {
  enabled: boolean;
  secret: string;
  appId: string;
  allowSandbox?: boolean;
};
export type Dependencies = {
  config: Config;
  record: (args: Record<string, unknown>) => Promise<{ error: unknown }>;
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
export async function handle(
  request: Request,
  deps: Dependencies,
): Promise<Response> {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }
  const { config } = deps;
  // Fail closed until secrets and the exact Apple RevenueCat app ID are configured.
  if (!config.enabled || config.secret.length < 32 || !config.appId) {
    return json({ error: "CE webhook not configured" }, 503);
  }
  if (!await authorized(request.headers.get("Authorization"), config.secret)) {
    return json({ error: "Unauthorized" }, 401);
  }
  try {
    // Bound the raw request before JSON parsing, even for chunked requests.
    const reader = request.body?.getReader();
    if (!reader) throw new InvalidEvent("Missing body");
    const chunks: Uint8Array[] = [];
    let length = 0;
    while (true) {
      const part = await reader.read();
      if (part.done) break;
      length += part.value.length;
      if (length > 65536) {
        await reader.cancel();
        return json({ error: "Payload too large" }, 413);
      }
      chunks.push(part.value);
    }
    const bytes = new Uint8Array(length);
    let offset = 0;
    for (const chunk of chunks) {
      bytes.set(chunk, offset);
      offset += chunk.length;
    }
    const event = parseEvent(
      JSON.parse(new TextDecoder().decode(bytes)),
      config.appId,
      Date.now(),
      config.allowSandbox === true,
    );
    if ("ignored" in event) {
      return json({ received: true, ignored: event.ignored });
    }
    const { error } = await deps.record({
      p_event_id: event.eventId,
      p_kind: event.kind,
      p_app_id: event.appId,
      p_transaction_id: event.transactionId,
      p_product_id: event.productId,
      p_user_id: event.userId,
      p_purchased_at: event.purchasedAt,
      p_occurred_at: event.occurredAt,
    });
    if (error) {
      return json({ error: "CE processing unavailable; retry required" }, 503);
    }
    // Acknowledge only after the atomic database operation succeeds.
    return json({ received: true });
  } catch (error) {
    if (error instanceof ReviewRequired) {
      return json({ error: "Manual CE review required" }, 422);
    }
    if (error instanceof InvalidEvent || error instanceof SyntaxError) {
      return json({ error: "Invalid event" }, 400);
    }
    // Never log tokens, raw receipts, user IDs or complete provider payloads.
    return json({ error: "CE processing unavailable; retry required" }, 503);
  }
}
