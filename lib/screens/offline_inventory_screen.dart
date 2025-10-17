import 'package:flutter/material.dart';
import '../repositories/product_repository.dart';
import '../widgets/offline_indicator.dart';

class OfflineInventoryScreen extends StatefulWidget {
  const OfflineInventoryScreen({super.key});

  @override
  State<OfflineInventoryScreen> createState() => _OfflineInventoryScreenState();
}

class _OfflineInventoryScreenState extends State<OfflineInventoryScreen> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Set tenant ID (you would get this from user session)
    _productRepository.setTenantId('your-tenant-id');

    // Listen for search changes
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await _productRepository.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = query.isEmpty ||
            product['name'].toString().toLowerCase().contains(query) ||
            product['category'].toString().toLowerCase().contains(query) ||
            (product['sku']?.toString().toLowerCase().contains(query) ?? false);

        final matchesCategory = _selectedCategory == 'All' ||
            product['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _addProduct() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddProductDialog(),
    );

    if (result != null) {
      final success = await _productRepository.addProduct(result);
      if (success) {
        _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add product')),
        );
      }
    }
  }

  Future<void> _updateStock(String productId, int currentStock) async {
    final newStock = await showDialog<int>(
      context: context,
      builder: (context) => UpdateStockDialog(currentStock: currentStock),
    );

    if (newStock != null) {
      final success = await _productRepository.updateStock(productId, newStock);
      if (success) {
        _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildProductList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SyncFloatingActionButton(),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _addProduct,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Inventory Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: _loadProducts,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    final categories = [
      'All',
      ...{for (final product in _products) product['category'] as String}
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'All';
                _filterProducts();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isLowStock = product['quantity'] <= product['minStock'];
    final needsSync = product['needsSync'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red : Colors.green,
          child: Text(
            product['quantity'].toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(product['name'])),
            if (needsSync)
              const Icon(
                Icons.sync_problem,
                color: Colors.orange,
                size: 16,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product['category']}'),
            Text('Price: \$${product['price'].toStringAsFixed(2)}'),
            if (product['sku'] != null) Text('SKU: ${product['sku']}'),
            if (isLowStock)
              Text(
                'Low Stock (Min: ${product['minStock']})',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _updateStock(product['id'], product['quantity']),
              icon: const Icon(Icons.edit),
              tooltip: 'Update Stock',
            ),
            IconButton(
              onPressed: () => _deleteProduct(product['id']),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Product',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _productRepository.deleteProduct(productId);
      if (success) {
        _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    }
  }
}

// Dialog for adding new products
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _skuController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(labelText: 'Minimum Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU (Optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final productData = {
                'name': _nameController.text,
                'category': _categoryController.text,
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                'price': double.parse(_priceController.text),
                'quantity': int.parse(_quantityController.text),
                'minStock': int.tryParse(_minStockController.text) ?? 0,
                'sku': _skuController.text.isEmpty ? null : _skuController.text,
                'imageUrls': <String>[],
                'isActive': true,
                'createdAt': DateTime.now(),
              };
              Navigator.of(context).pop(productData);
            }
          },
          child: const Text('Add Product'),
        ),
      ],
    );
  }
}

// Dialog for updating stock
class UpdateStockDialog extends StatefulWidget {
  final int currentStock;

  const UpdateStockDialog({super.key, required this.currentStock});

  @override
  State<UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<UpdateStockDialog> {
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _stockController =
        TextEditingController(text: widget.currentStock.toString());
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Stock'),
      content: TextField(
        controller: _stockController,
        decoration: const InputDecoration(labelText: 'New Stock Quantity'),
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newStock = int.tryParse(_stockController.text);
            if (newStock != null && newStock >= 0) {
              Navigator.of(context).pop(newStock);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
