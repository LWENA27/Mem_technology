-- Complete Schema Migration with Performance Indexes and Constraints
-- This migration establishes the final production-ready schema

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tenants table first (referenced by other tables)
CREATE TABLE IF NOT EXISTS public.tenants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  public_storefront boolean DEFAULT true,
  CONSTRAINT tenants_pkey PRIMARY KEY (id)
);

-- Create inventories table (consolidated product table)
CREATE TABLE IF NOT EXISTS public.inventories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  name text NOT NULL,
  sku text UNIQUE,
  quantity integer NOT NULL DEFAULT 0,
  selling_price numeric,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  category text NOT NULL,
  brand text,
  description text,
  image_url text,
  buying_price numeric NOT NULL,
  CONSTRAINT inventories_pkey PRIMARY KEY (id),
  CONSTRAINT inventories_tenant_id_fkey FOREIGN KEY (tenant_id) 
    REFERENCES public.tenants(id) ON DELETE CASCADE
);

-- Create sales table with corrected column names
CREATE TABLE IF NOT EXISTS public.sales (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  product_name text NOT NULL,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  total_amount numeric NOT NULL,
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  date timestamp with time zone NOT NULL DEFAULT now(),
  tenant_id uuid NOT NULL,
  receipt_number text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sales_pkey PRIMARY KEY (id),
  CONSTRAINT sales_tenant_id_fkey FOREIGN KEY (tenant_id) 
    REFERENCES public.tenants(id) ON DELETE CASCADE,
  CONSTRAINT sales_product_id_fkey FOREIGN KEY (product_id) 
    REFERENCES public.inventories(id) ON DELETE RESTRICT
);

-- Create profiles table with role-based access
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  role text NOT NULL DEFAULT 'user'::text,
  email text,
  name text,
  created_at timestamp with time zone DEFAULT now(),
  tenant_id uuid,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) 
    REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT profiles_tenant_id_fkey FOREIGN KEY (tenant_id) 
    REFERENCES public.tenants(id) ON DELETE CASCADE,
  CONSTRAINT profiles_role_check CHECK (role = ANY (ARRAY['user'::text, 'admin'::text, 'staff'::text, 'super_admin'::text]))
);

-- Add Performance Indexes (THE MISSING PIECE!)
-- Multi-tenant query optimization
CREATE INDEX IF NOT EXISTS idx_inventories_tenant_id ON public.inventories(tenant_id);
CREATE INDEX IF NOT EXISTS idx_sales_tenant_id ON public.sales(tenant_id);
CREATE INDEX IF NOT EXISTS idx_profiles_tenant_id ON public.profiles(tenant_id);

-- Product lookup optimization
CREATE INDEX IF NOT EXISTS idx_inventories_sku ON public.inventories(sku);
CREATE INDEX IF NOT EXISTS idx_inventories_category ON public.inventories(category);
CREATE INDEX IF NOT EXISTS idx_inventories_name ON public.inventories USING gin(to_tsvector('english', name));

-- Sales query optimization
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON public.sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON public.sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_receipt_number ON public.sales(receipt_number);

-- Tenant slug optimization
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON public.tenants(slug);

-- Role-based access optimization
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
DROP TRIGGER IF EXISTS update_inventories_updated_at ON public.inventories;
CREATE TRIGGER update_inventories_updated_at 
    BEFORE UPDATE ON public.inventories 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sales_updated_at ON public.sales;
CREATE TRIGGER update_sales_updated_at 
    BEFORE UPDATE ON public.sales 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Super Admin Helper Functions
CREATE OR REPLACE FUNCTION is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = user_id AND role = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to promote user to super admin
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
    INSERT INTO public.profiles (id, role, email, updated_at)
    VALUES (user_id, 'super_admin', user_email, NOW())
    ON CONFLICT (id) 
    DO UPDATE SET 
        role = 'super_admin',
        updated_at = NOW();
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION is_super_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION promote_to_super_admin(TEXT) TO service_role;

-- Row Level Security (RLS) Policies
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Tenant access policies
CREATE POLICY "Users can view their tenant" ON public.tenants
    FOR SELECT USING (
        id IN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid())
        OR is_super_admin(auth.uid())
    );

-- Inventory access policies  
CREATE POLICY "Users can manage inventory in their tenant" ON public.inventories
    FOR ALL USING (
        tenant_id IN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid())
        OR is_super_admin(auth.uid())
    );

-- Sales access policies
CREATE POLICY "Users can manage sales in their tenant" ON public.sales
    FOR ALL USING (
        tenant_id IN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid())
        OR is_super_admin(auth.uid())
    );

-- Profile access policies
CREATE POLICY "Users can view profiles in their tenant" ON public.profiles
    FOR SELECT USING (
        tenant_id IN (SELECT tenant_id FROM public.profiles WHERE id = auth.uid())
        OR is_super_admin(auth.uid())
        OR id = auth.uid()
    );

CREATE POLICY "Super admins can manage all profiles" ON public.profiles
    FOR ALL USING (is_super_admin(auth.uid()));

-- Comments for documentation
COMMENT ON TABLE public.inventories IS 'Consolidated product inventory with multi-tenant support';
COMMENT ON TABLE public.sales IS 'Sales transactions with corrected column names matching Dart code';
COMMENT ON TABLE public.profiles IS 'User profiles with role-based access control';
COMMENT ON COLUMN public.sales.date IS 'Sale date - matches Dart model field name';
COMMENT ON COLUMN public.sales.total_amount IS 'Total amount - matches Dart model field name';
COMMENT ON COLUMN public.inventories.selling_price IS 'Selling price - distinct from buying_price';
COMMENT ON COLUMN public.profiles.role IS 'User role: user, admin, staff, super_admin';

-- Example: Create your first super admin (uncomment and replace email)
-- SELECT promote_to_super_admin('your-admin@email.com');

COMMIT;
