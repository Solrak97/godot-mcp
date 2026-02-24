# Cursor Workflow

A modular, reusable Cursor project setup system for integrating MCP tools, workflows, and automation into new projects.

## Philosophy

This is a **modular workflow system** that allows you to easily add tools and workflows to any Cursor project. Each module is self-contained and can be enabled/disabled independently.

## Quick Start

```bash
# Add as submodule
git submodule add <repo-url> .cursor/cursor_workflow
cd .cursor/cursor_workflow
./setup.sh
```

The setup script will:
- Install all modules
- Configure MCP servers
- Copy rules
- Install dependencies
- Verify installation

## Available Modules

### 🔧 Core Modules

- **autotask**: AutoTask MCP bridge integration for task management
- **git**: Git MCP server for automated version control operations
- **autotask-plugin**: AutoTask plugin with connectivity checking and "start building features" workflow
- **godot**: Godot MCP server (Rust) + Godot plugin for Cursor integration—see `godot-mcp-server/` and `godot-plugin/`

### 📦 Adding New Modules

Modules are located in `modules/` and follow a standard structure:
- `mcp-config.json`: MCP server configuration (if applicable)
- `rules/`: Cursor rules specific to this module
- `scripts/`: Installation or setup scripts
- `README.md`: Module documentation

## Installation

### Option 1: As a Git Submodule (Recommended)

```bash
# In your project root
git submodule add https://github.com/yourusername/cursor_workflow.git .cursor/cursor_workflow
cd .cursor/cursor_workflow
./setup.sh
```

### Option 2: Manual Installation

```bash
# Clone or copy this repository
git clone https://github.com/yourusername/cursor_workflow.git .cursor/cursor_workflow
cd .cursor/cursor_workflow
./setup.sh
# Or install specific modules:
./install.sh [module1] [module2] ...
```

### Selective Module Installation

```bash
# Install only specific modules
./install.sh autotask git autotask-plugin

# Install all modules
./install.sh --all
```

## Module Details

### AutoTask Module

Integrates AutoTask MCP bridge for task management.

**Features:**
- Task CRUD operations via MCP
- Sprint and project management
- Task notes and comments

**Requirements:**
- AutoTask API running (default: `http://localhost:8000`)
- Bridge directory in project root

### Git Module

Provides Git operations via MCP for automated version control.

**Features:**
- `git_commit`: Create commits with messages
- `git_status`: Check repository status
- `git_diff`: View changes
- `git_log`: View commit history
- Auto-commit on task completion (when AutoTask module is enabled)

**Requirements:**
- Git installed and configured
- Python 3.11+ with `uv`

### AutoTask Plugin Module

Provides AutoTask integration with connectivity checking and feature building workflows.

**Features:**
- Connectivity verification to AutoTask server
- "Start building features" command workflow
- Task selection and management
- Integration with AutoTask MCP bridge

**Requirements:**
- AutoTask API running (default: `http://localhost:8000`)
- Bridge directory in project root
- AutoTask MCP bridge configured

## Project Structure

```
cursor_workflow/
├── README.md
├── setup.sh              # Complete setup script
├── install.sh            # Module installation script
├── godot-mcp-server/     # Rust MCP server for Godot (./install.sh godot)
├── godot-plugin/         # Godot editor addon (HTTP API)
├── modules/
│   ├── autotask/
│   │   ├── mcp-config.json
│   │   ├── rules/
│   │   │   └── autotask-mcp-usage.mdc
│   │   └── README.md
│   ├── git/
│   │   ├── mcp-config.json
│   │   ├── pyproject.toml
│   │   ├── git_mcp/
│   │   │   ├── __init__.py
│   │   │   ├── __main__.py
│   │   │   ├── server.py
│   │   │   └── tools.py
│   │   ├── rules/
│   │   │   └── git-workflow.mdc
│   │   └── README.md
│   ├── autotask-plugin/
│   │   ├── rules/
│   │   │   └── autotask-plugin-usage.mdc
│   │   └── README.md
│   └── .template/
│       └── README.md          # Template for new modules
├── rules/
│   └── auto-commit-on-task-close.mdc  # Cross-module rules
└── .cursor/
    └── skills/
        └── cursor_workflow_tools.md   # Cursor skill documentation
```

## Using the Tools

### In Cursor

Once installed, you can use the MCP tools directly:

- **Task Management**: "Create a task for X", "List open tasks", "Close task [id]"
- **Git Operations**: "Check git status", "Commit with message '...'", "Show diff"
- **Combined**: "Complete task [id]" → Closes task and auto-commits

### Cursor Skills

The system includes Cursor skills that are automatically copied to `.cursor/skills/` during installation:

- **cursor-workflow-tools**: Documents all available MCP tools, provides usage examples and workflows, guides the AI on when and how to use the tools
- **cursor-workflow-installation**: Complete guide for installing and setting up cursor_workflow in a Cursor project
- **autotask-installation**: Guide for setting up AutoTask from scratch (if autotask-installation skill is included)
- **project-startup**: Project kickoff flow—asks what to build, how to build it, tech and scope; use on open or "what should we build"
- **git-setup**: One-time git account setup (user.name, user.email); includes commit script for commits with messages when not using Git MCP

Skills are automatically available once installed and help Cursor understand what tools are available and how to use them.

**Installation Command**: Use the `cursor-workflow-installation` skill or run:
```bash
cd .cursor/cursor_workflow && ./setup.sh
```

## Creating a New Module

1. Create a new directory in `modules/your-module/`
2. Add `mcp-config.json` if your module provides an MCP server
3. Add `rules/` directory with any Cursor rules
4. Add `README.md` documenting your module
5. Update this README to list your module

See `modules/.template/README.md` for a module template.

## Configuration

After installation, review and customize:
- `.cursor/mcp.json`: MCP server configurations
- `.cursor/rules/`: Project-specific rules

## Requirements

- Python 3.11+ with `uv` package manager (for modules that need it)
- Git installed and configured
- Cursor IDE

## License

MIT
