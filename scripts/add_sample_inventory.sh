#!/usr/bin/env bash
set -euo pipefail

# Add sample inventory items to the local Supabase tenant
# Usage: ./scripts/add_sample_inventory.sh [tenant_id]

LOCAL_SUPABASE_URL="http://127.0.0.1:54321"
LOCAL_SERVICE_KEY="sb_secret_N7UND0UgjKTVK-Uodkm0Hg_xSvEMPvz"

TENANT_ID="${1:-87fd6580-3f62-4390-8f13-ea129d6d0893}"  # Default to the tenant we just created

echo "Adding sample inventory items to tenant: $TENANT_ID"

# Sample inventory items
ITEMS='[
  {
    "tenant_id": "'$TENANT_ID'",
    "name": "Laptop Computer",
    "sku": "LAP-001",
    "quantity": 15,
    "price": 899.99,
    "metadata": {"category": "Electronics", "brand": "TechCorp"}
  },
  {
    "tenant_id": "'$TENANT_ID'",
    "name": "Office Chair",
    "sku": "CHR-001", 
    "quantity": 8,
    "price": 129.50,
    "metadata": {"category": "Furniture", "color": "Black"}
  },
  {
    "tenant_id": "'$TENANT_ID'",
    "name": "Wireless Mouse",
    "sku": "MSE-001",
    "quantity": 25,
    "price": 24.99,
    "metadata": {"category": "Electronics", "wireless": true}
  },
  {
    "tenant_id": "'$TENANT_ID'",
    "name": "Coffee Beans",
    "sku": "COF-001",
    "quantity": 50,
    "price": 12.99,
    "metadata": {"category": "Food", "origin": "Colombia"}
  },
  {
    "tenant_id": "'$TENANT_ID'",
    "name": "Notebook Set",
    "sku": "NOT-001",
    "quantity": 100,
    "price": 5.99,
    "metadata": {"category": "Stationery", "pages": 200}
  }
]'

echo "Creating inventory items..."

RESPONSE=$(curl -s -X POST \
  "$LOCAL_SUPABASE_URL/rest/v1/inventories" \
  -H "apikey: $LOCAL_SERVICE_KEY" \
  -H "Authorization: Bearer $LOCAL_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$ITEMS")

echo "Response: $RESPONSE"

# Count created items
CREATED_COUNT=$(echo "$RESPONSE" | jq 'length // 0')
echo ""
echo "✓ Successfully created $CREATED_COUNT inventory items"
echo ""
echo "You can now view these items in your Flutter app or Supabase Studio."