import 'package:flutter/material.dart';
import 'package:memtechnology/services/inventory_service.dart';
import 'package:memtechnology/models/product.dart';
import 'package:memtechnology/widgets/add_product_dialog.dart';
import 'package:memtechnology/widgets/make_sale_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

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
      final products = await InventoryService.getInventories();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  _deleteProduct(Product product) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await InventoryService.deleteInventory(product.id);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${product.name} deleted successfully'),
                  ),
                ],
              ),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Failed to delete product: $e'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  _sellProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => MakeSaleDialog(
        availableProducts: [product], // Pass only the selected product
      ),
    ).then((_) => _loadProducts()); // Refresh products after sale
  }

  _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        product: product,
        onProductAdded: () => _loadProducts(),
      ),
    );
  }

  _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductAdded: () => _loadProducts(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: lightGray.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: lightGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No products in inventory',
                        style: TextStyle(
                          fontSize: 20,
                          color: darkGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first product using the + button',
                        style: TextStyle(
                          fontSize: 16,
                          color: lightGray,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Product',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  color: primaryGreen,
                  child: Column(
                    children: [
                      // Stats Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Products',
                                    style: TextStyle(
                                      color: lightGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_products.length}',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'In Stock',
                                    style: TextStyle(
                                      color: lightGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_products.where((p) => p.quantity > 0).length}',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Out of Stock',
                                    style: TextStyle(
                                      color: lightGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_products.where((p) => p.quantity == 0).length}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Products List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final isOutOfStock = product.quantity == 0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? Colors.red.withOpacity(0.1)
                                        : primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            product.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.shopping_bag,
                                                color: isOutOfStock
                                                    ? Colors.red
                                                    : primaryGreen,
                                                size: 30,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.shopping_bag,
                                          color: isOutOfStock
                                              ? Colors.red
                                              : primaryGreen,
                                          size: 30,
                                        ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkGray,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.category} • ${product.brand}',
                                      style: const TextStyle(
                                        color: lightGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Price: TSH ${product.sellingPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isOutOfStock
                                                ? Colors.red.withOpacity(0.1)
                                                : primaryGreen.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${product.quantity}',
                                            style: TextStyle(
                                              color: isOutOfStock
                                                  ? Colors.red
                                                  : primaryGreen,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Sell button - compact version
                                    if (!isOutOfStock)
                                      SizedBox(
                                        width: 60,
                                        height: 28,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _sellProduct(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            textStyle:
                                                const TextStyle(fontSize: 10),
                                          ),
                                          child: const Text('Sell'),
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    // More options menu
                                    PopupMenuButton(
                                      icon: const Icon(Icons.more_vert,
                                          color: lightGray, size: 20),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: primaryGreen,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            Duration.zero,
                                            () => _editProduct(product),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            Duration.zero,
                                            () => _deleteProduct(product),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
