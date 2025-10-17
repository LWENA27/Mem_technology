import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/offline_database.dart';
import 'connectivity_service.dart';
import 'image_upload_service.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final OfflineDatabase _db = OfflineDatabase();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String _syncStatus = 'Ready to sync';
  String get syncStatus => _syncStatus;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  int _totalPendingItems = 0;
  int get totalPendingItems => _totalPendingItems;

  int _syncedItems = 0;
  int get syncedItems => _syncedItems;

  String? _currentTenantId;

  void setTenantId(String? tenantId) {
    _currentTenantId = tenantId;
    debugPrint('SyncService: Tenant ID set to $_currentTenantId');
  }

  Future<void> initialize() async {
    try {
      // Update pending items count
      await _updatePendingItemsCount();

      // Set up connectivity listener
      _connectivityService.addListener(_onConnectivityChanged);

      debugPrint('SyncService initialized');
    } catch (e) {
      debugPrint('Failed to initialize SyncService: $e');
    }
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isOnline && !_isSyncing) {
      debugPrint('Connectivity restored, starting sync...');
      syncAll();
    }
  }

  Future<void> _updatePendingItemsCount() async {
    // Skip offline database operations on web platform
    if (kIsWeb) {
      _totalPendingItems = 0;
      notifyListeners();
      return;
    }

    try {
      final items = await _db.getPendingSyncItems(tenantId: _currentTenantId);
      _totalPendingItems = items.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update pending items count: $e');
    }
  }

  Future<void> syncAll() async {
    if (!_connectivityService.isOnline) {
      _syncStatus = 'Cannot sync: No internet connection';
      debugPrint(_syncStatus);
      notifyListeners();
      return;
    }

    if (_isSyncing) {
      debugPrint('Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    _syncedItems = 0;
    _syncStatus = 'Starting sync...';
    notifyListeners();

    try {
      debugPrint('Starting full sync...');

      // 1. Pull latest data from Supabase
      await _pullFromSupabase();

      // 2. Push pending changes to Supabase
      await _pushToSupabase();

      _lastSyncTime = DateTime.now();
      _syncStatus = 'Sync completed successfully';
      await _updatePendingItemsCount();

      debugPrint('Sync completed successfully at $_lastSyncTime');
    } catch (e) {
      _syncStatus = 'Sync failed: ${e.toString()}';
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _pullFromSupabase() async {
    _syncStatus = 'Downloading latest data...';
    notifyListeners();

    try {
      // Pull products
      await _pullProducts();

      // Pull sales (last 30 days)
      await _pullSales();

      // Pull categories
      await _pullCategories();

      // Pull suppliers
      await _pullSuppliers();

      debugPrint('Successfully pulled data from Supabase');
    } catch (e) {
      throw Exception('Failed to pull data: $e');
    }
  }

  Future<void> _pullProducts() async {
    try {
      // Pull from the current inventories table
      final response = await _supabase
          .from('inventories')
          .select()
          .eq('tenant_id', _currentTenantId ?? '');

      for (final productData in response) {
        // Map inventories table structure into OfflineProduct
        final metadata = productData['metadata'] as Map<String, dynamic>? ?? {};
        final topCategory =
            (productData['category'] as String?) ?? metadata['category'];
        final selling = (productData['selling_price'] as num?)?.toDouble() ??
            (productData['price'] as num?)?.toDouble() ??
            0.0;

        final offlineProduct = OfflineProduct(
          id: productData['id'] ?? '',
          name: productData['name'] ?? '',
          category: topCategory ?? '',
          description: (productData['description'] as String?) ??
              metadata['description'] as String?,
          price: selling,
          quantity: productData['quantity'] ?? 0,
          minStock: productData['min_stock'] ?? 0,
          imageUrls: List<String>.from(metadata['image_urls'] ?? []),
          sku: productData['sku'],
          isActive: productData['is_active'] ?? true,
          createdAt: DateTime.tryParse(productData['created_at'] ?? '') ??
              DateTime.now(),
          updatedAt: DateTime.tryParse(productData['updated_at'] ?? '') ??
              DateTime.now(),
          needsSync: false,
          tenantId: productData['tenant_id'] ?? '',
        );

        // Check if product exists locally
        final existing = await _db.getProduct(offlineProduct.id);
        if (existing == null) {
          await _db.insertProduct(offlineProduct);
        } else if (!existing.needsSync) {
          // Only update if local version doesn't have pending changes
          await _db.updateProduct(offlineProduct);
        }
      }
    } catch (e) {
      debugPrint('Failed to pull products: $e');
      rethrow;
    }
  }

  Future<void> _pullSales() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await _supabase
          .from('sales')
          .select()
          .eq('tenant_id', _currentTenantId ?? '')
          .gte('sale_date', thirtyDaysAgo.toIso8601String());

      for (final saleData in response) {
        final offlineSale = OfflineSale(
          id: saleData['id'] ?? '',
          productId: saleData['product_id'] ?? '',
          quantity: saleData['quantity'] ?? 0,
          unitPrice: (saleData['unit_price'] ?? 0).toDouble(),
          totalAmount: (saleData['total_amount'] ?? 0).toDouble(),
          customerName: saleData['customer_name'],
          customerPhone: saleData['customer_phone'],
          customerEmail: saleData['customer_email'],
          saleDate:
              DateTime.tryParse(saleData['sale_date'] ?? '') ?? DateTime.now(),
          createdAt:
              DateTime.tryParse(saleData['created_at'] ?? '') ?? DateTime.now(),
          needsSync: false,
          tenantId: saleData['tenant_id'] ?? '',
          userId: saleData['user_id'] ?? '',
        );

        // Insert if doesn't exist (use insertOrIgnore pattern)
        try {
          await _db.insertSale(offlineSale);
        } catch (e) {
          // Sale already exists, skip
        }
      }
    } catch (e) {
      debugPrint('Failed to pull sales: $e');
      rethrow;
    }
  }

  Future<void> _pullCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('tenant_id', _currentTenantId ?? '');

      for (final categoryData in response) {
        final offlineCategory = OfflineCategory(
          id: categoryData['id'] ?? '',
          name: categoryData['name'] ?? '',
          description: categoryData['description'],
          isActive: categoryData['is_active'] ?? true,
          createdAt: DateTime.tryParse(categoryData['created_at'] ?? '') ??
              DateTime.now(),
          updatedAt: DateTime.tryParse(categoryData['updated_at'] ?? '') ??
              DateTime.now(),
          needsSync: false,
          tenantId: categoryData['tenant_id'] ?? '',
        );

        try {
          await _db.insertCategory(offlineCategory);
        } catch (e) {
          // Category exists, skip
        }
      }
    } catch (e) {
      debugPrint('Failed to pull categories: $e');
      rethrow;
    }
  }

  Future<void> _pullSuppliers() async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .eq('tenant_id', _currentTenantId ?? '');

      for (final supplierData in response) {
        final offlineSupplier = OfflineSupplier(
          id: supplierData['id'] ?? '',
          name: supplierData['name'] ?? '',
          contactPerson: supplierData['contact_person'],
          email: supplierData['email'],
          phone: supplierData['phone'],
          address: supplierData['address'],
          isActive: supplierData['is_active'] ?? true,
          createdAt: DateTime.tryParse(supplierData['created_at'] ?? '') ??
              DateTime.now(),
          updatedAt: DateTime.tryParse(supplierData['updated_at'] ?? '') ??
              DateTime.now(),
          needsSync: false,
          tenantId: supplierData['tenant_id'] ?? '',
        );

        try {
          await _db.insertSupplier(offlineSupplier);
        } catch (e) {
          // Supplier exists, skip
        }
      }
    } catch (e) {
      debugPrint('Failed to pull suppliers: $e');
      rethrow;
    }
  }

  Future<void> _pushToSupabase() async {
    _syncStatus = 'Uploading pending changes...';
    notifyListeners();

    final pendingItems =
        await _db.getPendingSyncItems(tenantId: _currentTenantId);
    _totalPendingItems = pendingItems.length;

    for (final item in pendingItems) {
      try {
        _syncStatus =
            'Syncing ${item.recordTableName} (${_syncedItems + 1}/$_totalPendingItems)';
        notifyListeners();

        switch (item.recordTableName) {
          case 'products':
            await _syncProduct(item);
            break;
          case 'sales':
            await _syncSale(item);
            break;
          case 'categories':
            await _syncCategory(item);
            break;
          case 'suppliers':
            await _syncSupplier(item);
            break;
        }

        // Remove from sync queue
        await _db.removeSyncItem(item.id);
        _syncedItems++;

        debugPrint(
            'Successfully synced ${item.recordTableName} ${item.recordId}');
      } catch (e) {
        debugPrint('Failed to sync item ${item.id}: $e');
        await _db.incrementRetryCount(item.id, e.toString());

        // Remove items with too many retries
        if (item.retryCount >= 3) {
          await _db.removeSyncItem(item.id);
          debugPrint('Removed item ${item.id} after 3 failed attempts');
        }
      }
    }
  }

  Future<void> _syncProduct(SyncQueueItem item) async {
    final product = await _db.getProduct(item.recordId);
    if (product == null && item.action != 'delete') return;

    Map<String, dynamic>? productData;

    if (product != null) {
      // Handle local images - upload them to Supabase if they exist
      List<String> finalImageUrls = List<String>.from(product.imageUrls);

      // Check if there are any local images that need to be uploaded
      final localImages = finalImageUrls
          .where((url) => ImageUploadService.isLocalImage(url))
          .toList();

      if (localImages.isNotEmpty) {
        try {
          print(
              'Debug: Syncing ${localImages.length} local images for product ${product.id}');

          // Upload local images to Supabase
          final uploadedUrls =
              await ImageUploadService.syncLocalImages(localImages);

          // Replace local paths with uploaded URLs
          for (int i = 0; i < finalImageUrls.length; i++) {
            if (ImageUploadService.isLocalImage(finalImageUrls[i])) {
              final localIndex = localImages.indexOf(finalImageUrls[i]);
              if (localIndex >= 0 && localIndex < uploadedUrls.length) {
                finalImageUrls[i] = uploadedUrls[localIndex];
              }
            }
          }

          // Update product with new URLs in local database
          final updatedProduct = product.copyWith(
            imageUrls: finalImageUrls,
          );
          await _db.updateProduct(updatedProduct);

          print(
              'Debug: Updated product with ${uploadedUrls.length} synced image URLs');
        } catch (e) {
          print(
              'Warning: Failed to sync some local images for product ${product.id}: $e');
          // Continue with sync even if image upload fails
        }
      }

      productData = {
        'id': product.id,
        'name': product.name,
        'category': product.category,
        'description': product.description,
        // map local price -> selling_price in the central DB
        'selling_price': product.price,
        'buying_price': (product.price * 0.8),
        'quantity': product.quantity,
        'min_stock': product.minStock,
        'metadata': {
          'image_urls': finalImageUrls,
        },
        'image_url': finalImageUrls.isNotEmpty ? finalImageUrls.first : null,
        'sku': product.sku,
        'is_active': product.isActive,
        'created_at': product.createdAt.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
        'tenant_id': product.tenantId,
      };
    }

    switch (item.action) {
      case 'create':
        if (productData != null) {
          await _supabase.from('inventories').insert(productData);
        }
        break;
      case 'update':
        if (productData != null) {
          await _supabase
              .from('inventories')
              .update(productData)
              .eq('id', item.recordId);
        }
        break;
      case 'delete':
        await _supabase.from('inventories').delete().eq('id', item.recordId);
        break;
    }

    // Mark as synced in local database
    if (product != null) {
      await _db.updateProduct(
          product.copyWith(needsSync: false, syncAction: const Value(null)));
    }
  }

  Future<void> _syncSale(SyncQueueItem item) async {
    final sale = await _db
        .getAllSales(tenantId: _currentTenantId)
        .then((sales) => sales.where((s) => s.id == item.recordId).firstOrNull);

    if (sale == null && item.action != 'delete') return;

    final saleData = sale != null
        ? {
            'id': sale.id,
            'product_id': sale.productId,
            'quantity': sale.quantity,
            'unit_price': sale.unitPrice,
            'total_amount': sale.totalAmount,
            'customer_name': sale.customerName,
            'customer_phone': sale.customerPhone,
            'customer_email': sale.customerEmail,
            'sale_date': sale.saleDate.toIso8601String(),
            'created_at': sale.createdAt.toIso8601String(),
            'tenant_id': sale.tenantId,
            'user_id': sale.userId,
          }
        : null;

    switch (item.action) {
      case 'create':
        if (saleData != null) {
          await _supabase.from('sales').insert(saleData);
        }
        break;
      case 'update':
        if (saleData != null) {
          await _supabase
              .from('sales')
              .update(saleData)
              .eq('id', item.recordId);
        }
        break;
      case 'delete':
        await _supabase.from('sales').delete().eq('id', item.recordId);
        break;
    }
  }

  Future<void> _syncCategory(SyncQueueItem item) async {
    final category = await _db
        .getAllCategories(tenantId: _currentTenantId)
        .then((cats) => cats.where((c) => c.id == item.recordId).firstOrNull);

    if (category == null && item.action != 'delete') return;

    final categoryData = category != null
        ? {
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'is_active': category.isActive,
            'created_at': category.createdAt.toIso8601String(),
            'updated_at': category.updatedAt.toIso8601String(),
            'tenant_id': category.tenantId,
          }
        : null;

    switch (item.action) {
      case 'create':
        if (categoryData != null) {
          await _supabase.from('categories').insert(categoryData);
        }
        break;
      case 'update':
        if (categoryData != null) {
          await _supabase
              .from('categories')
              .update(categoryData)
              .eq('id', item.recordId);
        }
        break;
      case 'delete':
        await _supabase.from('categories').delete().eq('id', item.recordId);
        break;
    }
  }

  Future<void> _syncSupplier(SyncQueueItem item) async {
    final supplier = await _db
        .getAllSuppliers(tenantId: _currentTenantId)
        .then((sups) => sups.where((s) => s.id == item.recordId).firstOrNull);

    if (supplier == null && item.action != 'delete') return;

    final supplierData = supplier != null
        ? {
            'id': supplier.id,
            'name': supplier.name,
            'contact_person': supplier.contactPerson,
            'email': supplier.email,
            'phone': supplier.phone,
            'address': supplier.address,
            'is_active': supplier.isActive,
            'created_at': supplier.createdAt.toIso8601String(),
            'updated_at': supplier.updatedAt.toIso8601String(),
            'tenant_id': supplier.tenantId,
          }
        : null;

    switch (item.action) {
      case 'create':
        if (supplierData != null) {
          await _supabase.from('suppliers').insert(supplierData);
        }
        break;
      case 'update':
        if (supplierData != null) {
          await _supabase
              .from('suppliers')
              .update(supplierData)
              .eq('id', item.recordId);
        }
        break;
      case 'delete':
        await _supabase.from('suppliers').delete().eq('id', item.recordId);
        break;
    }
  }

  // Manual sync trigger
  Future<void> triggerManualSync() async {
    debugPrint('Manual sync triggered');
    await syncAll();
  }

  // Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isSyncing': _isSyncing,
      'isOnline': _connectivityService.isOnline,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'pendingItems': _totalPendingItems,
      'syncedItems': _syncedItems,
      'status': _syncStatus,
      'connectionType': _connectivityService.connectionStatusText,
    };
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
