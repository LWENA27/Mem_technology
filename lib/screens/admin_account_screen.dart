import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/supabase_service.dart';

enum MessageType { success, error, info }

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _currentEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addAdminEmailController = TextEditingController();
  final _addAdminPasswordController = TextEditingController();
  final _addAdminConfirmPasswordController = TextEditingController();
  final _addCustomerEmailController = TextEditingController();
  final _addCustomerPasswordController = TextEditingController();
  final _addCustomerConfirmPasswordController = TextEditingController();
  final _addCustomerNameController = TextEditingController();
  final _searchController = TextEditingController();

  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _addAdminFormKey = GlobalKey<FormState>();
  final _addCustomerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isCurrentPasswordVisible = false;
  bool _isAddAdminPasswordVisible = false;
  bool _isAddAdminConfirmVisible = false;
  bool _isAddCustomerPasswordVisible = false;
  bool _isAddCustomerConfirmVisible = false;
  String? _message;
  MessageType? _messageType;

  // User management state
  List<Map<String, dynamic>> _adminUsers = [];
  List<Map<String, dynamic>> _customerUsers = [];
  List<Map<String, dynamic>> _filteredAdminUsers = [];
  List<Map<String, dynamic>> _filteredCustomerUsers = [];
  bool _isLoadingUsers = false;
  String _searchQuery = '';
  String _selectedUserTab = 'admins'; // 'admins' or 'customers'

  // If you deploy the Edge Function, set its public invoke URL here (or
  // provide via runtime config). Example: https://<project>.functions.supabase.co/sync_users
  // Leave empty to disable UI-sync button.
  String syncFunctionUrl = '';

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
    _loadUsers();
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _addAdminEmailController.dispose();
    _addAdminPasswordController.dispose();
    _addAdminConfirmPasswordController.dispose();
    _addCustomerEmailController.dispose();
    _addCustomerPasswordController.dispose();
    _addCustomerConfirmPasswordController.dispose();
    _addCustomerNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      // Clear any existing error messages when loading
      setState(() {
        _message = null;
        _messageType = null;
      });

      final user = SupabaseService.instance.client.auth.currentUser;
      if (user != null) {
        setState(() {
          _currentEmailController.text = user.email ?? '';
        });
      } else {
        // Handle case where user is logged in via temporary bypass
        setState(() {
          _currentEmailController.text = 'admin@inventorymaster.com';
        });
      }
    } catch (e) {
      _showMessage('Error loading user info: $e', MessageType.error);
    }
  }

  Future<void> _triggerSyncUsers() async {
    if (syncFunctionUrl.isEmpty) {
      _showMessage('Sync function URL not configured', MessageType.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await http.post(Uri.parse(syncFunctionUrl), headers: {
        'Content-Type': 'application/json',
      });

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _showMessage('User sync started successfully', MessageType.success);
        // Optionally reload users after a short delay
        await Future.delayed(const Duration(seconds: 2));
        await _loadUsers();
      } else {
        _showMessage(
            'Sync failed: ${res.statusCode} ${res.body}', MessageType.error);
      }
    } catch (e) {
      _showMessage('Error invoking sync: $e', MessageType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearMessage() {
    setState(() {
      _message = null;
      _messageType = null;
    });
  }

  void _showMessage(String message, MessageType type) {
    setState(() {
      _message = message;
      _messageType = type;
    });

    // Clear message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _message = null;
          _messageType = null;
        });
      }
    });
  }

  Future<void> _updateEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await SupabaseService.instance
          .updateEmail(_newEmailController.text.trim());
      _showMessage(
          'Email update request sent! Please check your email to confirm.',
          MessageType.success);
      _newEmailController.clear();
    } catch (e) {
      _showMessage('Failed to update email: $e', MessageType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await SupabaseService.instance
          .updatePassword(_newPasswordController.text.trim());
      _showMessage('Password updated successfully!', MessageType.success);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showMessage('Failed to update password: $e', MessageType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_currentEmailController.text.isEmpty) {
      _showMessage('No email address found', MessageType.error);
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
            'Send password reset email to ${_currentEmailController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Send Reset Email',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _message = null;
      });

      try {
        await SupabaseService.instance
            .resetPasswordForEmail(_currentEmailController.text);
        _showMessage(
            'Password reset email sent successfully!', MessageType.success);
      } catch (e) {
        _showMessage('Failed to send reset email: $e', MessageType.error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addAdminUser() async {
    if (!_addAdminFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Check for rate limiting by adding a delay between requests
      await Future.delayed(const Duration(seconds: 2));

      // Create new admin user
      await SupabaseService.instance.createAdminUser(
        _addAdminEmailController.text.trim(),
        _addAdminPasswordController.text.trim(),
      );

      _showMessage('New admin user created successfully!', MessageType.success);
      _addAdminEmailController.clear();
      _addAdminPasswordController.clear();
      _addAdminConfirmPasswordController.clear();

      // Reload admin users list
      _loadUsers();
    } catch (e) {
      String errorMessage = e.toString();

      // Handle specific rate limit error
      if (errorMessage.contains('over_email_send_rate_limit')) {
        _showMessage(
            'Rate limit exceeded. Please wait 45 seconds before creating another admin user.',
            MessageType.error);
      } else if (errorMessage.contains('email_address_invalid')) {
        _showMessage('Invalid email address. Please check the email format.',
            MessageType.error);
      } else if (errorMessage.contains('password_too_short')) {
        _showMessage('Password is too short. Must be at least 6 characters.',
            MessageType.error);
      } else if (errorMessage.contains('email_address_already_exists')) {
        _showMessage(
            'This email is already registered. Please use a different email.',
            MessageType.error);
      } else {
        _showMessage(
            'Failed to create admin user: ${errorMessage.replaceAll('Exception: ', '')}',
            MessageType.error);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // User Management Methods
  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final supabase = SupabaseService.instance.client;

      // Load all users from profiles table
      final usersData = await supabase
          .from('profiles')
          .select('id, email, role, created_at')
          .order('created_at', ascending: false);

      setState(() {
        _adminUsers =
            usersData.where((user) => user['role'] == 'admin').toList();
        _customerUsers = usersData
            .where(
                (user) => user['role'] == 'user' || user['role'] == 'customer')
            .toList();
        _filteredAdminUsers = List.from(_adminUsers);
        _filteredCustomerUsers = List.from(_customerUsers);
      });

      _filterUsers();
    } catch (e) {
      _showMessage('Failed to load users: $e', MessageType.error);
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  void _filterUsers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredAdminUsers = List.from(_adminUsers);
        _filteredCustomerUsers = List.from(_customerUsers);
      } else {
        _filteredAdminUsers = _adminUsers.where((user) {
          final email = user['email']?.toString().toLowerCase() ?? '';
          return email.contains(_searchQuery.toLowerCase());
        }).toList();

        _filteredCustomerUsers = _customerUsers.where((user) {
          final email = user['email']?.toString().toLowerCase() ?? '';
          return email.contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addCustomerUser() async {
    if (!_addCustomerFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final supabase = SupabaseService.instance.client;

      // Create new customer user
      final response = await supabase.auth.signUp(
        email: _addCustomerEmailController.text.trim(),
        password: _addCustomerPasswordController.text.trim(),
      );

      if (response.user != null) {
        // Add customer role to profiles table
        await supabase.from('profiles').upsert({
          'id': response.user!.id,
          'role': 'customer',
          'email': _addCustomerEmailController.text.trim(),
        });

        _showMessage(
            'New customer user created successfully!', MessageType.success);
        _addCustomerEmailController.clear();
        _addCustomerPasswordController.clear();
        _addCustomerConfirmPasswordController.clear();
        _addCustomerNameController.clear();

        // Reload users list
        _loadUsers();
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('email_address_already_exists')) {
        _showMessage(
            'This email is already registered. Please use a different email.',
            MessageType.error);
      } else {
        _showMessage(
            'Failed to create customer user: ${errorMessage.replaceAll('Exception: ', '')}',
            MessageType.error);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String userId, String email, String role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content:
            Text('Are you sure you want to delete the $role user: $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        final supabase = SupabaseService.instance.client;

        // Delete from profiles table (this should cascade to auth.users if properly configured)
        await supabase.from('profiles').delete().eq('id', userId);

        _showMessage('User deleted successfully!', MessageType.success);
        _loadUsers();
      } catch (e) {
        _showMessage('Failed to delete user: $e', MessageType.error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editUserRole(String userId, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Admin'),
              leading: Radio<String>(
                value: 'admin',
                groupValue: currentRole,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
            ),
            ListTile(
              title: const Text('Customer'),
              leading: Radio<String>(
                value: 'customer',
                groupValue: currentRole,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newRole != null && newRole != currentRole) {
      try {
        setState(() {
          _isLoading = true;
        });

        final supabase = SupabaseService.instance.client;
        await supabase
            .from('profiles')
            .update({'role': newRole}).eq('id', userId);

        _showMessage('User role updated successfully!', MessageType.success);
        _loadUsers();
      } catch (e) {
        _showMessage('Failed to update user role: $e', MessageType.error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildExpandableSection(
      String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: primaryGreen,
        collapsedIconColor: primaryGreen,
        childrenPadding: const EdgeInsets.all(24),
        children: children,
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: textColor ?? Colors.white),
        label: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(text,
                style:
                    TextStyle(color: textColor ?? Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primaryGreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: (backgroundColor ?? primaryGreen).withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildAddAdminUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Form(
        key: _addAdminFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Add New Admin User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new administrator account with full system access',
              style: TextStyle(
                color: Colors.indigo.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addAdminEmailController,
              decoration: InputDecoration(
                labelText: 'Admin Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.admin_panel_settings),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                if (_message != null) {
                  _clearMessage();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter admin email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _addAdminPasswordController,
              label: 'Admin Password',
              isVisible: _isAddAdminPasswordVisible,
              onToggleVisibility: () => setState(() =>
                  _isAddAdminPasswordVisible = !_isAddAdminPasswordVisible),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _addAdminConfirmPasswordController,
              label: 'Confirm Admin Password',
              isVisible: _isAddAdminConfirmVisible,
              onToggleVisibility: () => setState(
                  () => _isAddAdminConfirmVisible = !_isAddAdminConfirmVisible),
              validator: (value) {
                if (value != _addAdminPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Due to security limits, please wait 45 seconds between creating admin users.',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStyledButton(
              text: 'Create New Admin User',
              onPressed: _addAdminUser,
              icon: Icons.person_add,
              backgroundColor: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomerUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Form(
        key: _addCustomerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Add New Customer User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new customer account with basic access',
              style: TextStyle(
                color: Colors.teal.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addCustomerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addCustomerEmailController,
              decoration: InputDecoration(
                labelText: 'Customer Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _addCustomerPasswordController,
              label: 'Customer Password',
              isVisible: _isAddCustomerPasswordVisible,
              onToggleVisibility: () => setState(() =>
                  _isAddCustomerPasswordVisible =
                      !_isAddCustomerPasswordVisible),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _addCustomerConfirmPasswordController,
              label: 'Confirm Customer Password',
              isVisible: _isAddCustomerConfirmVisible,
              onToggleVisibility: () => setState(() =>
                  _isAddCustomerConfirmVisible = !_isAddCustomerConfirmVisible),
              validator: (value) {
                if (value != _addCustomerPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildStyledButton(
              text: 'Create New Customer User',
              onPressed: _addCustomerUser,
              icon: Icons.person_add,
              backgroundColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(List<Map<String, dynamic>> users, String userType) {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              userType == 'admin' ? Icons.admin_panel_settings : Icons.people,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${userType}s found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Add your first $userType user above',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final rawEmail = user['email'];
        final email = (rawEmail == null ||
                (rawEmail is String && rawEmail.trim().isEmpty))
            ? null
            : rawEmail.toString();
        final role = user['role'] ?? 'user';
        final userId = user['id'] ?? '';
        final createdAt = user['created_at'];

        DateTime? createDate;
        if (createdAt != null) {
          try {
            createDate = DateTime.parse(createdAt);
          } catch (e) {
            // Handle parsing error
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: role == 'admin' ? Colors.indigo : Colors.teal,
              child: Icon(
                role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    email ?? 'No email',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (email == null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Chip(
                      backgroundColor: Colors.red.shade50,
                      label: Text(
                        'Email missing',
                        style:
                            TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role: ${role.toUpperCase()}',
                  style: TextStyle(
                    color: role == 'admin' ? Colors.indigo : Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (createDate != null)
                  Text(
                    'Created: ${createDate.day}/${createDate.month}/${createDate.year}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit_role':
                    _editUserRole(userId, role);
                    break;
                  case 'delete':
                    _deleteUser(userId, email ?? '', role);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit_role',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete User', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Account Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Message Display
            if (_message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _messageType == MessageType.success
                      ? Colors.green.shade50
                      : _messageType == MessageType.error
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _messageType == MessageType.success
                        ? Colors.green
                        : _messageType == MessageType.error
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _messageType == MessageType.success
                          ? Icons.check_circle
                          : _messageType == MessageType.error
                              ? Icons.error
                              : Icons.info,
                      color: _messageType == MessageType.success
                          ? Colors.green
                          : _messageType == MessageType.error
                              ? Colors.red
                              : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _messageType == MessageType.success
                              ? Colors.green.shade700
                              : _messageType == MessageType.error
                                  ? Colors.red.shade700
                                  : Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearMessage,
                      color: _messageType == MessageType.success
                          ? Colors.green.shade700
                          : _messageType == MessageType.error
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                    ),
                  ],
                ),
              ),

            // My Info Section
            _buildExpandableSection(
              'My Info',
              Icons.person,
              [
                // Current Admin Info Subsection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Current Account Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _currentEmailController,
                        decoration: InputDecoration(
                          labelText: 'Current Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledButton(
                        text: 'Send Password Reset Email',
                        onPressed: _resetPassword,
                        icon: Icons.email,
                        backgroundColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Update Email Subsection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Form(
                    key: _emailFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Update Email Address',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newEmailController,
                          decoration: InputDecoration(
                            labelText: 'New Email Address',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter new email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildStyledButton(
                          text: 'Update Email',
                          onPressed: _updateEmail,
                          icon: Icons.email,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Change Password Subsection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.purple),
                            SizedBox(width: 8),
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          isVisible: _isNewPasswordVisible,
                          onToggleVisibility: () => setState(() =>
                              _isNewPasswordVisible = !_isNewPasswordVisible),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          isVisible: _isCurrentPasswordVisible,
                          onToggleVisibility: () => setState(() =>
                              _isCurrentPasswordVisible =
                                  !_isCurrentPasswordVisible),
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildStyledButton(
                          text: 'Change Password',
                          onPressed: _updatePassword,
                          icon: Icons.lock,
                          backgroundColor: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // User Management Section
            _buildExpandableSection(
              'User Management',
              Icons.group,
              [
                // Search Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search users by email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _filterUsers();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterUsers();
                    },
                  ),
                ),

                // Tab Selection + Sync Button
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedUserTab = 'admins';
                            });
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                          label: Text(
                              'Admin Users (${_filteredAdminUsers.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedUserTab == 'admins'
                                ? primaryGreen
                                : Colors.grey.shade200,
                            foregroundColor: _selectedUserTab == 'admins'
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedUserTab = 'customers';
                            });
                          },
                          icon: const Icon(Icons.people),
                          label: Text(
                              'Customers (${_filteredCustomerUsers.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedUserTab == 'customers'
                                ? primaryGreen
                                : Colors.grey.shade200,
                            foregroundColor: _selectedUserTab == 'customers'
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sync users button (calls Edge Function)
                      IconButton(
                        onPressed: _isLoading ? null : _triggerSyncUsers,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync),
                        tooltip: 'Sync users from auth',
                      ),
                    ],
                  ),
                ),

                // Add User Section
                if (_selectedUserTab == 'admins') ...[
                  _buildAddAdminUserSection(),
                ] else ...[
                  _buildAddCustomerUserSection(),
                ],

                const SizedBox(height: 24),

                // Users List
                if (_isLoadingUsers)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_selectedUserTab == 'admins')
                  _buildUsersList(_filteredAdminUsers, 'admin')
                else
                  _buildUsersList(_filteredCustomerUsers, 'customer'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
