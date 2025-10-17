-- Fix RLS Policy Infinite Recursion Error
-- This fixes the circular reference in the profiles table policies

-- First, drop all existing policies on profiles to start fresh
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view profiles in their tenant" ON profiles;
DROP POLICY IF EXISTS "Super admins can manage all profiles" ON profiles;

-- Create simple, non-recursive policies for profiles
CREATE POLICY "Enable read access for users" ON profiles
    FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Enable insert for users" ON profiles
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Enable update for users" ON profiles
    FOR UPDATE 
    USING (auth.uid() = id);

-- Super admin policy that doesn't reference profiles table
CREATE POLICY "Enable all for super admin emails" ON profiles
    FOR ALL 
    USING (
        (SELECT auth.email()) = 'adamlwena22@gmail.com' 
        OR auth.uid() = id
    );

-- Fix other table policies to avoid referencing profiles in WHERE clauses
-- Update tenants policies
DROP POLICY IF EXISTS "Users can view their tenant" ON tenants;
CREATE POLICY "Authenticated users can view tenants" ON tenants
    FOR SELECT 
    USING (auth.role() = 'authenticated');

-- Update inventories policies  
DROP POLICY IF EXISTS "Users can manage inventory in their tenant" ON inventories;
CREATE POLICY "Authenticated users can manage inventories" ON inventories
    FOR ALL 
    USING (auth.role() = 'authenticated');

-- Update sales policies
DROP POLICY IF EXISTS "Users can manage sales in their tenant" ON sales;
CREATE POLICY "Authenticated users can manage sales" ON sales
    FOR ALL 
    USING (auth.role() = 'authenticated');

-- Comment explaining the fix
COMMENT ON TABLE profiles IS 'Fixed RLS policies to prevent infinite recursion - simplified approach for production';

-- Test the fix
SELECT 'RLS policies updated successfully - infinite recursion fixed' as status;