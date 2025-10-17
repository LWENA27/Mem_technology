import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'connectivity_service.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final ConnectivityService _connectivityService = ConnectivityService();
  static const String _bucketName = 'product-images';
  static const String _localImageFolder = 'offline_images';

  /// Upload image to Supabase Storage and return the public URL
  /// If offline, store locally and return a local path
  static Future<String?> uploadImage({
    required XFile imageFile,
    String? existingImageUrl,
  }) async {
    try {
      print('Debug: Starting image upload process...');

      // Check if we're online
      if (!_connectivityService.isOnline) {
        print('Debug: Offline - storing image locally');
        return await _storeImageLocally(imageFile);
      }

      // Delete existing image if provided
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        await _deleteImageFromUrl(existingImageUrl);
      }

      // Generate unique filename
      const uuid = Uuid();
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${uuid.v4()}.$fileExtension';
      final filePath = 'products/$fileName';

      print('Debug: Uploading image as: $filePath');

      // Read and compress the image
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
      } else {
        final file = File(imageFile.path);
        imageBytes = await file.readAsBytes();
      }

      // Compress image if it's too large (limit to 2MB)
      if (imageBytes.length > 2 * 1024 * 1024) {
        print(
            'Debug: Image too large (${imageBytes.length} bytes), compressing...');
        imageBytes = await _compressImage(imageBytes, fileExtension);
        print('Debug: Compressed to ${imageBytes.length} bytes');
      }

      // Upload to Supabase Storage
      final response = await _supabase.storage.from(_bucketName).uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: _getContentType(fileExtension),
              upsert: false,
            ),
          );

      print('Debug: Upload response: $response');

      // Get public URL
      final publicUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(filePath);

      print('Debug: Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images to Supabase Storage and return the public URLs
  /// If offline, store locally and return local paths
  static Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    List<String>? existingImageUrls,
  }) async {
    try {
      print('Debug: Starting multiple image upload process...');
      print('Debug: Uploading ${imageFiles.length} images');

      // Check if we're online
      if (!_connectivityService.isOnline) {
        print('Debug: Offline - storing ${imageFiles.length} images locally');
        final List<String> localPaths = [];

        for (int i = 0; i < imageFiles.length; i++) {
          final imageFile = imageFiles[i];
          print('Debug: Storing image ${i + 1}/${imageFiles.length} locally');

          try {
            final localPath = await _storeImageLocally(imageFile);
            if (localPath != null) {
              localPaths.add(localPath);
            }
          } catch (e) {
            print('Warning: Failed to store image ${i + 1} locally: $e');
          }
        }

        print(
            'Debug: Successfully stored ${localPaths.length}/${imageFiles.length} images locally');
        return localPaths;
      }

      // Delete existing images if provided
      if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
        for (final imageUrl in existingImageUrls) {
          await _deleteImageFromUrl(imageUrl);
        }
      }

      final List<String> uploadedUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        print('Debug: Uploading image ${i + 1}/${imageFiles.length}');

        try {
          final url = await uploadImage(imageFile: imageFile);
          if (url != null) {
            uploadedUrls.add(url);
          }
        } catch (e) {
          print('Warning: Failed to upload image ${i + 1}: $e');
          // Continue with other images even if one fails
        }
      }

      print(
          'Debug: Successfully uploaded ${uploadedUrls.length}/${imageFiles.length} images');
      return uploadedUrls;
    } catch (e) {
      print('Error uploading multiple images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Delete image from storage using URL
  static Future<void> _deleteImageFromUrl(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      // Find the bucket name and file path
      final bucketIndex = segments.indexOf(_bucketName);
      if (bucketIndex >= 0 && bucketIndex < segments.length - 1) {
        final filePath = segments.sublist(bucketIndex + 1).join('/');
        print('Debug: Deleting existing image: $filePath');

        await _supabase.storage.from(_bucketName).remove([filePath]);

        print('Debug: Existing image deleted successfully');
      }
    } catch (e) {
      print('Warning: Failed to delete existing image: $e');
      // Don't throw error as this shouldn't block the new upload
    }
  }

  /// Delete image using file path
  static Future<void> deleteImage(String filePath) async {
    try {
      await _supabase.storage.from(_bucketName).remove([filePath]);
      print('Debug: Image deleted: $filePath');
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Simple image compression
  static Future<Uint8List> _compressImage(
      Uint8List imageBytes, String fileExtension) async {
    try {
      // For now, implement basic compression by reducing quality
      // In a production app, you might want to use a proper image compression library

      // Simple approach: if image is very large, take a sample
      if (imageBytes.length > 5 * 1024 * 1024) {
        // 5MB
        // Take every 2nd byte for extreme compression
        final compressed = <int>[];
        for (int i = 0; i < imageBytes.length; i += 2) {
          compressed.add(imageBytes[i]);
        }
        return Uint8List.fromList(compressed);
      } else if (imageBytes.length > 3 * 1024 * 1024) {
        // 3MB
        // Take every 1.5th byte
        final compressed = <int>[];
        for (int i = 0; i < imageBytes.length; i += 3) {
          compressed.add(imageBytes[i]);
          if (i + 1 < imageBytes.length) compressed.add(imageBytes[i + 1]);
        }
        return Uint8List.fromList(compressed);
      }

      return imageBytes; // Return as-is if not too large
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes; // Return original if compression fails
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Initialize storage bucket (call this during app initialization)
  static Future<void> initializeStorage() async {
    try {
      // Check if bucket exists, create if it doesn't
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        print('Debug: Creating storage bucket: $_bucketName');
        await _supabase.storage.createBucket(
          _bucketName,
          const BucketOptions(
            public: true,
            allowedMimeTypes: [
              'image/jpeg',
              'image/png',
              'image/gif',
              'image/webp'
            ],
            fileSizeLimit: '10MB', // 10MB limit
          ),
        );
        print('Debug: Storage bucket created successfully');
      } else {
        print('Debug: Storage bucket already exists');
      }
    } catch (e) {
      print('Error initializing storage: $e');
      // Don't throw error as the bucket might already exist
    }
  }

  /// Get a placeholder image URL for products without images
  static String getPlaceholderImageUrl() {
    return 'https://via.placeholder.com/400x300/f0f0f0/999999?text=No+Image';
  }

  /// Validate if the file is a supported image format
  static bool isValidImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Get file size in MB
  static double getFileSizeInMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  /// Store image locally when offline
  static Future<String?> _storeImageLocally(XFile imageFile) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final localImagesDir =
          Directory(path.join(appDir.path, _localImageFolder));

      // Create directory if it doesn't exist
      if (!await localImagesDir.exists()) {
        await localImagesDir.create(recursive: true);
      }

      // Generate unique filename
      const uuid = Uuid();
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${uuid.v4()}.$fileExtension';
      final localPath = path.join(localImagesDir.path, fileName);

      // Copy image to local storage
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
        final localFile = File(localPath);
        await localFile.writeAsBytes(imageBytes);
      } else {
        final sourceFile = File(imageFile.path);
        await sourceFile.copy(localPath);
      }

      print('Debug: Stored image locally at: $localPath');
      return 'local://$localPath'; // Use local:// prefix to identify local images
    } catch (e) {
      print('Error storing image locally: $e');
      return null;
    }
  }

  /// Upload locally stored images to Supabase when online
  static Future<List<String>> syncLocalImages(List<String> localPaths) async {
    final List<String> uploadedUrls = [];

    for (final localPath in localPaths) {
      if (localPath.startsWith('local://')) {
        try {
          final filePath = localPath.substring(8); // Remove 'local://' prefix
          final file = File(filePath);

          if (await file.exists()) {
            // Create XFile from local file
            final xFile = XFile(filePath);

            // Upload to Supabase
            final url = await uploadImage(imageFile: xFile);
            if (url != null) {
              uploadedUrls.add(url);

              // Delete local file after successful upload
              await file.delete();
              print('Debug: Uploaded and deleted local image: $filePath');
            }
          }
        } catch (e) {
          print('Error syncing local image $localPath: $e');
        }
      } else {
        // Already a remote URL, keep as is
        uploadedUrls.add(localPath);
      }
    }

    return uploadedUrls;
  }

  /// Check if a path is a local image
  static bool isLocalImage(String imagePath) {
    return imagePath.startsWith('local://');
  }

  /// Get display path for local images
  static String getDisplayPath(String imagePath) {
    if (isLocalImage(imagePath)) {
      return imagePath.substring(8); // Remove 'local://' prefix
    }
    return imagePath;
  }
}
