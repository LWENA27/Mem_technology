# InventoryMaster SaaS - Production Deployment Guide

## Overview
InventoryMaster is a multi-tenant SaaS inventory management system built with Flutter and Supabase. It features a public storefront for customers and secure admin portal for inventory management.

## Prerequisites
- Flutter SDK (3.4.0 or higher)
- Supabase account and project
- Web hosting service (Netlify, Vercel, etc.)

## Environment Configuration

### Required Environment Variables
Set these when building/deploying:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Build Commands

**For Production:**
```bash
flutter build web --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

**For Development:**
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=your-local-anon-key
```

## Database Setup

### Migrations
Apply these migrations to your Supabase project:

1. `supabase/migrations/20250702001_create_profiles.sql` - User profiles
2. `supabase/migrations/20251009001_create_tenants_inventories.sql` - Multi-tenant schema
3. `supabase/migrations/20251012001_add_public_storefront.sql` - Public access

### Row Level Security (RLS)
The system uses RLS policies to enforce multi-tenancy:
- Users can only access their own tenant data
- Public storefront access is controlled via `public_storefront` flag
- Unauthenticated users can browse public inventories

## Features

### Multi-Tenant Architecture
- Shared database with tenant isolation
- Row-level security for data protection
- Tenant-scoped inventory management

### Public Storefront
- Browse inventory without authentication
- Search and filter products
- Contact information display
- Optional admin login

### Admin Portal
- Secure authentication required
- Full CRUD operations on inventory
- Sales tracking and reporting
- PDF report generation
- User account management

## Deployment

### Netlify Deployment
1. Connect your repository to Netlify
2. Set build command: `flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY`
3. Set publish directory: `build/web`
4. Add environment variables in Netlify dashboard
5. Configure redirects using `web/_redirects` file

### Other Hosting Platforms
The app can be deployed to any static hosting service that supports SPA routing.

## Security Considerations

### Production Checklist
- ✅ Remove all debug statements
- ✅ Remove development bypass code
- ✅ Use environment variables for sensitive data
- ✅ Enable RLS policies
- ✅ Configure proper authentication flows
- ✅ Remove unused dependencies

### API Security
- All database operations are secured with RLS
- Authentication is handled by Supabase Auth
- Tenant isolation prevents cross-tenant data access

## Support
For technical support or customization requests, contact the development team.