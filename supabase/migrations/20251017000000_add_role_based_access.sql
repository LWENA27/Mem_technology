-- Add role column to profiles table for role-based access control
-- This enables super admin functionality

-- First, create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles table
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- First, check if role column exists and add it if not
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'role'
    ) THEN
        ALTER TABLE profiles ADD COLUMN role VARCHAR(50) DEFAULT 'user';
    END IF;
END $$;

-- Create index on role for performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Update existing profiles to have 'user' role if null
UPDATE profiles SET role = 'user' WHERE role IS NULL;

-- Make role NOT NULL with default
ALTER TABLE profiles ALTER COLUMN role SET NOT NULL;
ALTER TABLE profiles ALTER COLUMN role SET DEFAULT 'user';

-- Add check constraint for valid roles
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
    CHECK (role IN ('user', 'admin', 'staff', 'super_admin'));

-- Comment on the role column
COMMENT ON COLUMN profiles.role IS 'User role for access control: user, admin, staff, super_admin';

-- Create a function to check if user is super admin
CREATE OR REPLACE FUNCTION is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = user_id AND role = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to promote user to super admin (for administrative use)
CREATE OR REPLACE FUNCTION promote_to_super_admin(user_email TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Find user by email
    SELECT auth.users.id INTO user_id
    FROM auth.users
    WHERE auth.users.email = user_email;
    
    IF user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update or insert profile with super_admin role
    INSERT INTO profiles (id, role, updated_at)
    VALUES (user_id, 'super_admin', NOW())
    ON CONFLICT (id) 
    DO UPDATE SET 
        role = 'super_admin',
        updated_at = NOW();
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION is_super_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION promote_to_super_admin(TEXT) TO service_role;

-- Example usage (uncomment and modify email to create your first super admin):
-- SELECT promote_to_super_admin('your-admin@email.com');

COMMIT;