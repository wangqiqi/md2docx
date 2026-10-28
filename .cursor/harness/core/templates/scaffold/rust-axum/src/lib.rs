use axum::{routing::get, Json, Router};
use serde::Serialize;

#[derive(Serialize)]
pub struct HealthResponse {
    pub status: &'static str,
}

pub fn app() -> Router {
    Router::new().route("/health", get(health))
}

async fn health() -> Json<HealthResponse> {
    Json(HealthResponse { status: "ok" })
}
