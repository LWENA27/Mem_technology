import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase with service role key (for admin operations)
  await Supabase.initialize(
    url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
  );

  print('=== Super Admin Creation Tool ===');
  print(
      'This will create a proper super admin account that you can login with.');
  print('');

  const email = 'lwena027@gmail.com';
  const password = 'SuperAdmin123!'; // Use this password to login

  try {
    print('Step 1: Cleaning up existing user (if any)...');

    // Clean up existing profile first
    await Supabase.instance.client.from('profiles').delete().eq('email', email);

    print('Step 2: Creating new user account...');

    // Create user with sign up (this properly hashes password)
    final authResponse = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      final userId = authResponse.user!.id;
      print('✅ User created successfully with ID: $userId');

      print('Step 3: Promoting to super admin...');

      // Create profile with super admin role
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'email': email,
        'role': 'super_admin',
        'name': 'System Administrator',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Super admin profile created!');

      // Verify the setup
      final profileCheck = await Supabase.instance.client
          .from('profiles')
          .select('role, email')
          .eq('id', userId)
          .single();

      print('');
      print('🎉 SUCCESS! Super Admin account created:');
      print('   📧 Email: $email');
      print('   🔐 Password: $password');
      print('   👑 Role: ${profileCheck['role']}');
      print('');
      print('📱 Next Steps:');
      print('1. Use these credentials to login to your app');
      print('2. You should see the Super Admin Dashboard');
      print('3. Start managing your multi-tenant system!');
    } else {
      print('❌ Failed to create user account');
      if (authResponse.session == null) {
        print('No session created - user might already exist');
        print('Try using "Forgot Password" in the app to reset password');
      }
    }
  } catch (e) {
    print('❌ Error: $e');

    if (e.toString().contains('User already registered')) {
      print('');
      print(
          'The user already exists. Let me try to promote the existing user...');

      try {
        // Try to find existing user and promote
        final existingUser =
            await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (existingUser.user != null) {
          await Supabase.instance.client.from('profiles').upsert({
            'id': existingUser.user!.id,
            'email': email,
            'role': 'super_admin',
            'name': 'System Administrator',
            'updated_at': DateTime.now().toIso8601String(),
          });

          print('✅ Existing user promoted to super admin!');
          print('   📧 Email: $email');
          print('   🔐 Password: $password');
        }
      } catch (loginError) {
        print('Could not login with existing user: $loginError');
        print('');
        print('🔧 Manual Solution:');
        print('1. Go to Supabase Studio: http://127.0.0.1:54323');
        print('2. Navigate to Authentication > Users');
        print('3. Delete the existing user for $email');
        print('4. Run this script again');
      }
    }
  }
}
