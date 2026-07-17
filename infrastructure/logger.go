package infrastructure

import (
	"os"

	"github.com/rs/zerolog"
)

// NewLogger returns a zerolog.Logger configured for the given level and
// environment. In development it logs pretty console output; in production
// it logs plain JSON (what you want feeding into any log aggregator later).
func NewLogger(level string, env string) zerolog.Logger {
	l, err := zerolog.ParseLevel(level)
	if err != nil {
		l = zerolog.InfoLevel
	}
	zerolog.SetGlobalLevel(l)

	if env == "development" {
		return zerolog.New(zerolog.ConsoleWriter{Out: os.Stdout}).With().Timestamp().Logger()
	}
	return zerolog.New(os.Stdout).With().Timestamp().Logger()
}

// Event names — keep every structured log event name here as a constant so
// the growing list from the PRD (job.submitted, job.dead, workflow.triggered...)
// never gets typo'd across files.
const (
	EventJobSubmitted     = "job.submitted"
	EventJobDispatched    = "job.dispatched"
	EventJobAcked         = "job.acked"
	EventJobCompleted     = "job.completed"
	EventJobFailed        = "job.failed"
	EventWorkerRegistered = "worker.registered"
	EventWorkerDisconnect = "worker.disconnected"
	EventWorkerHeartbeat  = "worker.heartbeat"
)
