#!/usr/bin/env bash
set -euo pipefail

# Create a demo tenant in the local Supabase instance
# Usage: ./scripts/create_local_supabase_tenant.sh

LOCAL_SUPABASE_URL="http://127.0.0.1:54321"
LOCAL_SERVICE_KEY="sb_secret_N7UND0UgjKTVK-Uodkm0Hg_xSvEMPvz"  # From supabase start output

TENANT_NAME="${1:-Local Demo Tenant}"
TENANT_SLUG="${2:-local-demo}"
ADMIN_EMAIL="${3:-admin@localdemo.com}"
ADMIN_PASSWORD="${4:-password123}"

echo "Creating tenant: $TENANT_NAME ($TENANT_SLUG)"

# 1. Create the tenant
TENANT_RESPONSE=$(curl -s -X POST \
  "$LOCAL_SUPABASE_URL/rest/v1/tenants" \
  -H "apikey: $LOCAL_SERVICE_KEY" \
  -H "Authorization: Bearer $LOCAL_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"name\": \"$TENANT_NAME\",
    \"slug\": \"$TENANT_SLUG\",
    \"metadata\": {}
  }")

echo "Tenant creation response: $TENANT_RESPONSE"

# Extract tenant ID
TENANT_ID=$(echo "$TENANT_RESPONSE" | jq -r '.[0].id // .id // empty')

if [ -z "$TENANT_ID" ] || [ "$TENANT_ID" = "null" ]; then
  echo "Error: Failed to create tenant or extract tenant ID"
  echo "Response: $TENANT_RESPONSE"
  exit 1
fi

echo "Created tenant with ID: $TENANT_ID"

# 2. Create admin user
echo "Creating admin user: $ADMIN_EMAIL"

USER_RESPONSE=$(curl -s -X POST \
  "$LOCAL_SUPABASE_URL/auth/v1/admin/users" \
  -H "apikey: $LOCAL_SERVICE_KEY" \
  -H "Authorization: Bearer $LOCAL_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$ADMIN_EMAIL\",
    \"password\": \"$ADMIN_PASSWORD\",
    \"email_confirm\": true,
    \"user_metadata\": {
      \"role\": \"tenant_admin\"
    }
  }")

echo "User creation response: $USER_RESPONSE"

# Extract user ID
USER_ID=$(echo "$USER_RESPONSE" | jq -r '.id // empty')

if [ -z "$USER_ID" ] || [ "$USER_ID" = "null" ]; then
  echo "Error: Failed to create user or extract user ID"
  echo "Response: $USER_RESPONSE"
  exit 1
fi

echo "Created user with ID: $USER_ID"

# 3. Update the user's profile to link to the tenant
echo "Linking user profile to tenant..."

# First, try to create the profile (in case the trigger didn't work)
PROFILE_CREATE_RESPONSE=$(curl -s -X POST \
  "$LOCAL_SUPABASE_URL/rest/v1/profiles" \
  -H "apikey: $LOCAL_SERVICE_KEY" \
  -H "Authorization: Bearer $LOCAL_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"id\": \"$USER_ID\",
    \"email\": \"$ADMIN_EMAIL\",
    \"role\": \"tenant_admin\",
    \"tenant_id\": \"$TENANT_ID\"
  }" 2>/dev/null || echo "Profile might already exist")

# Then update it to ensure correct values
PROFILE_RESPONSE=$(curl -s -X PATCH \
  "$LOCAL_SUPABASE_URL/rest/v1/profiles?id=eq.$USER_ID" \
  -H "apikey: $LOCAL_SERVICE_KEY" \
  -H "Authorization: Bearer $LOCAL_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"tenant_id\": \"$TENANT_ID\",
    \"role\": \"tenant_admin\"
  }")

echo "Profile update response: $PROFILE_RESPONSE"

echo ""
echo "✓ Successfully created local demo setup:"
echo "  Tenant: $TENANT_NAME (ID: $TENANT_ID)"
echo "  Admin User: $ADMIN_EMAIL (ID: $USER_ID)"
echo "  Admin Password: $ADMIN_PASSWORD"
echo ""
echo "You can now log in to your Flutter app with:"
echo "  Email: $ADMIN_EMAIL"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo "Supabase Studio: http://127.0.0.1:54323"