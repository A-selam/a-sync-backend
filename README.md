# a-sync-backend

This is a Go application following a clean architecture structure.

## Directory Structure
- **cmd/api/**: Application entry point
- **config/**: Configuration loader (e.g., viper)
- **delivery/**: HTTP controllers and routes
- **domain/**: Domain models and interfaces
- **infrastructure/**: Database, middleware, logger, and Twilio setup
- **repository/**: Repository implementations
- **usecase/**: Business logic
- **utils/**: Utility functions, Docker, GitHub Actions, and OpenAPI spec
- **tests/**: Unit tests

## Setup
1. Install Go: https://golang.org/doc/install
2. Run `go mod tidy` to fetch dependencies
3. Start the application: `go run cmd/api/main.go`

