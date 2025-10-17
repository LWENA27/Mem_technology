# 🚀 LwenaTech Production Supabase Setup Guide

## Step 1: Create New Supabase Project

### 1.1 Project Creation
1. Go to [Supabase Dashboard](https://supabase.com/dashboard) (already opened for you)
2. Click **"New Project"** button
3. Fill in project details:
   ```
   Name: LwenaTech Inventory Production
   Database Password: [Generate a strong password - save it!]
   Region: Choose closest to Tanzania (e.g., ap-southeast-1)
   Pricing Plan: Free (can upgrade later)
   ```
4. Click **"Create new project"**
5. Wait 2-3 minutes for project initialization

### 1.2 Get Project Credentials
Once your project is ready:
1. Go to **Settings → API**
2. Copy these values (you'll need them):
   ```
   Project URL: https://[your-project-id].supabase.co
   Anon (public) key: eyJ0eXAiOiJKV1Q... [long string]
   Service role key: eyJ0eXAiOiJKV1Q... [different long string]
   ```

## Step 2: Apply Database Migrations

### 2.1 Method 1: SQL Editor (Recommended)
1. In your Supabase dashboard, go to **SQL Editor**
2. Create a new query
3. Copy and paste the content from: `supabase/migrations/20251016215748_complete_schema_with_indexes.sql`
4. Click **"Run"**
5. Create another new query
6. Copy and paste the content from: `supabase/migrations/20251017000000_add_role_based_access.sql`
7. Click **"Run"**

### 2.2 Method 2: Supabase CLI (Alternative)
If you have Supabase CLI installed:
```bash
# Link to your project
supabase link --project-ref [your-project-id]

# Push migrations
supabase db push
```

## Step 3: Configure Storage Bucket

### 3.1 Create product-images Bucket
1. Go to **Storage** in Supabase dashboard
2. Click **"New bucket"**
3. Set:
   ```
   Name: product-images
   Public bucket: ✅ (checked)
   File size limit: 10MB
   Allowed MIME types: image/jpeg, image/png, image/gif, image/webp
   ```
4. Click **"Create bucket"**

### 3.2 Set Bucket Policies
Go to **Storage → Policies** and add these policies for `product-images`:

**Policy 1: Allow authenticated users to upload**
```sql
CREATE POLICY "Allow authenticated users to upload images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'product-images' AND
    auth.role() = 'authenticated'
  );
```

**Policy 2: Allow public read access**
```sql
CREATE POLICY "Allow public read access to product images" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');
```

## Step 4: Configure Authentication

### 4.1 Email Settings
1. Go to **Authentication → Settings**
2. Under **Email Auth**:
   ```
   Enable email confirmations: ✅
   Enable email change confirmations: ✅
   Enable secure password change: ✅
   ```

### 4.2 URL Configuration
1. Still in Authentication Settings
2. Set **Site URL**: `https://your-domain.com` (will update after deployment)
3. Add **Redirect URLs** (will add after deployment):
   - `https://your-domain.com/auth/callback`
   - `http://localhost:3000` (for local development)

## Step 5: Verify Setup

### 5.1 Check Tables Created
Go to **Database → Tables** and verify you see:
- ✅ tenants
- ✅ inventories  
- ✅ sales
- ✅ profiles

### 5.2 Check Storage
Go to **Storage** and verify:
- ✅ product-images bucket exists
- ✅ Policies are set correctly

### 5.3 Test Connection
You can test the connection by running a simple query in SQL Editor:
```sql
SELECT 'LwenaTech Production Setup Complete!' as status;
```

## Next Steps Checklist

After completing above steps:

- [ ] ✅ Project created and initialized
- [ ] ✅ Copied Project URL and Anon key  
- [ ] ✅ Database migrations applied
- [ ] ✅ Storage bucket created with policies
- [ ] ✅ Authentication configured
- [ ] ✅ All tables verified

**Once complete, you're ready for Step 2: Run the production setup script!**

## Important Notes

🔐 **Security**: Save your database password and service role key securely
📝 **Credentials**: Keep your Project URL and Anon key handy for the next step
🌍 **Region**: Choose a region close to your users (Tanzania/East Africa)
💾 **Backup**: Consider setting up automated backups in production

## Support
- **Technical Support**: adamlwena22@gmail.com
- **WhatsApp Community**: https://chat.whatsapp.com/B8RUxQsQM665hjVm3Z05lc?mode=ems_share_t