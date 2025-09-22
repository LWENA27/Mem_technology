Supabase Edge Function: sync_users

Purpose:
- Sync `auth.users` -> `public.profiles.email` for all users.
- Intended to be deployed as a Supabase Edge Function. It requires the `service_role` key stored as a secret.

Quick notes:
- Use the Supabase CLI `supabase functions deploy sync_users` to deploy.
- Set the secret `SERVICE_ROLE_KEY` in Supabase (Project Settings -> API -> Service Role Key) or via the CLI.

Example deploy:
1) Set secret:
   supabase secrets set SERVICE_ROLE_KEY="<service_role_key>"
2) Deploy:
   supabase functions deploy sync_users --project <project-ref> --no-verify

Invoke manually to sync all users. You can also schedule this function from your infrastructure.
