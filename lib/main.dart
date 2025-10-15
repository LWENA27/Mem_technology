import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/admin_dashboard.dart';
import 'screens/customer_view.dart';
import 'services/image_upload_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://kzjgdeqfmxkmpmadtbpb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434',
    );
    print(
        'supabase.supabase_flutter: INFO: ***** Supabase init completed ***** ');

    // Initialize image storage bucket
    await ImageUploadService.initializeStorage();
    print('Image storage initialized');

    // Initialize image storage
    await ImageUploadService.initializeStorage();
    print('Image storage initialized');

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
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // MEM Technology green
        ),
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
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    try {
      // Give a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      final session = Supabase.instance.client.auth.currentSession;

      if (mounted) {
        if (session != null) {
          print('Active session found, navigating to dashboard');
          // User is logged in, go directly to dashboard (which shows inventory)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          print(
              'No active session found, showing customer view with all products');
          // No session, show customer view where guests can browse all products
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CustomerView()),
          );
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        // On error, show customer view so users can still browse products
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CustomerView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      body: Center(
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
