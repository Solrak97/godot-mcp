# AutoTask MCP Bridge

MCP (Model Context Protocol) bridge that connects Cursor to the AutoTask FastAPI application.

## Installation

```bash
cd bridge
uv sync
```

## Configuration

Copy `.env.example` to `.env` and configure:

- `FASTAPI_URL`: URL of the FastAPI server (default: `http://localhost:8000`)
- `API_KEY`: Optional API key for authentication

## Usage

The bridge is configured in `.cursor/mcp.json` and runs automatically when Cursor starts.

To test manually:

```bash
uv run python -m bridge
```

## Scripts

### Complete-task workflow

`scripts/complete_task_workflow.py` runs: **fetch a task → update progress (in_progress) → complete (closed) → update progress again** (description).

```bash
cd bridge
uv run python scripts/complete_task_workflow.py
```

Requires the API (and Postgres) to be running. Use `FASTAPI_URL` if the API is elsewhere.

## Tools

The bridge exposes the following MCP tools:

- `create_task`: Create a new task
- `get_task`: Get a task by ID
- `list_tasks`: List all tasks (with optional status filter)
- `update_task`: Update a task
- `delete_task`: Delete a task
