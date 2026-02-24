import subprocess
import json
from pathlib import Path
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

def get_tools() -> List[Tool]:
    """Return list of available Git MCP tools"""
    return [
        Tool(
            name="git_status",
            description="Get the current git repository status (staged, unstaged, untracked files)",
            inputSchema={
                "type": "object",
                "properties": {},
            }
        ),
        Tool(
            name="git_diff",
            description="Show changes between working directory and staging area, or between commits",
            inputSchema={
                "type": "object",
                "properties": {
                    "staged": {
                        "type": "boolean",
                        "description": "Show staged changes (default: false, shows unstaged)",
                        "default": False
                    },
                    "commit": {
                        "type": "string",
                        "description": "Show diff for specific commit (optional)"
                    }
                }
            }
        ),
        Tool(
            name="git_commit",
            description="Create a commit with the given message. Automatically stages all changes if there are any.",
            inputSchema={
                "type": "object",
                "properties": {
                    "message": {
                        "type": "string",
                        "description": "Commit message (required)"
                    },
                    "stage_all": {
                        "type": "boolean",
                        "description": "Stage all changes before committing (default: true)",
                        "default": True
                    }
                },
                "required": ["message"]
            }
        ),
        Tool(
            name="git_log",
            description="Show commit history. Returns recent commits with messages.",
            inputSchema={
                "type": "object",
                "properties": {
                    "limit": {
                        "type": "integer",
                        "description": "Number of commits to show (default: 10)",
                        "default": 10
                    },
                    "oneline": {
                        "type": "boolean",
                        "description": "Show one line per commit (default: true)",
                        "default": True
                    }
                }
            }
        ),
        Tool(
            name="git_branch",
            description="List branches or get current branch name",
            inputSchema={
                "type": "object",
                "properties": {
                    "current": {
                        "type": "boolean",
                        "description": "Get only the current branch name (default: false, lists all)",
                        "default": False
                    }
                }
            }
        )
    ]

async def handle_tool_call(tool_name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle tool execution and return results"""
    try:
        # Find git repository root
        repo_root = find_git_root()
        if not repo_root:
            return [TextContent(
                type="text",
                text="Error: Not in a git repository"
            )]
        
        if tool_name == "git_status":
            result = run_git_command(repo_root, ["status", "--porcelain"])
            if not result.strip():
                return [TextContent(
                    type="text",
                    text="Working directory clean. No changes."
                )]
            return [TextContent(
                type="text",
                text=f"Git status:\n{result}"
            )]
        
        elif tool_name == "git_diff":
            staged = arguments.get("staged", False)
            commit = arguments.get("commit")
            
            if commit:
                result = run_git_command(repo_root, ["diff", commit])
            elif staged:
                result = run_git_command(repo_root, ["diff", "--staged"])
            else:
                result = run_git_command(repo_root, ["diff"])
            
            if not result.strip():
                return [TextContent(
                    type="text",
                    text="No differences found."
                )]
            return [TextContent(
                type="text",
                text=f"Git diff:\n{result}"
            )]
        
        elif tool_name == "git_commit":
            message = arguments["message"]
            stage_all = arguments.get("stage_all", True)
            
            if stage_all:
                # Check if there are changes to stage
                status = run_git_command(repo_root, ["status", "--porcelain"])
                if status.strip():
                    run_git_command(repo_root, ["add", "-A"])
            
            result = run_git_command(repo_root, ["commit", "-m", message])
            return [TextContent(
                type="text",
                text=f"Commit created successfully:\n{result}"
            )]
        
        elif tool_name == "git_log":
            limit = arguments.get("limit", 10)
            oneline = arguments.get("oneline", True)
            
            cmd = ["log", f"-{limit}"]
            if oneline:
                cmd.append("--oneline")
            
            result = run_git_command(repo_root, cmd)
            if not result.strip():
                return [TextContent(
                    type="text",
                    text="No commits found."
                )]
            return [TextContent(
                type="text",
                text=f"Git log:\n{result}"
            )]
        
        elif tool_name == "git_branch":
            current_only = arguments.get("current", False)
            
            if current_only:
                result = run_git_command(repo_root, ["branch", "--show-current"])
            else:
                result = run_git_command(repo_root, ["branch", "-a"])
            
            return [TextContent(
                type="text",
                text=f"Branches:\n{result}"
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

def find_git_root(start_path: Path = None) -> Path:
    """Find the git repository root by walking up the directory tree"""
    if start_path is None:
        start_path = Path.cwd()
    
    current = Path(start_path).resolve()
    
    while current != current.parent:
        if (current / ".git").exists():
            return current
        current = current.parent
    
    return None

def run_git_command(repo_root: Path, args: List[str]) -> str:
    """Run a git command and return the output"""
    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        raise Exception(f"Git command failed: {e.stderr}")
