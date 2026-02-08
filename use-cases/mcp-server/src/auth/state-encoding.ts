// State encoding/decoding for OAuth flows

/**
 * Shape of the encoded OAuth state object.
 * Contains the original authorization request info that must survive
 * the redirect round-trip.
 */
export interface OAuthState {
  oauthReqInfo?: {
    clientId: string;
    [key: string]: unknown;
  };
  [key: string]: unknown;
}

/**
 * Encodes an OAuth state object to a URL-safe base64 string.
 * @param data - The state data to encode (will be stringified).
 * @returns A base64 encoded string.
 */
export function encodeState(data: OAuthState): string {
  try {
    const jsonString = JSON.stringify(data);
    return btoa(jsonString);
  } catch (e) {
    console.error("Error encoding state:", e);
    throw new Error("Could not encode state");
  }
}

/**
 * Decodes a base64 string back to an OAuth state object.
 * @param encoded - The base64 encoded string.
 * @returns The decoded state object.
 */
export function decodeState<T extends OAuthState = OAuthState>(encoded: string): T {
  try {
    const jsonString = atob(encoded);
    return JSON.parse(jsonString);
  } catch (e) {
    console.error("Error decoding state:", e);
    throw new Error("Could not decode state");
  }
}
