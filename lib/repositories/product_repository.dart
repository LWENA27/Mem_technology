import 'package:drift/drift.dart';
import '../database/offline_database.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  final OfflineDatabase _db = OfflineDatabase.instance;
  final SyncService _syncService = SyncService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Uuid _uuid = const Uuid();

  String? _currentTenantId;

  void setTenantId(String? tenantId) {
    _currentTenantId = tenantId;
  }

  // Convert OfflineProduct to a simple Product model for UI
  Map<String, dynamic> _productToMap(OfflineProduct product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'description': product.description,
      'price': product.price,
      'quantity': product.quantity,
      'minStock': product.minStock,
      'imageUrls': product.imageUrls,
      'sku': product.sku,
      'isActive': product.isActive,
      'createdAt': product.createdAt,
      'updatedAt': product.updatedAt,
      'needsSync': product.needsSync,
      'tenantId': product.tenantId,
    };
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final offlineProducts =
          await _db.getAllProducts(tenantId: _currentTenantId);
      return offlineProducts.map(_productToMap).toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  Future<List<Product>> getAllProductsAsModels() async {
    try {
      final offlineProducts =
          await _db.getAllProducts(tenantId: _currentTenantId);
      return offlineProducts.map((offlineProduct) {
        // Convert OfflineProduct to Product model
        return Product(
          id: offlineProduct.id,
          name: offlineProduct.name,
          category: offlineProduct.category,
          brand:
              offlineProduct.sku ?? 'Unknown Brand', // Use SKU as brand for now
          buyingPrice: offlineProduct.price * 0.8, // Estimate buying price
          sellingPrice: offlineProduct.price,
          quantity: offlineProduct.quantity,
          description: offlineProduct.description,
          imageUrls: offlineProduct.imageUrls,
          dateAdded: offlineProduct.createdAt,
        );
      }).toList();
    } catch (e) {
      print('Error getting all products as models: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    try {
      final offlineProduct = await _db.getProduct(id);
      return offlineProduct != null ? _productToMap(offlineProduct) : null;
    } catch (e) {
      print('Error getting product $id: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final offlineProducts =
          await _db.searchProducts(query, tenantId: _currentTenantId);
      return offlineProducts.map(_productToMap).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category) async {
    try {
      final offlineProducts =
          await _db.getProductsByCategory(category, tenantId: _currentTenantId);
      return offlineProducts.map(_productToMap).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final offlineProducts =
          await _db.getLowStockProducts(tenantId: _currentTenantId);
      return offlineProducts.map(_productToMap).toList();
    } catch (e) {
      print('Error getting low stock products: $e');
      return [];
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final id = productData['id']?.toString().isNotEmpty == true
          ? productData['id'].toString()
          : _uuid.v4();
      final now = DateTime.now();

      final offlineProduct = OfflineProduct(
        id: id,
        name: productData['name']?.toString() ?? '',
        category: productData['category']?.toString() ?? '',
        description: productData['description']?.toString(),
        price: (productData['price'] ?? 0).toDouble(),
        quantity: productData['quantity'] ?? 0,
        minStock: productData['minStock'] ?? 0,
        imageUrls: List<String>.from(productData['imageUrls'] ?? []),
        sku: productData['sku']?.toString(),
        isActive: productData['isActive'] ?? true,
        createdAt: productData['createdAt'] is DateTime
            ? productData['createdAt']
            : now,
        updatedAt: now,
        needsSync: true,
        syncAction: 'create',
        tenantId: _currentTenantId ?? '',
      );

      await _db.insertProduct(offlineProduct);
      await _db.markForSync('products', id, 'create',
          tenantId: _currentTenantId);

      // Trigger immediate sync if online
      if (_connectivityService.isOnline) {
        _syncService.syncAll();
      }

      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(
      String id, Map<String, dynamic> productData) async {
    try {
      final existing = await _db.getProduct(id);
      if (existing == null) return false;

      final now = DateTime.now();

      final offlineProduct = OfflineProduct(
        id: id,
        name: productData['name']?.toString() ?? existing.name,
        category: productData['category']?.toString() ?? existing.category,
        description:
            productData['description']?.toString() ?? existing.description,
        price: (productData['price'] ?? existing.price).toDouble(),
        quantity: productData['quantity'] ?? existing.quantity,
        minStock: productData['minStock'] ?? existing.minStock,
        imageUrls:
            List<String>.from(productData['imageUrls'] ?? existing.imageUrls),
        sku: productData['sku']?.toString() ?? existing.sku,
        isActive: productData['isActive'] ?? existing.isActive,
        createdAt: existing.createdAt,
        updatedAt: now,
        needsSync: true,
        syncAction: 'update',
        tenantId: existing.tenantId,
      );

      await _db.updateProduct(offlineProduct);
      await _db.markForSync('products', id, 'update',
          tenantId: _currentTenantId);

      // Trigger immediate sync if online
      if (_connectivityService.isOnline) {
        _syncService.syncAll();
      }

      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _db.deleteProduct(id);
      await _db.markForSync('products', id, 'delete',
          tenantId: _currentTenantId);

      // Trigger immediate sync if online
      if (_connectivityService.isOnline) {
        _syncService.syncAll();
      }

      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<bool> updateStock(String id, int newQuantity) async {
    try {
      final existing = await _db.getProduct(id);
      if (existing == null) return false;

      final updatedProduct = existing.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
        needsSync: true,
        syncAction: const Value('update'),
      );

      await _db.updateProduct(updatedProduct);
      await _db.markForSync('products', id, 'update',
          tenantId: _currentTenantId);

      // Trigger immediate sync if online
      if (_connectivityService.isOnline) {
        _syncService.syncAll();
      }

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }
}
