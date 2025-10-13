import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../services/DatabaseService.dart';
import '../models/product.dart';
import '../models/sale.dart';

// MEM Technology Color Scheme
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);
const Color darkGray = Color(0xFF424242);
const Color lightGray = Color(0xFF757575);
const Color backgroundColor = Color(0xFFF8F9FA);
const Color cardBackground = Colors.white;
const Color errorColor = Color(0xFFE57373);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate =
      DateTime(2020, 1, 1); // Start from early date to include all sales
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  String? _errorMessage;
  List<Sale> _allSales = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      color: primaryGreen,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryGreen, strokeWidth: 3),
            SizedBox(height: 16),
            Text('Loading report data...',
                style: TextStyle(color: darkGray, fontSize: 16)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: errorColor),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: lightGray),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReportData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    if (_reportData == null || _allSales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment_outlined, size: 64, color: lightGray),
            const SizedBox(height: 16),
            const Text(
              'No sales data found',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
            ),
            const SizedBox(height: 8),
            const Text(
              'for the selected period',
              style: TextStyle(color: lightGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range, color: Colors.white),
              label: const Text('Change Period',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildTopProducts(),
          const SizedBox(height: 24),
          _buildRecentSales(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Report Period',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: darkGray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                  style: const TextStyle(color: darkGray, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text('Change',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Sales',
                'TSH ${NumberFormat('#,##0.00').format(_reportData!['totalSales'])}',
                Icons.monetization_on,
                primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Transactions',
                '${_reportData!['totalTransactions']}',
                Icons.receipt_long,
                darkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Items Sold',
                NumberFormat('#,##0').format(_reportData!['totalItems']),
                Icons.shopping_cart,
                const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Average Sale',
                'TSH ${NumberFormat('#,##0.00').format(_reportData!['averageSale'])}',
                Icons.bar_chart,
                const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = _reportData!['topProducts'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Products',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: darkGray),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No product data available',
                    style: TextStyle(color: lightGray)),
              ),
            )
          else
            ...topProducts.map<Widget>((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: darkGray),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              'Quantity sold: ${entry.value}',
                              style: const TextStyle(
                                  fontSize: 12, color: lightGray),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentSales() {
    final recentSales = _reportData!['recentSales'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt, color: primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recent Sales',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGray),
                  ),
                ],
              ),
              if (recentSales.isNotEmpty)
                TextButton(
                  onPressed: _showAllSales,
                  child: const Text('View All',
                      style: TextStyle(color: primaryGreen)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSales.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No sales data available',
                    style: TextStyle(color: lightGray)),
              ),
            )
          else
            ...recentSales.map<Widget>((sale) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_bag,
                            color: primaryGreen, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale.productName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: darkGray),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              '${sale.customerName} • Qty: ${sale.quantity}',
                              style: const TextStyle(
                                  fontSize: 12, color: lightGray),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TSH ${NumberFormat('#,##0.00').format(sale.totalPrice)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              DateFormat('MMM dd, HH:mm').format(sale.saleDate),
                              style: const TextStyle(
                                  fontSize: 11, color: lightGray),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch sales data
      final sales = await DatabaseService.instance
          .getSalesByDateRange(_startDate, _endDate);

      // Fetch all products for profit/loss calculation
      final products = await DatabaseService.instance.getAllProducts();

      // Calculate metrics
      final totalSales =
          sales.fold<double>(0, (sum, sale) => sum + sale.totalPrice);
      final totalItems = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);

      // Calculate product sales quantities
      final productSales = <String, int>{};
      double profit = 0.0;
      double loss = 0.0;

      for (final sale in sales) {
        productSales[sale.productName] =
            (productSales[sale.productName] ?? 0) + sale.quantity;

        // Find matching product for profit calculation
        final product = products.cast<Product?>().firstWhere(
              (p) => p?.id == sale.productId,
              orElse: () => null,
            );

        if (product != null) {
          final cost = product.buyingPrice * sale.quantity;
          final saleProfit = sale.totalPrice - cost;
          if (saleProfit >= 0) {
            profit += saleProfit;
          } else {
            loss += saleProfit.abs();
          }
        }
      }

      // Sort top products by quantity sold
      final topProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        _allSales = sales;
        _reportData = {
          'totalSales': totalSales,
          'totalTransactions': sales.length,
          'totalItems': totalItems,
          'averageSale': sales.isNotEmpty ? totalSales / sales.length : 0.0,
          'topProducts': topProducts.take(5).toList(),
          'recentSales': sales.take(10).toList(),
          'allSales': sales,
          'profit': profit,
          'loss': loss,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load report data: $e';
        _reportData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
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
      await _loadReportData();
    }
  }

  Future<void> _downloadReport() async {
    if (_reportData == null) {
      _showMessage('No data available for download');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reportService = ReportService();
      await reportService.generateSalesReport(_startDate, _endDate);

      if (kIsWeb) {
        // For web, trigger download
        _showMessage('Report generated successfully');
      } else {
        // For mobile/desktop, save to downloads
        final fileName =
            'sales_report_${DateFormat('yyyy_MM_dd').format(_startDate)}_to_${DateFormat('yyyy_MM_dd').format(_endDate)}.pdf';
        // Implementation depends on platform-specific file handling
        _showMessage('Report saved as $fileName');
      }
    } catch (e) {
      _showMessage('Failed to generate report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAllSales() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Sales (${_allSales.length})',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGray),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _allSales.length,
                  itemBuilder: (context, index) {
                    final sale = _allSales[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryGreen.withOpacity(0.1),
                        child: const Icon(Icons.shopping_bag,
                            color: primaryGreen, size: 16),
                      ),
                      title: Text(sale.productName),
                      subtitle:
                          Text('${sale.customerName} • Qty: ${sale.quantity}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TSH ${NumberFormat('#,##0.00').format(sale.totalPrice)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen),
                          ),
                          Text(
                            DateFormat('MMM dd, HH:mm').format(sale.saleDate),
                            style:
                                const TextStyle(fontSize: 11, color: lightGray),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
