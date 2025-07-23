import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memtechnology/services/DatabaseService.dart';
import 'package:memtechnology/models/product.dart';
import 'package:memtechnology/widgets/add_product_dialog.dart';
import 'package:memtechnology/screens/inventory_screen.dart';
import 'sales_screen.dart';
import 'reports_screen.dart';
import 'admin_account_screen.dart';
import 'login_screen.dart' as login;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _dbService = DatabaseService.instance;
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InventoryScreen(),
    const SalesScreen(),
    const ReportsScreen(),
    const AdminAccountScreen(),
  ];

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _dbService.getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products: $e'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const login.LoginScreen()),
      (route) => false,
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductAdded: _loadProducts, // Add the required callback
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('MEMTECHNOLOGY - Admin'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
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
