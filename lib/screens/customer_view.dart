   import 'dart:io';
   import 'package:flutter/material.dart';
   import 'package:url_launcher/url_launcher.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import '../services/supabase_service.dart';
   import '../models/product.dart';
   import '../services/DatabaseService.dart';
   import 'login_screen.dart';

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

     @override
     void initState() {
       super.initState();
       _loadProducts();
     }

     Future<void> _loadProducts() async {
       setState(() => _isLoading = true);
       final products = await DatabaseService.instance.getAvailableProducts();
       final categories = products.map((p) => p.category).toSet();
       
       setState(() {
         _products = products;
         _filteredProducts = products;
         _categories = {'All', ...categories};
         _isLoading = false;
       });
     }

     _filterProducts() {
       setState(() {
         _filteredProducts = _products.where((product) {
           final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                       product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
           final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
           return matchesSearch && matchesCategory;
         }).toList();
       });
     }

     _callOwner() async {
       const phoneNumber = 'YOUR_PHONE_NUMBER'; // Replace with actual phone number
       if (await canLaunchUrl(Uri.parse(phoneNumber))) {
         await launchUrl(Uri.parse(phoneNumber));
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Could not launch phone dialer')),
         );
       }
     }

     _logout() async {
       final supabase = SupabaseService().client;
       await supabase.auth.signOut();
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (context) => const LoginScreen()),
         (route) => false,
       );
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('MEMTECHNOLOGY'),
           backgroundColor: Colors.blue,
           foregroundColor: Colors.white,
           actions: [
             IconButton(
               icon: const Icon(Icons.phone),
               onPressed: _callOwner,
             ),
             IconButton(
               icon: const Icon(Icons.logout),
               onPressed: _logout,
             ),
           ],
         ),
         body: Column(
           children: [
             Container(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   TextField(
                     decoration: InputDecoration( // Remove const here
                       hintText: 'Search products...',
                       prefixIcon: const Icon(Icons.search),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                     onChanged: (value) {
                       _searchQuery = value;
                       _filterProducts();
                     },
                   ),
                   const SizedBox(height: 10),
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: _categories.map((category) {
                         return Padding(
                           padding: const EdgeInsets.only(right: 8),
                           child: FilterChip(
                             label: Text(category),
                             selected: _selectedCategory == category,
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
                   ? const Center(child: CircularProgressIndicator())
                   : _filteredProducts.isEmpty
                       ? const Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                               SizedBox(height: 16),
                               Text('No products available', style: TextStyle(fontSize: 18)),
                               SizedBox(height: 8),
                               Text('Check back later for new arrivals'),
                             ],
                           ),
                         )
                       : RefreshIndicator(
                           onRefresh: () async => _loadProducts(),
                           child: GridView.builder(
                             padding: const EdgeInsets.all(8),
                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 2,
                               childAspectRatio: 0.7,
                               crossAxisSpacing: 8,
                               mainAxisSpacing: 8,
                             ),
                             itemCount: _filteredProducts.length,
                             itemBuilder: (context, index) {
                               final product = _filteredProducts[index];
                               return Card(
                                 elevation: 4,
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Expanded(
                                       flex: 3,
                                       child: Container(
                                         width: double.infinity,
                                         decoration: BoxDecoration(
                                           color: Colors.grey.shade200,
                                           borderRadius: const BorderRadius.vertical(
                                             top: Radius.circular(4),
                                           ),
                                         ),
                                         child: product.imageUrl != null
                                             ? (product.imageUrl!.startsWith('http')
                                                 ? Image.network(
                                                     product.imageUrl!,
                                                     fit: BoxFit.cover,
                                                     errorBuilder: (context, error, stackTrace) =>
                                                         const Icon(Icons.image, size: 50, color: Colors.grey),
                                                   )
                                                 : File(product.imageUrl!).existsSync()
                                                     ? Image.file(
                                                         File(product.imageUrl!),
                                                         fit: BoxFit.cover,
                                                         errorBuilder: (context, error, stackTrace) =>
                                                             const Icon(Icons.image, size: 50, color: Colors.grey),
                                                       )
                                                     : const Icon(Icons.devices, size: 50, color: Colors.grey))
                                             : const Icon(Icons.devices, size: 50, color: Colors.grey),
                                       ),
                                     ),
                                     Expanded(
                                       flex: 2,
                                       child: Padding(
                                         padding: const EdgeInsets.all(8),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               product.name,
                                               style: const TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 14,
                                               ),
                                               maxLines: 2,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             Text(
                                               product.brand,
                                               style: TextStyle(color: Colors.grey.shade600),
                                             ),
                                             const Spacer(),
                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text(
                                                   '\$${product.sellingPrice.toStringAsFixed(2)}',
                                                   style: const TextStyle(
                                                     fontWeight: FontWeight.bold,
                                                     color: Colors.green,
                                                     fontSize: 16,
                                                   ),
                                                 ),
                                                 Container(
                                                   padding: const EdgeInsets.symmetric(
                                                     horizontal: 6,
                                                     vertical: 2,
                                                   ),
                                                   decoration: BoxDecoration(
                                                     color: Colors.blue.shade100,
                                                     borderRadius: BorderRadius.circular(10),
                                                   ),
                                                   child: Text(
                                                     '${product.quantity} left',
                                                     style: TextStyle(
                                                       fontSize: 10,
                                                       color: Colors.blue.shade800,
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
                               );
                             },
                           ),
                         ),
             ),
           ],
         ),
         floatingActionButton: FloatingActionButton(
           onPressed: _callOwner,
           backgroundColor: Colors.green,
           child: const Icon(Icons.phone),
         ),
       );
     }
   }