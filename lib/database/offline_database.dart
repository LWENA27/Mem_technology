import 'package:drift/drift.dart';
import 'database_connection/shared.dart';

part 'offline_database.g.dart';

// Define tables
@DataClassName('OfflineProduct')
class OfflineProducts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  TextColumn get imageUrls => text().map(const StringListConverter())();
  TextColumn get sku => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction =>
      text().nullable()(); // 'create', 'update', 'delete'
  TextColumn get tenantId => text()(); // For multi-tenant support

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineSale')
class OfflineSales extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalAmount => real()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get customerEmail => text().nullable()();
  DateTimeColumn get saleDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  TextColumn get tenantId => text()(); // For multi-tenant support
  TextColumn get userId => text()(); // Who made the sale

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineUser')
class OfflineUsers extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text().nullable()();
  TextColumn get role => text()();
  DateTimeColumn get lastLogin => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get tenantId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineCategory')
class OfflineCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().nullable()();
  TextColumn get tenantId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineSupplier')
class OfflineSuppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().nullable()();
  TextColumn get tenantId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sync queue for tracking changes
@DataClassName('SyncQueueItem')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordTableName =>
      text()(); // Changed from tableName to avoid conflict
  TextColumn get recordId => text()();
  TextColumn get action => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text().nullable()(); // JSON data
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get tenantId => text()();
}

// Custom converter for string lists
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(tables: [
  OfflineProducts,
  OfflineSales,
  OfflineUsers,
  OfflineCategories,
  OfflineSuppliers,
  SyncQueue
])
class OfflineDatabase extends _$OfflineDatabase {
  // Singleton pattern to prevent multiple database instances
  static OfflineDatabase? _instance;
  static OfflineDatabase get instance {
    _instance ??= OfflineDatabase._internal();
    return _instance!;
  }

  OfflineDatabase._internal() : super(connect());

  // Factory constructor that returns the singleton instance
  factory OfflineDatabase() => instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  // Product operations
  Future<List<OfflineProduct>> getAllProducts({String? tenantId}) {
    final query = select(offlineProducts);
    if (tenantId != null) {
      query.where((p) => p.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<OfflineProduct?> getProduct(String id) =>
      (select(offlineProducts)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertProduct(OfflineProduct product) =>
      into(offlineProducts).insert(product);

  Future<void> updateProduct(OfflineProduct product) =>
      update(offlineProducts).replace(product);

  Future<void> deleteProduct(String id) =>
      (delete(offlineProducts)..where((p) => p.id.equals(id))).go();

  Future<List<OfflineProduct>> searchProducts(String query,
      {String? tenantId}) {
    final searchQuery = select(offlineProducts)
      ..where((p) =>
          p.name.contains(query) |
          p.description.contains(query) |
          p.sku.contains(query));

    if (tenantId != null) {
      searchQuery.where((p) => p.tenantId.equals(tenantId));
    }

    return searchQuery.get();
  }

  Future<List<OfflineProduct>> getProductsByCategory(String category,
      {String? tenantId}) {
    final query = select(offlineProducts)
      ..where((p) => p.category.equals(category));
    if (tenantId != null) {
      query.where((p) => p.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<List<OfflineProduct>> getLowStockProducts({String? tenantId}) async {
    final allProducts = await getAllProducts(tenantId: tenantId);
    return allProducts.where((p) => p.quantity <= p.minStock).toList();
  }

  // Sales operations
  Future<List<OfflineSale>> getAllSales({String? tenantId}) {
    final query = select(offlineSales)
      ..orderBy([(s) => OrderingTerm.desc(s.saleDate)]);
    if (tenantId != null) {
      query.where((s) => s.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<void> insertSale(OfflineSale sale) => into(offlineSales).insert(sale);

  Future<OfflineSale?> getSale(String id) async {
    final query = select(offlineSales)..where((s) => s.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<OfflineSale>> getSalesByDateRange(DateTime start, DateTime end,
      {String? tenantId}) {
    final query = select(offlineSales)
      ..where((s) => s.saleDate.isBetweenValues(start, end))
      ..orderBy([(s) => OrderingTerm.desc(s.saleDate)]);

    if (tenantId != null) {
      query.where((s) => s.tenantId.equals(tenantId));
    }

    return query.get();
  }

  Future<double> getTotalSalesAmount(
      {String? tenantId, DateTime? startDate, DateTime? endDate}) async {
    final query = selectOnly(offlineSales)
      ..addColumns([offlineSales.totalAmount.sum()]);

    if (tenantId != null) {
      query.where(offlineSales.tenantId.equals(tenantId));
    }

    if (startDate != null && endDate != null) {
      query.where(offlineSales.saleDate.isBetweenValues(startDate, endDate));
    }

    final result = await query.getSingle();
    return result.read(offlineSales.totalAmount.sum()) ?? 0.0;
  }

  // Category operations
  Future<List<OfflineCategory>> getAllCategories({String? tenantId}) {
    final query = select(offlineCategories);
    if (tenantId != null) {
      query.where((c) => c.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<void> insertCategory(OfflineCategory category) =>
      into(offlineCategories).insert(category);

  Future<void> updateCategory(OfflineCategory category) =>
      update(offlineCategories).replace(category);

  Future<void> deleteCategory(String id) =>
      (delete(offlineCategories)..where((c) => c.id.equals(id))).go();

  // Supplier operations
  Future<List<OfflineSupplier>> getAllSuppliers({String? tenantId}) {
    final query = select(offlineSuppliers);
    if (tenantId != null) {
      query.where((s) => s.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<void> insertSupplier(OfflineSupplier supplier) =>
      into(offlineSuppliers).insert(supplier);

  Future<void> updateSupplier(OfflineSupplier supplier) =>
      update(offlineSuppliers).replace(supplier);

  Future<void> deleteSupplier(String id) =>
      (delete(offlineSuppliers)..where((s) => s.id.equals(id))).go();

  // Sync operations
  Future<void> markForSync(String tableName, String recordId, String action,
      {String? data, String? tenantId}) async {
    await into(syncQueue).insert(SyncQueueCompanion.insert(
      recordTableName: tableName,
      recordId: recordId,
      action: action,
      data: data != null ? Value(data) : const Value(null),
      createdAt: DateTime.now(),
      tenantId: tenantId ?? '',
    ));
  }

  Future<List<SyncQueueItem>> getPendingSyncItems({String? tenantId}) {
    final query = select(syncQueue)
      ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]);
    if (tenantId != null) {
      query.where((s) => s.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<void> removeSyncItem(int id) =>
      (delete(syncQueue)..where((s) => s.id.equals(id))).go();

  Future<void> incrementRetryCount(int id, String errorMessage) async {
    final item =
        await (select(syncQueue)..where((s) => s.id.equals(id))).getSingle();
    await update(syncQueue).replace(item.copyWith(
      retryCount: item.retryCount + 1,
      errorMessage: const Value(null),
    ));
  }

  // Utility operations
  Future<void> clearAllData() async {
    await delete(offlineProducts).go();
    await delete(offlineSales).go();
    await delete(offlineCategories).go();
    await delete(offlineSuppliers).go();
    await delete(syncQueue).go();
  }

  Future<Map<String, int>> getDataCounts({String? tenantId}) async {
    int productCount = 0;
    int salesCount = 0;
    int categoryCount = 0;
    int supplierCount = 0;
    int pendingSyncCount = 0;

    if (tenantId != null) {
      productCount = await (selectOnly(offlineProducts)
            ..addColumns([offlineProducts.id.count()])
            ..where(offlineProducts.tenantId.equals(tenantId)))
          .getSingle()
          .then((r) => r.read(offlineProducts.id.count()) ?? 0);

      salesCount = await (selectOnly(offlineSales)
            ..addColumns([offlineSales.id.count()])
            ..where(offlineSales.tenantId.equals(tenantId)))
          .getSingle()
          .then((r) => r.read(offlineSales.id.count()) ?? 0);

      categoryCount = await (selectOnly(offlineCategories)
            ..addColumns([offlineCategories.id.count()])
            ..where(offlineCategories.tenantId.equals(tenantId)))
          .getSingle()
          .then((r) => r.read(offlineCategories.id.count()) ?? 0);

      supplierCount = await (selectOnly(offlineSuppliers)
            ..addColumns([offlineSuppliers.id.count()])
            ..where(offlineSuppliers.tenantId.equals(tenantId)))
          .getSingle()
          .then((r) => r.read(offlineSuppliers.id.count()) ?? 0);

      pendingSyncCount = await (selectOnly(syncQueue)
            ..addColumns([syncQueue.id.count()])
            ..where(syncQueue.tenantId.equals(tenantId)))
          .getSingle()
          .then((r) => r.read(syncQueue.id.count()) ?? 0);
    } else {
      productCount = await (selectOnly(offlineProducts)
            ..addColumns([offlineProducts.id.count()]))
          .getSingle()
          .then((r) => r.read(offlineProducts.id.count()) ?? 0);

      salesCount = await (selectOnly(offlineSales)
            ..addColumns([offlineSales.id.count()]))
          .getSingle()
          .then((r) => r.read(offlineSales.id.count()) ?? 0);

      categoryCount = await (selectOnly(offlineCategories)
            ..addColumns([offlineCategories.id.count()]))
          .getSingle()
          .then((r) => r.read(offlineCategories.id.count()) ?? 0);

      supplierCount = await (selectOnly(offlineSuppliers)
            ..addColumns([offlineSuppliers.id.count()]))
          .getSingle()
          .then((r) => r.read(offlineSuppliers.id.count()) ?? 0);

      pendingSyncCount = await (selectOnly(syncQueue)
            ..addColumns([syncQueue.id.count()]))
          .getSingle()
          .then((r) => r.read(syncQueue.id.count()) ?? 0);
    }

    return {
      'products': productCount,
      'sales': salesCount,
      'categories': categoryCount,
      'suppliers': supplierCount,
      'pendingSync': pendingSyncCount,
    };
  }
}
