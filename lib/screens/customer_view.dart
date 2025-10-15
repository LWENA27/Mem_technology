import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/inventory_service.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  _CustomerViewState createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _categories = {'All'};
  StreamSubscription<AuthState>? _authSubscription;

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProducts();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() async {
    try {
      // Don't initialize again - it's already done in _checkAuthAndLoadProducts
      if (SupabaseService.instance.isInitialized) {
        _authSubscription = SupabaseService
            .instance.client.auth.onAuthStateChange
            .listen((data) {
          final session = data.session;
          if (session != null) {
            debugPrint(
                'Auth state changed - user logged in, reloading products');
            _loadProducts();
          } else {
            debugPrint('Auth state changed - user logged out');
            setState(() {
              _products = [];
              _filteredProducts = [];
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
    }
  }

  Future<void> _checkAuthAndLoadProducts() async {
    try {
      // Initialize Supabase service
      await SupabaseService.instance.initialize();

      // Always try to load products first, regardless of auth status
      await _loadProducts();

      // Check if user is authenticated (for admin features)
      if (SupabaseService.instance.isAuthenticated()) {
        debugPrint('User is authenticated with admin access');
      } else {
        debugPrint('User browsing as customer (no admin access)');
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Loading public products for customer view...');
      final products = await InventoryService.getPublicInventories();
      debugPrint('Public products loaded: count = \'${products.length}\'');
      final categories = products.map((p) => p.category).toSet();
      debugPrint('Categories found: $categories');
      setState(() {
        _products = products;
        _filteredProducts = products;
        _categories = {'All', ...categories};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading public products: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'All' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  _callOwner() async {
    const phoneNumber = 'tel:+255692240929';
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone dialer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _sendWhatsAppMessage() async {
    const phoneNumber = '+255692240929';
    const message = 'Hello! Im interested in your products. Can you assist me?';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _navigateToLogin() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // If login was successful, reload products
    if (result == true) {
      debugPrint('Login successful, reloading products...');
      await _loadProducts();
    }
  }

  _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Widget _buildProductImage(Product product) {
    final firstImageUrl = product.firstImageUrl;

    if (firstImageUrl == null || firstImageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: const Icon(Icons.devices, size: 50, color: lightGray),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              firstImageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: backgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Image load error for $firstImageUrl: $error');
                return Container(
                  color: backgroundColor,
                  child: const Icon(Icons.broken_image,
                      size: 50, color: lightGray),
                );
              },
            ),
          ),
        ),
        // Show multi-image indicator if there are multiple images
        if (product.imageUrls.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library,
                      color: Colors.white, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${product.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'InventoryMaster',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkGray,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callOwner,
            tooltip: 'Call Us',
          ),
          // WhatsApp icon with brand color
          IconButton(
            icon: const Icon(Icons.message),
            color: const Color(0xFF25D366),
            onPressed: _sendWhatsAppMessage,
            tooltip: 'WhatsApp',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings & Downloads',
          ),
          IconButton(
            icon: Icon(SupabaseService.instance.isAuthenticated()
                ? Icons.admin_panel_settings
                : Icons.login),
            onPressed: _navigateToLogin,
            tooltip: SupabaseService.instance.isAuthenticated()
                ? 'Manage Inventory'
                : 'Inventory Login',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: primaryGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterProducts();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : darkGray,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryGreen,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? primaryGreen : lightGray,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterProducts();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 64, color: lightGray),
                            SizedBox(height: 16),
                            Text(
                              'No products available',
                              style: TextStyle(fontSize: 18, color: darkGray),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check back later for new arrivals',
                              style: TextStyle(color: lightGray),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: primaryGreen,
                        onRefresh: () async => _loadProducts(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.grey.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildProductImage(product),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: darkGray,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              product.brand,
                                              style: const TextStyle(
                                                  color: lightGray,
                                                  fontSize: 12),
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'TSH ${product.sellingPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryGreen,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primaryGreen
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: primaryGreen
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${product.quantity} left',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: primaryGreen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      // floatingActionButton removed per design (call button hidden)
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  // MEM Technology Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkGray,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: const TextStyle(
                      color: lightGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'TSH ${product.sellingPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: primaryGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${product.quantity} in stock',
                          style: const TextStyle(
                            color: primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'No description available.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: lightGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    final images = product.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 80, color: lightGray),
            SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(color: lightGray, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (images.length == 1) {
      return Container(
        height: 300,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            images.first,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.white,
                child:
                    const Icon(Icons.broken_image, size: 80, color: lightGray),
              );
            },
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryGreen),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: const Icon(Icons.broken_image,
                            size: 80, color: lightGray),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Image indicators
        if (images.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryGreen.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
