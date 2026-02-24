---
name: git-setup
description: One-time git account setup (user.name, user.email) and commit workflow. Use when the user asks to set up git, configure git identity, or when git user.name/user.email appear unset. After setup, use Git MCP tools or the commit script for commits with messages.
---

# Git Setup & Commits

## When to run

- User says "set up my git", "configure git", "git account", or similar
- Before first commit: check if identity is set (`git config user.name` / `git config user.email`); if empty, run the setup flow
- User asks how to commit or wants to make a commit (use commit flow below after identity is set)

## One-time account setup flow

Ask the user (one question at a time if needed):

1. **Name for commits:** `git config [--global] user.name "Your Name"`
2. **Email for commits:** `git config [--global] user.email "you@example.com"`
3. **Scope:** "For this repo only, or for all repos on this machine?"  
   - This repo only: omit `--global`  
   - All repos: use `--global`

Then run:

```bash
git config [--global] user.name "Their Name"
git config [--global] user.email "their@email.com"
```

Confirm with: `git config user.name` and `git config user.email` (or with `--global` if they chose global).

## Making commits (after setup)

Use **one** of these:

### Option A: Git MCP (preferred when available)

- **git_status**: Check for changes
- **git_diff**: Review changes
- **git_commit**: Create commit with message (stages all by default)
  - Parameters: `message` (required), `stage_all` (default true)

Use the `git_commit` tool with a clear, conventional message (e.g. `feat: add login form`, `fix: resolve null in parser`).

### Option B: Commit script (when MCP not used)

Run the skill's script from the **project repository root** (not inside the submodule):

```bash
bash .cursor/cursor_workflow/.cursor/skills/git-setup/scripts/commit.sh "your commit message here"
```

Or if skills were copied to project `.cursor/skills/`:

```bash
bash .cursor/skills/git-setup/scripts/commit.sh "your commit message here"
```

The script stages all changes and creates a single commit with the given message.

## Commit message guidelines

- Use conventional style when possible: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- One line, imperative: "Add login" not "Added login"
- Reference task/ticket if applicable (e.g. "feat: add login (task #12)")

## Summary

1. **Once:** Run account setup flow → set `user.name` and `user.email` (local or global).
2. **Commits:** Use Git MCP `git_commit` with a message, or run `scripts/commit.sh "message"` from repo root.
