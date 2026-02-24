---
name: autotask-installation
description: Guide through complete AutoTask installation including database, API, UI, bridge, and migrations. Use when setting up AutoTask from scratch, installing dependencies, configuring services, or when the user asks about AutoTask setup, installation, or getting started.
---

# AutoTask Installation

Complete guide for setting up AutoTask from scratch. Follow these steps in order.

## Prerequisites Check

Before starting, verify you have:

- [ ] Docker and Docker Compose installed
- [ ] Python 3.11+ with `uv` package manager
- [ ] Node.js 20+ and npm
- [ ] Git (for cloning/updating)

**Check commands:**
```bash
docker --version
docker-compose --version
uv --version
node --version
npm --version
```

## Installation Steps

### Step 1: Environment Variables Setup

Set up environment files for each component:

**Database (infra/.env):**
```bash
cd infra
cp .env.example .env
# Edit .env and set DB_PASSWORD (required)
```

**API (api/.env):**
```bash
cd api
cp .env.example .env
# Edit if needed (usually optional)
```

**Bridge (bridge/.env):**
```bash
cd bridge
cp .env.example .env
# Edit if needed (FASTAPI_URL defaults to http://localhost:8000)
```

### Step 2: Start Database and Services

Start PostgreSQL and application services with Docker:

```bash
cd infra
docker-compose up -d
```

This will:
- Start PostgreSQL database on port 5432
- Build and start the app container (UI + API)
- Services available at:
  - UI & API: http://localhost:8000
  - Database: localhost:5432 (internal Docker network)

**Verify services are running:**
```bash
docker-compose ps
# Should show 'db' and 'app' services as 'Up'
```

### Step 3: Install API Dependencies

Install Python dependencies for the API:

```bash
cd api
uv sync
```

### Step 4: Run Database Migrations

Apply database schema migrations:

```bash
cd api
uv run alembic upgrade head
```

**Verify migrations:**
```bash
# Check migration status
uv run alembic current
# Should show the latest migration version
```

### Step 5: Install Bridge Dependencies

Install Python dependencies for the MCP bridge:

```bash
cd bridge
uv sync
```

### Step 6: Install UI Dependencies

Install Node.js dependencies for the React UI:

```bash
cd ui
npm install
```

### Step 7: Verify MCP Bridge Configuration

Check that the MCP bridge is configured in Cursor:

```bash
# Verify .cursor/mcp.json exists and has autotask server configured
cat .cursor/mcp.json
```

The configuration should include:
```json
{
  "mcpServers": {
    "autotask": {
      "command": "uv",
      "args": ["run", "--directory", "bridge", "python", "-m", "bridge"],
      "env": {
        "FASTAPI_URL": "http://localhost:8000"
      }
    }
  }
}
```

**Restart Cursor** after configuration to activate the MCP bridge.

## Verification

### Check API Health

```bash
curl http://localhost:8000/api/health
# Should return: {"status":"ok"}
```

### Check Database Connection

```bash
# From api directory
uv run python -c "from app.database import engine; import asyncio; asyncio.run(engine.connect())"
# Should connect without errors
```

### Check UI

Open browser: http://localhost:8000

### Check MCP Bridge

The bridge runs automatically when Cursor starts. To test manually:

```bash
cd bridge
uv run python -m bridge
# Should start MCP server (will wait for input via stdio)
```

## Development Mode

### Running Services Locally (without Docker)

**API:**
```bash
cd api
uv run uvicorn app.main:app --reload
```

**UI:**
```bash
cd ui
npm run dev
```

**Bridge:**
```bash
cd bridge
uv run python -m bridge
```

**Database:**
Keep Docker database running:
```bash
cd infra
docker-compose up -d db
```

## Troubleshooting

### Database Connection Issues

- Verify `DB_PASSWORD` is set in `infra/.env`
- Check database is running: `docker-compose ps`
- Check database logs: `docker-compose logs db`
- Verify DATABASE_URL in API environment

### Migration Errors

- Ensure database is running and accessible
- Check `DATABASE_URL` in `api/.env` matches Docker setup
- Try: `uv run alembic downgrade -1` then `uv run alembic upgrade head`

### MCP Bridge Not Working

- Verify `.cursor/mcp.json` exists and is valid JSON
- Check bridge path is correct (relative to project root)
- Ensure bridge dependencies installed: `cd bridge && uv sync`
- Restart Cursor completely

### Port Conflicts

If port 8000 or 5432 are in use:
- Change ports in `infra/docker-compose.yml`
- Update `FASTAPI_URL` in bridge configuration
- Update API environment variables

## Quick Setup Checklist

Copy this checklist and track progress:

```
AutoTask Installation:
- [ ] Prerequisites verified (Docker, uv, Node.js)
- [ ] Environment files created (infra/.env, api/.env, bridge/.env)
- [ ] Docker services started (docker-compose up -d)
- [ ] API dependencies installed (cd api && uv sync)
- [ ] Database migrations run (cd api && uv run alembic upgrade head)
- [ ] Bridge dependencies installed (cd bridge && uv sync)
- [ ] UI dependencies installed (cd ui && npm install)
- [ ] MCP configuration verified (.cursor/mcp.json)
- [ ] API health check passed
- [ ] UI accessible at http://localhost:8000
- [ ] Cursor restarted to activate MCP bridge
```

## Next Steps

After installation:
1. Access UI at http://localhost:8000
2. Use MCP tools in Cursor (create_task, list_tasks, etc.)
3. Start developing features following full-stack patterns

## Common Commands Reference

```bash
# Start all services
cd infra && docker-compose up -d

# Stop all services
cd infra && docker-compose down

# View logs
cd infra && docker-compose logs -f

# Restart services
cd infra && docker-compose restart

# Run migrations
cd api && uv run alembic upgrade head

# Create new migration
cd api && uv run alembic revision --autogenerate -m "description"
```
