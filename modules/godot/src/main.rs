//! Godot MCP - MCP server bridge for Godot editor API.
//! Forwards tool calls to the Godot plugin HTTP API.

use rmcp::{
    handler::server::tool::ToolRouter,
    model::{CallToolResult, Content, ServerCapabilities, ServerInfo, *},
    tool, tool_handler, tool_router,
    transport::io,
    ErrorData as McpError,
    ServerHandler, ServiceExt,
};
use serde_json::Value;
use std::sync::Arc;

mod client;
use client::GodotClient;

#[derive(Clone)]
struct GodotMcpServer {
    client: Arc<GodotClient>,
    tool_router: ToolRouter<Self>,
}

#[tool_router]
impl GodotMcpServer {
    fn new(api_url: &str) -> Self {
        Self {
            client: Arc::new(GodotClient::new(api_url)),
            tool_router: Self::tool_router(),
        }
    }

    #[tool(description = "Run the game (editor play main scene)")]
    async fn run_project(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.run_project().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Stop the running game instance")]
    async fn stop_project(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.stop_project().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get last N log lines from editor/game output")]
    async fn get_output_log(&self, tail: Option<u32>) -> Result<CallToolResult, McpError> {
        let n = tail.unwrap_or(200);
        let s = self.client.get_output_log(n).await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get structured parse of recent errors (file, line, message)")]
    async fn get_last_errors(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.get_last_errors().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get scene tree: node paths and types. scene=current or scene path")]
    async fn get_scene_tree(&self, scene: Option<String>) -> Result<CallToolResult, McpError> {
        let s = self
            .client
            .get_scene_tree(scene.as_deref())
            .await
            .map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get currently selected node paths in the scene tree")]
    async fn get_selected_nodes(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.get_selected_nodes().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get key properties and metadata for a node by path")]
    async fn get_node_properties(&self, node_path: String) -> Result<CallToolResult, McpError> {
        let s = self
            .client
            .get_node_properties(&node_path)
            .await
            .map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Set a node property. path=node path, property=name, value=JSON value")]
    async fn set_node_property(
        &self,
        path: String,
        property: String,
        value: Value,
    ) -> Result<CallToolResult, McpError> {
        let s = self
            .client
            .set_node_property(&path, &property, value)
            .await
            .map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get list of open scene file paths")]
    async fn get_open_scenes(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.get_open_scenes().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }

    #[tool(description = "Get current (edited) scene file path")]
    async fn get_current_scene(&self) -> Result<CallToolResult, McpError> {
        let s = self.client.get_current_scene().await.map_err(McpError::invalid_params)?;
        Ok(CallToolResult::success(vec![Content::text(s)]))
    }
}

#[tool_handler]
impl ServerHandler for GodotMcpServer {
    fn get_info(&self) -> ServerInfo {
        ServerInfo {
            name: "godot-mcp".into(),
            version: Some("0.1.0".into()),
            instructions: Some(
                "MCP bridge for Godot editor. Requires Godot MCP plugin running in the editor."
                    .into(),
            ),
            capabilities: ServerCapabilities::builder().enable_tools().build(),
            ..Default::default()
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let api_url = std::env::var("GODOT_API_URL").unwrap_or_else(|_| "http://localhost:4242".into());
    let server = GodotMcpServer::new(&api_url);
    let transport = io::stdio();
    let service = server.serve(transport).await?;
    service.waiting().await?;
    Ok(())
}
