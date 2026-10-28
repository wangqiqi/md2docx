package integration_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"example.com/app/internal/server"
)

func TestHealthEndpointIntegration(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	server.NewMux().ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}

	var body map[string]string
	if err := json.NewDecoder(rec.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if body["status"] != "ok" {
		t.Fatalf("expected ok, got %q", body["status"])
	}
}
