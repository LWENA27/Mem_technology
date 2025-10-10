# Supabase SaaS initialization helper

This folder contains helper SQL and scripts to bootstrap a multi-tenant schema for turning this project into a SaaS.

Files added
- `seed.sql` — sample seed data and helper function `attach_profile_to_tenant`.
- `scripts/create_tenant.sh` — wrapper to create a tenant and an admin user using the Supabase Admin API.

Prerequisites
- Supabase project URL (e.g. `https://xyz.supabase.co`) and a `service_role` key. Store them as environment variables:

  SERVICE_ROLE_KEY=your_service_role_key
  SUPABASE_URL=https://xyz.supabase.co

- For psql fallback when applying SQL you may set `SUPABASE_DB_URL` to your Postgres connection string (includes password).

Usage: create a tenant + admin user

Example:

```bash
SERVICE_ROLE_KEY=... SUPABASE_URL=https://xyz.supabase.co \
  ./supabase/scripts/create_tenant.sh "Acme Ltd" acme admin@acme.example 'StrongPass123!'
```

What the script does
- Inserts a row into `tenants` (or updates if slug exists)
- Creates an auth user via the Admin API
- Attaches the created/updated `profiles` row to the new tenant and sets role `tenant_admin` using `attach_profile_to_tenant`.

Next steps to integrate with your dashboard
- In your dashboard (Flutter app), after sign-in, read `profiles.tenant_id` to know which tenant the user belongs to.
- Use RLS rules already present on `inventories` (and future tables) to ensure users can only access tenant-scoped rows.
- Add admin pages that use the service_role key (on server only) to create tenants, manage billing, and promote users.

Security notes
- Never expose `SERVICE_ROLE_KEY` to client apps. Use it only in server-side processes or CI.
- When performing tenant provisioning from a frontend, call your own backend which holds the service role key.

If you want, I can:
- Add an Express/Node.js tiny admin API that wraps tenant creation so you don't store service_role on your machine.
- Add sample Flutter dashboard screens for tenant creation and switching.
