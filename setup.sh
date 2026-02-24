#!/bin/bash

# Comprehensive setup script for Cursor Workflow
# This script does everything needed to set up cursor_workflow in a new project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Cursor Workflow - Complete Setup"
echo "===================================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

MISSING_DEPS=0

if ! command -v git &> /dev/null; then
    echo "   ❌ Git not found"
    MISSING_DEPS=1
else
    echo "   ✅ Git found"
fi

if ! command -v uv &> /dev/null; then
    echo "   ⚠️  uv not found (required for some modules)"
    echo "      Install from: https://github.com/astral-sh/uv"
else
    echo "   ✅ uv found"
fi

if ! command -v jq &> /dev/null; then
    echo "   ⚠️  jq not found (recommended for config merging)"
    echo "      Install with: brew install jq (macOS) or apt-get install jq (Linux)"
else
    echo "   ✅ jq found"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo "❌ Missing required dependencies. Please install them and try again."
    exit 1
fi

echo ""
echo "📦 Installing modules..."

# Run the main install script
bash "$SCRIPT_DIR/install.sh" --all

echo ""
echo "🔍 Verifying installation..."

# Check if MCP config was created
if [ -f "$PROJECT_ROOT/.cursor/mcp.json" ]; then
    echo "   ✅ MCP configuration created"
    
    # Count installed servers
    if command -v jq &> /dev/null; then
        SERVER_COUNT=$(jq '.mcpServers | length' "$PROJECT_ROOT/.cursor/mcp.json")
        echo "   ✅ $SERVER_COUNT MCP server(s) configured"
    fi
else
    echo "   ⚠️  MCP configuration not found"
fi

# Check if rules were copied
if [ -d "$PROJECT_ROOT/.cursor/rules" ]; then
    RULE_COUNT=$(find "$PROJECT_ROOT/.cursor/rules" -name "*.mdc" | wc -l | tr -d ' ')
    echo "   ✅ $RULE_COUNT rule(s) installed"
else
    echo "   ⚠️  Rules directory not found"
fi

echo ""
echo "📝 Setup Summary"
echo "================"
echo ""
echo "Installed location: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""
echo "Configuration files:"
echo "  - .cursor/mcp.json (MCP server configuration)"
echo "  - .cursor/rules/ (Cursor rules)"
echo ""
echo "Next steps:"
echo "  1. Review .cursor/mcp.json and update paths if needed"
echo "  2. Check module requirements in modules/*/README.md"
echo "  3. Restart Cursor to load MCP servers and rules"
echo "  4. Use the Cursor skill to discover available tools"
echo ""
echo "✅ Setup complete!"
