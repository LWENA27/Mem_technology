import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/enhanced_feedback_widget.dart';

class TenantManagementScreen extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onTenantSelected;
  final String? selectedTenantId;

  const TenantManagementScreen({
    super.key,
    required this.onTenantSelected,
    this.selectedTenantId,
  });

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  List<Map<String, dynamic>> _tenants = [];
  bool _isLoading = true;
  String _searchQuery = '';

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      setState(() => _isLoading = true);

      final response = await Supabase.instance.client.from('tenants').select('''
            *,
            profiles:profiles!tenant_id(count),
            inventories:inventories!tenant_id(count)
          ''').order('created_at', ascending: false);

      setState(() {
        _tenants = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to load tenants: $e',
      );
    }
  }

  Future<void> _createTenant() async {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Tenant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tenant Name',
                  hintText: 'e.g., Acme Corporation',
                ),
                onChanged: (value) {
                  // Auto-generate slug
                  slugController.text = value
                      .toLowerCase()
                      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                      .replaceAll(RegExp(r'^-|-$'), '');
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: slugController,
                decoration: const InputDecoration(
                  labelText: 'Slug (URL identifier)',
                  hintText: 'acme-corporation',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the tenant',
                ),
                maxLines: 3,
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
              if (nameController.text.trim().isEmpty ||
                  slugController.text.trim().isEmpty) {
                EnhancedFeedbackWidget.showErrorSnackBar(
                  context,
                  'Name and slug are required',
                );
                return;
              }

              try {
                await Supabase.instance.client.from('tenants').insert({
                  'name': nameController.text.trim(),
                  'slug': slugController.text.trim(),
                  'public_storefront': true,
                  'metadata': {
                    'description': descriptionController.text.trim(),
                    'created_by': 'super_admin',
                  },
                });

                Navigator.pop(context, true);
              } catch (e) {
                EnhancedFeedbackWidget.showErrorSnackBar(
                  context,
                  'Failed to create tenant: $e',
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
      _loadTenants();
      EnhancedFeedbackWidget.showSuccessSnackBar(
        context,
        'Tenant created successfully!',
      );
    }
  }

  Future<void> _toggleTenantStatus(Map<String, dynamic> tenant) async {
    try {
      final newStatus = !(tenant['public_storefront'] ?? false);

      await Supabase.instance.client
          .from('tenants')
          .update({'public_storefront': newStatus}).eq('id', tenant['id']);

      _loadTenants();

      EnhancedFeedbackWidget.showSuccessSnackBar(
        context,
        'Tenant ${newStatus ? 'enabled' : 'disabled'} successfully!',
      );
    } catch (e) {
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to update tenant: $e',
      );
    }
  }

  List<Map<String, dynamic>> get _filteredTenants {
    if (_searchQuery.isEmpty) return _tenants;

    return _tenants.where((tenant) {
      final name = tenant['name']?.toString().toLowerCase() ?? '';
      final slug = tenant['slug']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || slug.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Create Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search tenants...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _createTenant,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create Tenant',
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

          // Tenants List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTenants.isEmpty
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
                              _searchQuery.isEmpty
                                  ? 'No tenants found'
                                  : 'No tenants match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTenants,
                        child: ListView.builder(
                          itemCount: _filteredTenants.length,
                          itemBuilder: (context, index) {
                            final tenant = _filteredTenants[index];
                            final isSelected =
                                tenant['id'] == widget.selectedTenantId;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              elevation: isSelected ? 4 : 1,
                              color: isSelected
                                  ? primaryGreen.withOpacity(0.1)
                                  : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      tenant['public_storefront'] == true
                                          ? primaryGreen
                                          : Colors.grey,
                                  child: Icon(
                                    tenant['public_storefront'] == true
                                        ? Icons.storefront
                                        : Icons.business,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  tenant['name'] ?? 'Unnamed Tenant',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Slug: ${tenant['slug'] ?? 'N/A'}'),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${tenant['profiles']?.length ?? 0} users',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.inventory,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${tenant['inventories']?.length ?? 0} products',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value:
                                          tenant['public_storefront'] == true,
                                      onChanged: (_) =>
                                          _toggleTenantStatus(tenant),
                                      activeColor: primaryGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? primaryGreen
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  widget.onTenantSelected(tenant['id'], tenant);
                                },
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
}
