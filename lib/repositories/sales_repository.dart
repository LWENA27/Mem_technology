import 'package:drift/drift.dart';
import '../database/offline_database.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../models/sale.dart';
import 'package:uuid/uuid.dart';

class SalesRepository {
  static final SalesRepository _instance = SalesRepository._internal();
  factory SalesRepository() => _instance;
  SalesRepository._internal();

  final OfflineDatabase _db = OfflineDatabase.instance;
  final SyncService _syncService = SyncService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Uuid _uuid = const Uuid();

  String? _currentTenantId;
  String? _currentUserId;

  void setTenantId(String? tenantId) {
    _currentTenantId = tenantId;
  }

  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Generate a receipt number
  static String generateReceiptNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'RCP-${timestamp.toString().substring(7)}';
  }

  /// Record a sale - compatible with SalesService interface
  Future<String> recordSale({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required String customerName,
    String? customerPhone,
    String? receiptNumber,
  }) async {
    try {
      final saleId = _uuid.v4();

      // Store the productName in customerEmail field temporarily
      // until we can add a proper productName field to the schema
      final saleData = {
        'id': saleId,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalAmount': quantity * unitPrice,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': 'PRODUCT:$productName', // Store product name here
        'updateStock': true, // Always update stock when recording sale
      };

      final success = await addSale(saleData);
      if (success) {
        return saleId;
      } else {
        throw Exception('Failed to record sale');
      }
    } catch (e) {
      print('Error in recordSale: $e');
      throw Exception('Failed to record sale: $e');
    }
  }

  /// Get sale by ID - compatible with SalesService interface
  Future<Sale?> getSaleById(String saleId) async {
    try {
      final offlineSale = await _db.getSale(saleId);
      if (offlineSale != null) {
        // Extract product name from customerEmail field
        String productName = '';
        if (offlineSale.customerEmail?.startsWith('PRODUCT:') == true) {
          productName = offlineSale.customerEmail!.substring(8);
        }

        return Sale(
          id: offlineSale.id,
          tenantId: offlineSale.tenantId,
          productId: offlineSale.productId,
          productName: productName,
          quantity: offlineSale.quantity,
          unitPrice: offlineSale.unitPrice,
          totalPrice: offlineSale.totalAmount,
          customerName: offlineSale.customerName ?? '',
          customerPhone: offlineSale.customerPhone,
          saleDate: offlineSale.saleDate,
          receiptNumber: null, // Not stored in current schema
          createdAt: offlineSale.createdAt,
        );
      }
      return null;
    } catch (e) {
      print('Error getting sale by ID: $e');
      return null;
    }
  }

  /// Get all sales as Sale models - compatible with SalesService interface
  Future<List<Sale>> getAllSalesAsModels() async {
    try {
      final offlineSales = await _db.getAllSales(tenantId: _currentTenantId);
      return offlineSales.map((offlineSale) {
        // Extract product name from customerEmail field
        String productName = '';
        if (offlineSale.customerEmail?.startsWith('PRODUCT:') == true) {
          productName = offlineSale.customerEmail!.substring(8);
        }

        return Sale(
          id: offlineSale.id,
          tenantId: offlineSale.tenantId,
          productId: offlineSale.productId,
          productName: productName,
          quantity: offlineSale.quantity,
          unitPrice: offlineSale.unitPrice,
          totalPrice: offlineSale.totalAmount,
          customerName: offlineSale.customerName ?? '',
          customerPhone: offlineSale.customerPhone,
          saleDate: offlineSale.saleDate,
          receiptNumber: null, // Not stored in current schema
          createdAt: offlineSale.createdAt,
        );
      }).toList();
    } catch (e) {
      print('Error getting all sales as models: $e');
      return [];
    }
  }

  // Convert OfflineSale to a simple Sale model for UI
  Map<String, dynamic> _saleToMap(OfflineSale sale) {
    return {
      'id': sale.id,
      'productId': sale.productId,
      'quantity': sale.quantity,
      'unitPrice': sale.unitPrice,
      'totalAmount': sale.totalAmount,
      'customerName': sale.customerName,
      'customerPhone': sale.customerPhone,
      'customerEmail': sale.customerEmail,
      'saleDate': sale.saleDate,
      'createdAt': sale.createdAt,
      'needsSync': sale.needsSync,
      'tenantId': sale.tenantId,
      'userId': sale.userId,
    };
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    try {
      final offlineSales = await _db.getAllSales(tenantId: _currentTenantId);
      return offlineSales.map(_saleToMap).toList();
    } catch (e) {
      print('Error getting all sales: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSalesByDateRange(
      DateTime start, DateTime end) async {
    try {
      final offlineSales =
          await _db.getSalesByDateRange(start, end, tenantId: _currentTenantId);
      return offlineSales.map(_saleToMap).toList();
    } catch (e) {
      print('Error getting sales by date range: $e');
      return [];
    }
  }

  Future<double> getTotalSalesAmount(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _db.getTotalSalesAmount(
        tenantId: _currentTenantId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error getting total sales amount: $e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getTodaysSales() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSalesByDateRange(startOfDay, endOfDay);
  }

  Future<List<Map<String, dynamic>>> getThisWeekSales() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return getSalesByDateRange(startOfWeekDay, now);
  }

  Future<List<Map<String, dynamic>>> getThisMonthSales() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return getSalesByDateRange(startOfMonth, now);
  }

  Future<bool> addSale(Map<String, dynamic> saleData) async {
    try {
      final id = saleData['id']?.toString().isNotEmpty == true
          ? saleData['id'].toString()
          : _uuid.v4();
      final now = DateTime.now();

      final offlineSale = OfflineSale(
        id: id,
        productId: saleData['productId']?.toString() ?? '',
        quantity: saleData['quantity'] ?? 0,
        unitPrice: (saleData['unitPrice'] ?? 0).toDouble(),
        totalAmount: (saleData['totalAmount'] ?? 0).toDouble(),
        customerName: saleData['customerName']?.toString(),
        customerPhone: saleData['customerPhone']?.toString(),
        customerEmail: saleData['customerEmail']?.toString(),
        saleDate: saleData['saleDate'] is DateTime ? saleData['saleDate'] : now,
        createdAt: now,
        needsSync: true,
        tenantId: _currentTenantId ?? '',
        userId: _currentUserId ?? '',
      );

      await _db.insertSale(offlineSale);
      await _db.markForSync('sales', id, 'create', tenantId: _currentTenantId);

      // Update product stock
      if (saleData['updateStock'] == true) {
        await _updateProductStock(saleData['productId'], saleData['quantity']);
      }

      // Trigger immediate sync if online
      if (_connectivityService.isOnline) {
        _syncService.syncAll();
      }

      return true;
    } catch (e) {
      print('Error adding sale: $e');
      return false;
    }
  }

  Future<void> _updateProductStock(String productId, int soldQuantity) async {
    try {
      final product = await _db.getProduct(productId);
      if (product != null) {
        final newQuantity = product.quantity - soldQuantity;
        final updatedProduct = product.copyWith(
          quantity: newQuantity >= 0 ? newQuantity : 0,
          updatedAt: DateTime.now(),
          needsSync: true,
          syncAction: const Value('update'),
        );

        await _db.updateProduct(updatedProduct);
        await _db.markForSync('products', productId, 'update',
            tenantId: _currentTenantId);
      }
    } catch (e) {
      print('Error updating product stock: $e');
    }
  }

  // Analytics methods
  Future<Map<String, dynamic>> getSalesAnalytics(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final sales = await getSalesByDateRange(
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );

      double totalRevenue = 0;
      int totalQuantity = 0;
      Map<String, double> productSales = {};
      Map<String, int> dailySales = {};

      for (final sale in sales) {
        totalRevenue += sale['totalAmount'];
        totalQuantity += sale['quantity'] as int;

        // Track sales by product
        final productId = sale['productId'] as String;
        productSales[productId] =
            (productSales[productId] ?? 0) + sale['totalAmount'];

        // Track daily sales
        final date =
            (sale['saleDate'] as DateTime).toIso8601String().split('T')[0];
        dailySales[date] = (dailySales[date] ?? 0) + 1;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalQuantity': totalQuantity,
        'totalSales': sales.length,
        'averageSaleValue': sales.isNotEmpty ? totalRevenue / sales.length : 0,
        'productSales': productSales,
        'dailySales': dailySales,
      };
    } catch (e) {
      print('Error getting sales analytics: $e');
      return {
        'totalRevenue': 0.0,
        'totalQuantity': 0,
        'totalSales': 0,
        'averageSaleValue': 0.0,
        'productSales': <String, double>{},
        'dailySales': <String, int>{},
      };
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(
      {int limit = 10}) async {
    try {
      final sales = await getAllSales();
      Map<String, Map<String, dynamic>> productStats = {};

      for (final sale in sales) {
        final productId = sale['productId'] as String;
        if (!productStats.containsKey(productId)) {
          productStats[productId] = {
            'productId': productId,
            'totalQuantity': 0,
            'totalRevenue': 0.0,
            'salesCount': 0,
          };
        }

        productStats[productId]!['totalQuantity'] += sale['quantity'] as int;
        productStats[productId]!['totalRevenue'] +=
            sale['totalAmount'] as double;
        productStats[productId]!['salesCount'] += 1;
      }

      final sortedProducts = productStats.values.toList()
        ..sort((a, b) =>
            (b['totalQuantity'] as int).compareTo(a['totalQuantity'] as int));

      return sortedProducts.take(limit).toList();
    } catch (e) {
      print('Error getting top selling products: $e');
      return [];
    }
  }
}
