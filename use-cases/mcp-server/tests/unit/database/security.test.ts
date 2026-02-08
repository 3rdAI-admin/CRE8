import { describe, it, expect } from 'vitest'
import { validateSqlQuery, isWriteOperation, formatDatabaseError } from '../../../src/database/security'
import {
  validSelectQuery,
  validInsertQuery,
  validUpdateQuery,
  validDeleteQuery,
  dangerousDropQuery,
  dangerousDeleteAllQuery,
  maliciousInjectionQuery,
  emptyQuery,
  whitespaceQuery,
} from '../../fixtures/database.fixtures'

describe('Database Security', () => {
  describe('validateSqlQuery', () => {
    it('should validate safe SELECT queries', () => {
      const result = validateSqlQuery(validSelectQuery)
      expect(result.isValid).toBe(true)
      expect(result.error).toBeUndefined()
    })

    it('should validate safe INSERT queries', () => {
      const result = validateSqlQuery(validInsertQuery)
      expect(result.isValid).toBe(true)
      expect(result.error).toBeUndefined()
    })

    it('should reject empty queries', () => {
      const result = validateSqlQuery(emptyQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('SQL query cannot be empty')
    })

    it('should reject whitespace-only queries', () => {
      const result = validateSqlQuery(whitespaceQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('SQL query cannot be empty')
    })

    it('should reject dangerous DROP queries', () => {
      const result = validateSqlQuery(dangerousDropQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
    })

    it('should reject dangerous DELETE ALL queries', () => {
      const result = validateSqlQuery(dangerousDeleteAllQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
    })

    it('should reject SQL injection attempts', () => {
      const result = validateSqlQuery(maliciousInjectionQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
    })

    it('should handle case-insensitive dangerous patterns', () => {
      const upperCaseQuery = 'SELECT * FROM users; DROP TABLE users;'
      const result = validateSqlQuery(upperCaseQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
    })

    // Edge cases for obfuscation attempts
    it('should reject TRUNCATE at start of query', () => {
      expect(validateSqlQuery('TRUNCATE TABLE users').isValid).toBe(false)
    })

    it('should reject ALTER at start of query', () => {
      expect(validateSqlQuery('ALTER TABLE users ADD COLUMN admin BOOLEAN').isValid).toBe(false)
    })

    it('should reject piggy-backed GRANT statements', () => {
      expect(validateSqlQuery('SELECT 1; GRANT ALL ON users TO public').isValid).toBe(false)
    })

    it('should reject piggy-backed REVOKE statements', () => {
      expect(validateSqlQuery('SELECT 1; REVOKE ALL ON users FROM public').isValid).toBe(false)
    })

    it('should reject xp_cmdshell anywhere in query', () => {
      expect(validateSqlQuery("SELECT * FROM users WHERE name = 'xp_cmdshell'").isValid).toBe(false)
    })

    it('should reject sp_executesql anywhere in query', () => {
      expect(validateSqlQuery("EXEC sp_executesql N'SELECT 1'").isValid).toBe(false)
    })

    it('should reject piggy-backed CREATE statements', () => {
      expect(validateSqlQuery('SELECT 1; CREATE TABLE evil (id int)').isValid).toBe(false)
    })

    it('should reject mixed-case DROP injection', () => {
      expect(validateSqlQuery('SELECT 1; DrOp TABLE users').isValid).toBe(false)
    })

    it('should allow safe queries with the word drop in values', () => {
      // "drop" in a string literal value should be fine (no semicolon + DROP pattern)
      expect(validateSqlQuery("SELECT * FROM items WHERE name = 'raindrop'").isValid).toBe(true)
    })

    it('should allow subqueries and CTEs', () => {
      expect(validateSqlQuery('WITH cte AS (SELECT 1) SELECT * FROM cte').isValid).toBe(true)
    })

    it('should allow safe JOIN queries', () => {
      expect(validateSqlQuery('SELECT u.name, p.title FROM users u JOIN posts p ON u.id = p.user_id').isValid).toBe(true)
    })
  })

  describe('isWriteOperation', () => {
    it('should identify SELECT as read operation', () => {
      expect(isWriteOperation(validSelectQuery)).toBe(false)
    })

    it('should identify INSERT as write operation', () => {
      expect(isWriteOperation(validInsertQuery)).toBe(true)
    })

    it('should identify UPDATE as write operation', () => {
      expect(isWriteOperation(validUpdateQuery)).toBe(true)
    })

    it('should identify DELETE as write operation', () => {
      expect(isWriteOperation(validDeleteQuery)).toBe(true)
    })

    it('should identify DROP as write operation', () => {
      expect(isWriteOperation(dangerousDropQuery)).toBe(true)
    })

    it('should handle case-insensitive operations', () => {
      expect(isWriteOperation('insert into users values (1, \'test\')')).toBe(true)
      expect(isWriteOperation('UPDATE users SET name = \'test\'')).toBe(true)
      expect(isWriteOperation('Delete from users where id = 1')).toBe(true)
    })

    it('should handle queries with leading whitespace', () => {
      expect(isWriteOperation('   INSERT INTO users VALUES (1, \'test\')')).toBe(true)
      expect(isWriteOperation('\t\nSELECT * FROM users')).toBe(false)
    })
  })

  describe('formatDatabaseError', () => {
    it('should format generic database errors', () => {
      const error = new Error('Connection failed')
      const result = formatDatabaseError(error)
      expect(result).toBe('Database error: Connection failed')
    })

    it('should sanitize password errors', () => {
      const error = new Error('authentication failed for user "test" with password "secret123"')
      const result = formatDatabaseError(error)
      expect(result).toBe('Database authentication failed. Please check your credentials.')
    })

    it('should handle timeout errors', () => {
      const error = new Error('Connection timeout after 30 seconds')
      const result = formatDatabaseError(error)
      expect(result).toBe('Database connection timed out. Please try again.')
    })

    it('should handle connection errors', () => {
      const error = new Error('Could not connect to database server')
      const result = formatDatabaseError(error)
      expect(result).toBe('Unable to connect to database. Please check your connection string.')
    })

    it('should handle non-Error objects', () => {
      const result = formatDatabaseError('string error')
      expect(result).toBe('An unknown database error occurred.')
    })

    it('should handle null/undefined errors', () => {
      expect(formatDatabaseError(null)).toBe('An unknown database error occurred.')
      expect(formatDatabaseError(undefined)).toBe('An unknown database error occurred.')
    })

    it('should handle number error', () => {
      expect(formatDatabaseError(42)).toBe('An unknown database error occurred.')
    })

    it('should hide password even in complex error messages', () => {
      const error = new Error('FATAL: password authentication failed for user "admin"')
      expect(formatDatabaseError(error)).toBe('Database authentication failed. Please check your credentials.')
    })

    it('should detect "connect" substring in connection errors', () => {
      const error = new Error('could not connect to server: Connection refused')
      expect(formatDatabaseError(error)).toBe('Unable to connect to database. Please check your connection string.')
    })

    it('should pass through non-sensitive error messages', () => {
      const error = new Error('relation "nonexistent_table" does not exist')
      expect(formatDatabaseError(error)).toBe('Database error: relation "nonexistent_table" does not exist')
    })
  })
})