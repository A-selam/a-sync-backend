-- Phase 1: core multi-tenant job loop schema

CREATE TABLE organizations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TYPE api_key_type AS ENUM ('APPLICATION', 'WORKER', 'OPERATOR');

CREATE TABLE api_keys (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    key_type    api_key_type NOT NULL,
    key_hash    TEXT NOT NULL,          -- never store the raw key after creation
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at  TIMESTAMPTZ
);
CREATE INDEX idx_api_keys_org_id ON api_keys(org_id);

CREATE TABLE queues (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    is_paused   BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (org_id, name)
);

CREATE TABLE workers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id          UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    queues          TEXT[] NOT NULL DEFAULT '{}',
    concurrency     INT NOT NULL DEFAULT 1,
    connected_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_heartbeat  TIMESTAMPTZ,
    disconnected_at TIMESTAMPTZ
);
CREATE INDEX idx_workers_org_id ON workers(org_id);

CREATE TYPE job_status AS ENUM (
    'PENDING', 'DISPATCHED', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED'
);

CREATE TABLE jobs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id        UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    queue_id      UUID NOT NULL REFERENCES queues(id),
    worker_id     UUID REFERENCES workers(id),
    status        job_status NOT NULL DEFAULT 'PENDING',
    priority      INT NOT NULL DEFAULT 0,
    payload       JSONB NOT NULL DEFAULT '{}',
    result        JSONB,
    error_message TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    dispatched_at TIMESTAMPTZ,
    completed_at  TIMESTAMPTZ
);
CREATE INDEX idx_jobs_org_id ON jobs(org_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_queue_id ON jobs(queue_id);