# Module Template

This is a template for creating new modules in the Cursor Workflow Setup system.

## Module Structure

```
modules/your-module/
├── README.md              # Module documentation (required)
├── mcp-config.json        # MCP server configuration (if module provides MCP server)
├── pyproject.toml         # Python dependencies (if module needs Python)
├── install.sh             # Custom installation script (optional)
├── rules/                 # Cursor rules specific to this module
│   └── your-module-rule.mdc
└── [module code/]         # Any code or scripts needed
```

## Required Files

### README.md

Document your module:
- What it does
- Features
- Requirements
- MCP tools (if any)
- Configuration
- Usage examples

### mcp-config.json (if applicable)

If your module provides an MCP server, include a configuration:

```json
{
  "mcpServers": {
    "your-module": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        ".cursor/workflow-setup/modules/your-module",
        "python",
        "-m",
        "your_module"
      ],
      "disabled": false,
      "autoApprove": ["tool1", "tool2"]
    }
  }
}
```

### rules/ (optional)

Add Cursor rules that guide AI behavior when using your module. Rules should:
- Be descriptive
- Include examples
- Follow the `.mdc` format with frontmatter

## Installation Script (optional)

If your module needs custom setup, create `install.sh`:

```bash
#!/bin/bash
# Custom installation for your-module
PROJECT_ROOT="$1"
# Your setup logic here
```

## Best Practices

1. **Self-contained**: Module should work independently
2. **Documentation**: Clear README with examples
3. **Configuration**: Use environment variables or config files
4. **Error handling**: Graceful failures with helpful messages
5. **Testing**: Test your module before adding to the repo

## Example Module

See `modules/autotask/` or `modules/git/` for complete examples.
