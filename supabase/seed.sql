-- seed.sql
-- Sample seed data for SaaS multi-tenant setup.
-- This will create a demo tenant and a few sample inventories. It's safe to run multiple times
-- because it uses INSERT ... ON CONFLICT DO NOTHING where appropriate.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Demo tenant
INSERT INTO tenants (id, name, slug, metadata)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Demo Tenant',
  'demo-tenant',
  jsonb_build_object('demo', true)
)
ON CONFLICT (slug) DO NOTHING;

-- Demo inventories for demo tenant
INSERT INTO inventories (id, tenant_id, name, sku, quantity, price, metadata)
VALUES
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', 'Sample Widget', 'SW-001', 100, 9.99, '{}'::jsonb)
ON CONFLICT (tenant_id, sku) DO NOTHING;

INSERT INTO inventories (id, tenant_id, name, sku, quantity, price, metadata)
VALUES
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001', 'Another Item', 'AI-001', 50, 19.99, '{}'::jsonb)
ON CONFLICT (tenant_id, sku) DO NOTHING;

-- Helpful function to attach an existing profile (auth user) to a tenant and set role
-- Call as: SELECT attach_profile_to_tenant('<user-uuid>', '<tenant-uuid>', 'tenant_admin');
CREATE OR REPLACE FUNCTION public.attach_profile_to_tenant(p_profile_id UUID, p_tenant_id UUID, p_role TEXT DEFAULT 'tenant_admin')
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Ensure tenant exists
  IF NOT EXISTS (SELECT 1 FROM tenants WHERE id = p_tenant_id) THEN
    RAISE EXCEPTION 'tenant % does not exist', p_tenant_id;
  END IF;

  -- Update profiles if exists
  IF EXISTS (SELECT 1 FROM public.profiles WHERE id = p_profile_id) THEN
    UPDATE public.profiles
    SET tenant_id = p_tenant_id,
        role = p_role,
        updated_at = NOW()
    WHERE id = p_profile_id;
  ELSE
    -- Insert placeholder profile pointing to an existing auth.users row (use only with service_role)
    INSERT INTO public.profiles (id, role, tenant_id, created_at, updated_at)
    VALUES (p_profile_id, p_role, p_tenant_id, NOW(), NOW());
  END IF;
END;
$$;
