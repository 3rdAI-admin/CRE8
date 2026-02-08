import postgres from "postgres";

/**
 * Database connection singleton.
 *
 * THREAD SAFETY NOTE: Cloudflare Workers use a single-threaded V8 isolate
 * model.  Each Worker invocation runs in its own isolate, so this singleton
 * is safe — there is no concurrent access to `dbInstance` within a single
 * request handler.  If you move to a multi-threaded runtime (e.g. Node.js
 * with worker_threads), add a mutex around the initialisation check.
 */
let dbInstance: postgres.Sql | null = null;

const DEFAULT_POOL_MAX = 5;
const DEFAULT_IDLE_TIMEOUT = 20;
const DEFAULT_CONNECT_TIMEOUT = 10;

/**
 * Get database connection singleton with connection pooling.
 *
 * Pool sizing: Cloudflare Workers limits concurrent outbound connections
 * to 6 per isolate.  The default pool max of 5 leaves 1 connection for
 * non-database network calls.  Override via the `poolMax` parameter if
 * your deployment has different concurrency requirements.
 *
 * @param databaseUrl - PostgreSQL connection string.
 * @param poolMax - Maximum number of connections in the pool (default: 5).
 */
export function getDb(databaseUrl: string, poolMax: number = DEFAULT_POOL_MAX): postgres.Sql {
  if (!dbInstance) {
    dbInstance = postgres(databaseUrl, {
      max: poolMax,
      idle_timeout: DEFAULT_IDLE_TIMEOUT,
      connect_timeout: DEFAULT_CONNECT_TIMEOUT,
      prepare: true,
    });
  }
  return dbInstance;
}

/**
 * Close database connection pool.
 * Call this when the Durable Object is shutting down.
 */
export async function closeDb(): Promise<void> {
  if (dbInstance) {
    try {
      await dbInstance.end();
    } catch (error) {
      console.error("Error closing database connection:", error);
    } finally {
      dbInstance = null;
    }
  }
}
