import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AddProductDialog extends StatefulWidget {
  final Product? product; // For editing existing products
  final VoidCallback onProductAdded; // Add this callback parameter

  const AddProductDialog({
    super.key,
    this.product,
    required this.onProductAdded, // Make it required
  });

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // Predefined categories
  final List<String> _categories = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'Accessories',
    'Audio',
    'Gaming',
    'Cameras',
    'Smart Home',
    'Wearables',
    'Components',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields();
    } else {
      // Set default values for new products to make testing easier
      _quantityController.text = '1';
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _brandController.text = product.brand;
    _categoryController.text = product.category;
    _buyingPriceController.text = product.buyingPrice.toString();
    _sellingPriceController.text = product.sellingPrice.toString();
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = product.description ?? '';
    _currentImageUrl = product.imageUrl;
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null || _currentImageUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Image',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _currentImageUrl = null;
                      });
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    } catch (e) {
      _showErrorMessage('Error opening image picker: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null && !kIsWeb) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _currentImageUrl =
              null; // Clear current URL when new image is selected
        });
      }
    } catch (e) {
      _showErrorMessage('Error picking image: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    print('Debug: _saveProduct called');
    
    if (!_formKey.currentState!.validate()) {
      print('Debug: Form validation failed');
      return;
    }
    
    print('Debug: Form validation passed');

    setState(() {
      _isLoading = true;
      _isUploading = _selectedImage != null;
    });

    try {
      // For now, we'll skip image upload and focus on core functionality
      // TODO: Implement image upload to Supabase storage in the future
      if (_selectedImage != null) {
        // Placeholder for future image upload functionality
        _showErrorMessage('Image upload not implemented yet. Product will be saved without image.');
      }

      print('Debug: Starting to save product...');
      print('Debug: Name: ${_nameController.text}');
      print('Debug: Category: ${_categoryController.text}');
      print('Debug: Brand: ${_brandController.text}');
      print('Debug: Price: ${_sellingPriceController.text}');
      print('Debug: Quantity: ${_quantityController.text}');

      if (widget.product == null) {
        // Adding new product
        await InventoryService.addInventory(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          brand: _brandController.text.trim(),
          price: double.parse(_sellingPriceController.text),
          quantity: int.parse(_quantityController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          sku: null, // Can add SKU field later if needed
        );
        _showSuccessMessage('Product added successfully!');
      } else {
        // Updating existing product
        await InventoryService.updateInventory(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          brand: _brandController.text.trim(),
          price: double.parse(_sellingPriceController.text),
          quantity: int.parse(_quantityController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          sku: null, // Can add SKU field later if needed
        );
        _showSuccessMessage('Product updated successfully!');
      }

      // Call the callback to refresh the inventory list
      widget.onProductAdded();

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      _showErrorMessage('Error saving product: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null && !kIsWeb) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    Text('Error loading image'),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      // Show current image from URL
      if (_currentImageUrl!.startsWith('http')) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _currentImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      Text('Error loading image'),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // Local file path
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (!kIsWeb && File(_currentImageUrl!).existsSync())
                ? Image.file(
                    File(_currentImageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                            Text('Error loading image'),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                        Text('Image not found'),
                      ],
                    ),
                  ),
          ),
        );
      }
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tap to add product image',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8, // Add height constraint
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: _buildImagePreview(),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Uploading image...',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Form fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _categories.contains(_categoryController.text)
                      ? _categoryController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _categoryController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _buyingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Buying Price *',
                          border: OutlineInputBorder(),
                          prefixText: 'TSH ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price';
                          }
                          if (double.parse(value) < 0) {
                            return 'Price must be positive';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price *',
                          border: OutlineInputBorder(),
                          prefixText: 'TSH ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price';
                          }
                          if (double.parse(value) < 0) {
                            return 'Price must be positive';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid quantity';
                    }
                    if (int.parse(value) < 0) {
                      return 'Quantity must be positive';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product == null ? 'Add Product' : 'Update Product'),
        ),
      ],
    );
  }
}
