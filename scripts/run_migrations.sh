#!/usr/bin/env bash
set -euo pipefail

# Apply all SQL migration files in the supabase/migrations directory in filename order
# Usage: LOCAL_DB_URL=postgresql://postgres:postgres@localhost:5432/inventory ./scripts/run_migrations.sh

if [ -z "${LOCAL_DB_URL:-}" ]; then
  echo "Please set LOCAL_DB_URL environment variable. Example: postgresql://postgres:postgres@localhost:5432/inventory" >&2
  exit 2
fi

MIG_DIR="supabase/migrations"

if [ ! -d "$MIG_DIR" ]; then
  echo "Migrations directory $MIG_DIR not found" >&2
  exit 1
fi

echo "Applying migrations from $MIG_DIR to $LOCAL_DB_URL"

for f in $(ls "$MIG_DIR"/*.sql | sort); do
  echo "-- Running $f"
  psql "$LOCAL_DB_URL" -f "$f"
done

echo "Applying seed file (if present)"
if [ -f supabase/seed.sql ]; then
  psql "$LOCAL_DB_URL" -f supabase/seed.sql
fi

echo "Migrations complete."
