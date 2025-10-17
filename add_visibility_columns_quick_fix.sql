-- Run this SQL script in Supabase SQL Editor to add the missing visibility columns
-- This will fix the error: "column inventories.visible_to_customers does not exist"

-- Add visible_to_customers column to inventories table
ALTER TABLE inventories 
ADD COLUMN IF NOT EXISTS visible_to_customers BOOLEAN DEFAULT true;

-- Add show_products_to_customers column to tenants table  
ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS show_products_to_customers BOOLEAN DEFAULT true;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_inventories_visible_to_customers 
ON inventories(visible_to_customers);

CREATE INDEX IF NOT EXISTS idx_tenants_show_products_to_customers 
ON tenants(show_products_to_customers);

-- Update existing records to be visible by default
UPDATE inventories 
SET visible_to_customers = true 
WHERE visible_to_customers IS NULL;

UPDATE tenants 
SET show_products_to_customers = true 
WHERE show_products_to_customers IS NULL;

-- Display success message
SELECT 'Visibility columns added successfully! Your app should now work without errors.' as result;