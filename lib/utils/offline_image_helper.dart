import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_upload_service.dart';

class OfflineImageHelper {
  /// Check if an image URL is local and display appropriate widget
  static Widget buildImageWidget(String imageUrl,
      {double? width, double? height, BoxFit? fit}) {
    if (ImageUploadService.isLocalImage(imageUrl)) {
      // Display local image with offline indicator
      final localPath = ImageUploadService.getDisplayPath(imageUrl);
      return Stack(
        children: [
          Image.file(
            File(localPath),
            width: width,
            height: height,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
          // Offline indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Offline',
                    style: TextStyle(
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
    } else {
      // Display remote image normally
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }

  /// Get a readable status for image sync
  static String getImageSyncStatus(List<String> imageUrls) {
    final localImages =
        imageUrls.where((url) => ImageUploadService.isLocalImage(url)).length;
    final totalImages = imageUrls.length;

    if (localImages == 0) {
      return 'All images synced';
    } else if (localImages == totalImages) {
      return 'All images stored locally';
    } else {
      return '$localImages/$totalImages images pending sync';
    }
  }

  /// Show a dialog explaining offline image functionality
  static void showOfflineImageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Offline Image Storage'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When you\'re offline, images are stored locally on your device:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Images are saved to local storage immediately'),
              Text('• Products can be created without internet connection'),
              Text('• Local images are marked with an "Offline" badge'),
              Text('• Images sync to cloud storage when internet returns'),
              Text('• Local images are deleted after successful sync'),
              SizedBox(height: 12),
              Text(
                'This ensures you can continue working even without internet access!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}
