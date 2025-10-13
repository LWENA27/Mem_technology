# 🐛 Registration Error Troubleshooting Guide

## Current Issue
**Error**: `AuthApiException(message: Email address 'lwena@gmail.com' is invalid, statusCode: 400, code: email_address_invalid)`

This error typically occurs due to:

## 🔍 Root Causes & Solutions

### 1. **Supabase Environment Variables**
The most likely cause is incorrect or missing environment variables in Netlify.

**✅ Fix:**
1. Go to [Netlify Dashboard](https://app.netlify.com) → Your Site → Site Settings → Environment Variables
2. Verify these environment variables are set correctly:
   ```bash
   SUPABASE_URL=https://kzjgdeqfmxkmpmadtbpb.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434
   ```
3. After adding/updating variables, trigger a new deployment

### 2. **Supabase Auth Configuration**
Check your Supabase project settings.

**✅ Fix:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb)
2. Go to **Authentication** → **Settings**
3. Verify these settings:
   - **Enable email confirmations**: Should be OFF for testing
   - **Enable email change confirmations**: Can be OFF for testing
   - **Secure email change**: Can be OFF for testing
   - **Site URL**: Should include `https://inventorymaster.netlify.app`

### 3. **Email Format Validation**
Enhanced email validation has been added to catch format issues.

**✅ Applied Fix:**
- Improved email regex validation
- Better error messages for different types of validation failures

### 4. **Supabase Project Status**
Ensure your Supabase project is active and not paused.

**✅ Check:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb)
2. Verify project status is "Active"
3. Check if there are any billing or quota issues

## 🧪 Testing Steps

### Test 1: Local Development
```bash
cd /path/to/inventorymaster-saas
flutter run -d chrome --dart-define=SUPABASE_URL=https://kzjgdeqfmxkmpmadtbpb.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
```

### Test 2: Direct Supabase API Test
Open browser and go to:
```
https://kzjgdeqfmxkmpmadtbpb.supabase.co/rest/v1/
```
Should return JSON response if Supabase is accessible.

### Test 3: Registration with Different Email
Try registering with:
- Different email format: `23@example.com`
- Different email provider: `test@outlook.com`

## 🔧 Quick Fixes to Deploy

### Option 1: Redeploy with Debug Info
The latest code includes:
- Enhanced error messages
- Better email validation
- Debug logging for troubleshooting

### Option 2: Manual Environment Variable Check
Add this temporary debug code to see what environment variables are being used:
```dart
debugPrint('Using SUPABASE_URL: ${const String.fromEnvironment('SUPABASE_URL')}');
debugPrint('Using SUPABASE_ANON_KEY: ${const String.fromEnvironment('SUPABASE_ANON_KEY')}');
```

## 🚀 Immediate Action Plan

1. **Set Netlify Environment Variables** (most important)
2. **Check Supabase Auth Settings**
3. **Deploy Updated Code** with better error handling
4. **Test Registration** with different email formats

## 📞 If Issue Persists

The issue is most likely one of:
1. **Missing environment variables in Netlify** (90% probability)
2. **Supabase Auth configuration** (8% probability)
3. **Supabase project access issues** (2% probability)

Check the browser developer console for more detailed error messages when the registration fails.