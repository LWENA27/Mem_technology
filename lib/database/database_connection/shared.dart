import 'package:drift/drift.dart';

import 'stub.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'native.dart';

DatabaseConnection connect() {
  return createDatabaseConnection();
}
