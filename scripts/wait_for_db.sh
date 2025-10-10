#!/usr/bin/env bash
set -euo pipefail

# Usage: LOCAL_DB_URL=... ./scripts/wait_for_db.sh [timeout_seconds]
TIMEOUT=${1:-60}
if [ -z "${LOCAL_DB_URL:-}" ]; then
  echo "Please set LOCAL_DB_URL before calling this script." >&2
  exit 2
fi

echo "Waiting up to $TIMEOUT seconds for database to accept connections..."
START=$(date +%s)
while :; do
  if psql "$LOCAL_DB_URL" -c '\q' >/dev/null 2>&1; then
    echo "Database is ready"
    exit 0
  fi
  NOW=$(date +%s)
  if [ $((NOW-START)) -ge $TIMEOUT ]; then
    echo "Timed out waiting for database after $TIMEOUT seconds" >&2
    exit 1
  fi
  sleep 1
done
