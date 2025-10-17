import 'package:flutter/foundation.dart';

class SecureErrorHandler {
  /// Converts technical errors into user-friendly messages while hiding sensitive information
  static String getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network connectivity errors
    if (errorString.contains('socketexception') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection') ||
        errorString.contains('host lookup') ||
        errorString.contains('no address associated')) {
      return 'Network connection issue. Please check your internet and try again.';
    }

    // Database/Storage errors
    if (errorString.contains('supabase') ||
        errorString.contains('database') ||
        errorString.contains('storage') ||
        errorString.contains('postgresql')) {
      return 'Database connection issue. Working in offline mode.';
    }

    // Authentication errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('authentication') ||
        errorString.contains('invalid_grant') ||
        errorString.contains('access denied')) {
      return 'Authentication error. Please log in again.';
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('deadline exceeded')) {
      return 'Request timed out. Please try again.';
    }

    // Permission errors
    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('row-level security')) {
      return 'Permission denied. Please contact support.';
    }

    // File/Image errors
    if (errorString.contains('file') ||
        errorString.contains('image') ||
        errorString.contains('upload')) {
      return 'File operation failed. Please try again.';
    }

    // Validation errors
    if (errorString.contains('validation') ||
        errorString.contains('invalid format') ||
        errorString.contains('required field')) {
      return 'Please check your input and try again.';
    }

    // Generic fallback - hide all technical details
    return 'An unexpected error occurred. Please try again.';
  }

  /// Logs the full error for debugging while showing safe message to user
  static void logError(String context, dynamic error,
      [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🔍 DEBUG ERROR [$context]: $error');
      if (stackTrace != null) {
        print('📋 STACK TRACE: $stackTrace');
      }
    }
    // In production, this would send to crash reporting service
  }

  /// Combined method to log full error and return user-friendly message
  static String handleError(String context, dynamic error,
      [StackTrace? stackTrace]) {
    logError(context, error, stackTrace);
    return getUserFriendlyError(error);
  }
}
