"""Workflow: fetch a task, update progress, complete it, update progress again."""
import asyncio
import os
import sys
from pathlib import Path

# Allow importing bridge package when run as script
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import httpx
from bridge.client import FastAPIClient


async def check_health(base_url: str) -> bool:
    """Verify API is up before running workflow."""
    async with httpx.AsyncClient(base_url=base_url, timeout=5.0) as c:
        r = await c.get("/api/health")
        return r.is_success


async def main() -> None:
    base_url = os.getenv("FASTAPI_URL", "http://localhost:8000")
    if not await check_health(base_url):
        print(f"API not reachable at {base_url}. Start the API and Postgres first.")
        sys.exit(1)

    client = FastAPIClient()
    try:
        # 1. Fetch a task (list open tasks, or any task)
        print("1. Fetching tasks...")
        try:
            tasks = await client.list_tasks(status="open")
        except Exception:
            tasks = await client.list_tasks()
        if not tasks:
            print("   No tasks found. Creating one...")
            task = await client.create_task(
                "Workflow demo task",
                "Created for fetch → progress → complete → progress workflow",
            )
            tasks = [task]

        task = tasks[0]
        tid = task["id"]
        print(f"   Fetched task: {task['title']!r} (id={tid}, status={task['status']})")

        # 2. Update progress → in_progress
        print("\n2. Updating progress (status → in_progress)...")
        task = await client.update_task(tid, status="in_progress")
        print(f"   Updated: status={task['status']}")

        # 3. Complete the task
        print("\n3. Completing task (status → closed)...")
        task = await client.update_task(tid, status="closed")
        print(f"   Completed: status={task['status']}")

        # 4. Update progress again (e.g. add completion note to description)
        print("\n4. Updating progress again (description)...")
        desc = (task.get("description") or "").strip()
        suffix = " [Progress updated after completion.]"
        if suffix not in desc:
            desc = f"{desc}{suffix}" if desc else suffix.strip()
        task = await client.update_task(tid, description=desc)
        d = task.get("description") or ""
        print(f"   Updated: description={d[:80]}{'...' if len(d) > 80 else ''}")

        print("\nDone.")
    finally:
        await client.close()


if __name__ == "__main__":
    asyncio.run(main())
