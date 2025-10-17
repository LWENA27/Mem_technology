-- Create or Update Super Admin Account for Production
-- This script handles existing accounts and creates/updates super admin properly

-- First, let's check if the user exists and get their ID
DO $$
DECLARE
    user_id UUID;
    user_exists BOOLEAN := FALSE;
BEGIN
    -- Check if user exists in auth.users
    SELECT id INTO user_id FROM auth.users WHERE email = 'adamlwena22@gmail.com';
    
    IF user_id IS NOT NULL THEN
        user_exists := TRUE;
        RAISE NOTICE 'User already exists with ID: %', user_id;
    ELSE
        -- User doesn't exist, create new one
        user_id := gen_random_uuid();
        
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
            user_id,
            'authenticated',
            'authenticated',
            'adamlwena22@gmail.com',
            crypt('SuperAdmin123', gen_salt('bf')),
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
        
        RAISE NOTICE 'Created new user with ID: %', user_id;
    END IF;
    
    -- Handle profile - either insert or update
    IF EXISTS (SELECT 1 FROM profiles WHERE id = user_id) THEN
        -- Profile exists, update it to super admin
        UPDATE profiles 
        SET 
            role = 'super_admin',
            name = 'System Administrator',
            updated_at = NOW()
        WHERE id = user_id;
        
        RAISE NOTICE 'Updated existing profile to super admin';
    ELSE
        -- Profile doesn't exist, create it
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
        
        RAISE NOTICE 'Created new super admin profile';
    END IF;
END $$;

-- Verify the final result
SELECT 
    u.email,
    p.role,
    p.name,
    u.email_confirmed_at IS NOT NULL as email_confirmed,
    u.created_at
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email = 'adamlwena22@gmail.com';

-- Success message
SELECT 'Super Admin account ready! Login: adamlwena22@gmail.com / SuperAdmin123' as status;