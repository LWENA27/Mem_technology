import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late ConnectivityService _connectivityService;
  late SyncService _syncService;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _syncService = SyncService();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _connectivityService.addListener(_onConnectivityChanged);
    _syncService.addListener(_onSyncStatusChanged);

    // Start animation if should show indicator
    if (_shouldShowIndicator()) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _syncService.removeListener(_onSyncStatusChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onConnectivityChanged() {
    setState(() {
      if (_shouldShowIndicator()) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onSyncStatusChanged() {
    setState(() {});
  }

  bool _shouldShowIndicator() {
    return !_connectivityService.isOnline ||
        _syncService.isSyncing ||
        _syncService.totalPendingItems > 0;
  }

  Color _getIndicatorColor() {
    if (_syncService.isSyncing) return Colors.blue;
    if (!_connectivityService.isOnline) return Colors.orange;
    if (_syncService.totalPendingItems > 0) return Colors.amber;
    return Colors.green;
  }

  IconData _getIndicatorIcon() {
    if (_syncService.isSyncing) return Icons.sync;
    if (!_connectivityService.isOnline) return Icons.wifi_off;
    if (_syncService.totalPendingItems > 0) return Icons.cloud_upload;
    return Icons.wifi;
  }

  String _getIndicatorText() {
    if (_syncService.isSyncing) {
      if (_syncService.totalPendingItems > 0) {
        return 'Syncing ${_syncService.syncedItems}/${_syncService.totalPendingItems}...';
      }
      return _syncService.syncStatus;
    }

    if (!_connectivityService.isOnline) {
      final pendingText = _syncService.totalPendingItems > 0
          ? ' (${_syncService.totalPendingItems} pending)'
          : '';
      return 'Working offline$pendingText';
    }

    if (_syncService.totalPendingItems > 0) {
      return '${_syncService.totalPendingItems} items to sync';
    }

    return 'Connected (${_connectivityService.connectionStatusText})';
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _getIndicatorColor(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_syncService.isSyncing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      value: _syncService.totalPendingItems > 0
                          ? _syncService.syncedItems /
                              _syncService.totalPendingItems
                          : null,
                    ),
                  )
                else
                  Icon(
                    _getIndicatorIcon(),
                    size: 16,
                    color: Colors.white,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getIndicatorText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_connectivityService.isOnline && !_syncService.isSyncing)
                  GestureDetector(
                    onTap: () {
                      _syncService.triggerManualSync();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Sync',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sync Status Dialog for detailed information
class SyncStatusDialog extends StatelessWidget {
  const SyncStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSyncInfo(),
          const SizedBox(height: 16),
          _buildConnectionInfo(),
          const SizedBox(height: 16),
          _buildLastSyncInfo(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (ConnectivityService().isOnline && !SyncService().isSyncing)
          ElevatedButton(
            onPressed: () {
              SyncService().triggerManualSync();
              Navigator.of(context).pop();
            },
            child: const Text('Sync Now'),
          ),
      ],
    );
  }

  Widget _buildSyncInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: ${SyncService().syncStatus}'),
            Text('Pending Items: ${SyncService().totalPendingItems}'),
            if (SyncService().isSyncing)
              Text(
                  'Progress: ${SyncService().syncedItems}/${SyncService().totalPendingItems}'),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionInfo() {
    final connectivity = ConnectivityService();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: connectivity.isOnline ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(connectivity.connectionStatusText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncInfo() {
    final lastSync = SyncService().lastSyncTime;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Sync',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lastSync != null ? _formatDateTime(lastSync) : 'Never',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

// Floating action button for sync
class SyncFloatingActionButton extends StatelessWidget {
  const SyncFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ConnectivityService(),
        SyncService(),
      ]),
      builder: (context, child) {
        final connectivity = ConnectivityService();
        final sync = SyncService();

        if (!connectivity.isOnline) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.small(
          onPressed: sync.isSyncing
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (context) => const SyncStatusDialog(),
                  );
                },
          backgroundColor:
              sync.totalPendingItems > 0 ? Colors.orange : Colors.green,
          child: sync.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  sync.totalPendingItems > 0
                      ? Icons.cloud_upload
                      : Icons.cloud_done,
                  color: Colors.white,
                ),
        );
      },
    );
  }
}
