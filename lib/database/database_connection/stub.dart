import 'package:drift/drift.dart';

/// This stub method is used as a fallback if no platform-specific implementation is available.
DatabaseConnection createDatabaseConnection() {
  throw UnsupportedError(
    'No suitable database implementation found for this platform.',
  );
}
