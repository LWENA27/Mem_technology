import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/DatabaseService.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/EditProductDialog.dart'; // Add this import

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await DatabaseService.instance.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  _addProduct() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    ).then((result) {
      if (result == true) {
        _loadProducts();
      }
    });
  }

  _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(product: product),
    ).then((result) {
      if (result == true) {
        _loadProducts();
      }
    });
  }

  _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteProduct(product.id);
              Navigator.pop(context);
              _loadProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No products found', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Add your first product to get started'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: product.imageUrl != null
                              ? (product.imageUrl!.startsWith('http')
                                  ? Image.network(
                                      product.imageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                        backgroundColor: product.quantity > 0 ? Colors.green : Colors.red,
                                        child: Text(
                                          product.quantity.toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : File(product.imageUrl!).existsSync()
                                      ? Image.file(
                                          File(product.imageUrl!),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                            backgroundColor: product.quantity > 0 ? Colors.green : Colors.red,
                                            child: Text(
                                              product.quantity.toString(),
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: product.quantity > 0 ? Colors.green : Colors.red,
                                          child: Text(
                                            product.quantity.toString(),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ))
                              : CircleAvatar(
                                  backgroundColor: product.quantity > 0 ? Colors.green : Colors.red,
                                  child: Text(
                                    product.quantity.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product.brand} - ${product.category}'),
                              Text(
                                'Price: \$${product.sellingPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(
                                'Added: ${DateFormat('MMM dd, yyyy').format(product.dateAdded)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editProduct(product);
                              } else if (value == 'delete') {
                                _deleteProduct(product);
                              }
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}