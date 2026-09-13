// Triggered by the same documents-insert database trigger as
// on-document-insert (see
// supabase/migrations/20260912000000_documents_whatsapp_webhook.sql), as a
// second, fully independent net.http_post target. Sends the client a
// WhatsApp Business Cloud API template message (Meta Graph API directly —
// no BSP/middleman) with a link to the newly uploaded PDF. Entirely
// separate from the FCM push function — a failure here must never affect
// that path, and doesn't, since the trigger invokes both independently.
//
// Required secrets (`supabase secrets set ...`):
//   WHATSAPP_WEBHOOK_SECRET      — shared secret checked against the trigger's
//                                  request (a DIFFERENT value than
//                                  on-document-insert's WEBHOOK_SECRET)
//   WHATSAPP_ACCESS_TOKEN        — Meta System User permanent access token
//                                  (whatsapp_business_messaging permission)
//   WHATSAPP_PHONE_NUMBER_ID     — the WABA phone number ID sending messages
//   WHATSAPP_TEMPLATE_PAYMENT_NAME — approved Utility template name (payment docs)
//   WHATSAPP_TEMPLATE_INFO_NAME    — approved Utility template name (info docs)
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY — provided automatically by the platform

import { createClient } from "npm:@supabase/supabase-js@2";

interface DocumentInsertPayload {
  record: {
    id: string;
    client_id: string;
    accountant_id: string;
    category: "payment" | "info" | "unclassified";
    doc_type: string;
    period: string | null;
    amount: number | null;
    due_date: string | null;
    storage_path: string;
  };
}

// Keep reasonably current: v21.0 (the version this was first written against)
// stopped resolving newly-approved templates, failing sends with a
// misleading 132001 "template does not exist" error even though the
// template read API showed it as APPROVED.
const WHATSAPP_GRAPH_API_VERSION = "v26.0";

Deno.serve(async (req) => {
  try {
    const webhookSecret = Deno.env.get("WHATSAPP_WEBHOOK_SECRET");
    if (webhookSecret && req.headers.get("x-webhook-secret") !== webhookSecret) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { record } = (await req.json()) as DocumentInsertPayload;

    if (record.category === "unclassified") {
      return new Response(JSON.stringify({ skipped: "unclassified" }), { status: 200 });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: contact } = await supabaseAdmin
      .from("client_contact_info")
      .select("phone, whatsapp_enabled")
      .eq("client_id", record.client_id)
      .maybeSingle();

    if (!contact?.phone || contact.whatsapp_enabled !== true) {
      return new Response(JSON.stringify({ skipped: "no_phone_or_disabled" }), { status: 200 });
    }

    const to = normalizeTrPhone(contact.phone);
    if (!to) {
      console.error("Unparseable phone for client", record.client_id);
      return new Response(JSON.stringify({ skipped: "bad_phone" }), { status: 200 });
    }

    const [{ data: clientProfile }, { data: accountantProfile }] = await Promise.all([
      supabaseAdmin.from("profiles").select("full_name").eq("id", record.client_id).maybeSingle(),
      supabaseAdmin
        .from("profiles")
        .select("full_name")
        .eq("id", record.accountant_id)
        .maybeSingle(),
    ]);

    const { data: signedUrlData, error: signedUrlError } = await supabaseAdmin.storage
      .from("documents")
      .createSignedUrl(record.storage_path, 60 * 60 * 24 * 3); // 3 gün

    if (signedUrlError || !signedUrlData) {
      console.error("Signed URL creation failed", signedUrlError?.message);
      return new Response(JSON.stringify({ skipped: "no_signed_url" }), { status: 200 });
    }

    const templateBody = buildTemplatePayload({
      to,
      clientName: clientProfile?.full_name ?? "Değerli mükellefimiz",
      accountantName: accountantProfile?.full_name ?? "Muhasebeciniz",
      docTypeLabel: docTypeLabel(record.doc_type),
      period: record.period ?? "-",
      amount: record.amount,
      dueDate: record.due_date,
      category: record.category as "payment" | "info",
      documentUrl: signedUrlData.signedUrl,
    });

    if (!templateBody) {
      // No approved template name configured for this category yet.
      return new Response(JSON.stringify({ skipped: "no_template_configured" }), { status: 200 });
    }

    const phoneNumberId = Deno.env.get("WHATSAPP_PHONE_NUMBER_ID");
    const accessToken = Deno.env.get("WHATSAPP_ACCESS_TOKEN");
    if (!phoneNumberId || !accessToken) {
      console.error("WhatsApp secrets not configured (WHATSAPP_PHONE_NUMBER_ID/WHATSAPP_ACCESS_TOKEN)");
      return new Response(JSON.stringify({ skipped: "not_configured" }), { status: 200 });
    }

    const response = await fetch(
      `https://graph.facebook.com/${WHATSAPP_GRAPH_API_VERSION}/${phoneNumberId}/messages`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(templateBody),
      },
    );

    if (!response.ok) {
      const errBody = await response.text().catch(() => "");
      console.error("WhatsApp send failed", response.status, errBody);
      return new Response(JSON.stringify({ sent: false }), { status: 200 });
    }

    return new Response(JSON.stringify({ sent: true }), { status: 200 });
  } catch (e) {
    // Never let an unexpected error surface as a 5xx that pg_net might
    // retry indefinitely — log and acknowledge instead.
    console.error("send-whatsapp-document unexpected error", e);
    return new Response(JSON.stringify({ sent: false, error: String(e) }), { status: 200 });
  }
});

// Simple TR-specific normalization: strips spaces/dashes, leaves numbers
// already starting with '+' or '90' untouched, replaces a leading '0'
// with '+90'. Not a general E.164 validator — good enough for TR mobile
// numbers as entered by accountants in client_contact_info_screen.dart
// (a plain, unvalidated text field).
function normalizeTrPhone(raw: string): string | null {
  const cleaned = raw.replace(/[\s-]/g, "");
  if (cleaned.startsWith("+")) return cleaned;
  if (cleaned.startsWith("90")) return `+${cleaned}`;
  if (cleaned.startsWith("0")) return `+90${cleaned.slice(1)}`;
  return null;
}

function docTypeLabel(docType: string): string {
  const labels: Record<string, string> = {
    kdv: "KDV",
    muhtasar: "Muhtasar",
    kdv2: "KDV2",
    gecici_vergi: "Geçici Vergi",
    damga: "Damga Vergisi",
    sgk_prim: "SGK Primi",
    ise_giris: "İşe Giriş Bildirgesi",
    isten_cikis: "İşten Çıkış Bildirgesi",
    other: "Belge",
  };
  return labels[docType] ?? "Belge";
}

function buildTemplatePayload(args: {
  to: string;
  clientName: string;
  accountantName: string;
  docTypeLabel: string;
  period: string;
  amount: number | null;
  dueDate: string | null;
  category: "payment" | "info";
  documentUrl: string;
}) {
  const templateName =
    args.category === "payment"
      ? Deno.env.get("WHATSAPP_TEMPLATE_PAYMENT_NAME")
      : Deno.env.get("WHATSAPP_TEMPLATE_INFO_NAME");
  if (!templateName) return null;

  const bodyParams =
    args.category === "payment"
      ? [
          args.clientName,
          args.accountantName,
          args.docTypeLabel,
          args.period,
          args.amount != null ? `${args.amount.toFixed(2)} TL` : "-",
          args.dueDate ?? "-",
        ]
      : [args.clientName, args.accountantName, args.docTypeLabel, args.period];

  return {
    messaging_product: "whatsapp",
    to: args.to,
    type: "template",
    template: {
      name: templateName,
      language: { code: "tr" },
      components: [
        {
          type: "header",
          parameters: [
            { type: "document", document: { link: args.documentUrl, filename: "belge.pdf" } },
          ],
        },
        {
          type: "body",
          parameters: bodyParams.map((text) => ({ type: "text", text })),
        },
      ],
    },
  };
}
