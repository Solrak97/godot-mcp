import httpx
import os
from typing import Dict, Any, Optional
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    fastapi_url: str = os.getenv("FASTAPI_URL", "http://localhost:8000")
    api_key: Optional[str] = os.getenv("API_KEY", None)
    
    class Config:
        env_file = ".env"

settings = Settings()

class FastAPIClient:
    """HTTP client for communicating with FastAPI"""
    
    def __init__(self, base_url: str = None, api_key: str = None):
        self.base_url = base_url or settings.fastapi_url
        self.api_key = api_key or settings.api_key
        self.client = httpx.AsyncClient(
            base_url=self.base_url,
            timeout=30.0,
            headers={"Authorization": f"Bearer {self.api_key}"} if self.api_key else {}
        )
    
    async def get_task(self, task_id: str) -> Dict[str, Any]:
        """Get a task by ID"""
        response = await self.client.get(f"/api/tasks/{task_id}")
        response.raise_for_status()
        return response.json()
    
    async def list_tasks(
        self,
        status: Optional[str] = None,
        kind: Optional[str] = None,
        project_id: Optional[str] = None,
        sprint_id: Optional[str] = None,
        created_after: Optional[str] = None,
        created_before: Optional[str] = None,
        updated_after: Optional[str] = None,
        updated_before: Optional[str] = None,
    ) -> list[Dict[str, Any]]:
        """List all tasks, optionally filtered by status, kind, project_id, sprint_id, and/or date range."""
        params: Dict[str, str] = {}
        if status:
            params["status"] = status
        if kind:
            params["kind"] = kind
        if project_id:
            params["project_id"] = project_id
        if sprint_id:
            params["sprint_id"] = sprint_id
        if created_after:
            params["created_after"] = created_after
        if created_before:
            params["created_before"] = created_before
        if updated_after:
            params["updated_after"] = updated_after
        if updated_before:
            params["updated_before"] = updated_before
        response = await self.client.get("/api/tasks", params=params)
        response.raise_for_status()
        return response.json()
    
    async def create_task(
        self,
        title: str,
        description: Optional[str] = None,
        kind: Optional[str] = None,
        status: str = "open",
        points: Optional[int] = None,
        project_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new task. kind: task, feature, or epic (default task). Optionally set project_id."""
        data: Dict[str, Any] = {"title": title, "status": status}
        if description:
            data["description"] = description
        if kind:
            data["kind"] = kind
        if points is not None:
            data["points"] = points
        if project_id:
            data["project_id"] = project_id
        response = await self.client.post("/api/tasks", json=data)
        response.raise_for_status()
        return response.json()

    async def list_projects(self) -> list[Dict[str, Any]]:
        """List all projects."""
        response = await self.client.get("/api/projects")
        response.raise_for_status()
        return response.json()

    async def get_project(self, project_id: str) -> Dict[str, Any]:
        """Get a project by ID."""
        response = await self.client.get(f"/api/projects/{project_id}")
        response.raise_for_status()
        return response.json()

    async def create_project(
        self,
        name: str,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new project."""
        data: Dict[str, Any] = {"name": name}
        if description is not None:
            data["description"] = description
        response = await self.client.post("/api/projects", json=data)
        response.raise_for_status()
        return response.json()

    async def update_task(
        self,
        task_id: str,
        title: Optional[str] = None,
        description: Optional[str] = None,
        kind: Optional[str] = None,
        status: Optional[str] = None,
        points: Optional[int] = None,
    ) -> Dict[str, Any]:
        """Update a task. kind: task, feature, or epic."""
        data: Dict[str, Any] = {}
        if title is not None:
            data["title"] = title
        if description is not None:
            data["description"] = description
        if kind is not None:
            data["kind"] = kind
        if status is not None:
            data["status"] = status
        if points is not None:
            data["points"] = points
        response = await self.client.put(f"/api/tasks/{task_id}", json=data)
        response.raise_for_status()
        return response.json()
    
    async def delete_task(self, task_id: str) -> None:
        """Delete a task"""
        response = await self.client.delete(f"/api/tasks/{task_id}")
        response.raise_for_status()

    async def list_task_notes(self, task_id: str) -> list[Dict[str, Any]]:
        """List notes for a task."""
        response = await self.client.get(f"/api/tasks/{task_id}/notes")
        response.raise_for_status()
        return response.json()

    async def create_task_note(
        self,
        task_id: str,
        content: str,
        author: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Add a note to a task."""
        data: Dict[str, Any] = {"content": content}
        if author:
            data["author"] = author
        response = await self.client.post(f"/api/tasks/{task_id}/notes", json=data)
        response.raise_for_status()
        return response.json()

    async def list_sprints(
        self,
        project_id: Optional[str] = None,
    ) -> list[Dict[str, Any]]:
        """List all sprints, optionally filtered by project_id."""
        params: Dict[str, str] = {}
        if project_id:
            params["project_id"] = project_id
        response = await self.client.get("/api/sprints", params=params)
        response.raise_for_status()
        return response.json()

    async def get_sprint(self, sprint_id: str) -> Dict[str, Any]:
        """Get a sprint by ID."""
        response = await self.client.get(f"/api/sprints/{sprint_id}")
        response.raise_for_status()
        return response.json()
    
    async def close(self):
        """Close the HTTP client"""
        await self.client.aclose()
