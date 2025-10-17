import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../widgets/enhanced_feedback_widget.dart';

class StorefrontSettingsScreen extends StatefulWidget {
  const StorefrontSettingsScreen({super.key});

  @override
  State<StorefrontSettingsScreen> createState() =>
      _StorefrontSettingsScreenState();
}

class _StorefrontSettingsScreenState extends State<StorefrontSettingsScreen> {
  bool _isLoading = true;
  bool _storefrontVisible = true;
  String _businessName = 'Unknown Business';
  final TextEditingController _businessNameController = TextEditingController();

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);

      final settings = await SettingsService.getTenantSettings();

      setState(() {
        _storefrontVisible = settings['showProductsToCustomers'] ?? true;
        _businessName = settings['name'] ?? 'Unknown Business';
        _businessNameController.text = _businessName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Failed to load settings: $e',
        );
      }
    }
  }

  Future<void> _updateStorefrontVisibility(bool visible) async {
    try {
      await SettingsService.updateStorefrontVisibility(visible);

      setState(() {
        _storefrontVisible = visible;
      });

      if (mounted) {
        EnhancedFeedbackWidget.showSuccessSnackBar(
          context,
          visible
              ? 'Storefront is now visible to customers'
              : 'Storefront is now hidden from customers',
        );
      }
    } catch (e) {
      if (mounted) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Failed to update storefront visibility: $e',
        );
      }
    }
  }

  Future<void> _updateBusinessName() async {
    final newName = _businessNameController.text.trim();
    if (newName.isEmpty || newName == _businessName) return;

    try {
      await SettingsService.updateBusinessName(newName);

      setState(() {
        _businessName = newName;
      });

      if (mounted) {
        EnhancedFeedbackWidget.showSuccessSnackBar(
          context,
          'Business name updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        EnhancedFeedbackWidget.showErrorSnackBar(
          context,
          'Failed to update business name: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storefront Settings'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Information Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.business, color: primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Business Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: darkGray,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _businessNameController,
                            decoration: const InputDecoration(
                              labelText: 'Business Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.store),
                            ),
                            onSubmitted: (_) => _updateBusinessName(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _updateBusinessName,
                                icon: const Icon(Icons.save),
                                label: const Text('Update Name'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Storefront Visibility Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront, color: primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Global Storefront Settings',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: darkGray,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Storefront Visibility Toggle
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _storefrontVisible
                                  ? primaryGreen.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _storefrontVisible
                                    ? primaryGreen.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _storefrontVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _storefrontVisible
                                      ? primaryGreen
                                      : Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Show Products to Customers',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _storefrontVisible
                                              ? primaryGreen
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _storefrontVisible
                                            ? 'Your storefront is visible to customers. They can browse and view your products.'
                                            : 'Your storefront is hidden from customers. No products will be visible to them.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _storefrontVisible,
                                  onChanged: _updateStorefrontVisibility,
                                  activeColor: primaryGreen,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Information Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'How Visibility Works',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '• Global setting: Controls whether ANY products are visible\n'
                                        '• Individual product visibility: Each product can be hidden/shown separately\n'
                                        '• Both settings must be enabled for products to be visible to customers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Additional Settings Section (for future expansion)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.settings, color: primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Additional Settings',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: darkGray,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading:
                                const Icon(Icons.language, color: lightGray),
                            title: const Text('Currency & Region'),
                            subtitle: const Text('TSH (Tanzanian Shilling)'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Future: Currency settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Currency settings coming soon'),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading:
                                const Icon(Icons.palette, color: lightGray),
                            title: const Text('Theme & Branding'),
                            subtitle: const Text(
                                'Customize your storefront appearance'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Future: Theme settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Theme settings coming soon'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }
}
