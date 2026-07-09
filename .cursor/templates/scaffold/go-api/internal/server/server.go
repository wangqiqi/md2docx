package server

import (
	"net/http"

	"example.com/app/internal/handler"
)

// NewMux returns the application HTTP handler tree for serving and integration tests.
func NewMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", handler.Health)
	return mux
}
