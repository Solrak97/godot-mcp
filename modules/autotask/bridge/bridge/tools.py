from mcp.types import Tool, TextContent
from typing import Any, Dict
from bridge.client import FastAPIClient

# Initialize client
client = FastAPIClient()

def get_tools() -> list[Tool]:
    """Return list of available MCP tools"""
    return [
        Tool(
            name="create_project",
            description="Create a new project. Use this to set up a project before creating tasks.",
            inputSchema={
                "type": "object",
                "properties": {
                    "name": {"type": "string", "description": "Project name (required)"},
                    "description": {"type": "string", "description": "Project description (optional)"}
                },
                "required": ["name"]
            }
        ),
        Tool(
            name="list_projects",
            description="List all projects",
            inputSchema={"type": "object", "properties": {}}
        ),
        Tool(
            name="get_project",
            description="Get a project by its ID",
            inputSchema={
                "type": "object",
                "properties": {"id": {"type": "string", "description": "Project UUID"}},
                "required": ["id"]
            }
        ),
        Tool(
            name="create_task",
            description="Create a new task with title, description, kind (task/feature/epic), status, optional points, and optional project_id",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string", "description": "Task title (required)"},
                    "description": {"type": "string", "description": "Task description (optional)"},
                    "kind": {
                        "type": "string",
                        "enum": ["task", "feature", "epic"],
                        "description": "Task kind: task (default), feature, or epic",
                        "default": "task"
                    },
                    "status": {
                        "type": "string",
                        "enum": ["open", "in_progress", "blocked", "closed"],
                        "description": "Task status (default: open)",
                        "default": "open"
                    },
                    "points": {"type": "integer", "description": "Optional story points (non-negative integer)"},
                    "project_id": {"type": "string", "description": "Project UUID to assign the task to (optional)"}
                },
                "required": ["title"]
            }
        ),
        Tool(
            name="get_task",
            description="Get a task by its ID",
            inputSchema={
                "type": "object",
                "properties": {
                    "id": {
                        "type": "string",
                        "description": "Task UUID"
                    }
                },
                "required": ["id"]
            }
        ),
        Tool(
            name="list_tasks",
            description="List all tasks, optionally filtered by status, kind, project_id, sprint_id, and/or date range (created_after, created_before, updated_after, updated_before; use YYYY-MM-DD or ISO datetime)",
            inputSchema={
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["open", "in_progress", "blocked", "closed"],
                        "description": "Filter tasks by status (optional)"
                    },
                    "kind": {
                        "type": "string",
                        "enum": ["task", "feature", "epic", "issue"],
                        "description": "Filter tasks by kind (optional)"
                    },
                    "project_id": {
                        "type": "string",
                        "description": "Filter tasks by project UUID (optional)"
                    },
                    "sprint_id": {
                        "type": "string",
                        "description": "Filter tasks by sprint UUID (optional)"
                    },
                    "created_after": {
                        "type": "string",
                        "description": "Filter: created_at >= this date (YYYY-MM-DD or ISO datetime) (optional)"
                    },
                    "created_before": {
                        "type": "string",
                        "description": "Filter: created_at <= this date (YYYY-MM-DD or ISO datetime) (optional)"
                    },
                    "updated_after": {
                        "type": "string",
                        "description": "Filter: updated_at >= this date (YYYY-MM-DD or ISO datetime) (optional)"
                    },
                    "updated_before": {
                        "type": "string",
                        "description": "Filter: updated_at <= this date (YYYY-MM-DD or ISO datetime) (optional)"
                    }
                }
            }
        ),
        Tool(
            name="update_task",
            description="Update a task's title, description, kind (task/feature/epic/issue), status, or points",
            inputSchema={
                "type": "object",
                "properties": {
                    "id": {
                        "type": "string",
                        "description": "Task UUID"
                    },
                    "title": {
                        "type": "string",
                        "description": "New task title (optional)"
                    },
                    "description": {
                        "type": "string",
                        "description": "New task description (optional)"
                    },
                    "kind": {
                        "type": "string",
                        "enum": ["task", "feature", "epic", "issue"],
                        "description": "New task kind (optional)"
                    },
                    "status": {
                        "type": "string",
                        "enum": ["open", "in_progress", "blocked", "closed"],
                        "description": "New task status (optional)"
                    },
                    "points": {
                        "type": "integer",
                        "description": "New story points (optional, non-negative integer)"
                    }
                },
                "required": ["id"]
            }
        ),
        Tool(
            name="delete_task",
            description="Delete a task by its ID",
            inputSchema={
                "type": "object",
                "properties": {
                    "id": {
                        "type": "string",
                        "description": "Task UUID"
                    }
                },
                "required": ["id"]
            }
        ),
        Tool(
            name="list_task_notes",
            description="List notes/comments for a task",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "string",
                        "description": "Task UUID"
                    }
                },
                "required": ["task_id"]
            }
        ),
        Tool(
            name="create_task_note",
            description="Add a note or comment to a task",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "string",
                        "description": "Task UUID"
                    },
                    "content": {
                        "type": "string",
                        "description": "Note content (required)"
                    },
                    "author": {
                        "type": "string",
                        "description": "Author name (optional)"
                    }
                },
                "required": ["task_id", "content"]
            }
        ),
        Tool(
            name="list_sprints",
            description="List all sprints, optionally filtered by project_id",
            inputSchema={
                "type": "object",
                "properties": {
                    "project_id": {
                        "type": "string",
                        "description": "Filter sprints by project UUID (optional)"
                    }
                }
            }
        ),
        Tool(
            name="get_sprint",
            description="Get a sprint by its ID",
            inputSchema={
                "type": "object",
                "properties": {
                    "id": {
                        "type": "string",
                        "description": "Sprint UUID"
                    }
                },
                "required": ["id"]
            }
        )
    ]

async def handle_tool_call(tool_name: str, arguments: Dict[str, Any]) -> list[TextContent]:
    """Handle tool execution and return results"""
    try:
        if tool_name == "create_project":
            result = await client.create_project(
                name=arguments["name"],
                description=arguments.get("description"),
            )
            return [TextContent(type="text", text=f"Project created successfully: {result}")]
        if tool_name == "list_projects":
            result = await client.list_projects()
            return [TextContent(type="text", text=f"Projects: {result}")]
        if tool_name == "get_project":
            result = await client.get_project(arguments["id"])
            return [TextContent(type="text", text=f"Project: {result}")]
        if tool_name == "create_task":
            result = await client.create_task(
                title=arguments["title"],
                description=arguments.get("description"),
                kind=arguments.get("kind"),
                status=arguments.get("status", "open"),
                points=arguments.get("points"),
                project_id=arguments.get("project_id"),
            )
            return [TextContent(
                type="text",
                text=f"Task created successfully: {result}"
            )]
        
        elif tool_name == "get_task":
            result = await client.get_task(arguments["id"])
            return [TextContent(
                type="text",
                text=f"Task: {result}"
            )]
        
        elif tool_name == "list_tasks":
            result = await client.list_tasks(
                status=arguments.get("status"),
                kind=arguments.get("kind"),
                project_id=arguments.get("project_id"),
                sprint_id=arguments.get("sprint_id"),
                created_after=arguments.get("created_after"),
                created_before=arguments.get("created_before"),
                updated_after=arguments.get("updated_after"),
                updated_before=arguments.get("updated_before")
            )
            return [TextContent(
                type="text",
                text=f"Tasks: {result}"
            )]
        
        elif tool_name == "update_task":
            result = await client.update_task(
                task_id=arguments["id"],
                title=arguments.get("title"),
                description=arguments.get("description"),
                kind=arguments.get("kind"),
                status=arguments.get("status"),
                points=arguments.get("points")
            )
            return [TextContent(
                type="text",
                text=f"Task updated successfully: {result}"
            )]
        
        elif tool_name == "delete_task":
            await client.delete_task(arguments["id"])
            return [TextContent(
                type="text",
                text=f"Task {arguments['id']} deleted successfully"
            )]
        
        elif tool_name == "list_task_notes":
            result = await client.list_task_notes(arguments["task_id"])
            return [TextContent(
                type="text",
                text=f"Notes: {result}"
            )]
        
        elif tool_name == "create_task_note":
            result = await client.create_task_note(
                task_id=arguments["task_id"],
                content=arguments["content"],
                author=arguments.get("author")
            )
            return [TextContent(
                type="text",
                text=f"Note added: {result}"
            )]
        
        elif tool_name == "list_sprints":
            result = await client.list_sprints(project_id=arguments.get("project_id"))
            return [TextContent(
                type="text",
                text=f"Sprints: {result}"
            )]
        
        elif tool_name == "get_sprint":
            result = await client.get_sprint(arguments["id"])
            return [TextContent(
                type="text",
                text=f"Sprint: {result}"
            )]
        
        else:
            return [TextContent(
                type="text",
                text=f"Unknown tool: {tool_name}"
            )]
    
    except Exception as e:
        return [TextContent(
            type="text",
            text=f"Error executing {tool_name}: {str(e)}"
        )]
