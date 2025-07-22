import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/DatabaseService.dart';

class MakeSaleDialog extends StatefulWidget {
  final List<Product> availableProducts;

  const MakeSaleDialog({required this.availableProducts, super.key});

  @override
  _MakeSaleDialogState createState() => _MakeSaleDialogState();
}

class _MakeSaleDialogState extends State<MakeSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableProducts.isNotEmpty) {
      _selectedProduct = widget.availableProducts[0];
    }
  }

  _recordSale() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final quantity = int.parse(_quantityController.text);
    final unitPrice = _selectedProduct!.sellingPrice;
    final totalPrice = quantity * unitPrice;
    if (unitPrice <= 0 || totalPrice <= 0) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale price must be greater than zero.')),
      );
      return;
    }
    final sale = Sale(
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      saleDate: DateTime.now(),
    );

    try {
      await DatabaseService.instance.insertSale(sale);
      // Update product quantity
      final updatedProduct = Product(
        id: _selectedProduct!.id,
        name: _selectedProduct!.name,
        category: _selectedProduct!.category,
        brand: _selectedProduct!.brand,
        buyingPrice: _selectedProduct!.buyingPrice,
        sellingPrice: _selectedProduct!.sellingPrice,
        quantity: _selectedProduct!.quantity - quantity,
        description: _selectedProduct!.description,
        dateAdded: _selectedProduct!.dateAdded,
        imageUrl: _selectedProduct!.imageUrl,
      );
      await DatabaseService.instance.updateProduct(updatedProduct);

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale recorded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording sale: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Sale'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Product *',
                  border: OutlineInputBorder(),
                ),
                items: widget.availableProducts.map((product) {
                  return DropdownMenuItem<Product>(
                    value: product,
                    child:
                        Text('${product.name} (${product.quantity} available)'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a product';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Invalid quantity';
                  }
                  if (_selectedProduct != null &&
                      quantity > _selectedProduct!.quantity) {
                    return 'Quantity exceeds available stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Customer Phone *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer phone';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _recordSale,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Record Sale'),
        ),
      ],
    );
  }
}
