import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';
import '../services/image_upload_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

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

  List<File> _selectedImages = [];
  List<XFile> _selectedImageFiles = [];
  List<String> _currentImageUrls = [];
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
    _currentImageUrls = List.from(product.imageUrls);
  }

  Future<void> _pickImages() async {
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
                    'Add Product Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Select from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getMultipleImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Select Single from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImageFiles.isNotEmpty ||
                    _currentImageUrls.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Clear All Images',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImages.clear();
                        _selectedImageFiles.clear();
                        _currentImageUrls.clear();
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

      if (pickedFile != null) {
        if (!await _validateAndAddImage(pickedFile)) {
          return;
        }
        _showSuccessMessage('Image added successfully!');
      }
    } catch (e) {
      _showErrorMessage('Error picking image: $e');
    }
  }

  Future<void> _getMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        int addedCount = 0;
        for (final file in pickedFiles) {
          if (await _validateAndAddImage(file)) {
            addedCount++;
          }
        }

        if (addedCount > 0) {
          _showSuccessMessage('$addedCount image(s) added successfully!');
        }
      }
    } catch (e) {
      _showErrorMessage('Error picking images: $e');
    }
  }

  Future<bool> _validateAndAddImage(XFile pickedFile) async {
    // Check if we already have too many images
    final totalImages = _selectedImageFiles.length + _currentImageUrls.length;
    if (totalImages >= 5) {
      _showErrorMessage('Maximum 5 images allowed per product.');
      return false;
    }

    // Validate file size
    final bytes = await pickedFile.readAsBytes();
    final sizeInMB = ImageUploadService.getFileSizeInMB(bytes.length);

    if (sizeInMB > 10) {
      _showErrorMessage(
          'Image "${pickedFile.name}" is too large. Please select images smaller than 10MB.');
      return false;
    }

    // Validate file type
    if (!ImageUploadService.isValidImageFile(pickedFile.name)) {
      _showErrorMessage(
          'Invalid format for "${pickedFile.name}". Please select JPG, PNG, GIF, or WebP.');
      return false;
    }

    setState(() {
      _selectedImageFiles.add(pickedFile);
      if (!kIsWeb) {
        _selectedImages.add(File(pickedFile.path));
      }
    });

    return true;
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
      _isUploading = _selectedImageFiles.isNotEmpty;
    });

    try {
      List<String> allImageUrls = List.from(_currentImageUrls);

      // Upload new images if selected
      if (_selectedImageFiles.isNotEmpty) {
        print('Debug: Uploading ${_selectedImageFiles.length} images...');
        setState(() {
          _isUploading = true;
        });

        try {
          final uploadedUrls = await ImageUploadService.uploadMultipleImages(
            imageFiles: _selectedImageFiles,
          );
          allImageUrls.addAll(uploadedUrls);
          print('Debug: Images uploaded successfully: $uploadedUrls');
          _showSuccessMessage(
              '${uploadedUrls.length} image(s) uploaded successfully!');
        } catch (e) {
          print('Debug: Image upload failed: $e');
          _showErrorMessage('Failed to upload some images: $e');
          // Continue with product save even if some image uploads fail
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }

      print('Debug: Starting to save product...');
      print('Debug: Name: ${_nameController.text}');
      print('Debug: Category: ${_categoryController.text}');
      print('Debug: Brand: ${_brandController.text}');
      print('Debug: Price: ${_sellingPriceController.text}');
      print('Debug: Quantity: ${_quantityController.text}');
      print('Debug: Image URLs: $allImageUrls');

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
          imageUrls: allImageUrls,
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
          imageUrls: allImageUrls,
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

  Widget _buildImagesGrid() {
    final totalImages = _selectedImageFiles.length + _currentImageUrls.length;

    if (totalImages == 0) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
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
              Text('Tap to add product images',
                  style: TextStyle(color: Colors.grey)),
              Text('(Up to 5 images)',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Images ($totalImages/5)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (totalImages < 5)
              TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate, size: 16),
                label: const Text('Add More'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: totalImages,
          itemBuilder: (context, index) {
            return _buildImageTile(index);
          },
        ),
      ],
    );
  }

  Widget _buildImageTile(int index) {
    final isCurrentImage = index < _currentImageUrls.length;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isCurrentImage
                ? _buildCurrentImageWidget(_currentImageUrls[index])
                : _buildSelectedImageWidget(index - _currentImageUrls.length),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentImageWidget(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  Widget _buildSelectedImageWidget(int fileIndex) {
    final imageFile = _selectedImageFiles[fileIndex];

    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(
        File(imageFile.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _currentImageUrls.length) {
        _currentImageUrls.removeAt(index);
      } else {
        final fileIndex = index - _currentImageUrls.length;
        _selectedImageFiles.removeAt(fileIndex);
        if (!kIsWeb && fileIndex < _selectedImages.length) {
          _selectedImages.removeAt(fileIndex);
        }
      }
    });
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
        height:
            MediaQuery.of(context).size.height * 0.8, // Add height constraint
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section
                _buildImagesGrid(),
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
