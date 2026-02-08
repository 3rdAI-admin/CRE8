import type { SqlValidationResult } from "../types";

/**
 * SQL injection protection via pattern-based validation.
 *
 * SECURITY NOTE: This is a defence-in-depth measure that catches common
 * attack patterns, but it is NOT foolproof.  Obfuscated queries (e.g. using
 * comments, Unicode tricks, or alternate casing) may bypass these checks.
 * Always pair this with:
 *   1. Parameterized queries where possible (prefer `db(sql, [params])` over `db.unsafe(sql)`)
 *   2. Least-privilege database credentials (read-only role for query tools)
 *   3. Network-level controls (e.g. Cloudflare Access, IP allowlists)
 *
 * Each pattern targets a specific attack vector — see inline comments.
 */
export function validateSqlQuery(sql: string): SqlValidationResult {
  const trimmedSql = sql.trim().toLowerCase();

  if (!trimmedSql) {
    return { isValid: false, error: "SQL query cannot be empty" };
  }

  // Reason: each regex targets a distinct destructive SQL pattern.
  // Patterns are intentionally broad (case-insensitive, optional whitespace)
  // to catch simple obfuscation while accepting that advanced bypass is possible.
  const dangerousPatterns = [
    /;\s*drop\s+/i, // Piggy-backed DROP after another statement
    /^drop\s+/i, // DROP as the primary statement
    /;\s*delete\s+.*\s+where\s+1\s*=\s*1/i, // Unconditional DELETE via tautology
    /;\s*update\s+.*\s+set\s+.*\s+where\s+1\s*=\s*1/i, // Unconditional UPDATE via tautology
    /;\s*truncate\s+/i, // Piggy-backed TRUNCATE
    /^truncate\s+/i, // TRUNCATE as the primary statement
    /;\s*alter\s+/i, // Piggy-backed ALTER
    /^alter\s+/i, // ALTER as the primary statement
    /;\s*create\s+/i, // Piggy-backed CREATE
    /;\s*grant\s+/i, // Privilege escalation via GRANT
    /;\s*revoke\s+/i, // Privilege removal via REVOKE
    /xp_cmdshell/i, // SQL Server command execution
    /sp_executesql/i, // SQL Server dynamic execution
  ];

  for (const pattern of dangerousPatterns) {
    if (pattern.test(sql)) {
      return { isValid: false, error: "Query contains potentially dangerous SQL patterns" };
    }
  }

  return { isValid: true };
}

/**
 * Check if a SQL query is a write operation.
 */
export function isWriteOperation(sql: string): boolean {
  const trimmedSql = sql.trim().toLowerCase();
  const writeKeywords = ["insert", "update", "delete", "create", "drop", "alter", "truncate", "grant", "revoke", "commit", "rollback"];

  return writeKeywords.some((keyword) => trimmedSql.startsWith(keyword));
}

/**
 * Format database error for user-friendly display.
 *
 * SECURITY NOTE: Uses keyword matching to hide sensitive information.
 * This is a blocklist approach — unknown error messages fall through to the
 * generic `Database error: <message>` format.  For maximum safety, consider
 * switching to a whitelist of allowed messages and returning a generic
 * response for everything else.  Full error details should be logged
 * server-side (e.g. via Sentry) for debugging.
 */
export function formatDatabaseError(error: unknown): string {
  if (error instanceof Error) {
    // Hide sensitive connection details
    if (error.message.includes("password")) {
      return "Database authentication failed. Please check your credentials.";
    }
    if (error.message.includes("timeout")) {
      return "Database connection timed out. Please try again.";
    }
    if (error.message.includes("connection") || error.message.includes("connect")) {
      return "Unable to connect to database. Please check your connection string.";
    }
    return `Database error: ${error.message}`;
  }
  return "An unknown database error occurred.";
}
