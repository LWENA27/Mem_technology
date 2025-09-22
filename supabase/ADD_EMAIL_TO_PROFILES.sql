-- Add email column to profiles and populate it from auth.users
-- Run this in your Supabase SQL editor or psql with a service_role key if needed.

BEGIN;

-- 1. Add the column (nullable at first)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email text;

-- 2. Populate email from auth.users (if you have access via service role)
-- Note: auth.users stores user email in 'email' column. If you don't have
-- permission to query auth.users directly, run this with a Supabase
-- service_role key or perform the mapping in an admin script.

UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id
  AND (p.email IS NULL OR p.email = '');

-- 3. (Optional) Make column not null once verified
-- ALTER TABLE public.profiles ALTER COLUMN email SET NOT NULL;

COMMIT;

-- "Add bulk-sync UI button that calls the Edge Function"
-- "Convert Edge function to TypeScript / Deno"
-- "Help run the migration via CLI (I'll paste safe env values locally)"