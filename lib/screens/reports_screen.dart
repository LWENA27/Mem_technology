import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/report_service.dart';
import '../services/DatabaseService.dart';
import '../models/product.dart';

// MEM Technology Color Scheme
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGray = Color(0xFF424242);
const Color lightGray = Color(0xFF757575);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _profit = 0.0;
  double _loss = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryGreen.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: _showSaveOptionsDialog,
            tooltip: 'Save Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
                strokeWidth: 2,
              ),
            )
          : _reportData == null
              ? Center(
                  child: Text(
                    'No sales data for selected period.',
                    style: TextStyle(color: darkGray, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Period: '
                            '${DateFormat('MMM dd, yyyy').format(_startDate)} - '
                            '${DateFormat('MMM dd, yyyy').format(_endDate)}',
                            style:
                                const TextStyle(color: lightGray, fontSize: 14),
                          ),
                          TextButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.date_range,
                                color: primaryGreen),
                            label: const Text('Change',
                                style: TextStyle(color: primaryGreen)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Sales',
                              'TSH \\${_reportData!['totalSales'].toStringAsFixed(2)}',
                              Icons.monetization_on,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Transactions',
                              '\\${_reportData!['totalTransactions']}',
                              Icons.receipt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Items',
                              '\\${_reportData!['totalItems']}',
                              Icons.shopping_basket,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Average Sale',
                              'TSH \\${_reportData!['averageSale'].toStringAsFixed(2)}',
                              Icons.bar_chart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Top Products',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: darkGray)),
                      const SizedBox(height: 8),
                      ...(_reportData!['topProducts'] as List).isEmpty
                          ? [
                              Text('No data',
                                  style: TextStyle(color: lightGray))
                            ]
                          : (_reportData!['topProducts'] as List)
                              .map<Widget>((entry) => ListTile(
                                    leading: const Icon(Icons.star,
                                        color: primaryGreen),
                                    title: Text(entry.key),
                                    trailing: Text('Qty: \\${entry.value}'),
                                  ))
                              .toList(),
                      const SizedBox(height: 24),
                      Text('Recent Sales',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: darkGray)),
                      const SizedBox(height: 8),
                      ...(_reportData!['recentSales'] as List).isEmpty
                          ? [
                              Text('No data',
                                  style: TextStyle(color: lightGray))
                            ]
                          : (_reportData!['recentSales'] as List)
                              .map<Widget>((sale) => ListTile(
                                    leading: const Icon(Icons.receipt_long,
                                        color: primaryGreen),
                                    title: Text(sale.productName),
                                    subtitle: Text(
                                        'Qty: \\${sale.quantity}  |  TSH \\${sale.totalPrice.toStringAsFixed(2)}'),
                                    trailing: Text(DateFormat('MMM dd')
                                        .format(sale.saleDate)),
                                  ))
                              .toList(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _previewReport,
                            icon: const Icon(Icons.visibility,
                                color: Colors.white),
                            label: const Text('Preview',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  // double _totalSales = 0.0; // Removed unused field
  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _reportData;

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await DatabaseService.instance
          .getSalesByDateRange(_startDate, _endDate);
      final products = await DatabaseService.instance.getAllProducts();
      final totalSales =
          sales.fold<double>(0, (sum, sale) => sum + sale.totalPrice);
      final totalItems = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);
      final productSales = <String, int>{};
      double profit = 0.0;
      double loss = 0.0;
      for (final sale in sales) {
        productSales[sale.productName] =
            (productSales[sale.productName] ?? 0) + sale.quantity;
        final product = products.firstWhere((p) => p.id == sale.productId,
            orElse: () => Product(
                  id: sale.productId,
                  name: sale.productName,
                  category: '',
                  brand: '',
                  buyingPrice: 0.0,
                  sellingPrice: sale.unitPrice,
                  quantity: 0,
                  dateAdded: sale.saleDate,
                ));
        final cost = product.buyingPrice * sale.quantity;
        final saleProfit = sale.totalPrice - cost;
        if (saleProfit >= 0) {
          profit += saleProfit;
        } else {
          loss += saleProfit.abs();
        }
      }
      final topProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        _profit = profit;
        _loss = loss;
        _reportData = {
          'totalSales': totalSales,
          'totalTransactions': sales.length,
          'totalItems': totalItems,
          'averageSale': sales.isNotEmpty ? totalSales / sales.length : 0.0,
          'topProducts': topProducts.take(5).toList(),
          'recentSales': sales.take(10).toList(),
          'allSales': sales,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _reportData = null;
        _isLoading = false;
      });
    }
  }

  _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryGreen,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    }
  }

  _previewReport() {
    if (_reportData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available for preview')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPreviewScreen(
          startDate: _startDate,
          endDate: _endDate,
          reportData: _reportData!,
        ),
      ),
    );
  }

  // Save to Downloads folder
  _saveToLocation(String locationName, String path) async {
    setState(() => _isLoading = true);
    try {
      final reportService = ReportService();
      final pdf = await reportService.generateSalesReport(_startDate, _endDate);

      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName =
          'MemTech_SalesReport_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('$path/$fileName');

      await file.writeAsBytes(await pdf.save());

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Report saved to $locationName: $fileName')),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error saving report: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Show save location options
  _showSaveOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save_alt, color: primaryGreen),
            SizedBox(width: 8),
            Text('Choose Save Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download, color: primaryGreen),
              title: const Text('Downloads'),
              subtitle: const Text('Easy to find and share'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocation('Downloads', '/storage/emulated/0/Download');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: primaryGreen),
              title: const Text('Documents'),
              subtitle: const Text('Organized storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocation('Documents', '/storage/emulated/0/Documents');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business, color: primaryGreen),
              title: const Text('MemTech Folder'),
              subtitle: const Text('App-specific storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocation(
                    'MemTech Folder', '/storage/emulated/0/MemTechnology');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Add the ReportPreviewScreen here (simplified version without file_picker)
class ReportPreviewScreen extends StatelessWidget {
  void _showSaveOptionsFromPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save_alt, color: primaryGreen),
            SizedBox(width: 8),
            Text('Choose Save Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download, color: primaryGreen),
              title: const Text('Downloads'),
              subtitle: const Text('Easy to find and share'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocationFromPreview(context, 'Downloads', '/storage/emulated/0/Download');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: primaryGreen),
              title: const Text('Documents'),
              subtitle: const Text('Organized storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocationFromPreview(context, 'Documents', '/storage/emulated/0/Documents');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business, color: primaryGreen),
              title: const Text('MemTech Folder'),
              subtitle: const Text('App-specific storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocationFromPreview(context, 'MemTech Folder', '/storage/emulated/0/MemTechnology');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

  void _saveToLocationFromPreview(BuildContext context, String locationName, String path) async {
    try {
      final reportService = ReportService();
      final pdf = await reportService.generateSalesReport(startDate, endDate);

      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName =
          'MemTech_SalesReport_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('$path/$fileName');

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Report saved to $locationName: $fileName')),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> reportData;

  ReportPreviewScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.reportData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MEMTECHNOLOGY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sales Report',
                style: TextStyle(
                  fontSize: 18,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 16),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Sales',
                      'TSH ${reportData['totalSales'].toStringAsFixed(2)}',
                      Icons.monetization_on)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Transactions',
                      '${reportData['totalTransactions']}',
                      Icons.receipt)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Profit',
                      'TSH ${reportData['profit']?.toStringAsFixed(2) ?? '0.00'}',
                      Icons.trending_up)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Loss',
                      'TSH ${reportData['loss']?.toStringAsFixed(2) ?? '0.00'}',
                      Icons.trending_down)),
                ],
              ),
              const SizedBox(height: 24),
              Text('All Sales', style: TextStyle(fontWeight: FontWeight.bold, color: darkGray)),
              const SizedBox(height: 8),
              ...((reportData['allSales'] as List).isEmpty
                ? [Text('No sales', style: TextStyle(color: lightGray))]
                : (reportData['allSales'] as List)
                    .map<Widget>((sale) => ListTile(
                          leading: const Icon(Icons.shopping_cart, color: primaryGreen),
                          title: Text(sale.productName),
                          subtitle: Text('Qty: ${sale.quantity} | TSH ${sale.totalPrice.toStringAsFixed(2)}'),
                          trailing: Text(DateFormat('MMM dd, yyyy').format(sale.saleDate)),
                        ))
                    .toList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSaveOptionsFromPreview(context),
        icon: const Icon(Icons.save_alt),
        label: const Text('Preview & Save'),
        backgroundColor: primaryGreen,
      ),
    );
  }


  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  