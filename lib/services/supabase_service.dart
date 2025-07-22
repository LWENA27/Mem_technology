import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Update admin email
  Future<void> updateEmail(String newEmail) async {
    if (!_initialized) await initialize();
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final response =
        await client.auth.updateUser(UserAttributes(email: newEmail));
    if (response.user == null) {
      throw Exception('Failed to update email. Response: '
          '${response.toString()}');
    }
  }

  // Update admin password
  Future<void> updatePassword(String newPassword) async {
    if (!_initialized) await initialize();
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final response =
        await client.auth.updateUser(UserAttributes(password: newPassword));
    if (response.user == null) {
      throw Exception('Failed to update password. Response: '
          '${response.toString()}');
    }
  }

  static SupabaseService? _instance;
  static bool _initialized = false;

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseService._internal();

  // Initialize Supabase only when authentication is needed
  Future<void> initialize() async {
    if (!_initialized) {
      try {
        await Supabase.initialize(
          url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
        );
        _initialized = true;

        // Listen for auth state changes and restore session
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          final session = data.session;
          if (session != null) {
            print('Auth state changed, session active: ${session.user.id}');
          } else {
            print('No active session');
          }
        });

        print('Supabase initialized successfully');
      } catch (e) {
        _initialized = false;
        throw Exception('Failed to initialize Supabase: $e');
      }
    }
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  // Check if Supabase is initialized
  bool get isInitialized => _initialized;

  // Check if user is logged in
  bool get isLoggedIn => _initialized && client.auth.currentUser != null;

  // Get current user
  User? get currentUser => _initialized ? client.auth.currentUser : null;

  // Method to check if user is authenticated
  bool isAuthenticated() {
    return _initialized && client.auth.currentSession != null;
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Sign out
  Future<void> signOut() async {
    if (!_initialized) return;
    await client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (!_initialized) {
      await initialize();
    }
    await client.auth.resetPasswordForEmail(email);
  }
}
