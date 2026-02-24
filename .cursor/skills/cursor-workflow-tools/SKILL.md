---
name: cursor-workflow-tools
description: Use MCP tools and workflows from the cursor_workflow system for task management, git operations, and automated workflows. Use when working with AutoTask tasks, git operations, Godot projects, or when the user mentions task management, commits, automated workflows, or Godot MCP.
---

# Cursor Workflow Tools

This skill enables you to use the MCP tools and workflows provided by the cursor_workflow system installed in this project.

## Quick Reference

The cursor_workflow system provides modular MCP tools accessible through Cursor. Check `.cursor/mcp.json` to see which servers are configured.

## Available MCP Tools

### AutoTask Tools (if autotask module installed)

- **create_task**: Create new tasks
  - Parameters: `title` (required), `description`, `kind` (task/feature/epic), `status`, `points`
- **get_task**: Get task by ID
- **list_tasks**: List tasks with filters (status, kind, project_id, sprint_id, dates)
- **update_task**: Update task properties
- **delete_task**: Delete a task
- **list_task_notes**: View task notes
- **create_task_note**: Add a note to a task
- **list_sprints**: List sprints
- **get_sprint**: Get sprint details

### Git Tools (if git module installed)

- **git_status**: Check repository status
- **git_diff**: View changes (staged/unstaged/commit)
- **git_commit**: Create commits (auto-stages by default)
- **git_log**: View commit history
- **git_branch**: List branches or get current branch

### Godot MCP Tools (if godot module installed; skill: godot-mcp)

- **run_project**, **stop_project**: Play/stop the game
- **get_output_log**, **get_last_errors**: Logs and errors
- **get_scene_tree**, **get_selected_nodes**, **get_node_properties**: Scene inspection
- **set_node_property**: Edit node properties
- **get_open_scenes**, **get_current_scene**: Open/current scene

Use the **godot-mcp** skill when working with Godot projects, .gd files, .tscn scenes, or running/inspecting the game.

### Git Setup (skill: git-setup)

- **One-time account setup**: When the user asks to set up git or when `user.name`/`user.email` are unset, use the **git-setup** skill to ask for name and email, then run `git config [--global] user.name` and `git config [--global] user.email`.
- **Commits**: Prefer the **git_commit** MCP tool. If not using MCP, run the commit script from repo root: `bash .cursor/skills/git-setup/scripts/commit.sh "message"` (or from submodule path `.cursor/cursor_workflow/.cursor/skills/git-setup/scripts/commit.sh`).

## AutoTask Plugin (if autotask-plugin module installed)

The AutoTask plugin provides enhanced workflows for building features:

- **Start Building Features**: Use the `start-building-features` command to:
  1. Check connectivity to AutoTask server via MCP bridge
  2. List available open tasks
  3. Select highest priority unblocked task
  4. Begin implementation by updating task to `in_progress`

The plugin includes connectivity checking and automatic task selection based on priority and dependencies.

## Common Workflows

### Start Building Features Workflow

1. **Check Connectivity**: Verify AutoTask server is reachable via MCP bridge
2. **List Tasks**: Get all open, unblocked tasks
3. **Select Task**: Choose highest priority task with no unclosed dependencies
4. **Begin Work**: Update task status to `in_progress` and start implementation
5. **Complete**: Update status to `closed` - triggers auto-commit if git module is installed

### Task Management Workflow

1. **Create Task**: Use `create_task` with title and description
2. **Start Work**: Update task status to `in_progress` with `update_task`
3. **Add Notes**: Use `create_task_note` to document progress
4. **Complete**: Update status to `closed` - this triggers auto-commit if git module is installed

### Git Workflow

1. **Ensure identity set**: If first time or user asked to set up git, run **git-setup** skill (ask name, email, repo vs global; then `git config`).
2. **Check Status**: Use `git_status` to see changes
3. **Review Changes**: Use `git_diff` to see what changed
4. **Commit**: Use `git_commit` with descriptive message, or run `scripts/commit.sh "message"` from repo root
5. **View History**: Use `git_log` to see recent commits

### Auto-Commit on Task Close

When you close a task (status → `closed`):
- System automatically checks for changes
- Stages all changes
- Creates commit with message: `feat: [Task Title] - [Description]`

## Usage Examples

**Create and manage tasks**:
- "Create a task for implementing user authentication"
- "List all open tasks"
- "Update task [id] to in_progress"
- "Close task [id]" (auto-commits if changes exist)

**Git setup and operations**:
- "Set up my git account" / "Configure git" → use git-setup skill (name, email, scope)
- "Check git status"
- "Show me the diff"
- "Commit with message 'feat: add login form'" (use git_commit or commit script)
- "Show last 5 commits"

**Combined**:
- "Complete task [id]" → Closes task and commits changes
- "Start working on task [id]" → Sets to in_progress
- "Start building features" → Checks connectivity, selects task, begins work

## When to Use

Use these tools when:
- Managing tasks in AutoTask
- Creating git commits
- Automating workflows between task management and version control
- Need to check repository status or view changes
- Want to automate commit creation when completing work

## Prerequisites

- Modules must be installed via `./setup.sh` or `./install.sh [modules]`
- AutoTask module requires: AutoTask API running, bridge directory
- AutoTask plugin requires: AutoTask module installed, MCP bridge configured
- Git module requires: Git installed, Python 3.11+ with uv

## Configuration

- MCP servers configured in: `.cursor/mcp.json`
- Rules and workflows in: `.cursor/rules/`
- Module documentation in: `modules/*/README.md`

## Troubleshooting

If tools aren't available:
1. Check `.cursor/mcp.json` exists and is valid
2. Verify MCP server paths are correct
3. Ensure dependencies installed: `cd modules/[module] && uv sync`
4. Restart Cursor after installation

For module-specific issues, see `modules/[module]/README.md`.
