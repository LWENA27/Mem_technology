import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'tenant_manager.dart';

class InventoryService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all inventories for the current user's tenant
  static Future<List<Product>> getInventories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Use TenantManager for consistent tenant handling
      final tenantId = TenantManager().getOperationTenantId();

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

      // Get only visible products from tenants with public storefronts enabled
      // Primary attempt: filter by tenant setting via tenants.show_products_to_customers
      try {
        final response = await _supabase
            .from('inventories')
            .select('''
              *,
              tenants!inner(
                show_products_to_customers
              )
            ''')
            .eq('visible_to_customers', true)
            .eq('tenants.show_products_to_customers', true)
            .order('name');

        print(
            'Debug: Found ${response.length} visible products (with tenant filter)');

        final products = response
            .map<Product>((item) => Product.fromInventoryJson(item))
            .toList();

        return products;
      } on PostgrestException catch (pe) {
        // Handle missing column error specifically (Postgres error code 42703)
        print(
            'Debug: PostgrestException while filtering by tenants.show_products_to_customers: $pe');
        print(
            'Debug: The tenants.show_products_to_customers column may be missing. Falling back to tenant-agnostic query.');

        // Retry without joining tenants or using visibility columns - show all products when columns are missing
        try {
          final fallback =
              await _supabase.from('inventories').select().order('name');

          print(
              'Debug: Found ${fallback.length} products (fallback without visibility filters)');
          print(
              'Debug: Recommendation: Run the visibility migration SQL scripts to enable product visibility controls.');

          return fallback
              .map<Product>((item) => Product.fromInventoryJson(item))
              .toList();
        } on PostgrestException catch (fallbackError) {
          print('Debug: Fallback query also failed: $fallbackError');

          // Final fallback - try to get any products at all
          final basicResponse = await _supabase
              .from('inventories')
              .select(
                  'id, name, price, quantity, sku, description, category, image_url, created_at, updated_at, tenant_id')
              .order('name');

          print('Debug: Basic query found ${basicResponse.length} products');
          return basicResponse
              .map<Product>((item) => Product.fromInventoryJson(item))
              .toList();
        }
      }

      // unreachable - kept for clarity
      // (primary flow returns earlier)
    } catch (e) {
      print('Debug: Error loading public inventories: $e');
      throw Exception('Failed to load public products: $e');
    }
  }

  /// Add new inventory item
  static Future<String> addInventory({
    required String name,
    required String category,
    required String brand,
    required double price,
    double? buyingPrice,
    required int quantity,
    String? description,
    String? sku,
    String? imageUrl,
    List<String>? imageUrls,
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

      // Use TenantManager for consistent tenant handling
      final tenantId = TenantManager().getOperationTenantId();
      print('Debug: Using tenant ID: $tenantId');

      // Map app price -> DB selling_price. Include buying_price if provided
      final effectiveBuyingPrice = buyingPrice ?? (price * 0.8);

      final inventoryData = {
        'tenant_id': tenantId,
        'name': name,
        'sku': sku,
        'quantity': quantity,
        'selling_price': price,
        'buying_price': effectiveBuyingPrice,
        // top-level fields for easier querying
        'category': category,
        'brand': brand,
        'description': description ?? '',
        'image_url': imageUrl,
        'metadata': {
          'image_urls': imageUrls ?? (imageUrl != null ? [imageUrl] : []),
        },
      };

      // Try to set visibility - gracefully handle missing column
      try {
        inventoryData['visible_to_customers'] =
            true; // Default new products to visible
      } catch (e) {
        print(
            'Debug: Could not set visible_to_customers (column may not exist): $e');
      }

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
    double? buyingPrice,
    required int quantity,
    String? description,
    String? sku,
    String? imageUrl,
    List<String>? imageUrls,
    bool? visibleToCustomers,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final effectiveBuyingPrice = buyingPrice ?? (price * 0.8);

      final inventoryData = {
        'name': name,
        'sku': sku,
        'quantity': quantity,
        'selling_price': price,
        'buying_price': effectiveBuyingPrice,
        'category': category,
        'brand': brand,
        'description': description ?? '',
        'image_url': imageUrl,
        'metadata': {
          'image_urls': imageUrls ?? (imageUrl != null ? [imageUrl] : []),
        },
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only update visibility if explicitly provided and column exists
      if (visibleToCustomers != null) {
        try {
          inventoryData['visible_to_customers'] = visibleToCustomers;
        } catch (e) {
          print(
              'Debug: Could not set visible_to_customers (column may not exist): $e');
        }
      }

      await _supabase.from('inventories').update(inventoryData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  /// Update product visibility for customers
  static Future<void> updateProductVisibility(
      String productId, bool visible) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      try {
        await _supabase.from('inventories').update({
          'visible_to_customers': visible,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', productId);

        print('Debug: Updated product $productId visibility to $visible');
      } on PostgrestException catch (pe) {
        if (pe.code == '42703') {
          print(
              'Debug: visible_to_customers column does not exist. Please run the visibility migration.');
          print(
              'Debug: Recommendation: Execute add_visibility_columns.sql in Supabase SQL Editor');
          // Don't throw - just log the issue
          return;
        }
        rethrow;
      }
    } catch (e) {
      print('Debug: Error updating product visibility: $e');
      throw Exception('Failed to update product visibility: $e');
    }
  }

  /// Delete inventory item
  static Future<void> deleteInventory(String id) async {
    try {
      print('Debug: Attempting to delete inventory: $id');

      // First check if there are any sales records for this product
      final salesCheck = await _supabase
          .from('sales')
          .select('id')
          .eq('product_id', id)
          .limit(1);

      if (salesCheck.isNotEmpty) {
        print('Debug: Product has sales records, cannot delete');
        throw Exception(
            'Cannot delete product: This product has sales records. '
            'Products with sales history cannot be deleted to maintain data integrity. '
            'Consider setting quantity to 0 to mark as discontinued instead.');
      }

      print('Debug: No sales records found, proceeding with deletion');

      // Get the product to check if it has an image
      final product = await getInventoryById(id);

      // Delete the image from storage if it exists
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        try {
          // Extract the file path from the URL and delete the image
          final uri = Uri.parse(product.imageUrl!);
          final segments = uri.pathSegments;
          const bucketName = 'product-images';

          final bucketIndex = segments.indexOf(bucketName);
          if (bucketIndex >= 0 && bucketIndex < segments.length - 1) {
            final filePath = segments.sublist(bucketIndex + 1).join('/');
            print('Debug: Deleting image: $filePath');

            await _supabase.storage.from(bucketName).remove([filePath]);

            print('Debug: Image deleted successfully');
          }
        } catch (imageError) {
          print('Warning: Failed to delete product image: $imageError');
          // Continue with product deletion even if image deletion fails
        }
      }

      // Now delete the inventory item
      await _supabase.from('inventories').delete().eq('id', id);
      print('Debug: Inventory deleted successfully');
    } catch (e) {
      print('Debug: Delete error: $e');
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
      if (tenantId == null) {
        throw Exception('User not associated with a tenant');
      }

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
