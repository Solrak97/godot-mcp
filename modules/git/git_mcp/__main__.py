"""Entry point for Git MCP server"""

from git_mcp.server import main
import asyncio

if __name__ == "__main__":
    asyncio.run(main())
