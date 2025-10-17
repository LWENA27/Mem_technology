import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../widgets/offline_indicator.dart';
import '../utils/offline_image_helper.dart';

class OfflineDemoScreen extends StatefulWidget {
  const OfflineDemoScreen({super.key});

  @override
  State<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
}

class _OfflineDemoScreenState extends State<OfflineDemoScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _connectivityService.addListener(_onConnectivityChanged);
    _syncService.addListener(_onSyncStatusChanged);
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _syncService.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    setState(() {});
  }

  void _onSyncStatusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Functionality Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => OfflineImageHelper.showOfflineImageInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator widget
          const OfflineIndicator(),

          // Connection status
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _connectivityService.isOnline
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: _connectivityService.isOnline
                    ? Colors.green
                    : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _connectivityService.isOnline
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: _connectivityService.isOnline
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _connectivityService.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _connectivityService.isOnline
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _connectivityService.isOnline
                      ? 'Connected to the internet. Data syncs automatically.'
                      : 'No internet connection. Data is stored locally and will sync when connection is restored.',
                ),
              ],
            ),
          ),

          // Sync status
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _syncService.isSyncing ? Icons.sync : Icons.sync_disabled,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sync Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Status: ${_syncService.syncStatus}'),
                if (_syncService.totalPendingItems > 0) ...[
                  const SizedBox(height: 4),
                  Text('Pending items: ${_syncService.totalPendingItems}'),
                ],
                if (_syncService.lastSyncTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      'Last sync: ${_formatLastSync(_syncService.lastSyncTime!)}'),
                ],
              ],
            ),
          ),

          // Instructions
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Test Offline Functionality:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _InstructionStep(
                    number: 1,
                    title: 'Ensure you\'re online first',
                    description: 'Make sure the app is connected and synced.',
                  ),
                  _InstructionStep(
                    number: 2,
                    title: 'Turn off internet/WiFi',
                    description:
                        'Disable your internet connection in device settings.',
                  ),
                  _InstructionStep(
                    number: 3,
                    title: 'Add a product with images',
                    description:
                        'Use the + button to add a new product with photos. Images will be stored locally.',
                  ),
                  _InstructionStep(
                    number: 4,
                    title: 'Turn internet back on',
                    description: 'Re-enable your internet connection.',
                  ),
                  _InstructionStep(
                    number: 5,
                    title: 'Watch automatic sync',
                    description:
                        'The app will automatically sync your offline data and upload images to the cloud.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
