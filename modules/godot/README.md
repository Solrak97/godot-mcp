# Godot MCP Module

MCP server bridge for the Godot editor. Enables Cursor to run the game, inspect scenes, read logs, and edit node properties via the Godot MCP plugin.

## Architecture

- **Part 1: Godot Plugin** (`addons/godot_mcp/`) - HTTP API running inside the editor
- **Part 2: MCP Bridge** (this module) - Rust stdio MCP server that forwards tool calls to Godot
- **Part 3: Cursor** - MCP client (built-in), configured via `.cursor/mcp.json`

## Installation

1. Enable the Godot MCP plugin in your Godot project (Project > Project Settings > Plugins)
2. Install this module: `./install.sh godot` (from the cursor_workflow root)
3. Restart Cursor

**Requirements:** Rust toolchain (`cargo`) for building the MCP server binary.

## Configuration

- `GODOT_API_URL` - Default `http://localhost:4242`. Set in `mcp.json` env.
- Plugin port can be changed in Editor Settings (`godot_mcp/port`).

## Tools (Phase 1)

| Tool | Description |
|------|-------------|
| run_project | Play main scene |
| stop_project | Stop running game |
| get_output_log | Last N log lines |
| get_last_errors | Parsed errors |
| get_scene_tree | Node paths + types |
| get_selected_nodes | Selected node paths |
| get_node_properties | Node properties |
| set_node_property | Set property |
| get_open_scenes | Open scene paths |
| get_current_scene | Current scene path |

## Manual Build

```bash
cd modules/godot
cargo build --release
# Binary: target/release/godot_mcp (or godot_mcp.exe on Windows)
```
