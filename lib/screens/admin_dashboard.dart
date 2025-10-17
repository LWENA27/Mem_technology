import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/tenant_manager.dart';
import '../widgets/add_product_dialog.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'enhanced_reports_screen.dart';
import 'admin_account_screen.dart';
import 'super_admin_dashboard.dart';
import 'login_screen.dart' as login;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InventoryScreen(),
    const SalesScreen(),
    const EnhancedReportsScreen(),
    const AdminAccountScreen(),
  ];

  final List<String> _screenTitles = [
    'Inventory Management',
    'Sales Management',
    'Reports & Analytics',
    'Settings & Users',
  ];

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _initializeTenant();
  }

  _initializeTenant() async {
    try {
      // Ensure tenant is properly initialized for this user
      await TenantManager().initializeTenant();
      await TenantManager().ensureTenantConsistency();
    } catch (e) {
      debugPrint('Error initializing tenant: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkSuperAdminStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'super_admin';
    } catch (e) {
      print('Error checking super admin status: $e');
      return false;
    }
  }

  void _navigateToSuperAdmin() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SuperAdminDashboard(),
      ),
    );
  }

  _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const login.LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }

  void _refreshCurrentScreen() {
    if (_currentIndex == 0) {
      // Inventory refresh will be handled by the InventoryScreen itself
      setState(() {}); // Trigger rebuild
    } else if (_currentIndex == 1) {
      // For sales screen, we need to call its refresh method
      // This will be handled by a key to access the sales screen
      setState(() {}); // Trigger rebuild for now
    }
  }

  List<Widget> _getAppBarActions() {
    List<Widget> actions = [];

    // Add screen-specific actions
    if (_currentIndex == 0 || _currentIndex == 1) {
      // Inventory or Sales screen
      actions.add(
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshCurrentScreen,
          tooltip: _currentIndex == 0 ? 'Refresh Inventory' : 'Refresh Sales',
        ),
      );
    }

    // Add super admin button for authorized users
    actions.add(
      FutureBuilder<bool>(
        future: _checkSuperAdminStatus(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: _navigateToSuperAdmin,
              tooltip: 'Super Admin Dashboard',
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );

    // Always add logout button
    actions.add(
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: _logout,
        tooltip: 'Logout',
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _screenTitles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.3),
        actions: _getAppBarActions(),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
                strokeWidth: 2,
              ),
            )
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightGray,
        selectedLabelStyle: const TextStyle(color: primaryGreen),
        unselectedLabelStyle: const TextStyle(color: lightGray),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 // Show only on Inventory screen
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
