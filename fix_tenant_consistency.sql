-- Fix tenant consistency and create default public tenant
-- Run this in your Supabase SQL Editor

-- 1. Ensure default public tenant exists
INSERT INTO tenants (id, name, slug, public_storefront, metadata) 
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Public Store',
    'public-store',
    true,
    '{"description": "Default public store for shared products", "is_default": true}'::jsonb
) ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    public_storefront = EXCLUDED.public_storefront,
    metadata = EXCLUDED.metadata;

-- 2. Move all orphaned inventories to the default public tenant
UPDATE inventories 
SET tenant_id = '11111111-1111-1111-1111-111111111111'
WHERE tenant_id IS NULL OR tenant_id NOT IN (SELECT id FROM tenants);

-- 3. Ensure all authenticated users without tenant get the default tenant
UPDATE profiles 
SET tenant_id = '11111111-1111-1111-1111-111111111111'
WHERE tenant_id IS NULL;

-- 4. Check the current state
SELECT 
    'Tenants' as table_name,
    count(*) as total_records,
    count(*) FILTER (WHERE public_storefront = true) as public_tenants
FROM tenants
UNION ALL
SELECT 
    'Inventories' as table_name,
    count(*) as total_records,
    count(DISTINCT tenant_id) as unique_tenants
FROM inventories
UNION ALL
SELECT 
    'Profiles' as table_name,
    count(*) as total_records,
    count(*) FILTER (WHERE tenant_id IS NOT NULL) as with_tenant
FROM profiles;