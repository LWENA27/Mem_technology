import 'package:uuid/uuid.dart';

class Sale {
  final String id; // Non-nullable, always assigned
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String customerName;
  final String customerPhone;
  final DateTime saleDate;

  Sale({
    String? id, // Accepts null or empty string
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.customerName,
    required this.customerPhone,
    required this.saleDate,
  }) : id = (id == null || id.isEmpty) ? const Uuid().v4() : id;

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String?,
      productId: json['product_id'] as String? ?? 'Unknown Product ID',
      productName: json['product_name'] as String? ?? 'Unnamed Product',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customer_name'] as String? ?? 'Unknown Customer',
      customerPhone: json['customer_phone'] as String? ?? 'N/A',
      saleDate: json['sale_date'] != null
          ? DateTime.parse(json['sale_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_price': totalPrice,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'sale_date': saleDate.toIso8601String(),
  };
}
