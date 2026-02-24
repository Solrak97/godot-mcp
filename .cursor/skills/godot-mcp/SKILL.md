---
name: godot-mcp
description: Use Godot MCP tools to run, inspect, and edit Godot projects from Cursor. Use when working with Godot projects, .gd files, .tscn scenes, or when the user wants to run the game, inspect the scene tree, read logs, or edit node properties without opening the editor.
---

# Godot MCP

MCP tools for Godot editor integration. Requires the Godot MCP plugin enabled in the editor and the MCP server configured in Cursor.

## Project Layout

- **godot-plugin/**: Editor addon (HTTP API). Plugin path: `res://godot-plugin/plugin.cfg`
- **godot-mcp-server/**: Rust MCP bridge. Install with `./install.sh godot`

## Prerequisites

1. Godot editor open with the project
2. Godot MCP plugin enabled (Project > Project Settings > Plugins > Godot MCP)
3. MCP server installed: `./install.sh godot` from repo root
4. Cursor restarted after install

Plugin serves on `http://localhost:4242` (configurable in Editor Settings → godot_mcp/port).

## Available Tools

| Tool | Description |
|------|-------------|
| run_project | Play main scene |
| stop_project | Stop running game |
| get_output_log | Last N log lines (default 200) |
| get_last_errors | Parsed errors with file, line, message |
| get_scene_tree | Node paths + types |
| get_selected_nodes | Selected node paths |
| get_node_properties | Node properties (requires node_path) |
| set_node_property | Set property (path, property, value as JSON) |
| get_open_scenes | Open scene file paths |
| get_current_scene | Current edited scene path |

## Workflow

1. **Inspect**: Use `get_scene_tree` or `get_selected_nodes` to understand scene structure
2. **Edit**: Modify .gd / .tscn in Cursor, or use `set_node_property` for quick tweaks
3. **Run**: `run_project` to test
4. **Diagnose**: `get_output_log` or `get_last_errors` after running

## Notes

- Node paths are relative to root (e.g. `/Root/Player/Sprite`)
- For `set_node_property`, value must be valid JSON matching the property type
- Keep the Godot editor open when using tools
