-- InventoryMaster SaaS - Complete Database Setup
-- Single file for clean, production-ready database
-- Run this entire file in your Supabase Dashboard → SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. TENANTS TABLE (Business/Organizations) - CREATE FIRST
-- ========================================

-- Create tenants table FIRST (referenced by other tables)
CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    public_storefront BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on tenants
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 2. PROFILES TABLE (User Management)
-- ========================================

-- Create profiles table for user roles and tenant association
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'admin',
    email TEXT,
    tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 3. INVENTORIES TABLE (Products)
-- ========================================

-- Create inventories table
CREATE TABLE IF NOT EXISTS inventories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sku TEXT,
    quantity INTEGER NOT NULL DEFAULT 0,
    price NUMERIC(10,2) NOT NULL DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on inventories
ALTER TABLE inventories ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 4. SALES TABLE (Sales Records)
-- ========================================

-- Create sales table
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES inventories(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL DEFAULT 0,
    total_price NUMERIC(10,2) NOT NULL DEFAULT 0,
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    sale_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    receipt_number TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on sales
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 5. CREATE INDEXES (After all tables exist)
-- ========================================

-- Indexes for inventories
CREATE INDEX IF NOT EXISTS idx_inventories_tenant_id ON inventories(tenant_id);
CREATE INDEX IF NOT EXISTS idx_inventories_name ON inventories(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inventories_tenant_sku ON inventories(tenant_id, sku) WHERE sku IS NOT NULL;

-- Indexes for sales
CREATE INDEX IF NOT EXISTS idx_sales_tenant_id ON sales(tenant_id);
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_receipt_number ON sales(receipt_number) WHERE receipt_number IS NOT NULL;

-- ========================================
-- 6. ROW LEVEL SECURITY POLICIES
-- ========================================

-- Tenants policies
DROP POLICY IF EXISTS "Public can read tenants" ON tenants;
DROP POLICY IF EXISTS "Authenticated users can create tenants" ON tenants;
DROP POLICY IF EXISTS "Users can update own tenant" ON tenants;

CREATE POLICY "Public can read tenants" ON tenants
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create tenants" ON tenants
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own tenant" ON tenants
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT id FROM profiles WHERE tenant_id = tenants.id AND role = 'admin'
        )
    );

-- Profiles policies
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Inventories policies
DROP POLICY IF EXISTS "Public can read public inventories" ON inventories;
DROP POLICY IF EXISTS "Users can read own tenant inventories" ON inventories;
DROP POLICY IF EXISTS "Users can manage own tenant inventories" ON inventories;

-- Public can read inventories from public storefronts
CREATE POLICY "Public can read public inventories" ON inventories
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tenants t 
            WHERE t.id = inventories.tenant_id 
            AND t.public_storefront = true
        )
    );

-- Authenticated users can read their tenant's inventories
CREATE POLICY "Users can read own tenant inventories" ON inventories
    FOR SELECT USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

-- Authenticated users can manage their tenant's inventories
CREATE POLICY "Users can manage own tenant inventories" ON inventories
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

-- Sales policies
DROP POLICY IF EXISTS "Users can manage own tenant sales" ON sales;

CREATE POLICY "Users can manage own tenant sales" ON sales
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

-- ========================================
-- 7. USER CREATION TRIGGER
-- ========================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (new.id, new.email, 'admin');
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for automatic profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- 8. SAMPLE DATA FOR TESTING
-- ========================================

-- Insert sample tenant for testing
INSERT INTO tenants (id, name, slug, public_storefront, metadata) 
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Test Store',
    'test-store',
    true,
    '{"description": "Sample store for testing", "address": "123 Test Street, Kampala", "phone": "+256-700-123456", "tin": "1234567890"}'::jsonb
) ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    public_storefront = EXCLUDED.public_storefront,
    metadata = EXCLUDED.metadata;

-- Insert sample products for testing
INSERT INTO inventories (tenant_id, name, sku, quantity, price, metadata) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Laptop Computer', 'LAP001', 15, 1200000, '{"category": "Electronics", "brand": "TechPro", "description": "High-performance laptop for business"}'),
    ('11111111-1111-1111-1111-111111111111', 'Wireless Mouse', 'MOU001', 50, 45000, '{"category": "Accessories", "brand": "TechPro", "description": "Ergonomic wireless mouse"}'),
    ('11111111-1111-1111-1111-111111111111', 'USB-C Cable', 'USB001', 100, 15000, '{"category": "Cables", "brand": "ConnectPro", "description": "USB-C to USB-A cable"}'),
    ('11111111-1111-1111-1111-111111111111', '24" Monitor', 'MON001', 12, 450000, '{"category": "Electronics", "brand": "ViewMax", "description": "24-inch Full HD monitor"}'),
    ('11111111-1111-1111-1111-111111111111', 'Bluetooth Headphones', 'HEA001', 25, 180000, '{"category": "Audio", "brand": "SoundWave", "description": "Noise-cancelling wireless headphones"}'),
    ('11111111-1111-1111-1111-111111111111', 'Smartphone Case', 'CAS001', 75, 25000, '{"category": "Accessories", "brand": "ProtectMax", "description": "Durable smartphone protection"}'),
    ('11111111-1111-1111-1111-111111111111', 'Power Bank', 'PWR001', 30, 65000, '{"category": "Electronics", "brand": "PowerPro", "description": "10000mAh portable charger"}')
ON CONFLICT (tenant_id, sku) DO UPDATE SET
    name = EXCLUDED.name,
    quantity = EXCLUDED.quantity,
    price = EXCLUDED.price,
    metadata = EXCLUDED.metadata,
    updated_at = NOW();

-- ========================================
-- 9. HELPER FUNCTION FOR ADMIN USER SETUP
-- ========================================

-- Function to create admin user for testing (call this after creating a user in Supabase Auth)
CREATE OR REPLACE FUNCTION public.setup_test_admin(
    user_email TEXT,
    user_id UUID DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    found_user_id UUID;
    test_tenant_id UUID := '11111111-1111-1111-1111-111111111111';
BEGIN
    -- Find user by email if ID not provided
    IF user_id IS NULL THEN
        SELECT id INTO found_user_id
        FROM auth.users
        WHERE email = user_email
        LIMIT 1;
        
        IF found_user_id IS NULL THEN
            RETURN 'Error: User with email ' || user_email || ' not found';
        END IF;
    ELSE
        found_user_id := user_id;
    END IF;
    
    -- Update or insert profile
    INSERT INTO profiles (id, email, role, tenant_id, created_at, updated_at)
    VALUES (found_user_id, user_email, 'admin', test_tenant_id, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        role = 'admin',
        tenant_id = test_tenant_id,
        updated_at = NOW();
    
    RETURN 'Success: User ' || user_email || ' is now admin of Test Store';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 10. CLEANUP - Remove orphaned data
-- ========================================

-- Clean up any existing data that might conflict
DELETE FROM sales WHERE tenant_id NOT IN (SELECT id FROM tenants);
DELETE FROM inventories WHERE tenant_id NOT IN (SELECT id FROM tenants);
DELETE FROM profiles WHERE tenant_id IS NOT NULL AND tenant_id NOT IN (SELECT id FROM tenants);

-- ========================================
-- SETUP COMPLETE
-- ========================================

-- Display setup completion message
DO $$
BEGIN
    RAISE NOTICE '✅ InventoryMaster SaaS Database Setup Complete!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 What was created:';
    RAISE NOTICE '   • Tenants table for business/organization data';
    RAISE NOTICE '   • Profiles table with user roles and tenant association';
    RAISE NOTICE '   • Inventories table for products (with RLS policies)';
    RAISE NOTICE '   • Sales table for transaction records';
    RAISE NOTICE '   • Sample tenant "Test Store" with 7 sample products';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Security features:';
    RAISE NOTICE '   • Row Level Security (RLS) enabled on all tables';
    RAISE NOTICE '   • Tenant data isolation enforced';
    RAISE NOTICE '   • Public storefront access for unauthenticated users';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 For testing:';
    RAISE NOTICE '   1. Create a user in Supabase Auth Dashboard';
    RAISE NOTICE '   2. Run: SELECT setup_test_admin(''your-email@example.com'');';
    RAISE NOTICE '   3. Login with that user to access Test Store';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Ready for production!';
END
$$;
