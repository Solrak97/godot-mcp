# AutoTask Module

Integrates AutoTask MCP bridge for task management in Cursor projects.

## Features

- **Task Management**: Create, read, update, and delete tasks via MCP
- **Sprint Management**: List and get sprint information
- **Task Notes**: Add comments and notes to tasks
- **Filtering**: Filter tasks by status, kind, project, sprint, and date ranges

## Requirements

- AutoTask API running (default: `http://localhost:8000`)
- Python 3.11+ with `uv` package manager

The bridge is automatically installed to `.cursor/bridges/autotask` during module installation.

## MCP Tools

This module provides the following MCP tools:

- `create_task`: Create a new task
- `get_task`: Get a task by ID
- `list_tasks`: List all tasks with optional filters
- `update_task`: Update task properties
- `delete_task`: Delete a task
- `list_task_notes`: List notes for a task
- `create_task_note`: Add a note to a task
- `list_sprints`: List all sprints
- `get_sprint`: Get a sprint by ID

## Configuration

The MCP configuration assumes:
- Bridge is located at `.cursor/bridges/autotask` (installed automatically)
- AutoTask API is at `http://localhost:8000`

To customize, edit `.cursor/mcp.json` after installation.

## Usage

Once installed, you can use AutoTask tools in Cursor. The rules in `rules/autotask-mcp-usage.mdc` guide the AI on how to use these tools effectively.
