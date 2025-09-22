import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _sqliteDb;

  Future<Database> get sqliteDb async {
    if (kIsWeb) {
      // sqlite (sqflite) is not available on web. Callers should avoid
      // accessing sqliteDb when running on web. Throw a clear error so
      // accidental calls fail fast during development.
      throw UnsupportedError('Local sqlite database not supported on web');
    }

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

  // Helper method to safely get Supabase client
  Future<dynamic> _getSupabaseClient() async {
    try {
      await SupabaseService.instance.initialize();
      return SupabaseService.instance.client;
    } catch (e) {
      print('Supabase not available: $e');
      return null;
    }
  }

  // Upload product image, save locally if offline
  Future<String?> uploadProductImage(dynamic imageFile) async {
    try {
      // On web platform, we don't support local file operations
      if (kIsWeb) {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          // For web, we would handle this differently with Uint8List
          // This is a simplified version
          throw UnsupportedError('Image upload not yet implemented for web');
        }
        return null;
      }

      // Mobile/Desktop platform handling
      final fileAsFile = imageFile as File;
      if (await _isOnline()) {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${basename(fileAsFile.path)}';
          await supabase.storage
              .from('product-images')
              .upload(fileName, fileAsFile);
          return supabase.storage.from('product-images').getPublicUrl(fileName);
        }
      }

      // Fallback to local storage (mobile/desktop only)
      final localDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${basename(fileAsFile.path)}';
      final localPath = '${localDir.path}/$fileName';
      await fileAsFile.copy(localPath);
      return localPath;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Supabase or local storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (await _isOnline() && imageUrl.contains('supabase')) {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final uri = Uri.parse(imageUrl);
          final fileName = uri.pathSegments.last;
          await supabase.storage.from('product-images').remove([fileName]);
        }
      } else if (!kIsWeb &&
          imageUrl
              .startsWith((await getApplicationDocumentsDirectory()).path)) {
        final file = File(imageUrl);
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Handle image updates with offline support
  Future<String?> updateProductImage({
    String? oldImageUrl,
    dynamic newImageFile,
    bool removeImage = false,
  }) async {
    try {
      if (removeImage && oldImageUrl != null) {
        await deleteProductImage(oldImageUrl);
        return null;
      }

      if (newImageFile == null) return oldImageUrl;

      final newImageUrl = await uploadProductImage(newImageFile);
      if (newImageUrl != null &&
          oldImageUrl != null &&
          oldImageUrl != newImageUrl) {
        await deleteProductImage(oldImageUrl);
      }
      return newImageUrl;
    } catch (e) {
      print('Error updating product image: $e');
      return oldImageUrl;
    }
  }

  Future<List<Product>> getAllProducts() async {
    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final response = await supabase.from('products').select();
          // Normalize response (handles Dart List and JSArray on web)
          final List<dynamic> rows = _normalizeResponseRows(response);
          return rows.map<Product>((p) {
            final product = Product.fromJson(Map<String, dynamic>.from(p));
            if (product.imageUrl != null &&
                !product.imageUrl!.contains('http')) {
              return product.copyWith(
                  imageUrl: supabase.storage
                      .from('product-images')
                      .getPublicUrl(product.imageUrl!));
            }
            return product;
          }).toList();
        }
      } catch (e) {
        print('Error fetching from Supabase, falling back to local: $e');
      }
    }

    // Fallback to local database (not available on web)
    if (kIsWeb) {
      // On web we assume Supabase should be used; return empty list as a
      // safe fallback when Supabase fetch fails.
      return <Product>[];
    }

    final db = await sqliteDb;
    final result = await db.query('products');
    return result.map((p) => Product.fromJson(p)).toList();
  }

  Future<void> insertProduct(Product product) async {
    final productJson = product.toJson();
    // Local DB insert only for non-web platforms
    if (!kIsWeb) {
      final db = await sqliteDb;
      await db.insert('products', productJson,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          await supabase.from('products').insert(productJson);
        }
      } catch (e) {
        print('Error syncing to Supabase: $e');
      }
    }
  }

  Future<void> updateProduct(Product product) async {
    final productJson = product.toJson();
    if (!kIsWeb) {
      final db = await sqliteDb;
      await db.update('products', productJson,
          where: 'id = ?', whereArgs: [product.id]);
    }

    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          await supabase
              .from('products')
              .update(productJson)
              .eq('id', product.id);
        }
      } catch (e) {
        print('Error syncing update to Supabase: $e');
      }
    }
  }

  Future<void> updateProductWithImage({
    required Product product,
    dynamic newImageFile,
    bool removeImage = false,
  }) async {
    try {
      final updatedImageUrl = await updateProductImage(
        oldImageUrl: product.imageUrl,
        newImageFile: newImageFile,
        removeImage: removeImage,
      );

      final updatedProduct = product.copyWith(imageUrl: updatedImageUrl);
      await updateProduct(updatedProduct);

      if (await _isOnline() &&
          newImageFile != null &&
          updatedImageUrl != null &&
          !updatedImageUrl.startsWith('http')) {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final fileName = basename(updatedImageUrl);
          await supabase.storage
              .from('product-images')
              .upload(fileName, newImageFile);
          final publicUrl =
              supabase.storage.from('product-images').getPublicUrl(fileName);
          await updateProduct(updatedProduct.copyWith(imageUrl: publicUrl));
        }
      }
    } catch (e) {
      print('Error updating product with image: $e');
      rethrow;
    }
  }

  Future<void> insertSale(Sale sale) async {
    final saleJson = sale.toJson();

    // On web, use Supabase only
    if (kIsWeb) {
      if (await _isOnline()) {
        try {
          final supabase = await _getSupabaseClient();
          if (supabase != null) {
            final res = await supabase.from('sales').insert(saleJson);
            // some clients return a response object; if an error appears it will
            // surface as an exception, but log the successful response when present
            print('Inserted sale to Supabase (web): ${jsonEncode(res)}');
            return;
          }
          throw Exception('Supabase client not available');
        } catch (e) {
          _logSupabaseError('insert sale (web)', e);
          // rethrow a readable exception for UI
          throw Exception(
              'Failed to record sale online: ${_extractSupabaseError(e)}');
        }
      } else {
        throw Exception(
            'Cannot record sales offline on web. Please check your internet connection.');
      }
    } else {
      // On mobile/desktop, use local database with Supabase sync
      final db = await sqliteDb;
      await db.insert('sales', saleJson,
          conflictAlgorithm: ConflictAlgorithm.replace);

      if (await _isOnline()) {
        try {
          final supabase = await _getSupabaseClient();
          if (supabase != null) {
            await supabase.from('sales').insert(saleJson);
          }
        } catch (e) {
          _logSupabaseError('sync sale (mobile)', e);
        }
      }
    }
  }

  Future<List<Sale>> getAllSales() async {
    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final response = await supabase.from('sales').select();
          final List<dynamic> rows = _normalizeResponseRows(response);
          return rows
              .map<Sale>(
                  (json) => Sale.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      } catch (e) {
        _logSupabaseError('fetch all sales', e);
      }
    }

    // Fallback to local database. On web we cannot use sqlite so return
    // an empty list (safe fallback) instead of attempting sqlite calls.
    if (kIsWeb) return <Sale>[];

    final db = await sqliteDb;
    final result = await db.query('sales');
    return result.map((json) => Sale.fromJson(json)).toList();
  }

  Future<List<Product>> getAvailableProducts() async {
    final products = await getAllProducts();
    return products.where((product) => product.quantity > 0).toList();
  }

  Future<List<Sale>> getSalesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final String startDateStr =
        startDate.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final String endDateStr =
        endDate.toIso8601String().substring(0, 10); // YYYY-MM-DD

    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          // Use Postgres date cast for date-only comparison
          final response = await supabase
              .from('sales')
              .select()
              .gte('sale_date::date', startDateStr)
              .lte('sale_date::date', endDateStr);
          final List<dynamic> rows = _normalizeResponseRows(response);
          return rows
              .map((json) => Sale.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      } catch (e) {
        _logSupabaseError('fetch sales by date', e);
      }
    }

    // Fallback to local database, compare only the date part. On web we
    // cannot access sqlite, so return empty list as a safe fallback.
    if (kIsWeb) return <Sale>[];

    final db = await sqliteDb;
    final result = await db.query(
      'sales',
      where: 'substr(sale_date, 1, 10) BETWEEN ? AND ?',
      whereArgs: [startDateStr, endDateStr],
    );
    return result.map((json) => Sale.fromJson(json)).toList();
  }

  Future<double?> getTotalSalesForPeriod(
      DateTime startDate, DateTime endDate) async {
    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          final response = await supabase
              .from('sales')
              .select('total_price')
              .gte('sale_date', startDate.toIso8601String())
              .lte('sale_date', endDate.toIso8601String());
          final List<dynamic> rows = _normalizeResponseRows(response);
          return rows.fold<double>(0.0,
              (sum, item) => sum + ((item['total_price'] as num).toDouble()));
        }
      } catch (e) {
        _logSupabaseError('fetch total sales', e);
      }
    }

    // Fallback to local database. On web return 0.0 as a safe default.
    if (kIsWeb) return 0.0;

    final db = await sqliteDb;
    final result = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM sales WHERE sale_date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble();
  }

  Future<void> deleteProduct(String id) async {
    final products = await getAllProducts();
    final product = products.where((p) => p.id == id).firstOrNull;

    if (!kIsWeb) {
      final db = await sqliteDb;
      await db.delete('products', where: 'id = ?', whereArgs: [id]);
    }

    if (await _isOnline()) {
      try {
        final supabase = await _getSupabaseClient();
        if (supabase != null) {
          await supabase.from('products').delete().eq('id', id);
          if (product?.imageUrl != null) {
            await deleteProductImage(product!.imageUrl!);
          }
        }
      } catch (e) {
        print('Error deleting product from Supabase: $e');
      }
    }
  }

  Future<void> syncWithSupabase() async {
    if (!await _isOnline()) return;

    try {
      final supabase = await _getSupabaseClient();
      if (supabase == null) return;

      if (!kIsWeb) {
        final db = await sqliteDb;

        final localProducts = await db.query('products');
        for (final productData in localProducts) {
          await supabase.from('products').upsert(productData);
        }

        final localSales = await db.query('sales');
        for (final saleData in localSales) {
          await supabase.from('sales').upsert(saleData);
        }
      }

      print('Successfully synced local data with Supabase');
    } catch (e) {
      print('Error syncing with Supabase: $e');
    }
  }

  Future<bool> _isOnline() async {
    try {
      // For web platform, we assume online connectivity
      // since we can't use InternetAddress.lookup in browsers
      if (kIsWeb) {
        return true;
      }

      // For mobile/desktop platforms, use the original method
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      // Fallback for any errors (including web platform issues)
      if (kIsWeb) {
        return true; // Assume online for web
      }
      return false;
    }
  }

  // Helpful logging wrapper to surface Supabase/Postgrest errors
  void _logSupabaseError(String context, dynamic error) {
    try {
      final details = _extractSupabaseError(error);
      print('Supabase error [$context]: $details');
    } catch (e) {
      print('Supabase error [$context]: $error');
    }
  }

  // Normalize Supabase client responses to Dart List<dynamic>
  List<dynamic> _normalizeResponseRows(dynamic response) {
    if (response == null) return <dynamic>[];
    // If it's already a Dart List, return directly
    if (response is List<dynamic>) return response;
    // JS interop types (JSArray) may not be List<dynamic>, try a fallback
    try {
      return List<dynamic>.from(response as Iterable);
    } catch (_) {
      // Last resort: try to encode/decode via json (works for simple shapes)
      try {
        final encoded = jsonEncode(response);
        final decoded = jsonDecode(encoded);
        if (decoded is List<dynamic>) return decoded;
      } catch (_) {}
    }
    return <dynamic>[];
  }

  // Try to parse common Supabase/Postgrest error shapes to a readable string
  String _extractSupabaseError(dynamic error) {
    if (error == null) return 'Unknown error';
    try {
      // PostgrestException-like
      if (error is Map) return jsonEncode(error);
      final s = error.toString();
      // Some Supabase clients include JSON in the message
      final jsonStart = s.indexOf('{');
      if (jsonStart != -1) {
        final jsonPart = s.substring(jsonStart);
        return jsonPart;
      }
      return s;
    } catch (e) {
      return error.toString();
    }
  }
}

// Extension to allow copying Product with updated fields
extension ProductCopyWith on Product {
  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    double? buyingPrice,
    double? sellingPrice,
    int? quantity,
    String? description,
    String? imageUrl,
    DateTime? dateAdded,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
