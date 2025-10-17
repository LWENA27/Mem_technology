-- Add visibility controls to inventories and tenant settings
-- This enables per-product and global visibility control

-- Add visibility column to inventories table
ALTER TABLE inventories 
ADD COLUMN IF NOT EXISTS visible_to_customers BOOLEAN DEFAULT true;

-- Add global settings to tenants table
ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS show_products_to_customers BOOLEAN DEFAULT true;

-- Create index for visibility queries
CREATE INDEX IF NOT EXISTS idx_inventories_visibility 
ON inventories(visible_to_customers, tenant_id);

-- Update comments
COMMENT ON COLUMN inventories.visible_to_customers IS 'Whether this product is visible to customers on storefront';
COMMENT ON COLUMN tenants.show_products_to_customers IS 'Global setting: whether any products are visible to customers';

-- Test the changes
SELECT 'Visibility columns added successfully' as status;