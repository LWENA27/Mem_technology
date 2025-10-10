#!/usr/bin/env bash
# Helper to run the ADD_EMAIL_TO_PROFILES.sql migration against Supabase
# Usage:
#   SERVICE_ROLE_KEY=... ./run_migration.sh
# or with supabase CLI:
#   supabase secrets set SERVICE_ROLE_KEY=...
#   ./run_migration.sh

set -euo pipefail

if [ -z "${SERVICE_ROLE_KEY:-}" ]; then
  echo "SERVICE_ROLE_KEY environment variable not set. Set it to your Supabase 'service_role' key." >&2
  exit 1
fi

# Require psql
if command -v psql >/dev/null 2>&1; then
  echo "Using psql to apply migration..."
  psql "$SUPABASE_DB_URL" -c "\i $(pwd)/ADD_EMAIL_TO_PROFILES.sql"
  exit 0
fi

# Fallback to supabase cli
if command -v supabase >/dev/null 2>&1; then
  echo "Using supabase CLI to run SQL..."
  # supabase sql query requires a project ref; ensure SUPABASE_PROJECT_REF is set
  if [ -z "${SUPABASE_PROJECT_REF:-}" ]; then
    echo "Please set SUPABASE_PROJECT_REF to your project ref or run with 'supabase --project <ref> sql'" >&2
    exit 1
  fi
  supabase --project "$SUPABASE_PROJECT_REF" sql $(pwd)/ADD_EMAIL_TO_PROFILES.sql --service-role
  exit 0
fi

echo "Neither psql nor supabase CLI found. Install one of them or run the SQL manually in Supabase SQL editor." >&2
exit 1
