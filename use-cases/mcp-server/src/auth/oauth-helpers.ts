// OAuth helper functions for upstream service interaction

import type { UpstreamAuthorizeParams, UpstreamTokenParams } from "../types";

/**
 * Constructs an authorization URL for an upstream service.
 *
 * @param options - The parameters for constructing the URL.
 * @returns The authorization URL.
 */
export function getUpstreamAuthorizeUrl({ upstream_url, client_id, scope, redirect_uri, state }: UpstreamAuthorizeParams): string {
  const upstream = new URL(upstream_url);
  upstream.searchParams.set("client_id", client_id);
  upstream.searchParams.set("redirect_uri", redirect_uri);
  upstream.searchParams.set("scope", scope);
  if (state) upstream.searchParams.set("state", state);
  upstream.searchParams.set("response_type", "code");
  return upstream.href;
}

/**
 * Fetches an authorization token from an upstream service.
 *
 * @param options - The parameters for the token exchange.
 * @returns A promise that resolves to [accessToken, null] on success or [null, errorResponse] on failure.
 */
export async function fetchUpstreamAuthToken({
  client_id,
  client_secret,
  code,
  redirect_uri,
  upstream_url,
}: UpstreamTokenParams): Promise<[string, null] | [null, Response]> {
  if (!code) {
    return [null, new Response("Missing code", { status: 400 })];
  }

  const resp = await fetch(upstream_url, {
    body: new URLSearchParams({ client_id, client_secret, code, redirect_uri }).toString(),
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    method: "POST",
  });
  if (!resp.ok) {
    console.log(await resp.text());
    return [null, new Response("Failed to fetch access token", { status: 500 })];
  }
  const body = await resp.formData();
  const accessToken = body.get("access_token") as string;
  if (!accessToken) {
    return [null, new Response("Missing access token", { status: 400 })];
  }
  return [accessToken, null];
}
