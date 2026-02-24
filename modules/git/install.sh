#!/bin/bash

# Git module installation script
# Updates the MCP config path to be relative to project root

PROJECT_ROOT="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Calculate relative path from project root to this module
RELATIVE_PATH=$(realpath --relative-to="$PROJECT_ROOT" "$SCRIPT_DIR" 2>/dev/null || \
                python3 -c "import os; print(os.path.relpath('$SCRIPT_DIR', '$PROJECT_ROOT'))" 2>/dev/null || \
                echo ".cursor/cursor_workflow/modules/git")

echo "   📍 Git MCP path: $RELATIVE_PATH"

# Update mcp.json with correct path if jq is available
MCP_CONFIG="$PROJECT_ROOT/.cursor/mcp.json"
if [ -f "$MCP_CONFIG" ] && command -v jq &> /dev/null; then
    # Update the path in the git MCP server config (args[2] is the --directory value)
    jq --arg path "$RELATIVE_PATH" \
       'if .mcpServers.git then .mcpServers.git.args[2] = $path else . end' \
       "$MCP_CONFIG" > "$MCP_CONFIG.tmp" && mv "$MCP_CONFIG.tmp" "$MCP_CONFIG"
    echo "   ✅ Updated MCP config with correct path"
else
    echo "   ⚠️  Please manually update .cursor/mcp.json:"
    echo "      Set mcpServers.git.args[2] to: $RELATIVE_PATH"
fi
