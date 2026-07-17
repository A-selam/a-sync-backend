.PHONY: run dev build lint fmt test test-unit test-integration migrate-up migrate-down migrate-new mocks swagger docker-up docker-down

APP_NAME=a-sync-backend
MIGRATIONS_DIR=migrations
DB_URL=$${DATABASE_URL}

run:
	go run ./cmd/api

dev:
	air

build:
	go build -o bin/$(APP_NAME) ./cmd/api

lint:
	golangci-lint run ./...

fmt:
	gofmt -w .
	goimports -w .

# Fast inner-loop tests: no external services required (mocked repos only)
test-unit:
	go test -short ./...

# Slower tests: spins up real Postgres/Redis via testcontainers-go
test-integration:
	go test ./tests/...

test: test-unit test-integration

# --- Database migrations (golang-migrate) ---
migrate-up:
	migrate -path $(MIGRATIONS_DIR) -database "$(DB_URL)" up

migrate-down:
	migrate -path $(MIGRATIONS_DIR) -database "$(DB_URL)" down 1

# usage: make migrate-new name=phase1_core
migrate-new:
	migrate create -ext sql -dir $(MIGRATIONS_DIR) -seq $(name)

# --- Codegen ---
mocks:
	mockery

swagger:
	swag init -g cmd/api/main.go -o api/docs

# --- Local infra ---
docker-up:
	docker compose up -d --build

docker-down:
	docker compose down -v