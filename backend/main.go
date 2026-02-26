package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"github.com/henriquemeira/gotasks/backend/internal/api"
	db "github.com/henriquemeira/gotasks/backend/internal/generated/db"
)

func main() {
	// Load .env file if present (development only).
	_ = godotenv.Load()

	databaseURL := mustEnv("DATABASE_URL")
	port := getEnv("PORT", "8080")
	corsOrigins := getEnv("CORS_ORIGINS", "")

	pool, err := pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		log.Fatalf("unable to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(context.Background()); err != nil {
		log.Fatalf("database ping failed: %v", err)
	}
	log.Println("connected to database")

	queries := db.New(pool)
	handler := api.NewHandler(queries)
	router := api.NewRouter(handler, corsOrigins)

	addr := fmt.Sprintf("0.0.0.0:%s", port)
	log.Printf("starting server on %s", addr)
	if err := http.ListenAndServe(addr, router); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("environment variable %s is required", key)
	}
	return v
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
