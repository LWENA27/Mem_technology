import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../repositories/sales_repository.dart';
import '../services/sales_service.dart';
import '../services/receipt_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Sale> _sales = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Sale> sales;

      // Use platform-aware sales loading
      if (kIsWeb) {
        // Web: Use SalesService (Supabase directly)
        sales = await SalesService.getSales();
      } else {
        // Native: Use SalesRepository (offline-first)
        final salesRepository = SalesRepository();
        sales = await salesRepository.getAllSalesAsModels();
      }

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReceipt(Sale sale) async {
    if (sale.receiptNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt number available for this sale'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show dialog to get business information for receipt
      final businessInfo = await _showBusinessInfoDialog();
      if (businessInfo == null) return;

      await ReceiptService.downloadReceipt(
        sale: sale,
        businessName: businessInfo['name']!,
        businessAddress: businessInfo['address']!,
        businessPhone: businessInfo['phone']!,
        businessTIN: businessInfo['tin']!,
        receiptNumber: sale.receiptNumber!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, String>?> _showBusinessInfoDialog() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final tinController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Business Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Business Phone *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tinController,
                decoration: const InputDecoration(
                  labelText: 'Business TIN',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'address': addressController.text.trim(),
                'phone': phoneController.text.trim(),
                'tin': tinController.text.trim(),
              });
            },
            child: const Text('Generate Receipt'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'TSH ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSales,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _sales.isEmpty
                ? const Center(
                    child: Text(
                      'No sales recorded yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSales,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sales.length,
                      itemBuilder: (context, index) {
                        final sale = _sales[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sale.productName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (sale.receiptNumber != null)
                                      IconButton(
                                        icon: const Icon(Icons.receipt),
                                        onPressed: () => _downloadReceipt(sale),
                                        tooltip: 'Download Receipt',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      sale.customerName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                if (sale.customerPhone?.isNotEmpty == true) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        sale.customerPhone!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Qty: ${sale.quantity}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '@ ${_formatCurrency(sale.unitPrice)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(sale.saleDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Total: ${_formatCurrency(sale.totalPrice)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                                if (sale.receiptNumber != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Receipt: ${sale.receiptNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
  }
}
