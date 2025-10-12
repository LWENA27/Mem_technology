import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/sales_service.dart';
import '../services/receipt_service.dart';

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
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessTINController = TextEditingController();
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _generateReceipt = true;

  @override
  void initState() {
    super.initState();
    if (widget.availableProducts.isNotEmpty) {
      _selectedProduct = widget.availableProducts[0];
    }
    // Set default business info - in a real app, this would come from user profile/tenant settings
    _businessNameController.text = 'Your Business Name';
    _businessAddressController.text = 'Your Business Address';
    _businessPhoneController.text = '+255 XXX XXX XXX';
    _businessTINController.text = '123-456-789';
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

    try {
      // Generate receipt number if needed
      String? receiptNumber;
      if (_generateReceipt) {
        receiptNumber = SalesService.generateReceiptNumber();
      }

      // Record the sale using SalesService
      final saleId = await SalesService.recordSale(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: quantity,
        unitPrice: unitPrice,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isNotEmpty
            ? _customerPhoneController.text.trim()
            : null,
        receiptNumber: receiptNumber,
      );

      // Get the created sale for receipt generation
      Sale? sale;
      if (_generateReceipt) {
        sale = await SalesService.getSaleById(saleId);
      }

      // Generate and download receipt if requested
      if (_generateReceipt && sale != null) {
        try {
          await ReceiptService.downloadReceipt(
            sale: sale,
            businessName: _businessNameController.text.trim(),
            businessAddress: _businessAddressController.text.trim(),
            businessPhone: _businessPhoneController.text.trim(),
            businessTIN: _businessTINController.text.trim(),
            receiptNumber: receiptNumber!,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Sale recorded and receipt downloaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (receiptError) {
          // Sale was recorded but receipt failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Sale recorded but receipt download failed: $receiptError'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
      }

      Navigator.of(context).pop(true);
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
              const SizedBox(height: 16),

              // Receipt Generation Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _generateReceipt,
                          onChanged: (value) {
                            setState(() {
                              _generateReceipt = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Generate Receipt',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (_generateReceipt) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Business Information:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: _generateReceipt
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Business name required for receipt';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _businessAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Business Address',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                        validator: _generateReceipt
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Business address required for receipt';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _businessPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Business Phone',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _businessTINController,
                              decoration: const InputDecoration(
                                labelText: 'TIN',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
              : Text(_generateReceipt
                  ? 'Record Sale & Generate Receipt'
                  : 'Record Sale'),
        ),
      ],
    );
  }
}
