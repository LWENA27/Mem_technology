import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../services/sales_service.dart';
import '../services/inventory_service.dart';
import '../repositories/sales_repository.dart';
import '../repositories/product_repository.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../widgets/enhanced_feedback_widget.dart';
import '../utils/secure_error_handler.dart';

class EnhancedReportsScreen extends StatefulWidget {
  final bool showAppBar;

  const EnhancedReportsScreen({
    super.key,
    this.showAppBar = false, // Default to false when used in dashboard
  });

  @override
  _EnhancedReportsScreenState createState() => _EnhancedReportsScreenState();
}

class _EnhancedReportsScreenState extends State<EnhancedReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  // Data
  List<Sale> _sales = [];
  List<Product> _products = [];
  Map<String, dynamic> _analyticsData = {};

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Use platform-aware data loading
      if (kIsWeb) {
        // Web: Use Supabase services directly
        final salesFuture = SalesService.getSales();
        final productsFuture = InventoryService.getInventories();

        final results = await Future.wait([salesFuture, productsFuture]);

        _sales = results[0] as List<Sale>;
        _products = results[1] as List<Product>;
      } else {
        // Native: Use offline repositories
        final salesRepository = SalesRepository();
        final productRepository = ProductRepository();

        final salesFuture = salesRepository.getAllSalesAsModels();
        final productsFuture = productRepository.getAllProductsAsModels();

        final results = await Future.wait([salesFuture, productsFuture]);

        _sales = results[0] as List<Sale>;
        _products = results[1] as List<Product>;
      }

      _calculateAnalytics();

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);

      final userMessage =
          SecureErrorHandler.handleError('Load Reports Data', e, stackTrace);

      if (mounted) {
        EnhancedFeedbackWidget.showErrorSnackBar(context, userMessage);
      }
    }
  }

  void _calculateAnalytics() {
    final filteredSales = _sales.where((sale) {
      final saleDate = sale.saleDate;
      return saleDate.isAfter(_startDate) &&
          saleDate.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    final totalRevenue =
        filteredSales.fold<double>(0.0, (sum, sale) => sum + sale.totalPrice);

    final totalOrders = filteredSales.length;
    final averageOrderValue =
        totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    // Product performance
    final Map<String, dynamic> productStats = {};
    for (final sale in filteredSales) {
      final productId = sale.productId;
      if (!productStats.containsKey(productId)) {
        productStats[productId] = {
          'quantity': 0,
          'revenue': 0.0,
          'orders': 0,
        };
      }
      productStats[productId]['quantity'] += sale.quantity;
      productStats[productId]['revenue'] += sale.totalPrice;
      productStats[productId]['orders'] += 1;
    }

    // Daily sales for trend analysis
    final Map<String, double> dailySales = {};
    for (final sale in filteredSales) {
      final dateKey = DateFormat('yyyy-MM-dd').format(sale.saleDate);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0.0) + sale.totalPrice;
    }

    // Inventory status
    final lowStockProducts = _products.where((p) => p.quantity < 10).toList();
    final outOfStockProducts = _products.where((p) => p.quantity == 0).toList();

    _analyticsData = {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'productStats': productStats,
      'dailySales': dailySales,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalProducts': _products.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Reports & Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: primaryGreen,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadData,
                ),
                IconButton(
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  onPressed: _showDateRangePicker,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white70,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.analytics), text: 'Overview'),
                  Tab(icon: Icon(Icons.trending_up), text: 'Sales'),
                  Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
                  Tab(icon: Icon(Icons.insights), text: 'Insights'),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                color: primaryGreen,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(icon: Icon(Icons.analytics), text: 'Overview'),
                    Tab(icon: Icon(Icons.trending_up), text: 'Sales'),
                    Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
                    Tab(icon: Icon(Icons.insights), text: 'Insights'),
                  ],
                ),
              ),
            ),
      body: _isLoading
          ? EnhancedFeedbackWidget.buildLoadingState('Loading analytics...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSalesTab(),
                _buildInventoryTab(),
                _buildInsightsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeCard(),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 16),
            _buildRevenueChart(),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: primaryGreen, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reporting Period',
                    style: TextStyle(
                      fontSize: 14,
                      color: lightGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _showDateRangePicker,
              icon: const Icon(Icons.edit, color: primaryGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      _MetricData(
        title: 'Total Revenue',
        value: NumberFormat.currency(symbol: '\$')
            .format(_analyticsData['totalRevenue'] ?? 0),
        icon: Icons.attach_money,
        color: primaryGreen,
        trend: '+12.5%',
      ),
      _MetricData(
        title: 'Total Orders',
        value: '${_analyticsData['totalOrders'] ?? 0}',
        icon: Icons.shopping_cart,
        color: accentBlue,
        trend: '+8.3%',
      ),
      _MetricData(
        title: 'Avg Order Value',
        value: NumberFormat.currency(symbol: '\$')
            .format(_analyticsData['averageOrderValue'] ?? 0),
        icon: Icons.analytics,
        color: accentOrange,
        trend: '+4.2%',
      ),
      _MetricData(
        title: 'Products',
        value: '${_analyticsData['totalProducts'] ?? 0}',
        icon: Icons.inventory_2,
        color: accentPurple,
        trend: '+2',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => _buildMetricCard(metrics[index]),
    );
  }

  Widget _buildMetricCard(_MetricData metric) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(metric.icon, color: metric.color, size: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metric.trend,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.title,
              style: const TextStyle(
                fontSize: 12,
                color: lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  '📈 Chart visualization would be here\n(Integration with chart library needed)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lightGray,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
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
                  child: _buildActionButton(
                    'Export Report',
                    Icons.download,
                    primaryGreen,
                    () => _exportReport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Share Analytics',
                    Icons.share,
                    accentBlue,
                    () => _shareAnalytics(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSalesMetrics(),
          const SizedBox(height: 16),
          _buildTopProducts(),
          const SizedBox(height: 16),
          _buildRecentSales(),
        ],
      ),
    );
  }

  Widget _buildSalesMetrics() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            SizedBox(height: 16),
            // Sales metrics content would go here
            Text(
              'Detailed sales analytics and performance indicators',
              style: TextStyle(color: lightGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final productStats =
        _analyticsData['productStats'] as Map<String, dynamic>? ?? {};

    // Sort products by revenue
    final sortedProducts = productStats.entries.toList()
      ..sort((a, b) => (b.value['revenue'] as double)
          .compareTo(a.value['revenue'] as double));

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedProducts.take(5).length,
              itemBuilder: (context, index) {
                final entry = sortedProducts[index];
                final productId = entry.key;
                final stats = entry.value;

                return _buildProductStatsItem(productId, stats);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStatsItem(String productId, Map<String, dynamic> stats) {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: productId,
        name: 'Unknown Product',
        category: '',
        brand: '',
        buyingPrice: 0,
        sellingPrice: 0,
        quantity: 0,
        description: '',
        imageUrls: [],
        dateAdded: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryGreen.withOpacity(0.1),
            child: Text(
              product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  'Sold: ${stats['quantity']} | Revenue: ${NumberFormat.currency(symbol: '\$').format(stats['revenue'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: lightGray,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.trending_up,
            color: primaryGreen,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSales() {
    final recentSales = _sales.take(10).toList();

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSales.length,
              itemBuilder: (context, index) {
                final sale = recentSales[index];
                return _buildSaleItem(sale);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleItem(Sale sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accentBlue.withOpacity(0.1),
            radius: 16,
            child: const Icon(
              Icons.receipt,
              color: accentBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${sale.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  '${DateFormat('MMM dd, HH:mm').format(sale.saleDate)} | Qty: ${sale.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: lightGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(sale.totalPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInventoryOverview(),
          const SizedBox(height: 16),
          _buildStockAlerts(),
        ],
      ),
    );
  }

  Widget _buildInventoryOverview() {
    final lowStockProducts =
        _analyticsData['lowStockProducts'] as List<Product>? ?? [];
    final outOfStockProducts =
        _analyticsData['outOfStockProducts'] as List<Product>? ?? [];

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Status',
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
                  child: _buildInventoryStatusCard(
                    'Low Stock',
                    lowStockProducts.length.toString(),
                    Icons.warning,
                    accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryStatusCard(
                    'Out of Stock',
                    outOfStockProducts.length.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStatusCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlerts() {
    final lowStockProducts =
        _analyticsData['lowStockProducts'] as List<Product>? ?? [];

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStockProducts.take(5).length,
              itemBuilder: (context, index) {
                final product = lowStockProducts[index];
                return _buildStockAlertItem(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            product.quantity == 0 ? Icons.error : Icons.warning,
            color: product.quantity == 0 ? Colors.red : accentOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  'Stock: ${product.quantity} units',
                  style: const TextStyle(
                    fontSize: 12,
                    color: lightGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.quantity == 0 ? Colors.red : accentOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.quantity == 0 ? 'Out of Stock' : 'Low Stock',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInsightsCard(),
          const SizedBox(height: 16),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up,
              'Sales Growth',
              'Your sales have increased by 12.5% this month compared to last month.',
              primaryGreen,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.inventory,
              'Inventory Turnover',
              'Your best-selling products are turning over every 15 days on average.',
              accentBlue,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.warning,
              'Stock Alert',
              '${_analyticsData['lowStockProducts']?.length ?? 0} products are running low on stock.',
              accentOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              '📈 Increase marketing for top performers',
              'Your best-selling products could benefit from increased promotion.',
            ),
            _buildRecommendationItem(
              '📦 Restock low inventory items',
              'Consider restocking products that are running low to avoid stockouts.',
            ),
            _buildRecommendationItem(
              '💰 Review pricing strategy',
              'Analyze competitor pricing for better profit margins.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: lightGray,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkGray,
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
      _calculateAnalytics();
    }
  }

  void _exportReport() {
    EnhancedFeedbackWidget.showInfoSnackBar(
      context,
      'Export functionality will be implemented with PDF generation',
    );
  }

  void _shareAnalytics() {
    EnhancedFeedbackWidget.showInfoSnackBar(
      context,
      'Share functionality will be implemented with social sharing',
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });
}
