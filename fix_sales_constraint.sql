-- Fix sales table to reference inventories instead of products
-- This script updates the foreign key constraint for the sales table

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE public.sales DROP CONSTRAINT IF EXISTS sales_product_id_fkey;

-- Step 2: Add new foreign key constraint pointing to inventories table
ALTER TABLE public.sales 
ADD CONSTRAINT sales_product_id_fkey 
FOREIGN KEY (product_id) REFERENCES public.inventories(id);

-- Verify the constraint was created
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_name = 'sales_product_id_fkey';