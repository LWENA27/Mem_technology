-- InventoryMaster SaaS - Database Migration Script
-- This script updates your existing database to support the new multi-tenant structure
-- Run this in your Supabase Dashboard → SQL Editor

-- ========================================
-- 1. ADD MISSING COLUMNS TO EXISTING TABLES
-- ========================================

-- Add missing columns to sales table
ALTER TABLE public.sales 
ADD COLUMN IF NOT EXISTS tenant_id uuid,
ADD COLUMN IF NOT EXISTS receipt_number text,
ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();

-- Add missing columns to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();

-- ========================================
-- 2. ADD FOREIGN KEY CONSTRAINTS
-- ========================================

-- Add foreign key constraint for tenant_id in sales table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'sales_tenant_id_fkey'
    ) THEN
        ALTER TABLE public.sales 
        ADD CONSTRAINT sales_tenant_id_fkey 
        FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);
    END IF;
END $$;

-- ========================================
-- 3. ENABLE ROW LEVEL SECURITY
-- ========================================

-- Enable RLS on all tables
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 4. CREATE INDEXES FOR PERFORMANCE
-- ========================================

-- Indexes for inventories
CREATE INDEX IF NOT EXISTS idx_inventories_tenant_id ON public.inventories(tenant_id);
CREATE INDEX IF NOT EXISTS idx_inventories_name ON public.inventories(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inventories_tenant_sku ON public.inventories(tenant_id, sku) WHERE sku IS NOT NULL;

-- Indexes for sales
CREATE INDEX IF NOT EXISTS idx_sales_tenant_id ON public.sales(tenant_id);
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON public.sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON public.sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_receipt_number ON public.sales(receipt_number) WHERE receipt_number IS NOT NULL;

-- Indexes for products
CREATE INDEX IF NOT EXISTS idx_products_name ON public.products(name);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);

-- ========================================
-- 5. DROP EXISTING POLICIES (Clean slate)
-- ========================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can read tenants" ON public.tenants;
DROP POLICY IF EXISTS "Authenticated users can create tenants" ON public.tenants;
DROP POLICY IF EXISTS "Users can update own tenant" ON public.tenants;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Public can read public inventories" ON public.inventories;
DROP POLICY IF EXISTS "Users can read own tenant inventories" ON public.inventories;
DROP POLICY IF EXISTS "Users can manage own tenant inventories" ON public.inventories;
DROP POLICY IF EXISTS "Users can manage own tenant products" ON public.products;
DROP POLICY IF EXISTS "Users can manage own tenant sales" ON public.sales;

-- ========================================
-- 6. CREATE RLS POLICIES
-- ========================================

-- Tenants policies
CREATE POLICY "Public can read tenants" ON public.tenants
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create tenants" ON public.tenants
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own tenant" ON public.tenants
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT id FROM public.profiles WHERE tenant_id = tenants.id AND role = 'admin'
        )
    );

-- Profiles policies
CREATE POLICY "Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Inventories policies
CREATE POLICY "Public can read public inventories" ON public.inventories
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tenants t 
            WHERE t.id = inventories.tenant_id 
            AND t.public_storefront = true
        )
    );

CREATE POLICY "Users can read own tenant inventories" ON public.inventories
    FOR SELECT USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM public.profiles WHERE id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own tenant inventories" ON public.inventories
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        tenant_id IN (
            SELECT tenant_id FROM public.profiles WHERE id = auth.uid()
        )
    );

-- Products policies (assuming products will be tenant-specific in the future)
CREATE POLICY "Users can manage products" ON public.products
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Sales policies
CREATE POLICY "Users can manage own tenant sales" ON public.sales
    FOR ALL USING (
        auth.uid() IS NOT NULL AND 
        (tenant_id IN (
            SELECT tenant_id FROM public.profiles WHERE id = auth.uid()
        ) OR tenant_id IS NULL)
    );

-- ========================================
-- 7. UPDATE/CREATE USER TRIGGER
-- ========================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (new.id, new.email, 'admin')
    ON CONFLICT (id) DO NOTHING;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- 8. ENSURE SAMPLE TENANT EXISTS
-- ========================================

-- Insert or update sample tenant
INSERT INTO public.tenants (id, name, slug, public_storefront, metadata) 
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

-- ========================================
-- 9. MIGRATE EXISTING DATA
-- ========================================

-- Update existing inventories to belong to test tenant if they don't have tenant_id
UPDATE public.inventories 
SET tenant_id = '11111111-1111-1111-1111-111111111111'
WHERE tenant_id IS NULL;

-- Update existing sales to belong to test tenant if they don't have tenant_id
UPDATE public.sales 
SET tenant_id = '11111111-1111-1111-1111-111111111111'
WHERE tenant_id IS NULL;

-- ========================================
-- 10. HELPER FUNCTION FOR ADMIN SETUP
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
    INSERT INTO public.profiles (id, email, role, tenant_id, created_at, updated_at)
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
-- MIGRATION COMPLETE
-- ========================================

SELECT 'InventoryMaster SaaS Migration Complete!' as status,
       'Your existing data has been preserved and updated' as message,
       '1. Create user in Supabase Auth Dashboard' as step_1,
       '2. Run: SELECT setup_test_admin(''your-email@example.com'');' as step_2,
       '3. Login with that user to access Test Store' as step_3;