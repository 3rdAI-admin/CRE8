// Cookie-based client approval with HMAC-SHA256 signing

import type { AuthRequest } from "@cloudflare/workers-oauth-provider";
import type { ParsedApprovalResult } from "../types";
import { decodeState, type OAuthState } from "./state-encoding";

const COOKIE_NAME = "mcp-approved-clients";
const ONE_YEAR_IN_SECONDS = 31536000;
const MIN_SECRET_LENGTH = 32;

/**
 * Imports a secret key string for HMAC-SHA256 signing.
 * @param secret - The raw secret key string (minimum 32 characters).
 * @returns A promise resolving to the CryptoKey object.
 */
async function importKey(secret: string): Promise<CryptoKey> {
  if (!secret) {
    throw new Error("COOKIE_SECRET is not defined. A secret key is required for signing cookies.");
  }
  if (secret.length < MIN_SECRET_LENGTH) {
    throw new Error(`COOKIE_SECRET must be at least ${MIN_SECRET_LENGTH} characters for adequate security (got ${secret.length}).`);
  }
  const enc = new TextEncoder();
  return crypto.subtle.importKey("raw", enc.encode(secret), { hash: "SHA-256", name: "HMAC" }, false, ["sign", "verify"]);
}

/**
 * Signs data using HMAC-SHA256.
 * @param key - The CryptoKey for signing.
 * @param data - The string data to sign.
 * @returns A promise resolving to the signature as a hex string.
 */
async function signData(key: CryptoKey, data: string): Promise<string> {
  const enc = new TextEncoder();
  const signatureBuffer = await crypto.subtle.sign("HMAC", key, enc.encode(data));
  return Array.from(new Uint8Array(signatureBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * Verifies an HMAC-SHA256 signature.
 * @param key - The CryptoKey for verification.
 * @param signatureHex - The signature to verify (hex string).
 * @param data - The original data that was signed.
 * @returns A promise resolving to true if the signature is valid, false otherwise.
 */
async function verifySignature(key: CryptoKey, signatureHex: string, data: string): Promise<boolean> {
  const enc = new TextEncoder();
  try {
    const signatureBytes = new Uint8Array(signatureHex.match(/.{1,2}/g)!.map((byte) => Number.parseInt(byte, 16)));
    return await crypto.subtle.verify("HMAC", key, signatureBytes.buffer, enc.encode(data));
  } catch (e) {
    console.error("Error verifying signature:", e);
    return false;
  }
}

/**
 * Parses the signed cookie and verifies its integrity.
 * @param cookieHeader - The value of the Cookie header from the request.
 * @param secret - The secret key used for signing.
 * @returns A promise resolving to the list of approved client IDs if the cookie is valid, otherwise null.
 */
async function getApprovedClientsFromCookie(cookieHeader: string | null, secret: string): Promise<string[] | null> {
  if (!cookieHeader) return null;

  const cookies = cookieHeader.split(";").map((c) => c.trim());
  const targetCookie = cookies.find((c) => c.startsWith(`${COOKIE_NAME}=`));

  if (!targetCookie) return null;

  const cookieValue = targetCookie.substring(COOKIE_NAME.length + 1);
  const parts = cookieValue.split(".");

  if (parts.length !== 2) {
    console.warn("Invalid cookie format received.");
    return null;
  }

  const [signatureHex, base64Payload] = parts;
  const payload = atob(base64Payload);

  const key = await importKey(secret);
  const isValid = await verifySignature(key, signatureHex, payload);

  if (!isValid) {
    console.warn("Cookie signature verification failed.");
    return null;
  }

  try {
    const approvedClients = JSON.parse(payload);
    if (!Array.isArray(approvedClients)) {
      console.warn("Cookie payload is not an array.");
      return null;
    }
    if (!approvedClients.every((item) => typeof item === "string")) {
      console.warn("Cookie payload contains non-string elements.");
      return null;
    }
    return approvedClients as string[];
  } catch (e) {
    console.error("Error parsing cookie payload:", e);
    return null;
  }
}

/**
 * Checks if a given client ID has already been approved by the user,
 * based on a signed cookie.
 *
 * @param request - The incoming Request object to read cookies from.
 * @param clientId - The OAuth client ID to check approval for.
 * @param cookieSecret - The secret key used to sign/verify the approval cookie.
 * @returns A promise resolving to true if the client is approved, false otherwise.
 */
export async function clientIdAlreadyApproved(request: Request, clientId: string, cookieSecret: string): Promise<boolean> {
  if (!clientId) return false;
  const cookieHeader = request.headers.get("Cookie");
  const approvedClients = await getApprovedClientsFromCookie(cookieHeader, cookieSecret);

  return approvedClients?.includes(clientId) ?? false;
}

/**
 * Parses the form submission from the approval dialog, extracts the state,
 * and generates Set-Cookie headers to mark the client as approved.
 *
 * @param request - The incoming POST Request object containing the form data.
 * @param cookieSecret - The secret key used to sign the approval cookie.
 * @returns A promise resolving to an object containing the parsed state and necessary headers.
 * @throws If the request method is not POST, form data is invalid, or state is missing.
 */
export async function parseRedirectApproval(request: Request, cookieSecret: string): Promise<ParsedApprovalResult> {
  if (request.method !== "POST") {
    throw new Error("Invalid request method. Expected POST.");
  }

  let state: OAuthState;
  let clientId: string | undefined;

  try {
    const formData = await request.formData();
    const encodedState = formData.get("state");

    if (typeof encodedState !== "string" || !encodedState) {
      throw new Error("Missing or invalid 'state' in form data.");
    }

    state = decodeState(encodedState);
    clientId = state?.oauthReqInfo?.clientId;

    if (!clientId) {
      throw new Error("Could not extract clientId from state object.");
    }
  } catch (e) {
    console.error("Error processing form submission:", e);
    throw new Error(`Failed to parse approval form: ${e instanceof Error ? e.message : String(e)}`);
  }

  // Get existing approved clients
  const cookieHeader = request.headers.get("Cookie");
  const existingApprovedClients = (await getApprovedClientsFromCookie(cookieHeader, cookieSecret)) || [];

  // Add the newly approved client ID (avoid duplicates)
  const updatedApprovedClients = Array.from(new Set([...existingApprovedClients, clientId]));

  // Sign the updated list
  const payload = JSON.stringify(updatedApprovedClients);
  const key = await importKey(cookieSecret);
  const signature = await signData(key, payload);
  const newCookieValue = `${signature}.${btoa(payload)}`;

  const headers: Record<string, string> = {
    "Set-Cookie": `${COOKIE_NAME}=${newCookieValue}; HttpOnly; Secure; Path=/; SameSite=Lax; Max-Age=${ONE_YEAR_IN_SECONDS}`,
  };

  return { headers, state };
}
