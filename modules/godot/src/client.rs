//! HTTP client for Godot MCP plugin API.

use reqwest::Client;
use serde_json::Value;
use std::time::Duration;

pub struct GodotClient {
    base_url: String,
    client: Client,
}

impl GodotClient {
    pub fn new(base_url: impl Into<String>) -> Self {
        let client = Client::builder()
            .timeout(Duration::from_secs(30))
            .build()
            .expect("Failed to create HTTP client");
        Self {
            base_url: base_url.into().trim_end_matches('/').to_string(),
            client,
        }
    }

    pub async fn post(&self, path: &str, body: Option<Value>) -> Result<String, String> {
        let url = format!("{}{}", self.base_url, path);
        let mut req = self.client.post(&url);
        if let Some(b) = body {
            req = req.json(&b);
        }
        let resp = req.send().await.map_err(|e| e.to_string())?;
        let status = resp.status();
        let text = resp.text().await.map_err(|e| e.to_string())?;
        if !status.is_success() {
            return Err(format!("HTTP {}: {}", status, text));
        }
        Ok(text)
    }

    pub async fn get(&self, path: &str, query: &[(&str, String)]) -> Result<String, String> {
        let url = format!("{}{}", self.base_url, path);
        let mut req = self.client.get(&url);
        for (k, v) in query {
            req = req.query(&[(k, v)]);
        }
        let resp = req
            .send()
            .await
            .map_err(|e| e.to_string())?;
        let status = resp.status();
        let text = resp.text().await.map_err(|e| e.to_string())?;
        if !status.is_success() {
            return Err(format!("HTTP {}: {}", status, text));
        }
        Ok(text)
    }

    pub async fn run_project(&self) -> Result<String, String> {
        self.post("/run", None).await
    }

    pub async fn stop_project(&self) -> Result<String, String> {
        self.post("/stop", None).await
    }

    pub async fn get_output_log(&self, tail: u32) -> Result<String, String> {
        self.get("/log", &[("tail", tail.to_string())]).await
    }

    pub async fn get_last_errors(&self) -> Result<String, String> {
        self.get("/errors", &[]).await
    }

    pub async fn get_scene_tree(&self, scene: Option<&str>) -> Result<String, String> {
        let q = scene
            .map(|s| vec![("scene", s.to_string())])
            .unwrap_or_default();
        self.get("/scene_tree", &q).await
    }

    pub async fn get_selected_nodes(&self) -> Result<String, String> {
        self.get("/selected", &[]).await
    }

    pub async fn get_node_properties(&self, node_path: &str) -> Result<String, String> {
        self.get("/node/properties", &[("path", node_path.to_string())])
            .await
    }

    pub async fn set_node_property(
        &self,
        path: &str,
        property: &str,
        value: Value,
    ) -> Result<String, String> {
        let body = serde_json::json!({
            "path": path,
            "property": property,
            "value": value
        });
        self.post("/node/property", Some(body)).await
    }

    pub async fn get_open_scenes(&self) -> Result<String, String> {
        self.get("/open_scenes", &[]).await
    }

    pub async fn get_current_scene(&self) -> Result<String, String> {
        self.get("/current_scene", &[]).await
    }
}
