// Triggered by a pg_net-based database trigger (see
// supabase/migrations/*_documents_insert_webhook.sql) on every INSERT into
// public.documents, regardless of category. Looks up the client's mobile
// device tokens and sends a data-only FCM push carrying enough info
// (document_id, doc_type, category, due_date, amount) for the app to both
// show an immediate "Belge Geldi" notification and schedule a due-date
// local reminder (payment docs only) without a further network round-trip
// — including from the background isolate handler.
//
// Required secrets (`supabase secrets set ...`):
//   WEBHOOK_SECRET             — shared secret checked against the trigger's request
//   FCM_SERVICE_ACCOUNT_JSON   — full Firebase service account JSON (one line)
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY — provided automatically by the platform

import { createClient } from "npm:@supabase/supabase-js@2";

interface DocumentInsertPayload {
  record: {
    id: string;
    client_id: string;
    category: "payment" | "info" | "unclassified";
    doc_type: string;
    due_date: string | null;
    amount: number | null;
  };
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
}

Deno.serve(async (req) => {
  const webhookSecret = Deno.env.get("WEBHOOK_SECRET");
  if (webhookSecret && req.headers.get("x-webhook-secret") !== webhookSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { record } = (await req.json()) as DocumentInsertPayload;

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: tokens, error: tokensError } = await supabaseAdmin
    .from("device_tokens")
    .select("token")
    .eq("user_id", record.client_id);

  if (tokensError) {
    console.error("device_tokens lookup failed", tokensError.message);
    return new Response("Internal error", { status: 500 });
  }
  if (!tokens || tokens.length === 0) {
    // No mobile device registered — web clients get this via Realtime, not push.
    return new Response(JSON.stringify({ skipped: true }), { status: 200 });
  }

  const payload = {
    type: "new_document",
    document_id: record.id,
    doc_type: record.doc_type,
    category: record.category,
    due_date: record.due_date ?? "",
    amount: record.amount?.toString() ?? "",
  };
  // Never include record.raw_text or any other field here — it may contain
  // TC kimlik no and must not be logged or transmitted outside the DB.

  const accessToken = await getFcmAccessToken();

  const results = await Promise.all(
    tokens.map((t) => sendFcmMessage(accessToken, t.token, payload)),
  );

  const invalidTokens = tokens
    .filter((_, i) => results[i].invalidToken)
    .map((t) => t.token);
  if (invalidTokens.length > 0) {
    await supabaseAdmin.from("device_tokens").delete().in("token", invalidTokens);
  }

  return new Response(JSON.stringify({ sent: results.filter((r) => r.ok).length }), {
    status: 200,
  });
});

async function sendFcmMessage(
  accessToken: string,
  token: string,
  data: Record<string, string>,
): Promise<{ ok: boolean; invalidToken: boolean }> {
  const serviceAccount = getServiceAccount();
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      // android.priority: "high" is required for data-only messages to be
      // delivered promptly — without it FCM may defer delivery while the
      // device is in Doze/App Standby, which is most of the time for an
      // app that's not in the foreground.
      body: JSON.stringify({
        message: { token, data, android: { priority: "high" } },
      }),
    },
  );

  if (response.ok) return { ok: true, invalidToken: false };

  const body = await response.json().catch(() => null);
  const errorCode = body?.error?.details?.find(
    (d: { errorCode?: string }) => d.errorCode,
  )?.errorCode;
  const invalidToken = errorCode === "UNREGISTERED" || errorCode === "INVALID_ARGUMENT";
  if (!invalidToken) {
    console.error("FCM send failed", response.status, JSON.stringify(body));
  }
  return { ok: false, invalidToken };
}

function getServiceAccount(): ServiceAccount {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT_JSON secret not set");
  return JSON.parse(raw);
}

// Exchanges the service account's private key for a short-lived OAuth2
// access token (JWT bearer flow), per Google's HTTP v1 API requirements.
async function getFcmAccessToken(): Promise<string> {
  const serviceAccount = getServiceAccount();
  const now = Math.floor(Date.now() / 1000);

  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const unsigned = `${encode(header)}.${encode(claims)}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signatureBytes = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBytes)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const assertion = `${unsigned}.${signature}`;

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const tokenBody = await tokenResponse.json();
  if (!tokenResponse.ok) {
    throw new Error(`OAuth token exchange failed: ${JSON.stringify(tokenBody)}`);
  }
  return tokenBody.access_token as string;
}

function pemToDer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}
