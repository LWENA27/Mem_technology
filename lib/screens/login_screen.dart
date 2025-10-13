import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingSession = false;
  bool _isSupabaseInitialized = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // MEM Technology Color Scheme (Refined from logo)
  static const Color primaryGreen =
      Color(0xFF4CAF50); // Vibrant green from logo
  static const Color darkGray =
      Color(0xFF424242); // Dark gray from text and "M"
  static const Color lightGray =
      Color(0xFF757575); // Light gray for secondary text
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light background

  @override
  void initState() {
    super.initState();
    // Supabase is already initialized in main.dart, so just check login status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isSupabaseInitialized = true;
      });
      _checkLoginStatus();
    });
  }

  _checkLoginStatus() async {
    if (!mounted || !_isSupabaseInitialized) return;

    setState(() {
      _isCheckingSession = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null && mounted) {
        debugPrint('Checking user role for ID: ${session.user.id}');

        // Add timeout to prevent hanging
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle()
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Database query timed out');
            return null;
          },
        );

        debugPrint('User data retrieved: $userData');

        if (userData != null && mounted) {
          final role = userData['role'];
          debugPrint('User role: $role');

          if (role == 'admin') {
            debugPrint('Navigating to Admin Dashboard');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            debugPrint('Returning to Customer View with login success');
            Navigator.of(context)
                .pop(true); // Return true to indicate successful login
          }
        } else if (mounted) {
          debugPrint('No user data found');
          setState(() {
            _errorMessage = 'No role assigned. Please contact support.';
            _isCheckingSession = false;
          });
        }
      } else {
        debugPrint('No active session found');
        if (mounted) {
          setState(() {
            _isCheckingSession = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error during login status check: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error. Please try again.';
          _isCheckingSession = false;
        });
      }
    }
  }

  _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isSupabaseInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication not ready. Please wait.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Starting login process...');

      final response = await Supabase.instance.client.auth
          .signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Login request timed out. Please check your connection.');
        },
      );

      debugPrint('Login successful for user: ${response.user?.id}');

      if (mounted && response.user != null) {
        final supabase = Supabase.instance.client;
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle()
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Database query timed out');
          },
        );

        if (userData != null && mounted) {
          final role = userData['role'];
          debugPrint('Login: User role is $role');

          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            Navigator.of(context)
                .pop(true); // Return success to existing CustomerView
          }
        } else if (mounted) {
          setState(() =>
              _errorMessage = 'No role assigned. Please contact support.');
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Login failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                try {
                  await Supabase.instance.client.auth
                      .resetPasswordForEmail(email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Password reset email sent! Check your inbox.'),
                      backgroundColor: primaryGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Send Reset Link',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking session
    if (_isCheckingSession || !_isSupabaseInitialized) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: primaryGreen,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Initializing authentication...',
                style: TextStyle(
                  color: lightGray,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'InventoryMaster',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Multi-Tenant SaaS Platform',
                  style: TextStyle(
                    fontSize: 18,
                    color: lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.email, color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.lock, color: primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primaryGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style:
                                          TextStyle(color: Colors.red.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessSlugController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // MEM Technology Color Scheme (Refined from logo)
  static const Color primaryGreen =
      Color(0xFF4CAF50); // Vibrant green from logo
  static const Color darkGray =
      Color(0xFF424242); // Dark gray from text and "M"
  static const Color lightGray =
      Color(0xFF757575); // Light gray for secondary text
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light background

  @override
  void initState() {
    super.initState();
    // Auto-generate slug from business name
    _businessNameController.addListener(_updateSlug);
  }

  void _updateSlug() {
    final businessName = _businessNameController.text;
    final slug = businessName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    _businessSlugController.text = slug;
  }

  @override
  void dispose() {
    _businessNameController.removeListener(_updateSlug);
    super.dispose();
  }

  _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Starting registration process...');
      debugPrint('Email: ${_emailController.text.trim()}');
      debugPrint('Business: ${_businessNameController.text.trim()}');

      // Check Supabase connection status
      debugPrint('Supabase client initialized');

      // Sign up user with timeout
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'name': _nameController.text.trim(),
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Registration request timed out. Please check your connection.');
        },
      );

      if (response.user != null && mounted) {
        debugPrint('User created: ${response.user!.id}');

        final supabase = Supabase.instance.client;

        // Check if user needs email confirmation
        if (response.session == null) {
          debugPrint(
              'User created but session is null - email confirmation may be required');

          // Try to sign in the user directly since we don't want email confirmation
          try {
            debugPrint('Attempting direct sign-in after registration...');
            final signInResponse = await supabase.auth.signInWithPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

            if (signInResponse.user == null) {
              // Registration succeeded but immediate login failed
              // This means email confirmation is required
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Account created successfully! Please check your email to confirm your account, then try logging in.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 6),
                  ),
                );
                Navigator.of(context).pop();
              }
              return; // Exit early since we can't complete registration without email confirmation
            }
          } catch (signInError) {
            debugPrint('Sign-in after registration failed: $signInError');
            throw Exception(
                'Registration completed but automatic login failed. Please try logging in manually.');
          }
        }

        // Wait a moment for auth context to be fully established
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify user is authenticated before proceeding
        final currentUser = supabase.auth.currentUser;
        if (currentUser == null) {
          throw Exception(
              'Authentication failed after user creation. Please try logging in manually.');
        }
        debugPrint('User authenticated: ${currentUser.id}');

        // Step 1: Create tenant
        debugPrint('Creating tenant for user: ${currentUser.id}');
        final tenantData = await supabase
            .from('tenants')
            .insert({
              'name': _businessNameController.text.trim(),
              'slug': _businessSlugController.text.trim(),
              'public_storefront': true,
              'metadata': {
                'owner_name': _nameController.text.trim(),
                'owner_email': _emailController.text.trim(),
                'created_via': 'self_registration'
              }
            })
            .select()
            .single()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Tenant creation timed out');
              },
            );

        debugPrint('Tenant created: ${tenantData['id']}');

        // Step 2: Create or update user profile with tenant reference
        // First check if profile already exists
        final existingProfile = await supabase
            .from('profiles')
            .select('id')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Profile doesn't exist, create new one
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': _emailController.text.trim(),
            'role': 'admin', // Business owner gets admin role
            'tenant_id': tenantData['id'],
          }).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Profile creation timed out');
            },
          );
          debugPrint('Profile created successfully with tenant association');
        } else {
          // Profile exists, update it with new tenant
          await supabase
              .from('profiles')
              .update({
                'email': _emailController.text.trim(),
                'role': 'admin',
                'tenant_id': tenantData['id'],
              })
              .eq('id', response.user!.id)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception('Profile update timed out');
                },
              );
          debugPrint('Profile updated successfully with tenant association');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Business registration successful! You can now login to manage your inventory.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        String errorMessage = 'Registration failed: ';

        // Handle specific Supabase Auth errors
        if (e.toString().contains('email_address_invalid')) {
          errorMessage +=
              'Please enter a valid email address. Make sure there are no spaces or special characters.';
        } else if (e.toString().contains('User already registered')) {
          errorMessage +=
              'This email is already registered. Please use a different email or try logging in.';
        } else if (e
            .toString()
            .contains('duplicate key value violates unique constraint')) {
          errorMessage +=
              'Account already exists. Please try logging in with your email and password instead.';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage += 'Password must be at least 6 characters long.';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage +=
              'The email format is invalid. Please check and try again.';
        } else if (e.toString().contains('row-level security policy')) {
          errorMessage +=
              'Database permission error. Please try again in a few moments or contact support.';
        } else if (e
            .toString()
            .contains('Authentication failed after user creation')) {
          errorMessage +=
              'Account created successfully but automatic login failed. Please try logging in manually with your credentials.';
        } else if (e
            .toString()
            .contains('Registration completed but automatic login failed')) {
          errorMessage +=
              'Account created successfully! Please try logging in with your email and password.';
        } else if (e.toString().contains('timeout')) {
          errorMessage +=
              'Request timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('Network')) {
          errorMessage +=
              'Network error. Please check your internet connection.';
        } else {
          errorMessage += e.toString();
        }

        setState(() => _errorMessage = errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Start Your Business',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Create Your InventoryMaster Account',
                  style: TextStyle(
                    fontSize: 18,
                    color: lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Personal Information Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.person, color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.email, color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              // Improved email validation
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.lock, color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Business Information Section
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'Business Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _businessNameController,
                            decoration: InputDecoration(
                              labelText: 'Business Name',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon: const Icon(Icons.business,
                                  color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              hintText: 'e.g., ABC Electronics Store',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your business name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _businessSlugController,
                            decoration: InputDecoration(
                              labelText: 'Business URL (auto-generated)',
                              labelStyle: const TextStyle(color: lightGray),
                              prefixIcon:
                                  const Icon(Icons.link, color: primaryGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryGreen, width: 2),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              hintText: 'your-business-url',
                              helperText: 'This will be your unique store URL',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Business URL is required';
                              }
                              if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                                return 'URL can only contain lowercase letters, numbers, and hyphens';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style:
                                          TextStyle(color: Colors.red.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Text(
                                      'START MY BUSINESS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
