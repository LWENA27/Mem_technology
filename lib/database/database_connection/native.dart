import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Creates a native database connection for mobile and desktop platforms.
DatabaseConnection createDatabaseConnection() {
  return DatabaseConnection.delayed(Future(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'lwenatech_offline.db'));
      return DatabaseConnection(NativeDatabase.createInBackground(file));
    } catch (e) {
      // Fallback for platforms where path_provider might not work
      return DatabaseConnection(NativeDatabase.memory());
    }
  }));
}
