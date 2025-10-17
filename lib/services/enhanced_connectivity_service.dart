import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/enhanced_feedback_widget.dart';

class EnhancedConnectivityService {
  static final EnhancedConnectivityService _instance =
      EnhancedConnectivityService._internal();
  factory EnhancedConnectivityService() => _instance;
  EnhancedConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  BuildContext? _context;
  bool _wasOffline = false;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isOnline =>
      _connectionStatus.any((result) => result != ConnectivityResult.none);
  bool get hasShownOfflineMessage => _wasOffline;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> initialize() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('Connectivity service error: $error');
        },
      );
      debugPrint('ConnectivityService initialized - isOnline: $isOnline');
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = isOnline;
    _connectionStatus = results;

    debugPrint(
        'Connectivity changed: wasOnline=$wasOnline, isOnline=$isOnline, types=$results');

    // Show user feedback for network changes
    if (_context != null) {
      if (!wasOnline && isOnline) {
        // Just came back online
        EnhancedFeedbackWidget.showNetworkChangeSnackBar(_context!, true);
        _wasOffline = false;
      } else if (wasOnline && !isOnline) {
        // Just went offline
        EnhancedFeedbackWidget.showNetworkChangeSnackBar(_context!, false);
        _wasOffline = true;
      }
    }
  }

  Future<bool> checkConnection() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      return isOnline;
    } catch (e) {
      debugPrint('Error checking connection: $e');
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _context = null;
  }

  // Helper method to execute network operations with proper error handling
  Future<T> executeWithNetworkFeedback<T>({
    required Future<T> Function() onlineOperation,
    required Future<T> Function() offlineOperation,
    required BuildContext context,
    String? loadingMessage,
    bool showLoadingDialog = false,
  }) async {
    if (showLoadingDialog && loadingMessage != null) {
      EnhancedFeedbackWidget.showLoadingDialog(context, loadingMessage);
    }

    try {
      if (isOnline) {
        try {
          final result = await onlineOperation();
          if (showLoadingDialog) {
            EnhancedFeedbackWidget.hideLoadingDialog(context);
          }
          return result;
        } catch (e) {
          debugPrint('Online operation failed, falling back to offline: $e');
          // Fall through to offline operation
        }
      }

      final result = await offlineOperation();
      if (showLoadingDialog) {
        EnhancedFeedbackWidget.hideLoadingDialog(context);
      }

      if (!isOnline && !_wasOffline) {
        EnhancedFeedbackWidget.showInfoSnackBar(
            context, 'Working offline - changes will sync when connected');
        _wasOffline = true;
      }

      return result;
    } catch (e) {
      if (showLoadingDialog) {
        EnhancedFeedbackWidget.hideLoadingDialog(context);
      }

      final errorMessage = EnhancedFeedbackWidget.getErrorMessage(e);
      EnhancedFeedbackWidget.showErrorSnackBar(context, errorMessage,
          isLong: true);
      rethrow;
    }
  }
}
