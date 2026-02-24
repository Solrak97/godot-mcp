#!/bin/bash

# Godot MCP module installation script
# Builds the Rust MCP server binary and installs to .cursor/bridges/godot
# Updates MCP config with the binary path

set -e

PROJECT_ROOT="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE_TARGET="$PROJECT_ROOT/.cursor/bridges/godot"
MODULE_DIR="$SCRIPT_DIR"

# Create target directory
mkdir -p "$BRIDGE_TARGET"

# Build Rust binary
echo "   🔨 Building Godot MCP server..."
if command -v cargo &> /dev/null; then
    cd "$MODULE_DIR"
    cargo build --release 2>/dev/null || {
        echo "   ⚠️  Cargo build failed. Ensure Rust is installed: https://rustup.rs"
        exit 1
    }
    cd - > /dev/null

    # Copy binary (handle Windows .exe)
    if [ -f "$MODULE_DIR/target/release/godot_mcp.exe" ]; then
        cp "$MODULE_DIR/target/release/godot_mcp.exe" "$BRIDGE_TARGET/"
        BINARY_NAME="godot_mcp.exe"
    elif [ -f "$MODULE_DIR/target/release/godot_mcp" ]; then
        cp "$MODULE_DIR/target/release/godot_mcp" "$BRIDGE_TARGET/"
        BINARY_NAME="godot_mcp"
    else
        echo "   ⚠️  Built binary not found"
        exit 1
    fi

    BINARY_PATH="$BRIDGE_TARGET/$BINARY_NAME"
    echo "   ✅ Godot MCP binary installed to $BINARY_PATH"
else
    echo "   ⚠️  Cargo not found. Install Rust from https://rustup.rs"
    echo "      Then run: cd $MODULE_DIR && cargo build --release"
    echo "      And copy target/release/godot_mcp to $BRIDGE_TARGET/"
    exit 1
fi

# Update mcp.json with absolute path to binary (more reliable across environments)
MCP_CONFIG="$PROJECT_ROOT/.cursor/mcp.json"
if [ -f "$MCP_CONFIG" ] && command -v jq &> /dev/null; then
    # Use absolute path for the binary
    BINARY_ABS=$(cd "$(dirname "$BINARY_PATH")" && pwd)/$(basename "$BINARY_PATH")
    jq --arg cmd "$BINARY_ABS" \
       'if .mcpServers.godot then .mcpServers.godot.command = $cmd else . end' \
       "$MCP_CONFIG" > "$MCP_CONFIG.tmp" && mv "$MCP_CONFIG.tmp" "$MCP_CONFIG"
    echo "   ✅ Updated MCP config with binary path"
fi
