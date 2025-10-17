import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../widgets/enhanced_feedback_widget.dart';
import '../utils/tsh_formatter.dart';

class SuperAdminInventoryScreen extends StatefulWidget {
  final String? selectedTenantId;

  const SuperAdminInventoryScreen({
    super.key,
    this.selectedTenantId,
  });

  @override
  State<SuperAdminInventoryScreen> createState() =>
      _SuperAdminInventoryScreenState();
}

class _SuperAdminInventoryScreenState extends State<SuperAdminInventoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _categories = {'All'};

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(SuperAdminInventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTenantId != widget.selectedTenantId) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);

      if (widget.selectedTenantId == null) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('inventories')
          .select('*')
          .eq('tenant_id', widget.selectedTenantId!)
          .order('name');

      final products = response
          .map<Product>((item) => Product.fromInventoryJson(item))
          .toList();

      final categories = products.map((p) => p.category).toSet();

      setState(() {
        _products = products;
        _categories = {'All', ...categories};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      EnhancedFeedbackWidget.showErrorSnackBar(
        context,
        'Failed to load products: $e',
      );
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false) ||
              p.id.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
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
            .from('inventories')
            .delete()
            .eq('id', product.id);

        _loadProducts();

        EnhancedFeedbackWidget.showSuccessSnackBar(
          context,
          'Product deleted successfully!',
        );
      } catch (e) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Failed to delete product: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),

                // Category filter
                Row(
                  children: [
                    const Text('Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = category == _selectedCategory;
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) => setState(
                                    () => _selectedCategory = category),
                                selectedColor: primaryGreen.withOpacity(0.3),
                                checkmarkColor: primaryGreen,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Products list
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
                          'Select a tenant to view inventory',
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
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No products match your search'
                                      : 'No products in this tenant',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.builder(
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: primaryGreen,
                                      child: Text(
                                        product.name.isNotEmpty
                                            ? product.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'ID: ${product.id.substring(0, 8)}...'),
                                        Text('Category: ${product.category}'),
                                        Text(
                                            'Selling: ${TSHFormatter.formatCurrency(product.sellingPrice)}'),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.inventory,
                                              size: 16,
                                              color: product.quantity <= 10
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Stock: ${product.quantity}',
                                              style: TextStyle(
                                                color: product.quantity <= 10
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (action) {
                                        switch (action) {
                                          case 'delete':
                                            _deleteProduct(product);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
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
                                    onTap: () {
                                      // Show product details dialog
                                      _showProductDetails(product);
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

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', product.id),
              _buildDetailRow('Category', product.category),
              _buildDetailRow('Brand', product.brand),
              _buildDetailRow(
                  'Description', product.description ?? 'No description'),
              _buildDetailRow('Buying Price',
                  TSHFormatter.formatCurrency(product.buyingPrice)),
              _buildDetailRow('Selling Price',
                  TSHFormatter.formatCurrency(product.sellingPrice)),
              _buildDetailRow('Quantity', '${product.quantity}'),
              _buildDetailRow(
                  'Created', product.dateAdded.toString().split('.')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
