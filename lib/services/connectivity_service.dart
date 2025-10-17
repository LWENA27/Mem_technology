import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityResult _connectionType = ConnectivityResult.none;
  ConnectivityResult get connectionType => _connectionType;

  Timer? _syncTimer;
  Timer? _checkTimer;

  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('Connectivity stream error: $error');
        },
      );

      // Set up periodic connectivity checks (backup)
      _startPeriodicCheck();

      // Set up periodic sync when online
      _startPeriodicSync();

      debugPrint('ConnectivityService initialized - isOnline: $_isOnline');
    } catch (e) {
      debugPrint('Failed to initialize ConnectivityService: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    final previousConnectionType = _connectionType;

    // Determine if we're online and what type of connection
    _connectionType =
        results.isNotEmpty ? results.first : ConnectivityResult.none;
    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    debugPrint(
        'Connectivity changed: wasOnline=$wasOnline, isOnline=$_isOnline, type=$_connectionType');

    // Notify listeners if status changed
    if (_isOnline != wasOnline || _connectionType != previousConnectionType) {
      notifyListeners();

      if (_isOnline && !wasOnline) {
        // Trigger sync when coming back online
        debugPrint('Device came online, triggering sync...');
        _triggerSync();
      }
    }
  }

  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final result = await _connectivity.checkConnectivity();
        _updateConnectionStatus(result);
      } catch (e) {
        debugPrint('Periodic connectivity check failed: $e');
      }
    });
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline) {
        debugPrint('Periodic sync trigger...');
        _triggerSync();
      }
    });
  }

  void _triggerSync() {
    // Import here to avoid circular dependency
    try {
      // We'll implement this in the sync service
      Future.delayed(const Duration(seconds: 1), () {
        // This will be called from SyncService
      });
    } catch (e) {
      debugPrint('Failed to trigger sync: $e');
    }
  }

  String get connectionStatusText {
    if (!_isOnline) return 'Offline';

    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'Connected';
    }
  }

  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  bool get isMobile => _connectionType == ConnectivityResult.mobile;
  bool get isEthernet => _connectionType == ConnectivityResult.ethernet;

  // Manual connectivity check
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isOnline;
    } catch (e) {
      debugPrint('Manual connectivity check failed: $e');
      return false;
    }
  }

  // Force sync trigger (can be called from UI)
  void triggerManualSync() {
    if (_isOnline) {
      debugPrint('Manual sync triggered');
      _triggerSync();
    } else {
      debugPrint('Cannot sync: device is offline');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _syncTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }
}
