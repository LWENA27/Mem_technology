# Supabase Admin API (minimal)

This tiny Express server demonstrates a secure server-side endpoint to create tenants and bootstrap an admin user. It must run on a trusted server because it requires the Supabase `service_role` key.

Setup

1. Install dependencies

```bash
cd supabase/admin-api
npm install
```

2. Set environment variables and start

```bash
SERVICE_ROLE_KEY=your_service_role_key SUPABASE_URL=https://xyz.supabase.co npm start
```

Endpoint
- POST /create-tenant
  - body: { name, slug, admin_email, admin_password }
  - returns: { tenant_id, user_id }

Security
- Do not expose this server publicly without authentication. Add an API key or protect with OAuth.
- The server uses the Supabase service role key which bypasses RLS — keep it secret.
