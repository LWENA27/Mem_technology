#!/bin/bash

# Enhanced script to create Super Admin user with account creation
echo "=== InventoryMaster SaaS - Complete Super Admin Setup ==="
echo ""

# Get user details
read -p "Enter the email address for super admin: " ADMIN_EMAIL
read -s -p "Enter password for super admin: " ADMIN_PASSWORD
echo ""

if [ -z "$ADMIN_EMAIL" ] || [ -z "$ADMIN_PASSWORD" ]; then
    echo "Error: Both email and password are required"
    exit 1
fi

echo "Creating and setting up super admin for: $ADMIN_EMAIL"
echo ""

# Connect to local Supabase and create user + promote
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" << EOF
-- Create the user in auth.users table
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    role,
    aud,
    confirmation_token,
    email_change_token_current,
    email_change_token_new
) VALUES (
    gen_random_uuid(),
    '$ADMIN_EMAIL',
    crypt('$ADMIN_PASSWORD', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    '',
    '',
    ''
) ON CONFLICT (email) DO NOTHING;

-- Now promote to super admin
SELECT promote_to_super_admin('$ADMIN_EMAIL') as success;

-- Verify the setup
SELECT 
    u.email,
    p.role,
    CASE WHEN p.role = 'super_admin' THEN 'SUCCESS ✅' ELSE 'FAILED ❌' END as status
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE u.email = '$ADMIN_EMAIL';
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 COMPLETE! Super admin account created and configured."
    echo ""
    echo "🔐 Login Credentials:"
    echo "   Email: $ADMIN_EMAIL"
    echo "   Password: [The password you entered]"
    echo ""
    echo "📱 How to Test:"
    echo "1. Run your Flutter app: flutter run"
    echo "2. Login with the credentials above"
    echo "3. You should see the Super Admin Dashboard instead of regular dashboard"
    echo ""
    echo "🛠️ Super Admin Capabilities:"
    echo "- 🏢 View and manage all tenants"
    echo "- 📦 Monitor inventory across all tenants" 
    echo "- 👥 Manage users and roles"
    echo "- ⚙️ System-wide configuration"
else
    echo ""
    echo "❌ ERROR: Failed to create super admin."
    echo "Please check Supabase is running and try again."
fi