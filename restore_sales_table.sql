-- Check if sales table exists and restore/create it if missing
-- Run this in your Supabase SQL Editor

-- First, check where the sales table is located
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'sales';

-- If the above shows sales is in cleanup_backup, move it back to public:
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'cleanup_backup' AND table_name = 'sales'
  )
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'sales'
  ) THEN
    ALTER TABLE cleanup_backup.sales SET SCHEMA public;
    RAISE NOTICE 'Moved sales table from cleanup_backup to public schema';
  END IF;
END$$;

-- If sales doesn't exist anywhere, create it:
CREATE TABLE IF NOT EXISTS public.sales (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  total_price REAL NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  sale_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON public.sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON public.sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_customer_name ON public.sales(customer_name);

-- Enable Row Level Security
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY IF NOT EXISTS "sales_select_auth" ON public.sales
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "sales_insert_auth" ON public.sales
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "sales_update_auth" ON public.sales
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "sales_delete_auth" ON public.sales
  FOR DELETE USING (auth.role() = 'authenticated');

-- Verify the table exists and check policies
SELECT 'Sales table created/restored successfully' as status;
SELECT table_schema, table_name FROM information_schema.tables WHERE table_name = 'sales';
SELECT * FROM pg_policies WHERE schemaname = 'public' AND tablename = 'sales';
