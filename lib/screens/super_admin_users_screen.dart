import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/enhanced_feedback_widget.dart';

class SuperAdminUsersScreen extends StatefulWidget {
  final String? selectedTenantId;

  const SuperAdminUsersScreen({
    super.key,
    this.selectedTenantId,
  });

  @override
  State<SuperAdminUsersScreen> createState() => _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends State<SuperAdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didUpdateWidget(SuperAdminUsersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTenantId != widget.selectedTenantId) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);

      if (widget.selectedTenantId == null) {
        setState(() {
          _users = [];
          _isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('tenant_id', widget.selectedTenantId!)
          .order('email');

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to load users: $e',
      );
    }
  }

  Future<void> _createUser() async {
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'user');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'user@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: roleController.text,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                ],
                onChanged: (value) {
                  if (value != null) roleController.text = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) {
                EnhancedFeedbackWidget.showErrorSnackBar(
                  context,
                  'Email is required',
                );
                return;
              }

              try {
                // Create auth user first (this would typically be done via admin API)
                // For now, we'll just create the profile
                await Supabase.instance.client.from('profiles').insert({
                  'email': emailController.text.trim(),
                  'role': roleController.text,
                  'tenant_id': widget.selectedTenantId,
                });

                Navigator.pop(context, true);
              } catch (e) {
                EnhancedFeedbackWidget.showErrorSnackBar(
                  context,
                  'Failed to create user: $e',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadUsers();
      EnhancedFeedbackWidget.showSuccessSnackBar(
        context,
        'User created successfully!',
      );
    }
  }

  Future<void> _updateUserRole(
      Map<String, dynamic> user, String newRole) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': newRole}).eq('id', user['id']);

      _loadUsers();

      EnhancedFeedbackWidget.showSuccessSnackBar(
        context,
        'User role updated successfully!',
      );
    } catch (e) {
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to update user role: $e',
      );
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content:
            Text('Are you sure you want to delete user "${user['email']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .delete()
            .eq('id', user['id']);

        _loadUsers();

        EnhancedFeedbackWidget.showSuccessSnackBar(
          context,
          'User deleted successfully!',
        );
      } catch (e) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Failed to delete user: $e',
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      final email = user['email']?.toString().toLowerCase() ?? '';
      final role = user['role']?.toString().toLowerCase() ?? '';

      return email.contains(query) || role.contains(query);
    }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'staff':
        return Colors.orange;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search and create
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed:
                      widget.selectedTenantId != null ? _createUser : null,
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text('Add User',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: widget.selectedTenantId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a tenant to view users',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No users match your search'
                                      : 'No users in this tenant',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final role = user['role']?.toString() ?? 'user';

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getRoleColor(role),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      user['email'] ?? 'No email',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(role)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getRoleColor(role),
                                            ),
                                          ),
                                        ),
                                        if (user['created_at'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              'Created: ${DateTime.parse(user['created_at']).toString().split('.')[0]}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (action) {
                                        switch (action) {
                                          case 'change_role':
                                            _showRoleChangeDialog(user);
                                            break;
                                          case 'delete':
                                            _deleteUser(user);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'change_role',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Change Role'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${user['email']}'),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(
            labelText: 'New Role',
          ),
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
            DropdownMenuItem(value: 'staff', child: Text('Staff')),
            DropdownMenuItem(value: 'user', child: Text('User')),
          ],
          onChanged: (value) {
            if (value != null) selectedRole = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserRole(user, selectedRole);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
