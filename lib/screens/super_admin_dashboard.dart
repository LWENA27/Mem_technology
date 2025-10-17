import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/tenant_manager.dart';
import '../widgets/enhanced_feedback_widget.dart';
import 'tenant_management_screen.dart';
import 'super_admin_inventory_screen.dart';
import 'super_admin_users_screen.dart';
import 'admin_account_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _tenants = [];
  bool _isLoading = true;
  String? _selectedTenantId;
  Map<String, dynamic>? _selectedTenant;

  final List<Widget> _screens = [];

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGray = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadTenants();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens.addAll([
      TenantManagementScreen(
        onTenantSelected: _onTenantSelected,
        selectedTenantId: _selectedTenantId,
      ),
      SuperAdminInventoryScreen(selectedTenantId: _selectedTenantId),
      SuperAdminUsersScreen(selectedTenantId: _selectedTenantId),
      const AdminAccountScreen(),
    ]);
  }

  Future<void> _loadTenants() async {
    try {
      setState(() => _isLoading = true);

      final response = await Supabase.instance.client
          .from('tenants')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _tenants = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      if (_tenants.isNotEmpty && _selectedTenantId == null) {
        _onTenantSelected(_tenants.first['id'], _tenants.first);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to load tenants: $e',
      );
    }
  }

  void _onTenantSelected(String tenantId, Map<String, dynamic> tenant) {
    setState(() {
      _selectedTenantId = tenantId;
      _selectedTenant = tenant;
    });

    // Update screens with new selected tenant
    _screens.clear();
    _screens.addAll([
      TenantManagementScreen(
        onTenantSelected: _onTenantSelected,
        selectedTenantId: _selectedTenantId,
      ),
      SuperAdminInventoryScreen(selectedTenantId: _selectedTenantId),
      SuperAdminUsersScreen(selectedTenantId: _selectedTenantId),
      const AdminAccountScreen(),
    ]);
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        // Clear tenant manager
        TenantManager().clear();

        // Sign out from Supabase
        await Supabase.instance.client.auth.signOut();

        // Navigate back to customer view (login screen)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Logout failed: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Super Admin Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_selectedTenant != null)
              Text(
                'Managing: ${_selectedTenant!['name']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        backgroundColor: primaryGreen,
        elevation: 4,
        actions: [
          // Tenant Selector Dropdown
          if (_tenants.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTenantId,
                  dropdownColor: primaryGreen,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _tenants.map<DropdownMenuItem<String>>((tenant) {
                    return DropdownMenuItem<String>(
                      value: tenant['id'],
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          tenant['name'],
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      final tenant = _tenants.firstWhere(
                        (t) => t['id'] == newValue,
                      );
                      _onTenantSelected(newValue, tenant);
                    }
                  },
                ),
              ),
            ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTenants,
            tooltip: 'Refresh Tenants',
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryGreen),
                  SizedBox(height: 16),
                  Text('Loading tenants...'),
                ],
              ),
            )
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightGray,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Tenants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
