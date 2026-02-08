// HTML rendering for OAuth approval dialog

import type { ApprovalDialogOptions } from "../types";

/**
 * Sanitizes HTML content to prevent XSS attacks.
 *
 * Note: This escapes HTML entities only. It is NOT a complete XSS protection
 * library. For richer HTML content from untrusted sources, consider using
 * DOMPurify or a similar dedicated sanitization library.
 *
 * @param unsafe - The unsafe string that might contain HTML.
 * @returns A safe string with HTML special characters escaped.
 */
export function sanitizeHtml(unsafe: string): string {
  return unsafe.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}

/**
 * Renders an approval dialog for OAuth authorization.
 * The dialog displays information about the client and server
 * and includes a form to submit approval.
 *
 * @param request - The HTTP request.
 * @param options - Configuration for the approval dialog.
 * @returns A Response containing the HTML approval dialog.
 */
export function renderApprovalDialog(request: Request, options: ApprovalDialogOptions): Response {
  const { client, server, state } = options;

  const encodedState = btoa(JSON.stringify(state));

  const serverName = sanitizeHtml(server.name);
  const clientName = client?.clientName ? sanitizeHtml(client.clientName) : "Unknown MCP Client";
  const serverDescription = server.description ? sanitizeHtml(server.description) : "";

  const logoUrl = server.logo ? sanitizeHtml(server.logo) : "";
  const clientUri = client?.clientUri ? sanitizeHtml(client.clientUri) : "";
  const policyUri = client?.policyUri ? sanitizeHtml(client.policyUri) : "";
  const tosUri = client?.tosUri ? sanitizeHtml(client.tosUri) : "";

  const contacts = client?.contacts && client.contacts.length > 0 ? sanitizeHtml(client.contacts.join(", ")) : "";
  const redirectUris = client?.redirectUris && client.redirectUris.length > 0 ? client.redirectUris.map((uri) => sanitizeHtml(uri)) : [];

  const htmlContent = buildApprovalHtml({
    serverName,
    clientName,
    serverDescription,
    logoUrl,
    clientUri,
    policyUri,
    tosUri,
    contacts,
    redirectUris,
    encodedState,
    formAction: new URL(request.url).pathname,
  });

  return new Response(htmlContent, {
    headers: {
      "Content-Type": "text/html; charset=utf-8",
    },
  });
}

interface ApprovalHtmlParams {
  serverName: string;
  clientName: string;
  serverDescription: string;
  logoUrl: string;
  clientUri: string;
  policyUri: string;
  tosUri: string;
  contacts: string;
  redirectUris: string[];
  encodedState: string;
  formAction: string;
}

function buildApprovalHtml(params: ApprovalHtmlParams): string {
  const {
    serverName,
    clientName,
    serverDescription,
    logoUrl,
    clientUri,
    policyUri,
    tosUri,
    contacts,
    redirectUris,
    encodedState,
    formAction,
  } = params;

  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${clientName} | Authorization Request</title>
    <style>${approvalCss()}</style>
  </head>
  <body>
    <div class="container">
      <div class="precard">
        <div class="header">
          ${logoUrl ? `<img src="${logoUrl}" alt="${serverName} Logo" class="logo">` : ""}
          <h1 class="title"><strong>${serverName}</strong></h1>
        </div>
        ${serverDescription ? `<p class="description">${serverDescription}</p>` : ""}
      </div>

      <div class="card">
        <h2 class="alert"><strong>${clientName || "A new MCP Client"}</strong> is requesting access</h2>

        <div class="client-info">
          <div class="client-detail">
            <div class="detail-label">Name:</div>
            <div class="detail-value">${clientName}</div>
          </div>
          ${clientUri ? clientDetailLink("Website:", clientUri) : ""}
          ${policyUri ? clientDetailLink("Privacy Policy:", policyUri) : ""}
          ${tosUri ? clientDetailLink("Terms of Service:", tosUri) : ""}
          ${
            redirectUris.length > 0
              ? `
          <div class="client-detail">
            <div class="detail-label">Redirect URIs:</div>
            <div class="detail-value small">${redirectUris.map((uri) => `<div>${uri}</div>`).join("")}</div>
          </div>`
              : ""
          }
          ${
            contacts
              ? `
          <div class="client-detail">
            <div class="detail-label">Contact:</div>
            <div class="detail-value">${contacts}</div>
          </div>`
              : ""
          }
        </div>

        <p>This MCP Client is requesting to be authorized on ${serverName}. If you approve, you will be redirected to complete authentication.</p>

        <form method="post" action="${formAction}">
          <input type="hidden" name="state" value="${encodedState}">
          <div class="actions">
            <button type="button" class="button button-secondary" onclick="window.history.back()">Cancel</button>
            <button type="submit" class="button button-primary">Approve</button>
          </div>
        </form>
      </div>
    </div>
  </body>
</html>`;
}

function clientDetailLink(label: string, url: string): string {
  return `
          <div class="client-detail">
            <div class="detail-label">${label}</div>
            <div class="detail-value small">
              <a href="${url}" target="_blank" rel="noopener noreferrer">${url}</a>
            </div>
          </div>`;
}

function approvalCss(): string {
  return `
    :root {
      --primary-color: #0070f3;
      --error-color: #f44336;
      --border-color: #e5e7eb;
      --text-color: #333;
      --background-color: #fff;
      --card-shadow: 0 8px 36px 8px rgba(0, 0, 0, 0.1);
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                   Helvetica, Arial, sans-serif, "Apple Color Emoji",
                   "Segoe UI Emoji", "Segoe UI Symbol";
      line-height: 1.6;
      color: var(--text-color);
      background-color: #f9fafb;
      margin: 0;
      padding: 0;
    }
    .container { max-width: 600px; margin: 2rem auto; padding: 1rem; }
    .precard { padding: 2rem; text-align: center; }
    .card {
      background-color: var(--background-color);
      border-radius: 8px;
      box-shadow: var(--card-shadow);
      padding: 2rem;
    }
    .header { display: flex; align-items: center; justify-content: center; margin-bottom: 1.5rem; }
    .logo { width: 48px; height: 48px; margin-right: 1rem; border-radius: 8px; object-fit: contain; }
    .title { margin: 0; font-size: 1.3rem; font-weight: 400; }
    .alert { margin: 1rem 0; font-size: 1.5rem; font-weight: 400; text-align: center; }
    .description { color: #555; }
    .client-info { border: 1px solid var(--border-color); border-radius: 6px; padding: 1rem 1rem 0.5rem; margin-bottom: 1.5rem; }
    .client-name { font-weight: 600; font-size: 1.2rem; margin: 0 0 0.5rem 0; }
    .client-detail { display: flex; margin-bottom: 0.5rem; align-items: baseline; }
    .detail-label { font-weight: 500; min-width: 120px; }
    .detail-value {
      font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
      word-break: break-all;
    }
    .detail-value a { color: inherit; text-decoration: underline; }
    .detail-value.small { font-size: 0.8em; }
    .external-link-icon { font-size: 0.75em; margin-left: 0.25rem; vertical-align: super; }
    .actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }
    .button { padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 500; cursor: pointer; border: none; font-size: 1rem; }
    .button-primary { background-color: var(--primary-color); color: white; }
    .button-secondary { background-color: transparent; border: 1px solid var(--border-color); color: var(--text-color); }
    @media (max-width: 640px) {
      .container { margin: 1rem auto; padding: 0.5rem; }
      .card { padding: 1.5rem; }
      .client-detail { flex-direction: column; }
      .detail-label { min-width: unset; margin-bottom: 0.25rem; }
      .actions { flex-direction: column; }
      .button { width: 100%; }
    }`;
}
