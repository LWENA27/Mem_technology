-- 20251009001_create_tenants_inventories.sql
-- Adds tenants and inventories tables and example RLS policies for a SaaS multi-tenant model.

-- Ensure pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tenants table: one row per customer/organization
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Inventories scoped to a tenant
CREATE TABLE IF NOT EXISTS inventories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku TEXT,
  quantity INTEGER NOT NULL DEFAULT 0,
  price NUMERIC,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_inventories_tenant_id ON inventories(tenant_id);
CREATE INDEX IF NOT EXISTS idx_inventories_name ON inventories(name);
CREATE INDEX IF NOT EXISTS idx_inventories_created_at ON inventories(created_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inventories_tenant_sku ON inventories(tenant_id, sku);

-- Add tenant_id to profiles so each user can be associated with a tenant (optional)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES tenants(id);

-- Enable Row Level Security on new tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventories ENABLE ROW LEVEL SECURITY;

-- Policies for tenants
-- Public read access for tenants so the app can show tenant metadata when needed.
CREATE POLICY "Allow select tenants" ON tenants
  FOR SELECT USING (true);

-- Only admin (global) users or service role should be able to update/delete tenants.
-- Note: requests made with the Supabase service_role key bypass RLS. For safety, allow
-- updates/deletes only when profile.role = 'admin'. Adjust roles as needed for your app.
CREATE POLICY "Allow update tenants for global admins" ON tenants
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Allow delete tenants for global admins" ON tenants
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Policies for inventories (tenant-scoped)
-- Allow selecting inventories when the requesting user belongs to the same tenant
CREATE POLICY "Select inventories by tenant" ON inventories
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.tenant_id = inventories.tenant_id
    )
  );

-- Allow inserting inventories only if the user's profile matches the tenant and has an appropriate role
CREATE POLICY "Insert inventories by tenant role" ON inventories
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.tenant_id = tenant_id AND p.role IN ('tenant_admin', 'admin', 'staff')
    )
  );

-- Allow updating inventories only for users in the same tenant with appropriate role
CREATE POLICY "Update inventories by tenant role" ON inventories
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.tenant_id = inventories.tenant_id AND p.role IN ('tenant_admin', 'admin', 'staff')
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.tenant_id = tenant_id AND p.role IN ('tenant_admin', 'admin', 'staff')
    )
  );

-- Allow deleting inventories only for tenant admins or global admins
CREATE POLICY "Delete inventories by tenant admin" ON inventories
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.tenant_id = inventories.tenant_id AND p.role IN ('tenant_admin', 'admin')
    )
  );