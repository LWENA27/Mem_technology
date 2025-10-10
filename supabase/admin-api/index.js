import express from 'express';
import fetch from 'node-fetch';
import bodyParser from 'body-parser';

const app = express();
app.use(bodyParser.json());

const SERVICE_ROLE_KEY = process.env.SERVICE_ROLE_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;

if (!SERVICE_ROLE_KEY || !SUPABASE_URL) {
  console.error('Please set SERVICE_ROLE_KEY and SUPABASE_URL environment variables');
  process.exit(1);
}

const AUTH_URL = `${SUPABASE_URL}/auth/v1`;
const API_URL = `${SUPABASE_URL}/rest/v1`;

// Basic route to create tenant and admin user. In production secure this endpoint!
app.post('/create-tenant', async (req, res) => {
  try {
    const { name, slug, admin_email, admin_password } = req.body;
    if (!name || !slug || !admin_email || !admin_password) {
      return res.status(400).json({ error: 'missing required fields' });
    }

    // Insert tenant
    const createTenantSql = `INSERT INTO tenants (name, slug) VALUES ($1, $2) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id`;
    const tenantResp = await fetch(`${API_URL}/rpc`, {
      method: 'POST',
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ q: createTenantSql, args: [name, slug] })
    });
    const tenantJson = await tenantResp.json();
    const tenant_id = tenantJson && tenantJson[0] && tenantJson[0].id ? tenantJson[0].id : null;

    // Create admin user
    const userResp = await fetch(`${AUTH_URL}/admin/users`, {
      method: 'POST',
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email: admin_email, password: admin_password })
    });
    const userJson = await userResp.json();
    const user_id = userJson.id;

    // Attach profile to tenant using RPC function
    const attachSql = `SELECT public.attach_profile_to_tenant('${user_id}'::uuid, '${tenant_id}'::uuid, 'tenant_admin')`;
    await fetch(`${API_URL}/rpc`, {
      method: 'POST',
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ q: attachSql })
    });

    res.json({ tenant_id, user_id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: String(err) });
  }
});

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`Admin API listening on ${port}`));
