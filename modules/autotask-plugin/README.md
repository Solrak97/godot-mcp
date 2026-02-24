# AutoTask Plugin Module

Provides AutoTask integration and connectivity checking for Cursor IDE. This plugin enables seamless connection to the AutoTask server via the MCP bridge and provides a "start building features" workflow.

## Features

- **Connectivity Check**: Verifies connection to AutoTask server via MCP bridge
- **Start Building Features**: Command to begin working on tasks from AutoTask
- **AutoTask Integration**: Rules and workflows for using AutoTask in Cursor

## Requirements

- AutoTask API running (default: `http://localhost:8000`)
- Bridge directory in project root at `bridge/`
- AutoTask MCP bridge configured in `.cursor/mcp.json`

## Usage

Once installed, you can use the "Start Building Features" command to:
1. Check connectivity to AutoTask server
2. List available open tasks
3. Begin working on features from your AutoTask backlog

## Configuration

The plugin uses the AutoTask MCP bridge configuration from `.cursor/mcp.json`. Ensure the bridge is properly configured and the AutoTask API is running.

## Rules

The module includes rules for:
- AutoTask connectivity and usage
- Feature building workflows
- Task management best practices
