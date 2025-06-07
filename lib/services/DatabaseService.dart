import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/sale.dart';
import 'supabase_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  final _supabase = SupabaseService().client;
  Database? _sqliteDb;

  Future<Database> get sqliteDb async {
    _sqliteDb ??= await _initDatabase();
    return _sqliteDb!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'memtechnology_shop.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            brand TEXT NOT NULL,
            buying_price REAL NOT NULL,
            selling_price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            description TEXT,
            image_url TEXT,
            date_added TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            product_id TEXT NOT NULL,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            unit_price REAL NOT NULL,
            total_price REAL NOT NULL,
            customer_name TEXT NOT NULL,
            customer_phone TEXT NOT NULL,
            sale_date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Upload product image to Supabase Storage
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      if (await _isOnline()) {
        // Generate unique filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}';
        
        // Upload to Supabase Storage
        final response = await _supabase.storage
            .from('product-images')
            .upload(fileName, imageFile);
        
        // Get public URL
        final publicUrl = _supabase.storage
            .from('product-images')
            .getPublicUrl(fileName);
        
        return publicUrl;
      } else {
        // When offline, store locally and return local path
        // You might want to implement local storage logic here
        return imageFile.path;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Supabase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (await _isOnline() && imageUrl.contains('supabase')) {
        // Extract filename from URL
        final uri = Uri.parse(imageUrl);
        final fileName = uri.pathSegments.last;
        
        await _supabase.storage
            .from('product-images')
            .remove([fileName]);
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Enhanced method to handle image updates
  Future<String?> updateProductImage({
    String? oldImageUrl,
    File? newImageFile,
    bool removeImage = false,
  }) async {
    try {
      // If removing image, delete old one and return null
      if (removeImage) {
        if (oldImageUrl != null) {
          await deleteProductImage(oldImageUrl);
        }
        return null;
      }

      // If no new image provided, keep the old one
      if (newImageFile == null) {
        return oldImageUrl;
      }

      // Upload new image
      final newImageUrl = await uploadProductImage(newImageFile);
      
      // If upload successful and there's an old image, delete it
      if (newImageUrl != null && oldImageUrl != null && oldImageUrl != newImageUrl) {
        await deleteProductImage(oldImageUrl);
      }

      return newImageUrl;
    } catch (e) {
      print('Error updating product image: $e');
      return oldImageUrl; // Return old URL if update fails
    }
  }

  Future<List<Product>> getAllProducts() async {
    if (await _isOnline()) {
      try {
        final response = await _supabase.from('products').select();
        return response.map<Product>((p) => Product.fromJson(p)).toList();
      } catch (e) {
        print('Error fetching from Supabase, falling back to local: $e');
        // Fallback to local database
        final db = await sqliteDb;
        final result = await db.query('products');
        return result.map((p) => Product.fromJson(p)).toList();
      }
    } else {
      final db = await sqliteDb;
      final result = await db.query('products');
      return result.map((p) => Product.fromJson(p)).toList();
    }
  }

  Future<void> insertProduct(Product product) async {
    final productJson = product.toJson();
    
    // Always save to local database first
    final db = await sqliteDb;
    await db.insert('products', productJson, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Then try to sync with Supabase if online
    if (await _isOnline()) {
      try {
        await _supabase.from('products').insert(productJson);
      } catch (e) {
        print('Error syncing to Supabase: $e');
        // Product is still saved locally, so operation is not completely failed
      }
    }
  }

  Future<void> updateProduct(Product product) async {
    final productJson = product.toJson();
    
    // Always update local database first
    final db = await sqliteDb;
    await db.update('products', productJson, where: 'id = ?', whereArgs: [product.id]);
    
    // Then try to sync with Supabase if online
    if (await _isOnline()) {
      try {
        await _supabase.from('products').update(productJson).eq('id', product.id);
      } catch (e) {
        print('Error syncing update to Supabase: $e');
        // Product is still updated locally, so operation is not completely failed
      }
    }
  }

  // Enhanced update method that handles image updates
  Future<void> updateProductWithImage({
    required Product product,
    File? newImageFile,
    bool removeImage = false,
  }) async {
    try {
      // Handle image update
      final updatedImageUrl = await updateProductImage(
        oldImageUrl: product.imageUrl,
        newImageFile: newImageFile,
        removeImage: removeImage,
      );

      // Create updated product with new image URL
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        brand: product.brand,
        category: product.category,
        buyingPrice: product.buyingPrice,
        sellingPrice: product.sellingPrice,
        quantity: product.quantity,
        description: product.description,
        imageUrl: updatedImageUrl,
        dateAdded: product.dateAdded,
      );

      // Update the product
      await updateProduct(updatedProduct);
    } catch (e) {
      print('Error updating product with image: $e');
      rethrow;
    }
  }

  Future<void> insertSale(Sale sale) async {
    final saleJson = sale.toJson();
    
    // Always save to local database first
    final db = await sqliteDb;
    await db.insert('sales', saleJson, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Then try to sync with Supabase if online
    if (await _isOnline()) {
      try {
        await _supabase.from('sales').insert(saleJson);
      } catch (e) {
        print('Error syncing sale to Supabase: $e');
      }
    }
  }

  Future<List<Sale>> getAllSales() async {
    if (await _isOnline()) {
      try {
        final response = await _supabase.from('sales').select();
        return response.map<Sale>((json) => Sale.fromJson(json)).toList();
      } catch (e) {
        print('Error fetching sales from Supabase, falling back to local: $e');
        final db = await sqliteDb;
        final result = await db.query('sales');
        return result.map((json) => Sale.fromJson(json)).toList();
      }
    } else {
      final db = await sqliteDb;
      final result = await db.query('sales');
      return result.map((json) => Sale.fromJson(json)).toList();
    }
  }

  Future<List<Product>> getAvailableProducts() async {
    final products = await getAllProducts();
    return products.where((product) => product.quantity > 0).toList();
  }

  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    if (await _isOnline()) {
      try {
        final response = await _supabase
            .from('sales')
            .select()
            .gte('sale_date', startDate.toIso8601String())
            .lte('sale_date', endDate.toIso8601String());
        return response.map((json) => Sale.fromJson(json)).toList();
      } catch (e) {
        print('Error fetching sales by date from Supabase, falling back to local: $e');
        final db = await sqliteDb;
        final result = await db.query(
          'sales',
          where: 'sale_date BETWEEN ? AND ?',
          whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        );
        return result.map((json) => Sale.fromJson(json)).toList();
      }
    } else {
      final db = await sqliteDb;
      final result = await db.query(
        'sales',
        where: 'sale_date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      return result.map((json) => Sale.fromJson(json)).toList();
    }
  }

  Future<double?> getTotalSalesForPeriod(DateTime startDate, DateTime endDate) async {
    if (await _isOnline()) {
      try {
        final response = await _supabase
            .from('sales')
            .select('total_price')
            .gte('sale_date', startDate.toIso8601String())
            .lte('sale_date', endDate.toIso8601String());
        return response.fold<double>(0.0, (sum, item) => sum + (item['total_price'] as num).toDouble());
      } catch (e) {
        print('Error fetching total sales from Supabase, falling back to local: $e');
        final db = await sqliteDb;
        final result = await db.rawQuery(
          'SELECT SUM(total_price) as total FROM sales WHERE sale_date BETWEEN ? AND ?',
          [startDate.toIso8601String(), endDate.toIso8601String()],
        );
        return (result.first['total'] as num?)?.toDouble();
      }
    } else {
      final db = await sqliteDb;
      final result = await db.rawQuery(
        'SELECT SUM(total_price) as total FROM sales WHERE sale_date BETWEEN ? AND ?',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      return (result.first['total'] as num?)?.toDouble();
    }
  }

  Future<void> deleteProduct(String id) async {
    // Get the product first to handle image deletion
    final products = await getAllProducts();
    final product = products.where((p) => p.id == id).firstOrNull;
    
    // Delete from local database first
    final db = await sqliteDb;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    
    // Try to delete from Supabase if online
    if (await _isOnline()) {
      try {
        await _supabase.from('products').delete().eq('id', id);
        
        // Delete associated image if it exists and is stored in Supabase
        if (product?.imageUrl != null) {
          await deleteProductImage(product!.imageUrl!);
        }
      } catch (e) {
        print('Error deleting product from Supabase: $e');
      }
    }
  }

  // Method to sync local data with Supabase when connection is restored
  Future<void> syncWithSupabase() async {
    if (!await _isOnline()) return;
    
    try {
      final db = await sqliteDb;
      
      // Sync products
      final localProducts = await db.query('products');
      for (final productData in localProducts) {
        await _supabase.from('products').upsert(productData);
      }
      
      // Sync sales
      final localSales = await db.query('sales');
      for (final saleData in localSales) {
        await _supabase.from('sales').upsert(saleData);
      }
      
      print('Successfully synced local data with Supabase');
    } catch (e) {
      print('Error syncing with Supabase: $e');
    }
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}