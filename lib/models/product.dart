import 'package:uuid/uuid.dart';

class Product {
  final String id; // Non-nullable, always initialized
  final String name;
  final String category;
  final String brand;
  final double buyingPrice;
  final double sellingPrice;
  final int quantity;
  final String? description;
  final String? imageUrl; // Keep for backward compatibility
  final List<String> imageUrls; // New field for multiple images
  final DateTime dateAdded;

  Product({
    String? id, // Accepts nullable, but ensures a value
    required this.name,
    required this.category,
    required this.brand,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    this.description,
    this.imageUrl,
    List<String>? imageUrls,
    required this.dateAdded,
  })  : id = (id == null || id.isEmpty) ? const Uuid().v4() : id,
        imageUrls = imageUrls ?? (imageUrl != null ? [imageUrl] : []);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unnamed Product',
      category: json['category'] as String? ?? 'Uncategorized',
      brand: json['brand'] as String? ?? 'Unknown Brand',
      buyingPrice: (json['buying_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'] as String)
          : DateTime.now(),
    );
  }

  /// Factory constructor for the new inventories table structure
  factory Product.fromInventoryJson(Map<String, dynamic> json) {
    // Inventories table now stores some fields at top-level for easy querying
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final topCategory = (json['category'] as String?) ?? metadata['category'];
    final topBrand = (json['brand'] as String?) ?? metadata['brand'];

    final selling = (json['selling_price'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final buying =
        (json['buying_price'] as num?)?.toDouble() ?? (selling * 0.8);

    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unnamed Product',
      category: topCategory as String? ?? 'Uncategorized',
      brand: topBrand as String? ?? 'Unknown Brand',
      buyingPrice: buying,
      sellingPrice: selling,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: (json['description'] as String?) ??
          metadata['description'] as String?,
      imageUrl:
          (json['image_url'] as String?) ?? (metadata['image_url'] as String?),
      imageUrls: Product._parseImageUrls(metadata),
      dateAdded: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'brand': brand,
        'buying_price': buyingPrice,
        'selling_price': sellingPrice,
        'quantity': quantity,
        'description': description,
        'image_url': imageUrl,
        'image_urls': imageUrls,
        'date_added': dateAdded.toIso8601String(),
      };

  /// Helper method to parse image URLs from metadata
  static List<String> _parseImageUrls(Map<String, dynamic> metadata) {
    // Check for multiple images first
    if (metadata['image_urls'] != null) {
      final urls = metadata['image_urls'];
      if (urls is List) {
        return urls.cast<String>().where((url) => url.isNotEmpty).toList();
      }
    }

    // Fall back to single image URL for backward compatibility
    final singleUrl = metadata['image_url'] as String?;
    return singleUrl != null && singleUrl.isNotEmpty ? [singleUrl] : [];
  }

  /// Get the first image URL (for backward compatibility)
  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Check if product has any images
  bool get hasImages => imageUrls.isNotEmpty;
}
