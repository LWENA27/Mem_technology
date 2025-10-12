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
  final String? imageUrl;
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
    required this.dateAdded,
  }) : id = (id == null || id.isEmpty) ? const Uuid().v4() : id;

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
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unnamed Product',
      category: metadata['category'] as String? ?? 'Uncategorized',
      brand: metadata['brand'] as String? ?? 'Unknown Brand',
      buyingPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: metadata['description'] as String?,
      imageUrl: metadata['image_url'] as String?,
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
        'date_added': dateAdded.toIso8601String(),
      };
}
