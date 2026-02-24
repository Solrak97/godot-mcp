import asyncio
import sys
from pathlib import Path
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import CallToolResult, TextContent
from git_mcp.tools import get_tools, handle_tool_call

# Create MCP server
server = Server("git-mcp")

@server.list_tools()
async def list_tools() -> list:
    """List available Git tools"""
    return get_tools()

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> CallToolResult:
    """Handle tool calls"""
    contents = await handle_tool_call(name, arguments)
    return CallToolResult(
        content=contents
    )

async def main():
    """Run the MCP server"""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
