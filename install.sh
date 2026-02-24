#!/bin/bash

# Installation script for Cursor Workflow
# Usage: ./install.sh [module1] [module2] ... or ./install.sh --all

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

echo "🚀 Installing Cursor Workflow..."

# Check if we're in a Cursor project (has .cursor directory)
if [ ! -d "$PROJECT_ROOT/.cursor" ]; then
    echo "⚠️  Warning: .cursor directory not found. Creating it..."
    mkdir -p "$PROJECT_ROOT/.cursor"
fi

# Create necessary directories
mkdir -p "$PROJECT_ROOT/.cursor/rules"
mkdir -p "$PROJECT_ROOT/.cursor/mcp"
mkdir -p "$PROJECT_ROOT/.cursor/skills"

# Determine which modules to install
if [ "$1" == "--all" ] || [ $# -eq 0 ]; then
    # Install all modules
    MODULES=$(find "$MODULES_DIR" -maxdepth 1 -type d ! -name "modules" ! -name ".template" -exec basename {} \;)
    echo "📦 Installing all modules: $MODULES"
else
    MODULES="$@"
    echo "📦 Installing modules: $MODULES"
fi

# Initialize MCP config if it doesn't exist
MCP_CONFIG="$PROJECT_ROOT/.cursor/mcp.json"
if [ ! -f "$MCP_CONFIG" ]; then
    echo "📝 Creating new mcp.json..."
    echo '{"mcpServers": {}}' > "$MCP_CONFIG"
fi

# Install each module
for MODULE in $MODULES; do
    MODULE_DIR="$MODULES_DIR/$MODULE"
    # Godot module moved to top-level godot-mcp-server/
    if [ "$MODULE" = "godot" ] && [ ! -d "$MODULE_DIR" ] && [ -d "$SCRIPT_DIR/godot-mcp-server" ]; then
        MODULE_DIR="$SCRIPT_DIR/godot-mcp-server"
    fi
    if [ ! -d "$MODULE_DIR" ]; then
        echo "⚠️  Module '$MODULE' not found, skipping..."
        continue
    fi
    
    echo ""
    echo "🔧 Installing module: $MODULE"
    
    # 1. Merge MCP configuration if module has one
    MODULE_MCP_CONFIG="$MODULE_DIR/mcp-config.json"
    if [ -f "$MODULE_MCP_CONFIG" ]; then
        echo "   📝 Merging MCP configuration..."
        if command -v jq &> /dev/null; then
            # Merge the configurations
            jq -s '.[0].mcpServers * .[1].mcpServers | {mcpServers: .}' \
                "$MCP_CONFIG" "$MODULE_MCP_CONFIG" > "$MCP_CONFIG.tmp"
            mv "$MCP_CONFIG.tmp" "$MCP_CONFIG"
        else
            echo "   ⚠️  jq not found. Please manually merge:"
            echo "   $MODULE_MCP_CONFIG into $MCP_CONFIG"
        fi
    fi
    
    # 2. Copy module rules
    MODULE_RULES_DIR="$MODULE_DIR/rules"
    if [ -d "$MODULE_RULES_DIR" ]; then
        echo "   📋 Copying rules..."
        cp -r "$MODULE_RULES_DIR/"* "$PROJECT_ROOT/.cursor/rules/" 2>/dev/null || true
    fi
    
    # 3. Run module installation script if it exists
    MODULE_INSTALL="$MODULE_DIR/install.sh"
    if [ -f "$MODULE_INSTALL" ]; then
        echo "   🔨 Running module install script..."
        bash "$MODULE_INSTALL" "$PROJECT_ROOT"
    fi
    
    # 4. Install module dependencies if pyproject.toml exists
    MODULE_PYPROJECT="$MODULE_DIR/pyproject.toml"
    if [ -f "$MODULE_PYPROJECT" ]; then
        echo "   📦 Installing module dependencies..."
        cd "$MODULE_DIR"
        if command -v uv &> /dev/null; then
            uv sync
        else
            echo "   ⚠️  uv not found. Please install dependencies manually:"
            echo "   cd $MODULE_DIR && uv sync"
        fi
        cd "$SCRIPT_DIR"
    fi
    
    echo "   ✅ Module '$MODULE' installed"
done

# Copy cross-module rules
echo ""
echo "📋 Copying cross-module rules..."
if [ -d "$SCRIPT_DIR/rules" ]; then
    cp -r "$SCRIPT_DIR/rules/"* "$PROJECT_ROOT/.cursor/rules/" 2>/dev/null || true
fi

# Copy skills to main project
echo ""
echo "📚 Copying skills..."
if [ -d "$SCRIPT_DIR/.cursor/skills" ]; then
    for SKILL_DIR in "$SCRIPT_DIR/.cursor/skills"/*; do
        if [ -d "$SKILL_DIR" ]; then
            SKILL_NAME=$(basename "$SKILL_DIR")
            echo "   📖 Copying skill: $SKILL_NAME"
            cp -r "$SKILL_DIR" "$PROJECT_ROOT/.cursor/skills/" 2>/dev/null || true
        fi
    done
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Review and update .cursor/mcp.json if needed"
echo "2. Check module-specific requirements in modules/*/README.md"
echo "3. Restart Cursor to load new MCP servers and rules"
