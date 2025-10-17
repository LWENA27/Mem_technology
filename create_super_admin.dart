import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
  );

  print('=== Super Admin Setup Tool ===');
  print('This tool will set a user as super admin.');
  print('Make sure the user already exists in your system.\n');

  // You can either:
  // 1. Set a specific email/user_id as super admin
  // 2. Or create a new super admin user

  try {
    // Option 1: Set existing user as super admin by email
    const superAdminEmail = 'your-admin@email.com'; // Replace with your email

    print('Looking for user with email: $superAdminEmail');

    // Find user by email
    final userResponse = await Supabase.instance.client.auth.admin.listUsers();

    String? userId;
    for (final user in userResponse) {
      if (user.email == superAdminEmail) {
        userId = user.id;
        break;
      }
    }

    if (userId == null) {
      print('User not found. Please ensure the user exists first.');
      return;
    }

    print('Found user: $userId');

    // Update user role to super_admin
    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'role': 'super_admin',
      'updated_at': DateTime.now().toIso8601String(),
    });

    print('✅ Successfully set user as super admin!');
    print('User $superAdminEmail now has super_admin role.');
    print(
        '\nYou can now login with this account to access the Super Admin Dashboard.');
  } catch (e) {
    print('❌ Error setting super admin: $e');
    print('\nTroubleshooting:');
    print('1. Make sure the user exists in your system');
    print('2. Check that the profiles table has the correct structure');
    print('3. Verify Supabase connection and permissions');
  }
}
