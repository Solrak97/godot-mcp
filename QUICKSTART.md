# Quick Start Guide

Get started with Cursor Workflow Setup in 5 minutes.

## Installation

### Step 1: Add as Submodule (Recommended)

```bash
# In your project root
git submodule add https://github.com/yourusername/cursor-workflow-setup.git .cursor/workflow-setup
cd .cursor/workflow-setup
./install.sh --all
```

### Step 2: Configure

Review `.cursor/mcp.json` and update paths if needed:
- AutoTask bridge path (if using AutoTask module)
- Git module path (automatically set, but verify)

### Step 3: Restart Cursor

Close and reopen Cursor to load the new MCP servers and rules.

## Using Modules

### AutoTask Module

```bash
# Ensure AutoTask API is running
cd /path/to/autotask/api
uv run uvicorn app.main:app --reload

# In Cursor, you can now use AutoTask MCP tools
```

### Git Module

The Git module works automatically. Try:
- `git_status`: Check repository status
- `git_commit`: Create commits
- `git_log`: View history

### Auto-Commit on Task Close

When you close an AutoTask task, a commit is automatically created with a descriptive message.

## Troubleshooting

### MCP Server Not Loading

1. Check `.cursor/mcp.json` syntax
2. Verify paths are correct
3. Ensure dependencies are installed (`uv sync` in module directories)
4. Check Cursor's MCP server logs

### Module Not Found

1. Verify module is in `modules/` directory
2. Check install script ran successfully
3. Review module's README for requirements

### Path Issues

If paths are incorrect:
1. Update `.cursor/mcp.json` manually
2. Or re-run `./install.sh` for the specific module

## Next Steps

- Read module-specific documentation in `modules/*/README.md`
- Customize rules in `.cursor/rules/`
- Create your own modules using `modules/.template/` as a guide
