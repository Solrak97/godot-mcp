#!/bin/bash

# AutoTask module installation script
# Copies the bridge to .cursor/bridges/autotask and updates MCP config

PROJECT_ROOT="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE_SOURCE="$SCRIPT_DIR/bridge"
BRIDGE_TARGET="$PROJECT_ROOT/.cursor/bridges/autotask"

# Create bridges directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/.cursor/bridges"

# Copy bridge to bridges directory
if [ -d "$BRIDGE_SOURCE" ]; then
    echo "   📦 Copying bridge to .cursor/bridges/autotask..."
    # Remove old bridge if it exists
    [ -d "$BRIDGE_TARGET" ] && rm -rf "$BRIDGE_TARGET"
    # Copy bridge (excluding .venv and cache directories)
    rsync -av --exclude='.venv' --exclude='.uv-cache' --exclude='__pycache__' \
        "$BRIDGE_SOURCE/" "$BRIDGE_TARGET/" 2>/dev/null || \
    cp -r "$BRIDGE_SOURCE" "$BRIDGE_TARGET"
    
    # Install bridge dependencies
    if [ -f "$BRIDGE_TARGET/pyproject.toml" ] && command -v uv &> /dev/null; then
        echo "   📦 Installing bridge dependencies..."
        cd "$BRIDGE_TARGET"
        uv sync
        cd "$SCRIPT_DIR"
    fi
    
    echo "   ✅ Bridge installed to .cursor/bridges/autotask"
else
    echo "   ⚠️  Bridge source not found at $BRIDGE_SOURCE"
    exit 1
fi

# Update mcp.json with correct path if jq is available
# Check both possible locations
MCP_CONFIG="$PROJECT_ROOT/.cursor/mcp.json"
[ ! -f "$MCP_CONFIG" ] && MCP_CONFIG="$PROJECT_ROOT/.cursor/.cursor/mcp.json"
if [ -f "$MCP_CONFIG" ] && command -v jq &> /dev/null; then
    # Calculate relative path from project root to bridge
    BRIDGE_RELATIVE_PATH=".cursor/bridges/autotask"
    
    # Update the path in the autotask MCP server config (args[2] is the --directory value)
    jq --arg path "$BRIDGE_RELATIVE_PATH" \
       'if .mcpServers.autotask then .mcpServers.autotask.args[2] = $path else . end' \
       "$MCP_CONFIG" > "$MCP_CONFIG.tmp" && mv "$MCP_CONFIG.tmp" "$MCP_CONFIG"
    echo "   ✅ Updated MCP config with bridge path"
else
    echo "   ⚠️  Please manually update .cursor/mcp.json:"
    echo "      Set mcpServers.autotask.args[2] to: .cursor/bridges/autotask"
fi
