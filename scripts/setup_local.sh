#!/usr/bin/env bash
set -euo pipefail

# One-command local setup for Postgres + migrations + demo tenant
# Usage: ./scripts/setup_local.sh

HERE=$(cd "$(dirname "$0")/.." && pwd)
cd "$HERE"

export LOCAL_DB_URL=${LOCAL_DB_URL:-'postgresql://postgres:postgres@localhost:5433/inventory'}

echo "Starting docker compose (attempt without sudo first)..."
if docker compose up -d >/dev/null 2>&1; then
  echo "docker compose started (no sudo)"
else
  echo "Retrying with sudo..."
  sudo docker compose up -d
fi

echo "Waiting for Postgres to accept connections..."
./scripts/wait_for_db.sh 60

echo "Running migrations..."
LOCAL_DB_URL="$LOCAL_DB_URL" ./scripts/run_migrations.sh

echo "Creating demo tenant and admin..."
LOCAL_DB_URL="$LOCAL_DB_URL" ./scripts/create_local_tenant.sh "Local Demo" local-demo localadmin@example.com

echo "Setup complete."
echo "LOCAL_DB_URL=$LOCAL_DB_URL"
