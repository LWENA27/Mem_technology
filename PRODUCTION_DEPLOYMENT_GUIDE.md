# 🚀 LwenaTech Production Deployment Guide

## Step 1: Create Production Supabase Project

### 1.1 Create New Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign in with your GitHub account
3. Click "New Project"
4. Choose these settings:
   - **Name**: `LwenaTech-Production`
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your target market (Africa/Europe)
   - **Pricing Plan**: Pro Plan (for production features)

### 1.2 Configure Project Settings
After project creation:
1. Go to Settings → General
2. Copy your project details:
   - **Project URL**: `https://[your-project-id].supabase.co`
   - **API Key (anon)**: Copy the anon/public key
   - **API Key (service_role)**: Copy service role key (keep secret!)

### 1.3 Apply Database Migrations
```bash
# In your project directory
supabase link --project-ref [your-project-id]
supabase db push
```

### 1.4 Configure Authentication
1. Go to Authentication → Settings
2. Enable Email provider
3. Set Site URL to your production domain
4. Configure redirect URLs for your domain

### 1.5 Setup Storage Buckets
1. Go to Storage
2. Create `product-images` bucket
3. Make it public
4. Set upload limits to 10MB

## Step 2: Environment Configuration

### 2.1 Update Production Environment Variables
Create `.env.production` file with:
```env
SUPABASE_URL=https://[your-project-id].supabase.co
SUPABASE_ANON_KEY=[your-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[your-service-role-key]
```

### 2.2 Update Flutter Configuration
Update `lib/main.dart` Supabase initialization for production.

## Step 3: Web Deployment Options

### Option A: Vercel (Recommended)
1. Connect GitHub repository to Vercel
2. Configure build settings for Flutter web
3. Set environment variables in Vercel dashboard
4. Deploy with custom domain

### Option B: Netlify
1. Connect GitHub repository to Netlify
2. Configure build command: `flutter build web`
3. Set publish directory: `build/web`
4. Configure environment variables

### Option C: Firebase Hosting
1. Initialize Firebase project
2. Configure hosting for Flutter web
3. Deploy with Firebase CLI

## Step 4: Super Admin Setup

### 4.1 Create Super Admin Account
Use the production credentials:
- **Email**: adamlwena22@gmail.com
- **Password**: SuperAdmin123
- **Role**: super_admin

### 4.2 Run Super Admin Creation Script
```bash
dart run create_proper_super_admin.dart
```

## Step 5: Production Testing

### 5.1 Functionality Testing
- [ ] Login with Super Admin credentials
- [ ] Create test tenant
- [ ] Add sample products
- [ ] Record test sales
- [ ] Generate reports
- [ ] Test image uploads
- [ ] Verify TSH currency formatting

### 5.2 Multi-Tenant Testing
- [ ] Create multiple tenants
- [ ] Verify data isolation
- [ ] Test cross-tenant Super Admin access
- [ ] Verify RLS policies working

## Step 6: Domain & SSL

### 6.1 Custom Domain Setup
1. Purchase domain (lwenatech.com suggested)
2. Configure DNS settings
3. Set up SSL certificates
4. Update Supabase auth settings

### 6.2 Update GitHub Releases
Update the download links in todo.me with production URLs.

---

## 🔐 Production Credentials

**Super Admin Account:**
- Email: adamlwena22@gmail.com  
- Password: SuperAdmin123
- Role: super_admin

**WhatsApp Support Group:**
https://chat.whatsapp.com/B8RUxQsQM665hjVm3Z05lc?mode=ems_share_t

---

## 📊 Success Metrics

After deployment, verify:
✅ Supabase project live and accessible
✅ Database migrations applied successfully  
✅ Authentication working with production URLs
✅ Storage bucket configured and accessible
✅ Super Admin account created and functional
✅ Web app deployed and accessible via custom domain
✅ TSH currency system working in production
✅ Multi-tenant features operational
✅ All download links updated

---

*Ready to launch your Tanzanian SaaS business! 🇹🇿🚀*