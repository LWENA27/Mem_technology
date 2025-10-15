import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale.dart';

class SalesService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String> recordSale({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required String customerName,
    String? customerPhone,
    String? receiptNumber,
  }) async {
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

      final totalPrice = quantity * unitPrice;
      final saleDate = DateTime.now().toIso8601String();

      // Insert sale record
      final saleData = {
        'tenant_id': tenantId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'sale_date': saleDate,
        'receipt_number': receiptNumber,
      };

      final response =
          await _supabase.from('sales').insert(saleData).select().single();

      // Get current inventory quantity first
      final currentInventory = await _supabase
          .from('inventories')
          .select('quantity')
          .eq('id', productId)
          .single();

      final currentQuantity = currentInventory['quantity'] as int;
      final newQuantity = currentQuantity - quantity;

      if (newQuantity < 0) {
        throw Exception(
            'Insufficient inventory. Available: $currentQuantity, Requested: $quantity');
      }

      // Update inventory quantity - subtract the sold quantity
      await _supabase
          .from('inventories')
          .update({'quantity': newQuantity}).eq('id', productId);

      return response['id'];
    } catch (e) {
      throw Exception('Failed to record sale: $e');
    }
  }

  static Future<List<Sale>> getSales() async {
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
          .from('sales')
          .select()
          .eq('tenant_id', tenantId)
          .order('sale_date', ascending: false);

      return response.map<Sale>((sale) => Sale.fromJson(sale)).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales: $e');
    }
  }

  static Future<Sale?> getSaleById(String saleId) async {
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
          .from('sales')
          .select()
          .eq('id', saleId)
          .eq('tenant_id', tenantId)
          .single();

      return Sale.fromJson(response);
    } catch (e) {
      print('Failed to fetch sale: $e');
      return null;
    }
  }

  static Future<double> getTotalSales(
      {DateTime? startDate, DateTime? endDate}) async {
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

      var query = _supabase
          .from('sales')
          .select('total_price')
          .eq('tenant_id', tenantId);

      if (startDate != null) {
        query = query.gte('sale_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('sale_date', endDate.toIso8601String());
      }

      final response = await query;

      double total = 0.0;
      for (var sale in response) {
        total += (sale['total_price'] as num).toDouble();
      }

      return total;
    } catch (e) {
      throw Exception('Failed to calculate total sales: $e');
    }
  }

  static String generateReceiptNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(6);
    return 'RCP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }
}
