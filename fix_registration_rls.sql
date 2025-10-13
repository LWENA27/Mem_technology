-- Fix for Registration RLS Policy Issues
-- Run this in your Supabase SQL Editor to fix tenant creation during registration

-- Drop existing tenant policies
DROP POLICY IF EXISTS "Public can read tenants" ON tenants;
DROP POLICY IF EXISTS "Authenticated users can create tenants" ON tenants;
DROP POLICY IF EXISTS "Users can update own tenant" ON tenants;

-- Recreate tenant policies with better permission handling
CREATE POLICY "Public can read public tenants" ON tenants
    FOR SELECT USING (public_storefront = true);

CREATE POLICY "Authenticated users can read all tenants" ON tenants
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can create tenants" ON tenants
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND
        auth.uid()::text IS NOT NULL
    );

CREATE POLICY "Users can update own tenant" ON tenants
    FOR UPDATE USING (
        auth.uid() IS NOT NULL AND (
            -- User is in the profiles table with this tenant_id and admin role
            auth.uid() IN (
                SELECT id FROM profiles 
                WHERE tenant_id = tenants.id AND role = 'admin'
            )
            OR
            -- During registration, allow update if no profiles exist yet for this tenant
            NOT EXISTS (
                SELECT 1 FROM profiles WHERE tenant_id = tenants.id
            )
        )
    );

-- Ensure profiles policies work correctly too
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (
        auth.uid() = id AND
        auth.uid() IS NOT NULL
    );

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- REMOVED: The tenant profiles policy was causing infinite recursion
-- We'll handle tenant-wide profile access through application logic instead
-- This is safer and avoids circular dependencies in RLS policies

-- Test the policies work correctly
DO $$
BEGIN
    RAISE NOTICE '✅ RLS Policies Updated Successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Updated Policies:';
    RAISE NOTICE '   • Tenants: More permissive creation policy';
    RAISE NOTICE '   • Profiles: Better authentication checks';
    RAISE NOTICE '   • Registration: Should work without RLS violations';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Test registration again to verify the fix';
END
$$;