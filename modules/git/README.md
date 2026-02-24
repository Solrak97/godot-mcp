# Git Module

Provides Git operations via MCP for automated version control in Cursor projects.

## Features

- **Status Checking**: View repository status
- **Diff Viewing**: See changes in working directory or between commits
- **Commit Creation**: Automatically stage and commit changes
- **History Viewing**: Browse commit history
- **Branch Management**: List branches and get current branch

## Requirements

- Git installed and configured
- Python 3.11+ with `uv` package manager

## MCP Tools

This module provides the following MCP tools:

- `git_status`: Get current repository status
- `git_diff`: Show changes (staged, unstaged, or for a commit)
- `git_commit`: Create a commit with a message (auto-stages by default)
- `git_log`: View commit history
- `git_branch`: List branches or get current branch

## Configuration

The MCP server runs from the module directory. The path in `mcp-config.json` is relative to the project root where this module is installed.

## Usage

Once installed, you can use Git tools in Cursor. The rules in `rules/git-workflow.mdc` guide the AI on how to use these tools effectively.

## Auto-Approval

The following tools are auto-approved (no user confirmation needed):
- `git_status`
- `git_diff`
- `git_log`

The `git_commit` tool requires approval by default for safety.

## Integration with AutoTask

When the AutoTask module is also installed, the auto-commit-on-task-close rule will automatically create commits when tasks are completed.
