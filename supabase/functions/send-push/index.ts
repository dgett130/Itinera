// Itinera — Edge Function `send-push`
//
// Invia una notifica push FCM (HTTP v1) quando viene inserita una riga in
// `public.notifications`. Va collegata con un Database Webhook di Supabase
// (Database -> Webhooks) su INSERT della tabella notifications.
//
// Rispetta le preferenze dell'utente (`notification_prefs`): se il master o la
// categoria sono disattivati, la riga resta in inbox ma NON viene inviato push.
//
// Secret richiesti (supabase secrets set ...):
//   FCM_SERVICE_ACCOUNT  = JSON completo della service account Firebase
//                          (Impostazioni progetto -> Account di servizio ->
//                           Genera nuova chiave privata)
// Forniti automaticamente da Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
//
// Deploy:  supabase functions deploy send-push
// Test:    inserendo una riga in notifications (o via il webhook)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface NotificationRow {
  id: string;
  user_id: string;
  type: string;
  title: string;
  body: string | null;
  data: Record<string, unknown> | null;
}

// type notifica -> colonna preferenza
const PREF_COLUMN: Record<string, string> = {
  friend_request: "friend_requests",
  friend_accepted: "friend_requests",
  shared_trip: "shared_trips",
  new_document: "new_documents",
  system: "system_messages",
};

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

function b64url(data: Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): Uint8Array {
  const body = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const bin = atob(body);
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

// Legge il secret FCM_SERVICE_ACCOUNT: accetta sia il JSON grezzo sia il JSON
// codificato in base64 (comodo per impostarlo da Windows senza problemi di
// virgolette/newline).
function loadServiceAccount(): {
  client_email: string;
  private_key: string;
  project_id: string;
} {
  const raw = (Deno.env.get("FCM_SERVICE_ACCOUNT") ?? "").trim();
  const text = raw.startsWith("{")
    ? raw
    : new TextDecoder().decode(Uint8Array.from(atob(raw), (c) => c.charCodeAt(0)));
  return JSON.parse(text);
}

// Access token OAuth2 per FCM, firmando un JWT con la service account (RS256).
async function getAccessToken(sa: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(claim))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  const jwt = `${unsigned}.${b64url(sig)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  if (!json.access_token) throw new Error(`Token FCM: ${JSON.stringify(json)}`);
  return json.access_token as string;
}

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    const row: NotificationRow = payload.record ?? payload;
    if (!row?.user_id) return new Response("no user", { status: 200 });

    // 1) Preferenze
    const { data: prefs } = await admin
      .from("notification_prefs")
      .select("*")
      .eq("user_id", row.user_id)
      .maybeSingle();
    const pushEnabled = prefs?.push_enabled ?? true;
    const col = PREF_COLUMN[row.type] ?? "system_messages";
    const catEnabled = prefs?.[col] ?? true;
    if (!pushEnabled || !catEnabled) {
      return new Response("push disabilitato dalle preferenze", { status: 200 });
    }

    // 2) Token del destinatario
    const { data: tokens } = await admin
      .from("device_tokens")
      .select("token")
      .eq("user_id", row.user_id);
    if (!tokens || tokens.length === 0) {
      return new Response("nessun token", { status: 200 });
    }

    // 3) Invio FCM v1
    const sa = loadServiceAccount();
    const accessToken = await getAccessToken(sa);
    const dataStr: Record<string, string> = {};
    for (const [k, v] of Object.entries(row.data ?? {})) dataStr[k] = String(v);
    dataStr.notification_id = row.id;

    const url =
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
    const stale: string[] = [];
    await Promise.all(tokens.map(async ({ token }) => {
      const res = await fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: row.title, body: row.body ?? "" },
            data: dataStr,
            android: { priority: "high" },
          },
        }),
      });
      if (res.status === 404 || res.status === 400) stale.push(token);
    }));

    // 4) Pulizia token non piu' validi
    if (stale.length > 0) {
      await admin.from("device_tokens").delete().in("token", stale);
    }

    return new Response("ok", { status: 200 });
  } catch (e) {
    console.error("[send-push]", e);
    return new Response(`error: ${e}`, { status: 500 });
  }
});
