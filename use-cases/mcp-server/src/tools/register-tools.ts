import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { Props } from "../types";
// TODO: Move database-tools from examples/ to src/tools/ when implementing database features
// import { registerDatabaseTools } from "../../examples/database-tools";

/**
 * Register all MCP tools based on user permissions
 */
export function registerAllTools(server: McpServer, env: Env, props: Props) {
  // Database tools disabled until properly moved from examples/ to src/tools/
  // registerDatabaseTools(server, env, props);
  // Future tools can be registered here
  // registerOtherTools(server, env, props);
}
