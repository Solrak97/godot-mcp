---
name: cursor-workflow-installation
description: Guide for installing and setting up the cursor_workflow system in a Cursor project. Use when the user wants to install cursor_workflow, set up MCP tools, add workflow modules, or when they ask about installing the cursor workflow system.
---

# Cursor Workflow Installation

Complete guide for installing and setting up the cursor_workflow system in your Cursor project.

## What is Cursor Workflow?

Cursor Workflow is a modular system that provides MCP tools, workflows, and automation for Cursor projects. It includes modules for:
- **AutoTask**: Task management via MCP bridge
- **Git**: Automated version control operations
- **AutoTask Plugin**: Enhanced feature building workflows

## Installation Methods

### Option 1: As a Git Submodule (Recommended)

If cursor_workflow is a git repository:

```bash
# In your project root
git submodule add <repo-url> .cursor/cursor_workflow
cd .cursor/cursor_workflow
./setup.sh
```

### Option 2: Manual Installation

If you have the cursor_workflow directory already:

```bash
# Navigate to cursor_workflow directory
cd .cursor/cursor_workflow
./setup.sh
```

### Option 3: Selective Module Installation

Install only specific modules:

```bash
cd .cursor/cursor_workflow
./install.sh autotask git autotask-plugin
```

Or install all modules:

```bash
cd .cursor/cursor_workflow
./install.sh --all
```

## Prerequisites

Before installation, ensure you have:

- **Git**: For submodule management (if using submodule method)
- **uv**: Python package manager (required for Python-based modules)
- **jq**: JSON processor (recommended for config merging, optional)

**Check prerequisites:**
```bash
git --version
uv --version
jq --version  # Optional but recommended
```

## Installation Steps

### Step 1: Navigate to cursor_workflow

```bash
cd .cursor/cursor_workflow
```

### Step 2: Run Setup Script

```bash
./setup.sh
```

This will:
- Check prerequisites
- Install all modules
- Merge MCP configurations
- Copy rules to `.cursor/rules/`
- Install module dependencies
- Verify installation

### Step 3: Verify Installation

Check that configuration files were created:

```bash
# Check MCP configuration
cat ../mcp.json

# Check rules were copied
ls ../rules/
```

### Step 4: Restart Cursor

**Important**: Restart Cursor completely to load:
- New MCP servers
- New rules
- Updated configuration

## Module-Specific Requirements

### AutoTask Module

- AutoTask API running (default: `http://localhost:8000`)
- Bridge directory in project root at `bridge/`
- Bridge dependencies installed: `cd bridge && uv sync`

### Git Module

- Git installed and configured
- Python 3.11+ with `uv` package manager

### AutoTask Plugin Module

- AutoTask module must be installed first
- AutoTask MCP bridge configured in `.cursor/mcp.json`
- AutoTask API running

## Configuration

After installation, review and customize:

### MCP Configuration

Edit `.cursor/mcp.json` to:
- Update server paths if needed
- Adjust environment variables
- Configure auto-approval settings

### Rules

Rules are copied to `.cursor/rules/`. You can:
- Review module-specific rules
- Customize rules for your project
- Add project-specific rules

## Verification

### Check MCP Servers

```bash
# View configured servers
cat .cursor/mcp.json | jq '.mcpServers | keys'
```

### Test MCP Tools

In Cursor, try using MCP tools:
- "List all open tasks" (if AutoTask module installed)
- "Check git status" (if Git module installed)

### Check Rules

```bash
# List installed rules
ls .cursor/rules/*.mdc
```

## Troubleshooting

### MCP Servers Not Available

1. **Check configuration**: Verify `.cursor/mcp.json` exists and is valid JSON
2. **Check paths**: Ensure module paths in config are correct (relative to project root)
3. **Check dependencies**: Install module dependencies: `cd modules/[module] && uv sync`
4. **Restart Cursor**: Fully restart Cursor (not just reload window)

### Rules Not Applied

1. **Check rules directory**: Verify `.cursor/rules/` exists and contains `.mdc` files
2. **Check file format**: Rules must be `.mdc` files with proper frontmatter
3. **Restart Cursor**: Rules are loaded on startup

### Module Installation Fails

1. **Check prerequisites**: Ensure `uv` is installed for Python modules
2. **Check paths**: Verify module directories exist in `modules/`
3. **Check permissions**: Ensure install scripts are executable: `chmod +x install.sh`
4. **Manual installation**: Try installing modules individually to identify issues

### jq Not Found (Config Merging)

If `jq` is not installed, MCP config merging will be skipped. You can:
- Install jq: `brew install jq` (macOS) or `apt-get install jq` (Linux)
- Manually merge MCP configurations from `modules/*/mcp-config.json` into `.cursor/mcp.json`

## Quick Installation Command

For a quick reference, the installation command is:

```bash
cd .cursor/cursor_workflow && ./setup.sh
```

Or for specific modules:

```bash
cd .cursor/cursor_workflow && ./install.sh [module1] [module2] ...
```

## Post-Installation

After successful installation:

1. ✅ Review `.cursor/mcp.json` configuration
2. ✅ Check module requirements in `modules/*/README.md`
3. ✅ Restart Cursor completely
4. ✅ Test MCP tools in Cursor
5. ✅ Use the "Start Building Features" command (if AutoTask plugin installed)

## Available Commands

After installation, these commands are available in Cursor:

- **Start Building Features**: Check connectivity and begin working on tasks (requires AutoTask plugin)
- **Complete Task**: Complete a task and auto-commit (requires AutoTask and Git modules)

## Next Steps

- Read module documentation: `modules/*/README.md`
- Review available MCP tools in the cursor-workflow-tools skill
- Start using workflows in your development process
