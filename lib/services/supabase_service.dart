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
            debugPrint('Auth state changed, session active: ${session.user.id}');
          } else {
            debugPrint('No active session');
          }
        });

        debugPrint('Supabase initialized successfully');
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

  // Reset password for email (alias)
  Future<void> resetPasswordForEmail(String email) async {
    return await resetPassword(email);
  }

  // Helper method to create or reset admin access
  Future<void> createOrResetAdminAccess({
    String email = 'memtechnology01@gmail.com',
    String password = 'memtech123456',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Try to create new admin user
      debugPrint('Attempting to create admin user: $email');
      await createAdminUser(email, password);
      debugPrint('Admin user created successfully');
    } catch (e) {
      debugPrint('Could not create user (might already exist): $e');

      // If user already exists, try to reset password
      try {
        debugPrint('Attempting to reset password for: $email');
        await resetPasswordForEmail(email);
        debugPrint('Password reset email sent to: $email');
      } catch (resetError) {
        debugPrint('Password reset failed: $resetError');
      }
    }
  }

  // Create admin user
  Future<void> createAdminUser(String email, String password) async {
    if (!_initialized) {
      await initialize();
    }

    // Sign up the new user
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    try {
      // Add admin role to profiles table
      await client.from('profiles').upsert({
        'id': response.user!.id,
        'role': 'admin',
        'email': email,
      });
    } catch (e) {
      // If profiles table doesn't exist or has issues, just log the error
      // The user will still be created in auth.users
      debugPrint('Warning: Could not update profiles table: $e');
      // Don't throw an error here as the user creation was successful
    }
  }

  // Create user with role
  Future<void> createUser(String email, String password, String role,
      [String? name]) async {
    if (!_initialized) {
      await initialize();
    }

    // Sign up the new user
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    try {
      // Add user to profiles table with specified role
      final profileData = {
        'id': response.user!.id,
        'role': role,
        'email': email,
      };

      if (name != null && name.isNotEmpty) {
        profileData['name'] = name;
      }

      await client.from('profiles').upsert(profileData);
    } catch (e) {
      debugPrint('Warning: Could not update profiles table: $e');
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Try to select common columns. If the profiles table doesn't contain
      // an `email` column (schema drift), fall back to selecting available
      // columns and map missing values to null so the UI can show a friendly
      // placeholder like "No email".
      dynamic response;

      try {
        response = await client
            .from('profiles')
            .select('id, email, role, name, created_at')
            .order('created_at', ascending: false);
      } catch (inner) {
        // If selecting email fails (column missing), try a safer select
        // without the email column.
        debugPrint('profiles.email not found, trying fallback select: $inner');
        response = await client
            .from('profiles')
            .select('id, role, name, created_at')
            .order('created_at', ascending: false);
      }

      final list = List<Map<String, dynamic>>.from(response ?? []);

      // Ensure each map has the expected keys so UI code doesn't throw.
      return list.map((row) {
        return {
          'id': row['id'],
          'email': row.containsKey('email') ? row['email'] : null,
          'role': row.containsKey('role') ? row['role'] : null,
          'name': row.containsKey('name') ? row['name'] : null,
          'created_at':
              row.containsKey('created_at') ? row['created_at'] : null,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await client.from('profiles').update({'role': newRole}).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // First delete from profiles table
      await client.from('profiles').delete().eq('id', userId);

      // Note: Deleting from auth.users requires admin privileges
      // In a production app, you'd need to call an edge function or use the admin API
      debugPrint('User removed from profiles table. Note: Auth user still exists.');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
