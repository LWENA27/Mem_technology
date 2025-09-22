import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../services/DatabaseService.dart';
import '../widgets/make_sale_dialog.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Sale> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  _loadSales() async {
    setState(() => _isLoading = true);
    final sales = await DatabaseService.instance.getAllSales();
    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  _makeSale() async {
    // Fetch available products
    final availableProducts =
        await DatabaseService.instance.getAvailableProducts();
    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available for sale')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) =>
          MakeSaleDialog(availableProducts: availableProducts),
    ).then((result) {
      if (result == true) {
        _loadSales();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalSales = _sales.fold(0, (sum, sale) => sum + sale.totalPrice);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Total Sales',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'TSH ${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _sales.length.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No sales recorded',
                                style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text('Make your first sale to get started'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadSales(),
                        child: ListView.builder(
                          itemCount: _sales.length,
                          itemBuilder: (context, index) {
                            final sale = _sales[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.shopping_cart,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  sale.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Customer: ${sale.customerName}'),
                                    Text(
                                        'Qty: ${sale.quantity} × TSH ${sale.unitPrice.toStringAsFixed(2)}'),
                                    Text(
                                      DateFormat('MMM dd, yyyy HH:mm')
                                          .format(sale.saleDate),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  'TSH ${sale.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _makeSale,
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
