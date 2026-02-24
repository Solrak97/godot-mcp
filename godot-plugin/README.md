# Godot MCP Plugin

HTTP API addon for Godot 4 that exposes editor and runtime operations for MCP integration. Runs inside the Godot editor and serves requests from the Godot MCP server (Rust binary).

## Features

- **Run/Stop**: Play main scene, stop running game
- **Logs**: Output log and parsed errors
- **Scene inspection**: Scene tree, selected nodes, open scenes, current scene
- **Node editing**: Get/set node properties with undo support

## Installation

1. Copy the `godot-plugin` folder into your Godot project (e.g. as `addons/godot_mcp/` or keep at `godot-plugin/`)
2. Enable the plugin: Project > Project Settings > Plugins > Godot MCP
3. The HTTP server starts on port 4242 (configurable in Editor Settings → godot_mcp/port)

## Usage

Requires the [godot-mcp-server](../godot-mcp-server/) Rust binary and Cursor with MCP configured. The plugin runs inside Godot and serves HTTP; the MCP server forwards tool calls from Cursor to the plugin.
