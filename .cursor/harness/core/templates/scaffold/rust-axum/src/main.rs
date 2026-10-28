use std::net::SocketAddr;

use app::app;

#[tokio::main]
async fn main() {
    let addr: SocketAddr = std::env::var("ADDR")
        .unwrap_or_else(|_| "0.0.0.0:3000".into())
        .parse()
        .expect("invalid ADDR");

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("bind failed");

    println!("listening on {addr}");
    axum::serve(listener, app()).await.expect("server failed");
}
