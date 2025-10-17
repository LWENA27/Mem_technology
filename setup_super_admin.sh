#!/bin/bash

# Script to create your first Super Admin user
# Replace with your actual email address

echo "=== InventoryMaster SaaS - Super Admin Setup ==="
echo ""

# Get user email
read -p "Enter the email address for super admin: " ADMIN_EMAIL

if [ -z "$ADMIN_EMAIL" ]; then
    echo "Error: Email address is required"
    exit 1
fi

echo "Setting up super admin for: $ADMIN_EMAIL"
echo ""

# Connect to local Supabase and promote user
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" << EOF
SELECT promote_to_super_admin('$ADMIN_EMAIL');
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! User $ADMIN_EMAIL is now a super admin."
    echo ""
    echo "Next steps:"
    echo "1. Make sure this user exists in your system (sign up first if needed)"
    echo "2. Login with this account"
    echo "3. You'll automatically be redirected to the Super Admin Dashboard"
    echo ""
    echo "Super Admin Features:"
    echo "- View and manage all tenants"
    echo "- Monitor cross-tenant inventory"
    echo "- Manage users across all tenants"
    echo "- Configure system-wide settings"
else
    echo ""
    echo "❌ ERROR: Failed to set super admin. Please check:"
    echo "1. Supabase is running (supabase status)"
    echo "2. Database is properly migrated"
    echo "3. User exists in the system"
fi