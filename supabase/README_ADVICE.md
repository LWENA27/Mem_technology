If your admin UI shows a database error like "profiles.email does not exist":

1) Run the migration SQL in `ADD_EMAIL_TO_PROFILES.sql` using Supabase SQL editor or psql.
   - You may need to run the UPDATE step with a `service_role` key because `auth.users` is restricted.

2) Verify the `email` values in `profiles`.

3) After verification, you can make the column NOT NULL and add an index for faster searches.

If you can't run DB migrations, the UI now falls back to showing "No email" when the column is missing.

Contact your DB admin or use a Supabase Edge Function to sync emails if needed.
