import 'package:supabase_flutter/supabase_flutter.dart';
import 'tenant_manager.dart';

class SettingsService {
  static final _supabase = Supabase.instance.client;

  /// Get global storefront visibility setting for current tenant
  static Future<bool> getStorefrontVisibility() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tenantId = TenantManager().getOperationTenantId();

      try {
        final response = await _supabase
            .from('tenants')
            .select('show_products_to_customers')
            .eq('id', tenantId)
            .single();

        return response['show_products_to_customers'] ?? true;
      } on PostgrestException catch (pe) {
        print(
            'Debug: PostgrestException when reading show_products_to_customers: $pe');
        print(
            'Debug: Falling back to default storefront visibility = true. Please run the visibility migration to add the column.');
        return true;
      }
    } catch (e) {
      print('Debug: Error getting storefront visibility: $e');
      // Default to true if error occurs
      return true;
    }
  }

  /// Update global storefront visibility setting for current tenant
  static Future<void> updateStorefrontVisibility(bool visible) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tenantId = TenantManager().getOperationTenantId();

      try {
        await _supabase.from('tenants').update({
          'show_products_to_customers': visible,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', tenantId);

        print(
            'Debug: Updated storefront visibility to $visible for tenant $tenantId');
      } on PostgrestException catch (pe) {
        print(
            'Debug: PostgrestException when updating show_products_to_customers: $pe');
        print(
            'Debug: The tenants.show_products_to_customers column may be missing. Please run the visibility migration.');
        throw Exception(
            'Failed to update storefront visibility: missing database column show_products_to_customers');
      }
    } catch (e) {
      print('Debug: Error updating storefront visibility: $e');
      throw Exception('Failed to update storefront visibility: $e');
    }
  }

  /// Get all tenant settings including storefront visibility
  static Future<Map<String, dynamic>> getTenantSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tenantId = TenantManager().getOperationTenantId();

      final response = await _supabase
          .from('tenants')
          .select('name, show_products_to_customers, created_at, updated_at')
          .eq('id', tenantId)
          .single();
      try {
        return {
          'name': response['name'] ?? 'Unknown Business',
          'showProductsToCustomers':
              response['show_products_to_customers'] ?? true,
          'createdAt': response['created_at'],
          'updatedAt': response['updated_at'],
        };
      } on TypeError catch (_) {
        // In case the response doesn't contain the column, fallback
        print(
            'Debug: Tenant response missing show_products_to_customers - falling back to defaults');
        return {
          'name': response['name'] ?? 'Unknown Business',
          'showProductsToCustomers': true,
          'createdAt': response['created_at'],
          'updatedAt': response['updated_at'],
        };
      }
    } catch (e) {
      print('Debug: Error getting tenant settings: $e');
      throw Exception('Failed to get tenant settings: $e');
    }
  }

  /// Update tenant business name
  static Future<void> updateBusinessName(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tenantId = TenantManager().getOperationTenantId();

      await _supabase.from('tenants').update({
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tenantId);

      print('Debug: Updated business name to "$name" for tenant $tenantId');
    } catch (e) {
      print('Debug: Error updating business name: $e');
      throw Exception('Failed to update business name: $e');
    }
  }
}
