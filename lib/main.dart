import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import 'screens/admin_dashboard.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/customer_view.dart';
import 'services/image_upload_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'services/tenant_manager.dart';
import 'database/offline_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific optimizations for Linux desktop
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
    // Set system UI overlay style for better rendering
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // Suppress drift database multiple instance warnings
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  try {
    // Initialize offline storage
    await Hive.initFlutter();
    print('Hive initialized for offline storage');

    // Initialize offline database (singleton) - ensure it's ready
    OfflineDatabase.instance;
    print('Offline database initialized');

    // Initialize connectivity monitoring
    await ConnectivityService().initialize();
    print('Connectivity service initialized');

    // Initialize Supabase - using local development instance
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    );
    print('Supabase init completed (local development)');

    // Initialize sync service
    await SyncService().initialize();
    print('Sync service initialized');

    // Initialize tenant manager for consistent tenant handling
    await TenantManager().initializeTenant();
    print('Tenant manager initialized');

    // Initialize image storage bucket with timeout handling
    try {
      await ImageUploadService.initializeStorage()
          .timeout(const Duration(seconds: 5));
      print('Image storage initialized');
    } catch (e) {
      print('Error initializing storage: $e');
      // Don't let storage initialization failure prevent app startup
    }

    runApp(const MyApp());
  } catch (e) {
    runApp(ErrorApp(errorMessage: 'Failed to initialize app: $e'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InventoryMaster SaaS',
      debugShowCheckedModeBanner: false,
      // Linux-specific optimizations to reduce screen blinking
      builder: (context, child) {
        // Add RepaintBoundary to reduce unnecessary repaints on Linux
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
          return RepaintBoundary(
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // MEM Technology green
        ),
        // Optimize material design for desktop performance
        visualDensity: !kIsWeb && defaultTargetPlatform == TargetPlatform.linux
            ? VisualDensity.standard
            : VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash screen that checks authentication and routes accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    try {
      // Longer delay on Linux to reduce rapid state changes
      final delay = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux
          ? const Duration(milliseconds: 1000)
          : const Duration(milliseconds: 500);

      await Future.delayed(delay);

      final session = Supabase.instance.client.auth.currentSession;

      if (mounted && !_isNavigating) {
        _isNavigating = true;

        if (session != null) {
          print('Active session found, checking user role');

          // Check if user is super admin
          final isSuperAdmin = await _checkSuperAdminStatus(session.user.id);

          if (isSuperAdmin) {
            print('Super admin detected, navigating to super admin dashboard');
            await Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SuperAdminDashboard(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else {
            // Ensure tenant consistency for authenticated user
            await TenantManager().ensureTenantConsistency();

            // User is logged in, go directly to dashboard (which shows inventory)
            await Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AdminDashboard(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        } else {
          print(
              'No active session found, showing customer view with all products');
          // No session, show customer view where guests can browse all products
          await Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const CustomerView(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        // On error, show customer view so users can still browse products
        await Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CustomerView(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  Future<bool> _checkSuperAdminStatus(String userId) async {
    try {
      // Check if user has super_admin role
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] == 'super_admin';
    } catch (e) {
      print('Error checking super admin status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      body: RepaintBoundary(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'InventoryMaster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'SaaS Inventory Management',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Error screen as a fallback (kept for future use)
class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InventoryMaster - Error',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InventoryMaster - Error'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
