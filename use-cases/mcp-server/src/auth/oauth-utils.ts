// Barrel re-export — the original 622-line file has been split into:
//   state-encoding.ts  – encode/decode OAuth state
//   cookie-signing.ts  – HMAC cookie signing + approval helpers
//   html-rendering.ts  – OAuth approval dialog HTML
//   oauth-helpers.ts   – upstream OAuth URL/token helpers

export { clientIdAlreadyApproved, parseRedirectApproval } from "./cookie-signing";
export { renderApprovalDialog, sanitizeHtml } from "./html-rendering";
export { getUpstreamAuthorizeUrl, fetchUpstreamAuthToken } from "./oauth-helpers";
export { encodeState, decodeState, type OAuthState } from "./state-encoding";
