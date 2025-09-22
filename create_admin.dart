import 'package:supabase_flutter/supabase_flutter.dart';

// Simple script to create admin user or reset password
Future<void> main() async {
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
    );

    final client = Supabase.instance.client;

    print('Supabase initialized successfully');

    // Option 1: Try to create new admin user
    const email = 'admin@memtechnology.com';
    const password = 'memtech123456';

    print('Attempting to create admin user: $email');

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Admin user created successfully!');
        print('Email: $email');
        print('Password: $password');
        print('User ID: ${response.user!.id}');
      } else {
        print('❌ Failed to create user - no user returned');
      }
    } catch (e) {
      print('❌ Failed to create user: $e');

      // Option 2: Try to reset password for existing user
      print('\nTrying to reset password for existing user...');
      try {
        await client.auth.resetPasswordForEmail('memtechnology01@gmail.com');
        print('✅ Password reset email sent to memtechnology01@gmail.com');
        print('Check your email for reset instructions');
      } catch (resetError) {
        print('❌ Password reset failed: $resetError');
      }
    }

    // Option 3: Try the alternative admin email
    print('\nTrying alternative admin account...');
    try {
      final altResponse = await client.auth.signUp(
        email: 'memtech.admin@gmail.com',
        password: 'memtech123456',
      );

      if (altResponse.user != null) {
        print('✅ Alternative admin user created!');
        print('Email: memtech.admin@gmail.com');
        print('Password: memtech123456');
      }
    } catch (e) {
      print('Alternative admin creation failed: $e');
    }
  } catch (e) {
    print('❌ Script failed: $e');
  }
}
