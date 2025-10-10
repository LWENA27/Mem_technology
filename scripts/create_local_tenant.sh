#!/usr/bin/env bash
set -euo pipefail

# Usage: LOCAL_DB_URL=postgresql://postgres:postgres@localhost:5433/inventory ./scripts/create_local_tenant.sh "Local Demo" local-demo localadmin@example.com

if [ -z "${LOCAL_DB_URL:-}" ]; then
  echo "Please set LOCAL_DB_URL environment variable. Example: postgresql://postgres:postgres@localhost:5433/inventory" >&2
  exit 2
fi

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 \"Tenant Name\" tenant-slug admin-email" >&2
  exit 2
fi

TENANT_NAME="$1"
TENANT_SLUG="$2"
ADMIN_EMAIL="$3"

echo "Creating tenant '$TENANT_NAME' (slug: $TENANT_SLUG) ..."
# Escape single quotes for safe SQL embedding
TENANT_NAME_ESC=$(printf "%s" "$TENANT_NAME" | sed "s/'/''/g")
TENANT_SLUG_ESC=$(printf "%s" "$TENANT_SLUG" | sed "s/'/''/g")

tenant_id=$(psql "$LOCAL_DB_URL" -Atc "INSERT INTO tenants (name, slug) VALUES ('$TENANT_NAME_ESC', '$TENANT_SLUG_ESC') ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id;")
echo "Tenant ID: $tenant_id"

echo "Creating local auth.user for $ADMIN_EMAIL ..."
user_id=$(psql "$LOCAL_DB_URL" -Atc "SELECT gen_random_uuid();")
ADMIN_EMAIL_ESC=$(printf "%s" "$ADMIN_EMAIL" | sed "s/'/''/g")
psql "$LOCAL_DB_URL" <<-SQL
  INSERT INTO auth.users (id, email)
  VALUES ('$user_id', '$ADMIN_EMAIL_ESC')
  ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

  SELECT public.attach_profile_to_tenant('$user_id'::uuid, (SELECT id FROM tenants WHERE slug='$TENANT_SLUG_ESC')::uuid, 'tenant_admin');
SQL

echo "Done. user_id=$user_id tenant_id=$tenant_id"
