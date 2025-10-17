import 'package:flutter/foundation.dart';

/// Configuration service for environment-specific settings
class AppConfig {
  // Production Supabase Configuration
  // IMPORTANT: Replace these with your actual production values
  static const String _prodSupabaseUrl = 'https://kzjgdeqfmxkmpmadtbpb.supabase.co';
  static const String _prodSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434';
  
  // Development Supabase Configuration (local)
  static const String _devSupabaseUrl = 'http://127.0.0.1:54321';
  static const String _devSupabaseAnonKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  /// Get the appropriate Supabase URL for the current environment
  static String get supabaseUrl {
    if (kReleaseMode) {
      return _prodSupabaseUrl;
    } else {
      return _devSupabaseUrl;
    }
  }

  /// Get the appropriate Supabase anon key for the current environment
  static String get supabaseAnonKey {
    if (kReleaseMode) {
      return _prodSupabaseAnonKey;
    } else {
      return _devSupabaseAnonKey;
    }
  }

  /// Check if we're running in production mode
  static bool get isProduction => kReleaseMode;

  /// Check if we're running in development mode
  static bool get isDevelopment => kDebugMode;

  /// App information
  static const String appName = 'LwenaTech Inventory Management';
  static const String appVersion = '1.0.0';
  static const String companyName = 'LwenaTech Solutions';

  /// Business configuration
  static const String defaultCurrency = 'TSH';
  static const String currencySymbol = 'TSH';
  static const String businessCountry = 'Tanzania';
  static const String businessTimezone = 'Africa/Dar_es_Salaam';

  /// Storage configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png', 
    'image/gif',
    'image/webp'
  ];

  /// Support configuration
  static const String supportEmail = 'adamlwena22@gmail.com';
  static const String supportWhatsApp = 'https://chat.whatsapp.com/B8RUxQsQM665hjVm3Z05lc?mode=ems_share_t';

  /// Super Admin configuration
  static const String superAdminEmail = 'adamlwena22@gmail.com';
  
  /// Get environment name for display
  static String get environmentName {
    if (isProduction) return 'Production';
    if (isDevelopment) return 'Development';
    return 'Unknown';
  }

  /// Print configuration summary (for debugging)
  static void printConfig() {
    if (!kReleaseMode) {
      print('=== LwenaTech Configuration ===');
      print('Environment: ${environmentName}');
      print('Supabase URL: ${supabaseUrl}');
      print('App Version: ${appVersion}');
      print('Currency: ${defaultCurrency}');
      print('================================');
    }
  }
}

/// Production deployment checklist
/// 
/// BEFORE DEPLOYING TO PRODUCTION:
/// 1. Update _prodSupabaseUrl with your actual Supabase project URL
/// 2. Update _prodSupabaseAnonKey with your actual production anon key
/// 3. Ensure your Supabase project has all migrations applied
/// 4. Configure authentication settings in Supabase dashboard
/// 5. Set up storage buckets and RLS policies
/// 6. Create Super Admin account with credentials in todo.me
/// 7. Test all functionality in production environment
/// 8. Configure custom domain and SSL certificates