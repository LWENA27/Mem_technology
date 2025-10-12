# 🚀 Netlify Deployment Guide for InventoryMaster SaaS

This guide will help you deploy your InventoryMaster SaaS application to Netlify.

## 📋 Prerequisites

1. **GitHub Repository**: Your code should be pushed to GitHub (✅ Already done!)
2. **Supabase Project**: You need a live Supabase project with your database
3. **Netlify Account**: Sign up at [netlify.com](https://netlify.com)

## 🏗️ Deployment Steps

### Step 1: Connect Repository to Netlify

1. Go to [Netlify Dashboard](https://app.netlify.com)
2. Click **"Add new site"** → **"Import an existing project"**
3. Choose **GitHub** and authorize Netlify
4. Select your repository: `LWENA27/Mem_technology`
5. Choose branch: `main`

### Step 2: Configure Build Settings

Netlify should automatically detect the `netlify.toml` file, but verify these settings:

- **Build command**: `./build.sh`
- **Publish directory**: `build/web`
- **Production branch**: `main`

### Step 3: Set Environment Variables

In Netlify Dashboard → Site Settings → Environment Variables, add:

```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**How to get these values:**
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`

### Step 4: Deploy

1. Click **"Deploy site"**
2. Wait for the build to complete (usually 5-10 minutes)
3. Your app will be available at: `https://your-site-name.netlify.app`

## 🔧 Build Process

Our custom `build.sh` script will:

1. ✅ Download and install Flutter SDK
2. ✅ Enable Flutter web support
3. ✅ Install dependencies (`flutter pub get`)
4. ✅ Build the web app with your Supabase configuration
5. ✅ Output to `build/web` directory

## 🐛 Troubleshooting

### Build Fails with "Flutter not found"
- ✅ **Fixed**: Our `build.sh` script installs Flutter automatically

### Build Fails with "SUPABASE_URL not set"
- **Solution**: Add environment variables in Netlify dashboard
- **Temporary Fix**: App will build with placeholders but won't work until you add real values

### App Loads but Can't Connect to Database
- **Check**: Environment variables are correctly set in Netlify
- **Verify**: Supabase project is running and accessible
- **Test**: Try the Supabase URL in browser - should show a JSON response

### App Shows "Authentication Error"
- **Check**: SUPABASE_ANON_KEY is correct
- **Verify**: Key has proper permissions in Supabase

## 🌐 Custom Domain (Optional)

1. In Netlify → Site Settings → Domain Management
2. Click **"Add custom domain"**
3. Follow instructions to update DNS records
4. SSL will be automatically provisioned

## 📊 Post-Deployment Checklist

- [ ] Site builds successfully
- [ ] App loads without errors
- [ ] Login functionality works
- [ ] Database operations work (add/edit products)
- [ ] Sales functionality works
- [ ] Environment variables are secure

## 🔄 Automatic Deployments

Every time you push to the `main` branch:
- ✅ Netlify will automatically rebuild and deploy
- ✅ No manual intervention needed
- ✅ Build logs available in Netlify dashboard

## 🆘 Support

If you encounter issues:

1. **Check Build Logs**: Netlify Dashboard → Deploys → [Failed Deploy] → View Log
2. **Test Locally**: Run `./build.sh` locally to reproduce issues
3. **Verify Environment**: Ensure all environment variables are set

## 🎯 Expected Result

After successful deployment, you'll have:
- 🌐 **Live URL**: `https://your-site-name.netlify.app`
- 🔐 **Working Authentication**: Login/logout functionality
- 📦 **Full Inventory Management**: Add, edit, delete products
- 🛒 **Sales Management**: Record sales and generate receipts
- 📊 **Multi-tenant Support**: Secure tenant isolation
- 📱 **Responsive Design**: Works on desktop and mobile

Your InventoryMaster SaaS is now live and ready for production use! 🚀