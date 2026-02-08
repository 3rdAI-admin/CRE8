import { describe, it, expect } from 'vitest'
import { encodeState, decodeState, type OAuthState } from '../../../src/auth/state-encoding'

describe('State Encoding', () => {
  describe('encodeState / decodeState round-trip', () => {
    it('should round-trip a simple state object', () => {
      const state: OAuthState = { oauthReqInfo: { clientId: 'abc123' } }
      const encoded = encodeState(state)
      const decoded = decodeState(encoded)
      expect(decoded).toEqual(state)
    })

    it('should round-trip state with extra fields', () => {
      const state: OAuthState = {
        oauthReqInfo: { clientId: 'test', redirectUri: 'https://example.com' },
        customField: 'value',
      }
      const encoded = encodeState(state)
      const decoded = decodeState(encoded)
      expect(decoded).toEqual(state)
    })

    it('should round-trip state with special characters', () => {
      const state: OAuthState = {
        oauthReqInfo: { clientId: '<script>alert("xss")</script>' },
        notes: 'line1\nline2\ttab',
      }
      const encoded = encodeState(state)
      const decoded = decodeState(encoded)
      expect(decoded).toEqual(state)
    })

    it('should round-trip empty state object', () => {
      const state: OAuthState = {}
      const encoded = encodeState(state)
      const decoded = decodeState(encoded)
      expect(decoded).toEqual(state)
    })

    it('should produce base64 output', () => {
      const state: OAuthState = { oauthReqInfo: { clientId: 'test' } }
      const encoded = encodeState(state)
      // base64 should only contain A-Z, a-z, 0-9, +, /, =
      expect(encoded).toMatch(/^[A-Za-z0-9+/=]+$/)
    })
  })

  describe('decodeState error handling', () => {
    it('should throw on invalid base64', () => {
      expect(() => decodeState('not-valid-base64!!!')).toThrow('Could not decode state')
    })

    it('should throw on valid base64 but invalid JSON', () => {
      const invalidJson = btoa('not json')
      expect(() => decodeState(invalidJson)).toThrow('Could not decode state')
    })

    it('should throw on empty string', () => {
      expect(() => decodeState('')).toThrow('Could not decode state')
    })
  })
})
