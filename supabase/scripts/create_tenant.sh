#!/usr/bin/env bash
set -euo pipefail

# create_tenant.sh
# Usage:
#   SERVICE_ROLE_KEY=... SUPABASE_URL=https://xyz.supabase.co ./create_tenant.sh "Tenant Name" tenant-slug admin@example.com 'Admin123!'
#
# This script will:
#  - create a tenant row
#  - create a new auth user (email+password) via Supabase Admin REST API
#  - insert or update a profile and attach it to the new tenant using the seed function

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 \"Tenant Name\" tenant-slug admin-email admin-password" >&2
  exit 2
fi

TENANT_NAME="$1"
TENANT_SLUG="$2"
ADMIN_EMAIL="$3"
ADMIN_PASS="$4"

if [ -z "${SERVICE_ROLE_KEY:-}" ] || [ -z "${SUPABASE_URL:-}" ]; then
  echo "Please set SERVICE_ROLE_KEY and SUPABASE_URL environment variables." >&2
  exit 1
fi

API_URL="$SUPABASE_URL/rest/v1"
AUTH_URL="$SUPABASE_URL/auth/v1"

echo "Creating tenant '$TENANT_NAME' (slug: $TENANT_SLUG) ..."

# Create tenant via SQL - use a simple INSERT ON CONFLICT DO NOTHING through the SQL RPC endpoint
CREATE_SQL="INSERT INTO tenants (name, slug) VALUES ('$TENANT_NAME', '$TENANT_SLUG') ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id;"

tenant_id=$(curl -sSf --request POST "${API_URL}/rpc" \
  --header "apikey: ${SERVICE_ROLE_KEY}" \
  --header "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  --header "Content-Type: application/json" \
  --data-raw "{\"q\": \"${CREATE_SQL}\"}" | jq -r '.[0].id // empty' || true)

# Fallback: try simple insert via /sql endpoint (if rpc not allowed locally)
if [ -z "$tenant_id" ]; then
  # Use /sql endpoint if available (Supabase projects may not expose rpc endpoint for arbitrary SQL)
  SQL_PAYLOAD="{\"sql\": \"$CREATE_SQL\"}"
  tenant_id=$(curl -sSf --request POST "${SUPABASE_URL}/rest/v1/rpc" \
    --header "apikey: ${SERVICE_ROLE_KEY}" \
    --header "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
    --header "Content-Type: application/json" \
    --data-raw "$SQL_PAYLOAD" | jq -r '.[0].id // empty' || true)
fi

if [ -z "$tenant_id" ]; then
  echo "Could not create tenant via REST API; creating via psql fallback..."
  if ! command -v psql >/dev/null 2>&1; then
    echo "psql not found. Install psql or ensure supabase CLI is available." >&2
    exit 1
  fi
  # Try running SQL using psql and SUPABASE_DB_URL
  if [ -z "${SUPABASE_DB_URL:-}" ]; then
    echo "Please set SUPABASE_DB_URL environment variable for psql fallback." >&2
    exit 1
  fi
  tenant_id=$(psql "$SUPABASE_DB_URL" -Atc "INSERT INTO tenants (name, slug) VALUES ('$TENANT_NAME', '$TENANT_SLUG') ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id;")
fi

echo "Tenant ID: $tenant_id"

echo "Creating admin user: $ADMIN_EMAIL ..."
# Create user via Admin API
create_user_resp=$(curl -sSf --request POST "${AUTH_URL}/admin/users" \
  --header "apikey: ${SERVICE_ROLE_KEY}" \
  --header "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
  --header "Content-Type: application/json" \
  --data-raw "{\"email\": \"${ADMIN_EMAIL}\", \"password\": \"${ADMIN_PASS}\"}")

user_id=$(echo "$create_user_resp" | jq -r '.id')
echo "Created user id: $user_id"

echo "Attaching profile to tenant and setting role to tenant_admin..."

# Call the attach_profile_to_tenant function
ATTACH_SQL="SELECT public.attach_profile_to_tenant('${user_id}'::uuid, '${tenant_id}'::uuid, 'tenant_admin');"

if command -v psql >/dev/null 2>&1 && [ -n "${SUPABASE_DB_URL:-}" ]; then
  psql "$SUPABASE_DB_URL" -c "$ATTACH_SQL"
else
  # Attempt via REST SQL endpoint
  SQL_PAYLOAD="{\"sql\": \"$ATTACH_SQL\"}"
  curl -sSf --request POST "${API_URL}/rpc" \
    --header "apikey: ${SERVICE_ROLE_KEY}" \
    --header "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
    --header "Content-Type: application/json" \
    --data-raw "$SQL_PAYLOAD" >/dev/null
fi

echo "Tenant '$TENANT_NAME' created with admin $ADMIN_EMAIL (user id: $user_id)."
echo "Tenant ID: $tenant_id"
echo "Keep the admin credentials safe. Use the dashboard to invite additional users or create tenants programmatically."
