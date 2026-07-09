def test_health_content_type(client) -> None:
    response = client.get("/health")
    assert response.headers["content-type"].startswith("application/json")
