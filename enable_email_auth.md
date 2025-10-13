# Enable Email Authentication in Supabase

## 🚨 Current Issue:
Your registration is failing with error: `Email signups are disabled`

## 📋 Solution Steps:

### 1. Go to Supabase Dashboard
- Open: https://supabase.com/dashboard
- Select your project: `kzjgdeqfmxkmpmadtbpb`

### 2. Navigate to Authentication Settings
- Click on **Authentication** in the left sidebar
- Click on **Settings** tab
- Look for **Auth Providers** section

### 3. Enable Email Provider
- Find **Email** provider in the list
- Toggle it **ON** (enable it)
- Make sure "Enable email confirmations" is set according to your preference:
  - ✅ **Turn OFF** if you don't want email confirmation (recommended for development)
  - ❌ Turn ON if you want users to confirm their email

### 4. Save Settings
- Click **Save** at the bottom of the page
- Wait for the settings to be applied

### 5. Additional Settings to Check
Under **Authentication** → **Settings**:

#### Email Templates (Optional but recommended):
- **Confirm signup**: Customize if email confirmation is enabled
- **Reset password**: Customize password reset email
- **Magic link**: Customize magic link email

#### URL Configuration:
- **Site URL**: Set to your deployed URL or `http://localhost:3000` for development
- **Redirect URLs**: Add any additional URLs if needed

## 🔧 Alternative: SQL Method (if dashboard doesn't work)

If you can't access the dashboard, run this in Supabase SQL Editor:

```sql
-- Enable email authentication
UPDATE auth.config 
SET raw_app_meta_data = jsonb_set(
    COALESCE(raw_app_meta_data, '{}'::jsonb),
    '{providers,email,enabled}',
    'true'::jsonb
);

-- Disable email confirmations (optional)
UPDATE auth.config 
SET raw_app_meta_data = jsonb_set(
    COALESCE(raw_app_meta_data, '{}'::jsonb),
    '{mailer,autoconfirm}',
    'true'::jsonb
);
```

## ✅ After Enabling Email Auth:

1. **Test Registration**: Try registering a new user in your app
2. **Check Logs**: Monitor Flutter logs for success messages
3. **Verify Database**: Check if users are created in Supabase Auth dashboard

## 🐛 Common Issues After Enabling:

### Issue: Still getting authentication errors
**Solution**: 
- Clear app cache/data
- Restart the Flutter app
- Wait 1-2 minutes for Supabase settings to propagate

### Issue: Email confirmation required
**Solution**: 
- Go back to Authentication → Settings
- Turn OFF "Enable email confirmations"
- Or use the `disable_email_confirmation.sql` script we created earlier

## 📞 Need Help?
If you continue having issues, share the new error messages and I'll help debug further!