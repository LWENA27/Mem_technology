#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/flutter_run_local.sh
# This will run Flutter for web (chrome) and pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define

LOCAL_SUPABASE_URL=${LOCAL_SUPABASE_URL:-http://127.0.0.1:54321}
LOCAL_SUPABASE_ANON_KEY=${LOCAL_SUPABASE_ANON_KEY:-sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH}

echo "Running Flutter with SUPABASE_URL=$LOCAL_SUPABASE_URL"
flutter run -d chrome \
  --dart-define=SUPABASE_URL="$LOCAL_SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$LOCAL_SUPABASE_ANON_KEY"
