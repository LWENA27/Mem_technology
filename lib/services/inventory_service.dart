import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class InventoryService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all inventories for the current user's tenant
  static Future<List<Product>> getInventories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user's tenant ID
      final profile = await _supabase
          .from('profiles')
          .select('tenant_id')
          .eq('id', user.id)
          .single();

      final tenantId = profile['tenant_id'];
      if (tenantId == null)
        throw Exception('User not associated with a tenant');

      final response = await _supabase
          .from('inventories')
          .select()
          .eq('tenant_id', tenantId)
          .order('name');

      return response
          .map<Product>((item) => Product.fromInventoryJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load inventories: $e');
    }
  }

  /// Get all products from public storefronts (for guest browsing)
  static Future<List<Product>> getPublicInventories() async {
    try {
      print('Debug: Loading public inventories for guest users');

      // First get all public tenant IDs
      final publicTenants = await _supabase
          .from('tenants')
          .select('id')
          .eq('public_storefront', true);

      final tenantIds = publicTenants.map((tenant) => tenant['id']).toList();
      print('Debug: Found ${tenantIds.length} public tenants: $tenantIds');

      if (tenantIds.isEmpty) {
        print('Debug: No public tenants found');
        return [];
      }

      // Then get all inventories from these tenants
      final response = await _supabase
          .from('inventories')
          .select('*')
          .inFilter('tenant_id', tenantIds)
          .order('name');

      print('Debug: Found ${response.length} public products');

      return response
          .map<Product>((item) => Product.fromInventoryJson(item))
          .toList();
    } catch (e) {
      print('Debug: Error loading public inventories: $e');
      throw Exception('Failed to load public inventories: $e');
    }
  }

  /// Add new inventory item
  static Future<String> addInventory({
    required String name,
    required String category,
    required String brand,
    required double price,
    required int quantity,
    String? description,
    String? sku,
    String? imageUrl,
  }) async {
    try {
      print('Debug: addInventory called with:');
      print('  name: $name');
      print('  category: $category');
      print('  brand: $brand');
      print('  price: $price');
      print('  quantity: $quantity');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Debug: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('Debug: User authenticated: ${user.id}');

      // Get user's tenant ID
      final profile = await _supabase
          .from('profiles')
          .select('tenant_id')
          .eq('id', user.id)
          .single();

      final tenantId = profile['tenant_id'];
      print('Debug: Tenant ID: $tenantId');

      if (tenantId == null)
        throw Exception('User not associated with a tenant');

      final inventoryData = {
        'tenant_id': tenantId,
        'name': name,
        'sku': sku,
        'quantity': quantity,
        'price': price,
        'metadata': {
          'category': category,
          'brand': brand,
          'description': description ?? '',
          'image_url': imageUrl,
        },
      };

      print('Debug: Inventory data to insert: $inventoryData');

      final response = await _supabase
          .from('inventories')
          .insert(inventoryData)
          .select()
          .single();

      print('Debug: Insert successful: ${response['id']}');
      return response['id'];
    } catch (e) {
      throw Exception('Failed to add inventory: $e');
    }
  }

  /// Update inventory item
  static Future<void> updateInventory({
    required String id,
    required String name,
    required String category,
    required String brand,
    required double price,
    required int quantity,
    String? description,
    String? sku,
    String? imageUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final inventoryData = {
        'name': name,
        'sku': sku,
        'quantity': quantity,
        'price': price,
        'metadata': {
          'category': category,
          'brand': brand,
          'description': description ?? '',
          'image_url': imageUrl,
        },
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('inventories').update(inventoryData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  /// Delete inventory item
  static Future<void> deleteInventory(String id) async {
    try {
      await _supabase.from('inventories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete inventory: $e');
    }
  }

  /// Get inventory item by ID
  static Future<Product> getInventoryById(String id) async {
    try {
      final response =
          await _supabase.from('inventories').select().eq('id', id).single();

      return Product.fromInventoryJson(response);
    } catch (e) {
      throw Exception('Failed to get inventory: $e');
    }
  }

  /// Update inventory quantity (used when making sales)
  static Future<void> updateQuantity(String id, int newQuantity) async {
    try {
      await _supabase.from('inventories').update({
        'quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  /// Search inventories by name or SKU
  static Future<List<Product>> searchInventories(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user's tenant ID
      final profile = await _supabase
          .from('profiles')
          .select('tenant_id')
          .eq('id', user.id)
          .single();

      final tenantId = profile['tenant_id'];
      if (tenantId == null)
        throw Exception('User not associated with a tenant');

      final response = await _supabase
          .from('inventories')
          .select()
          .eq('tenant_id', tenantId)
          .or('name.ilike.%$query%,sku.ilike.%$query%')
          .order('name');

      return response
          .map<Product>((item) => Product.fromInventoryJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search inventories: $e');
    }
  }
}
