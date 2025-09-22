// Example Supabase Edge Function to sync auth.users -> public.profiles.email
// Deploy with supabase CLI. This example uses the service_role key stored
// in environment variable SERVICE_ROLE_KEY (set via supabase secrets set).

import fetch from 'node-fetch';

export async function handler(req) {
  const svcKey = process.env.SERVICE_ROLE_KEY;
  if (!svcKey) {
    return new Response(JSON.stringify({ error: 'SERVICE_ROLE_KEY not set' }), { status: 500 });
  }

  // Replace with your Supabase URL
  const SUPABASE_URL = process.env.SUPABASE_URL;
  if (!SUPABASE_URL) {
    return new Response(JSON.stringify({ error: 'SUPABASE_URL not set' }), { status: 500 });
  }

  try {
    // Fetch auth.users via the admin endpoint
    const usersRes = await fetch(`${SUPABASE_URL}/admin/v1/users`, {
      headers: {
        Authorization: `Bearer ${svcKey}`,
        apikey: svcKey,
      },
    });

    const users = await usersRes.json();

    // For each user, upsert into profiles
    for (const u of users) {
      const profile = {
        id: u.id,
        email: u.email,
      };

      // Upsert via REST table endpoint
      await fetch(`${SUPABASE_URL}/rest/v1/profiles`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${svcKey}`,
          apikey: svcKey,
          'Content-Type': 'application/json',
          Prefer: 'resolution=merge-duplicates',
        },
        body: JSON.stringify(profile),
      });
    }

    return new Response(JSON.stringify({ status: 'ok', synced: users.length }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
}
