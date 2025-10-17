import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates a web database connection using IndexedDB.
DatabaseConnection createDatabaseConnection() {
  return DatabaseConnection(WebDatabase('lwenatech_offline_db'));
}
