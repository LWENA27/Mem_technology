-- InventoryMaster SaaS - Production Database Setup
-- Single file for clean, production-ready database
-- Run this ENTIRE file in your Supabase Dashboard → SQL Editor (do not run in parts)

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. DROP EXISTING TABLES (Clean slate)
-- ========================================

-- Drop tables in reverse dependency order to avoid foreign key conflicts
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS inventories CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.setup_test_admin(TEXT, UUID) CASCADE;

-- ========================================
-- 2. CREATE TENANTS TABLE FIRST
-- ========================================

CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    public_storefront BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 3. CREATE PROFILES TABLE
-- ========================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'admin',
    email TEXT,
    tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 4. CREATE INVENTORIES TABLE
-- ========================================

CREATE TABLE inventories (
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

ALTER TABLE inventories ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 5. CREATE SALES TABLE
-- ========================================

CREATE TABLE sales (
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

ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 6. CREATE ALL INDEXES
-- ========================================

-- Indexes for inventories
CREATE INDEX idx_inventories_tenant_id ON inventories(tenant_id);
CREATE INDEX idx_inventories_name ON inventories(name);
CREATE UNIQUE INDEX idx_inventories_tenant_sku ON inventories(tenant_id, sku) WHERE sku IS NOT NULL;

-- Indexes for sales
CREATE INDEX idx_sales_tenant_id ON sales(tenant_id);
CREATE INDEX idx_sales_product_id ON sales(product_id);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_receipt_number ON sales(receipt_number) WHERE receipt_number IS NOT NULL;

-- ========================================
-- 7. CREATE RLS POLICIES
-- ========================================

-- Tenants policies
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
CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Inventories policies
CREATE POLICY "Public can read public inventories" ON inventories
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tenants t 
            WHERE t.id = inventories.tenant_id 
            AND t.public_storefront = true
        )
    );

CREATE POLICY "Users can read own tenant inventories" ON inventories
    FOR SELECT USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own tenant inventories" ON inventories
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

-- Sales policies
CREATE POLICY "Users can manage own tenant sales" ON sales
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM profiles WHERE id = auth.uid()
        )
    );

-- ========================================
-- 8. CREATE USER TRIGGER
-- ========================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (new.id, new.email, 'admin');
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- 9. INSERT SAMPLE DATA
-- ========================================

-- Insert sample tenant
INSERT INTO tenants (id, name, slug, public_storefront, metadata) 
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Test Store',
    'test-store',
    true,
    '{"description": "Sample store for testing", "address": "123 Test Street, Kampala", "phone": "+256-700-123456", "tin": "1234567890"}'::jsonb
);

-- Insert sample products
INSERT INTO inventories (tenant_id, name, sku, quantity, price, metadata) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Laptop Computer', 'LAP001', 15, 1200000, '{"category": "Electronics", "brand": "TechPro", "description": "High-performance laptop for business"}'),
    ('11111111-1111-1111-1111-111111111111', 'Wireless Mouse', 'MOU001', 50, 45000, '{"category": "Accessories", "brand": "TechPro", "description": "Ergonomic wireless mouse"}'),
    ('11111111-1111-1111-1111-111111111111', 'USB-C Cable', 'USB001', 100, 15000, '{"category": "Cables", "brand": "ConnectPro", "description": "USB-C to USB-A cable"}'),
    ('11111111-1111-1111-1111-111111111111', '24" Monitor', 'MON001', 12, 450000, '{"category": "Electronics", "brand": "ViewMax", "description": "24-inch Full HD monitor"}'),
    ('11111111-1111-1111-1111-111111111111', 'Bluetooth Headphones', 'HEA001', 25, 180000, '{"category": "Audio", "brand": "SoundWave", "description": "Noise-cancelling wireless headphones"}'),
    ('11111111-1111-1111-1111-111111111111', 'Smartphone Case', 'CAS001', 75, 25000, '{"category": "Accessories", "brand": "ProtectMax", "description": "Durable smartphone protection"}'),
    ('11111111-1111-1111-1111-111111111111', 'Power Bank', 'PWR001', 30, 65000, '{"category": "Electronics", "brand": "PowerPro", "description": "10000mAh portable charger"}');

-- ========================================
-- 10. HELPER FUNCTION
-- ========================================

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
-- COMPLETION MESSAGE
-- ========================================

SELECT 'InventoryMaster SaaS Database Setup Complete!' as status,
       'Ready for production use' as message,
       '1. Create user in Supabase Auth' as step_1,
       '2. Run: SELECT setup_test_admin(''your-email@example.com'');' as step_2,
       '3. Login with that user to access Test Store' as step_3;