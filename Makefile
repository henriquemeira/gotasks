.PHONY: migrate-up migrate-down sqlc-gen backend frontend help

DB_URL ?= $(or $(DATABASE_URL),postgres://postgres:postgres@localhost:5432/gotasks?sslmode=disable)
MIGRATIONS_PATH ?= backend/sql/migrations

## migrate-up: apply all pending database migrations
migrate-up:
	migrate -path $(MIGRATIONS_PATH) -database "$(DB_URL)" up

## migrate-down: roll back the last database migration
migrate-down:
	migrate -path $(MIGRATIONS_PATH) -database "$(DB_URL)" down 1

## sqlc-gen: regenerate Go code from SQL queries
sqlc-gen:
	cd backend && sqlc generate

## backend: run the Go backend server
backend:
	cd backend && go run .

## frontend: install dependencies and start the Vite dev server
frontend:
	cd frontend && npm install && npm run dev

## help: list available targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //'
