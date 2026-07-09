package handler

import (
	"encoding/json"
	"net/http"
)

// Health responds with a JSON health check payload.
func Health(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
