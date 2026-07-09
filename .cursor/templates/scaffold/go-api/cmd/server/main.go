package main

import (
	"log"
	"net/http"
	"os"

	"example.com/app/internal/server"
)

func main() {
	addr := os.Getenv("ADDR")
	if addr == "" {
		addr = ":8080"
	}

	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, server.NewMux()))
}
