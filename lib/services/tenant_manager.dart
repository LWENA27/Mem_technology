import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class TenantManager {
  static final TenantManager _instance = TenantManager._internal();
  factory TenantManager() => _instance;
  TenantManager._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  String? _currentTenantId;
  Map<String, dynamic>? _currentTenant;

  String? get currentTenantId => _currentTenantId;
  Map<String, dynamic>? get currentTenant => _currentTenant;

  /// Initialize tenant for the current user
  Future<void> initializeTenant() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('TenantManager: No authenticated user');
        return;
      }

      // Get user's profile and tenant_id
      final profile = await _supabase
          .from('profiles')
          .select('tenant_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['tenant_id'] != null) {
        _currentTenantId = profile['tenant_id'];

        // Get tenant details
        final tenant = await _supabase
            .from('tenants')
            .select('*')
            .eq('id', _currentTenantId!)
            .single();

        _currentTenant = tenant;

        debugPrint(
            'TenantManager: Initialized with tenant $_currentTenantId');
        debugPrint('TenantManager: Tenant name: ${_currentTenant?['name']}');
      } else {
        debugPrint(
            'TenantManager: User has no tenant_id, will use default tenant');
        await _setDefaultTenant();
      }
    } catch (e) {
      debugPrint('TenantManager: Error initializing tenant: $e');
      await _setDefaultTenant();
    }
  }

  /// Set default tenant (for shared public products)
  Future<void> _setDefaultTenant() async {
    try {
      // Look for the default public tenant
      final defaultTenant = await _supabase
          .from('tenants')
          .select('*')
          .eq('slug', 'test-store')
          .maybeSingle();

      if (defaultTenant != null) {
        _currentTenantId = defaultTenant['id'];
        _currentTenant = defaultTenant;
        debugPrint('TenantManager: Using default tenant: $_currentTenantId');
      } else {
        // Create default tenant if it doesn't exist
        await _createDefaultTenant();
      }
    } catch (e) {
      debugPrint('TenantManager: Error setting default tenant: $e');
      await _createDefaultTenant();
    }
  }

  /// Create default public tenant
  Future<void> _createDefaultTenant() async {
    try {
      final defaultTenant = await _supabase
          .from('tenants')
          .insert({
            'id': '11111111-1111-1111-1111-111111111111',
            'name': 'Public Store',
            'slug': 'public-store',
            'public_storefront': true,
            'metadata': {
              'description': 'Default public store for shared products',
              'is_default': true,
            }
          })
          .select()
          .single();

      _currentTenantId = defaultTenant['id'];
      _currentTenant = defaultTenant;

      debugPrint('TenantManager: Created default tenant: $_currentTenantId');
    } catch (e) {
      debugPrint('TenantManager: Error creating default tenant: $e');
      // Fallback to hardcoded default
      _currentTenantId = '11111111-1111-1111-1111-111111111111';
    }
  }

  /// Associate current user with the current tenant
  Future<void> associateUserWithTenant() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || _currentTenantId == null) return;

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'role': 'admin',
        'tenant_id': _currentTenantId,
      });

      debugPrint(
          'TenantManager: Associated user ${user.id} with tenant $_currentTenantId');
    } catch (e) {
      debugPrint('TenantManager: Error associating user with tenant: $e');
    }
  }

  /// Get tenant ID for operations (with fallback)
  String getOperationTenantId() {
    return _currentTenantId ?? '11111111-1111-1111-1111-111111111111';
  }

  /// Clear tenant data (for logout)
  void clear() {
    _currentTenantId = null;
    _currentTenant = null;
    debugPrint('TenantManager: Cleared tenant data');
  }

  /// Ensure user and tenant are properly linked
  Future<void> ensureTenantConsistency() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Check if user has a tenant
      final profile = await _supabase
          .from('profiles')
          .select('tenant_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        // Create profile for user
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'role': 'admin',
          'tenant_id': getOperationTenantId(),
        });
        debugPrint('TenantManager: Created profile for user ${user.id}');
      } else if (profile['tenant_id'] == null) {
        // Update profile with tenant
        await _supabase
            .from('profiles')
            .update({'tenant_id': getOperationTenantId()}).eq('id', user.id);
        debugPrint(
            'TenantManager: Updated profile with tenant for user ${user.id}');
      }
    } catch (e) {
      debugPrint('TenantManager: Error ensuring tenant consistency: $e');
    }
  }
}
