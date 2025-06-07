import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static bool _isInitialized = false;
  SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null || !_isInitialized) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
      );
      _isInitialized = true;
      _instance._client = Supabase.instance.client;

      // Listen for auth state changes and restore session
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          // Session restored or new login, persist locally
          print('Auth state changed, session active: ${session.user.id}');
        } else {
          print('No active session');
        }
      });
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // Method to check if user is authenticated
  bool isAuthenticated() {
    return _client?.auth.currentSession != null;
  }
}