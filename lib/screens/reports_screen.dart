import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/report_service.dart';
import '../services/DatabaseService.dart';
import 'admin_account_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  double _totalSales = 0.0;
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
      final totalSales =
          sales.fold<double>(0, (sum, sale) => sum + sale.totalPrice);
      final totalItems = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);
      // Top selling products
      final productSales = <String, int>{};
      for (final sale in sales) {
        productSales[sale.productName] =
            (productSales[sale.productName] ?? 0) + sale.quantity;
      }
      final topProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        _totalSales = totalSales;
        _reportData = {
          'totalSales': totalSales,
          'totalTransactions': sales.length,
          'totalItems': totalItems,
          'averageSale': sales.isNotEmpty ? totalSales / sales.length : 0.0,
          'topProducts': topProducts.take(5).toList(),
          'recentSales': sales.take(10).toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _totalSales = 0.0;
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sales Reports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Account',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminAccountScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selection Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Report Period',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'From',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: lightGray,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(_startDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: darkGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'To',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: lightGray,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(_endDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: darkGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.calendar_today,
                                  color: primaryGreen),
                              label: const Text(
                                'Select Date Range',
                                style: TextStyle(color: primaryGreen),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryGreen),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sales Summary Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.monetization_on,
                              color: primaryGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Sales',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: lightGray,
                                  ),
                                ),
                                Text(
                                  'TSH ${_totalSales.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Column(
                    children: [
                      // Preview Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _previewReport,
                          icon:
                              const Icon(Icons.visibility, color: Colors.white),
                          label: const Text(
                            'Preview Report',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Save Options
                      Row(
                        children: [
                          // Quick Save to Downloads
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _saveToLocation(
                                  'Downloads', '/storage/emulated/0/Download'),
                              icon: const Icon(Icons.download,
                                  color: Colors.white),
                              label: const Text(
                                'Quick Save',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen.withOpacity(0.8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Choose Location
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showSaveOptionsDialog,
                              icon: const Icon(Icons.folder_open,
                                  color: primaryGreen),
                              label: const Text(
                                'Choose Location',
                                style: TextStyle(
                                    color: primaryGreen, fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryGreen),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: primaryGreen,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Save Options:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Quick Save: Downloads folder (default)\n• Choose Location: Downloads, Documents, or MemTech folder\n• Preview: View report before saving',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Add the ReportPreviewScreen here (simplified version without file_picker)
class ReportPreviewScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> reportData;

  const ReportPreviewScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.reportData,
  });

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Report Preview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: lightGray,
                    ),
                  ),
                  Text(
                    'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: lightGray,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                    child: _buildSummaryCard('Transactions',
                        '${reportData['totalTransactions']}', Icons.receipt)),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: primaryGreen),
                label:
                    const Text('Back', style: TextStyle(color: primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSaveOptionsFromPreview(context),
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text('Save Report',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                _saveToLocationFromPreview(
                    context, 'Downloads', '/storage/emulated/0/Download');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: primaryGreen),
              title: const Text('Documents'),
              subtitle: const Text('Organized storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocationFromPreview(
                    context, 'Documents', '/storage/emulated/0/Documents');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business, color: primaryGreen),
              title: const Text('MemTech Folder'),
              subtitle: const Text('App-specific storage'),
              onTap: () {
                Navigator.pop(context);
                _saveToLocationFromPreview(context, 'MemTech Folder',
                    '/storage/emulated/0/MemTechnology');
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

  void _saveToLocationFromPreview(
      BuildContext context, String locationName, String path) async {
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

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
