-- Create Super Admin Account for Production
-- This script creates a super admin that can login to the app

-- First, let's clean up any existing account with this email
DELETE FROM auth.users WHERE email = 'adamlwena22@gmail.com';
DELETE FROM profiles WHERE email = 'adamlwena22@gmail.com';

-- Insert into auth.users table (this is where authentication data is stored)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'adamlwena22@gmail.com',
    crypt('SuperAdmin123', gen_salt('bf')), -- This hashes the password properly
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    '',
    '',
    '',
    ''
);

-- Get the user ID we just created
DO $$
DECLARE
    user_id UUID;
BEGIN
    -- Get the user ID
    SELECT id INTO user_id FROM auth.users WHERE email = 'adamlwena22@gmail.com';
    
    -- Insert into profiles table with super admin role
    INSERT INTO profiles (
        id,
        email,
        role,
        name,
        created_at,
        updated_at
    ) VALUES (
        user_id,
        'adamlwena22@gmail.com',
        'super_admin',
        'System Administrator',
        NOW(),
        NOW()
    );
END $$;

-- Verify the account was created
SELECT 
    u.email,
    p.role,
    p.name,
    u.created_at
FROM auth.users u
JOIN profiles p ON u.id = p.id
WHERE u.email = 'adamlwena22@gmail.com';

-- Success message
SELECT 'Super Admin account created successfully! You can now login with adamlwena22@gmail.com / SuperAdmin123' as status;