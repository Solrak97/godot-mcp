# Project Summary

## Overview

**Cursor Workflow Setup** is a modular, reusable system for adding MCP tools, workflows, and automation to any Cursor project. It's designed to be easily integrated as a git submodule and provides a plugin-like architecture for adding new capabilities.

## Architecture

### Modular Design

- **Modules**: Self-contained packages in `modules/` directory
- **Cross-module Rules**: Shared workflows in `rules/` directory
- **Installation Script**: Handles module installation and configuration merging

### Current Modules

1. **autotask**: AutoTask MCP bridge integration
   - Task management via MCP
   - Sprint and project support
   - Task notes and comments

2. **git**: Git operations via MCP
   - Status, diff, log, branch operations
   - Automated commit creation
   - Integration with AutoTask for auto-commits

### Key Features

- **Modular**: Add/remove modules independently
- **Extensible**: Easy to create new modules using template
- **Auto-configuration**: Merges MCP configs automatically
- **Cross-module workflows**: Rules that work across modules (e.g., auto-commit on task close)

## File Structure

```
cursor-workflow-setup/
├── README.md                    # Main documentation
├── QUICKSTART.md                # Quick start guide
├── install.sh                   # Main installation script
├── .gitignore                   # Git ignore rules
├── modules/
│   ├── autotask/                # AutoTask module
│   │   ├── mcp-config.json      # MCP server config
│   │   ├── README.md            # Module docs
│   │   └── rules/               # Module-specific rules
│   ├── git/                     # Git module
│   │   ├── git_mcp/             # MCP server implementation
│   │   ├── mcp-config.json      # MCP server config
│   │   ├── pyproject.toml       # Python dependencies
│   │   ├── install.sh           # Module install script
│   │   ├── README.md            # Module docs
│   │   └── rules/               # Module-specific rules
│   └── .template/               # Template for new modules
├── rules/                       # Cross-module rules
│   └── auto-commit-on-task-close.mdc
└── .cursor/                     # (Created during install)
    ├── mcp.json                 # Merged MCP configuration
    └── rules/                   # Copied rules
```

## Installation Flow

1. User adds as submodule or clones repo
2. Runs `./install.sh [modules]` or `./install.sh --all`
3. Script:
   - Creates `.cursor/` directories
   - Merges MCP configurations
   - Copies rules
   - Runs module-specific install scripts
   - Installs Python dependencies
4. User reviews `.cursor/mcp.json`
5. User restarts Cursor

## Module Development

To create a new module:

1. Copy `modules/.template/` to `modules/your-module/`
2. Add `mcp-config.json` if providing MCP server
3. Add `rules/` with module-specific rules
4. Add `install.sh` if custom setup needed
5. Add `pyproject.toml` if Python dependencies needed
6. Document in `README.md`
7. Update main `README.md` to list the module

## Integration Points

- **MCP Configuration**: Merged into `.cursor/mcp.json`
- **Rules**: Copied to `.cursor/rules/`
- **Dependencies**: Installed via `uv` in module directory
- **Paths**: Resolved relative to project root

## Future Enhancements

Potential additions:
- More modules (database, testing, deployment, etc.)
- Module dependency system
- Configuration validation
- Module update mechanism
- Health checks for MCP servers
