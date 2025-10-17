// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_database.dart';

// ignore_for_file: type=lint
class $OfflineProductsTable extends OfflineProducts
    with TableInfo<$OfflineProductsTable, OfflineProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _minStockMeta =
      const VerificationMeta('minStock');
  @override
  late final GeneratedColumn<int> minStock = GeneratedColumn<int>(
      'min_stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> imageUrls =
      GeneratedColumn<String>('image_urls', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(
              $OfflineProductsTable.$converterimageUrls);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncActionMeta =
      const VerificationMeta('syncAction');
  @override
  late final GeneratedColumn<String> syncAction = GeneratedColumn<String>(
      'sync_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        description,
        price,
        quantity,
        minStock,
        imageUrls,
        sku,
        isActive,
        createdAt,
        updatedAt,
        needsSync,
        syncAction,
        tenantId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_products';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineProduct> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('min_stock')) {
      context.handle(_minStockMeta,
          minStock.isAcceptableOrUnknown(data['min_stock']!, _minStockMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('sync_action')) {
      context.handle(
          _syncActionMeta,
          syncAction.isAcceptableOrUnknown(
              data['sync_action']!, _syncActionMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineProduct(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      minStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_stock'])!,
      imageUrls: $OfflineProductsTable.$converterimageUrls.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}image_urls'])!),
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      syncAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_action']),
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
    );
  }

  @override
  $OfflineProductsTable createAlias(String alias) {
    return $OfflineProductsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterimageUrls =
      const StringListConverter();
}

class OfflineProduct extends DataClass implements Insertable<OfflineProduct> {
  final String id;
  final String name;
  final String category;
  final String? description;
  final double price;
  final int quantity;
  final int minStock;
  final List<String> imageUrls;
  final String? sku;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final String? syncAction;
  final String tenantId;
  const OfflineProduct(
      {required this.id,
      required this.name,
      required this.category,
      this.description,
      required this.price,
      required this.quantity,
      required this.minStock,
      required this.imageUrls,
      this.sku,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.needsSync,
      this.syncAction,
      required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['quantity'] = Variable<int>(quantity);
    map['min_stock'] = Variable<int>(minStock);
    {
      map['image_urls'] = Variable<String>(
          $OfflineProductsTable.$converterimageUrls.toSql(imageUrls));
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || syncAction != null) {
      map['sync_action'] = Variable<String>(syncAction);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  OfflineProductsCompanion toCompanion(bool nullToAbsent) {
    return OfflineProductsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      quantity: Value(quantity),
      minStock: Value(minStock),
      imageUrls: Value(imageUrls),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      needsSync: Value(needsSync),
      syncAction: syncAction == null && nullToAbsent
          ? const Value.absent()
          : Value(syncAction),
      tenantId: Value(tenantId),
    );
  }

  factory OfflineProduct.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineProduct(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      quantity: serializer.fromJson<int>(json['quantity']),
      minStock: serializer.fromJson<int>(json['minStock']),
      imageUrls: serializer.fromJson<List<String>>(json['imageUrls']),
      sku: serializer.fromJson<String?>(json['sku']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      syncAction: serializer.fromJson<String?>(json['syncAction']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'quantity': serializer.toJson<int>(quantity),
      'minStock': serializer.toJson<int>(minStock),
      'imageUrls': serializer.toJson<List<String>>(imageUrls),
      'sku': serializer.toJson<String?>(sku),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'syncAction': serializer.toJson<String?>(syncAction),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  OfflineProduct copyWith(
          {String? id,
          String? name,
          String? category,
          Value<String?> description = const Value.absent(),
          double? price,
          int? quantity,
          int? minStock,
          List<String>? imageUrls,
          Value<String?> sku = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? needsSync,
          Value<String?> syncAction = const Value.absent(),
          String? tenantId}) =>
      OfflineProduct(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        description: description.present ? description.value : this.description,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        minStock: minStock ?? this.minStock,
        imageUrls: imageUrls ?? this.imageUrls,
        sku: sku.present ? sku.value : this.sku,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        needsSync: needsSync ?? this.needsSync,
        syncAction: syncAction.present ? syncAction.value : this.syncAction,
        tenantId: tenantId ?? this.tenantId,
      );
  OfflineProduct copyWithCompanion(OfflineProductsCompanion data) {
    return OfflineProduct(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      price: data.price.present ? data.price.value : this.price,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      minStock: data.minStock.present ? data.minStock.value : this.minStock,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      sku: data.sku.present ? data.sku.value : this.sku,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      syncAction:
          data.syncAction.present ? data.syncAction.value : this.syncAction,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineProduct(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('minStock: $minStock, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('sku: $sku, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      description,
      price,
      quantity,
      minStock,
      imageUrls,
      sku,
      isActive,
      createdAt,
      updatedAt,
      needsSync,
      syncAction,
      tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineProduct &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.description == this.description &&
          other.price == this.price &&
          other.quantity == this.quantity &&
          other.minStock == this.minStock &&
          other.imageUrls == this.imageUrls &&
          other.sku == this.sku &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.needsSync == this.needsSync &&
          other.syncAction == this.syncAction &&
          other.tenantId == this.tenantId);
}

class OfflineProductsCompanion extends UpdateCompanion<OfflineProduct> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> description;
  final Value<double> price;
  final Value<int> quantity;
  final Value<int> minStock;
  final Value<List<String>> imageUrls;
  final Value<String?> sku;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> needsSync;
  final Value<String?> syncAction;
  final Value<String> tenantId;
  final Value<int> rowid;
  const OfflineProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minStock = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.sku = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineProductsCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.description = const Value.absent(),
    required double price,
    required int quantity,
    this.minStock = const Value.absent(),
    required List<String> imageUrls,
    this.sku = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    required String tenantId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        price = Value(price),
        quantity = Value(quantity),
        imageUrls = Value(imageUrls),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        tenantId = Value(tenantId);
  static Insertable<OfflineProduct> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? price,
    Expression<int>? quantity,
    Expression<int>? minStock,
    Expression<String>? imageUrls,
    Expression<String>? sku,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? needsSync,
    Expression<String>? syncAction,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (minStock != null) 'min_stock': minStock,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (sku != null) 'sku': sku,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (syncAction != null) 'sync_action': syncAction,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String?>? description,
      Value<double>? price,
      Value<int>? quantity,
      Value<int>? minStock,
      Value<List<String>>? imageUrls,
      Value<String?>? sku,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? needsSync,
      Value<String?>? syncAction,
      Value<String>? tenantId,
      Value<int>? rowid}) {
    return OfflineProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      imageUrls: imageUrls ?? this.imageUrls,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      syncAction: syncAction ?? this.syncAction,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (minStock.present) {
      map['min_stock'] = Variable<int>(minStock.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(
          $OfflineProductsTable.$converterimageUrls.toSql(imageUrls.value));
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (syncAction.present) {
      map['sync_action'] = Variable<String>(syncAction.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('minStock: $minStock, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('sku: $sku, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineSalesTable extends OfflineSales
    with TableInfo<$OfflineSalesTable, OfflineSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerEmailMeta =
      const VerificationMeta('customerEmail');
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
      'customer_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        quantity,
        unitPrice,
        totalAmount,
        customerName,
        customerPhone,
        customerEmail,
        saleDate,
        createdAt,
        needsSync,
        tenantId,
        userId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_sales';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineSale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('customer_email')) {
      context.handle(
          _customerEmailMeta,
          customerEmail.isAcceptableOrUnknown(
              data['customer_email']!, _customerEmailMeta));
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name']),
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      customerEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_email']),
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sale_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
    );
  }

  @override
  $OfflineSalesTable createAlias(String alias) {
    return $OfflineSalesTable(attachedDatabase, alias);
  }
}

class OfflineSale extends DataClass implements Insertable<OfflineSale> {
  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final DateTime saleDate;
  final DateTime createdAt;
  final bool needsSync;
  final String tenantId;
  final String userId;
  const OfflineSale(
      {required this.id,
      required this.productId,
      required this.quantity,
      required this.unitPrice,
      required this.totalAmount,
      this.customerName,
      this.customerPhone,
      this.customerEmail,
      required this.saleDate,
      required this.createdAt,
      required this.needsSync,
      required this.tenantId,
      required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_amount'] = Variable<double>(totalAmount);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || customerEmail != null) {
      map['customer_email'] = Variable<String>(customerEmail);
    }
    map['sale_date'] = Variable<DateTime>(saleDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['tenant_id'] = Variable<String>(tenantId);
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  OfflineSalesCompanion toCompanion(bool nullToAbsent) {
    return OfflineSalesCompanion(
      id: Value(id),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalAmount: Value(totalAmount),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      customerEmail: customerEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(customerEmail),
      saleDate: Value(saleDate),
      createdAt: Value(createdAt),
      needsSync: Value(needsSync),
      tenantId: Value(tenantId),
      userId: Value(userId),
    );
  }

  factory OfflineSale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSale(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      customerEmail: serializer.fromJson<String?>(json['customerEmail']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      userId: serializer.fromJson<String>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'customerName': serializer.toJson<String?>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'customerEmail': serializer.toJson<String?>(customerEmail),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'tenantId': serializer.toJson<String>(tenantId),
      'userId': serializer.toJson<String>(userId),
    };
  }

  OfflineSale copyWith(
          {String? id,
          String? productId,
          int? quantity,
          double? unitPrice,
          double? totalAmount,
          Value<String?> customerName = const Value.absent(),
          Value<String?> customerPhone = const Value.absent(),
          Value<String?> customerEmail = const Value.absent(),
          DateTime? saleDate,
          DateTime? createdAt,
          bool? needsSync,
          String? tenantId,
          String? userId}) =>
      OfflineSale(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        totalAmount: totalAmount ?? this.totalAmount,
        customerName:
            customerName.present ? customerName.value : this.customerName,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        customerEmail:
            customerEmail.present ? customerEmail.value : this.customerEmail,
        saleDate: saleDate ?? this.saleDate,
        createdAt: createdAt ?? this.createdAt,
        needsSync: needsSync ?? this.needsSync,
        tenantId: tenantId ?? this.tenantId,
        userId: userId ?? this.userId,
      );
  OfflineSale copyWithCompanion(OfflineSalesCompanion data) {
    return OfflineSale(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSale(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('saleDate: $saleDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      quantity,
      unitPrice,
      totalAmount,
      customerName,
      customerPhone,
      customerEmail,
      saleDate,
      createdAt,
      needsSync,
      tenantId,
      userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSale &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalAmount == this.totalAmount &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.customerEmail == this.customerEmail &&
          other.saleDate == this.saleDate &&
          other.createdAt == this.createdAt &&
          other.needsSync == this.needsSync &&
          other.tenantId == this.tenantId &&
          other.userId == this.userId);
}

class OfflineSalesCompanion extends UpdateCompanion<OfflineSale> {
  final Value<String> id;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalAmount;
  final Value<String?> customerName;
  final Value<String?> customerPhone;
  final Value<String?> customerEmail;
  final Value<DateTime> saleDate;
  final Value<DateTime> createdAt;
  final Value<bool> needsSync;
  final Value<String> tenantId;
  final Value<String> userId;
  final Value<int> rowid;
  const OfflineSalesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineSalesCompanion.insert({
    required String id,
    required String productId,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.customerEmail = const Value.absent(),
    required DateTime saleDate,
    required DateTime createdAt,
    this.needsSync = const Value.absent(),
    required String tenantId,
    required String userId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice),
        totalAmount = Value(totalAmount),
        saleDate = Value(saleDate),
        createdAt = Value(createdAt),
        tenantId = Value(tenantId),
        userId = Value(userId);
  static Insertable<OfflineSale> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalAmount,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? customerEmail,
    Expression<DateTime>? saleDate,
    Expression<DateTime>? createdAt,
    Expression<bool>? needsSync,
    Expression<String>? tenantId,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (saleDate != null) 'sale_date': saleDate,
      if (createdAt != null) 'created_at': createdAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (tenantId != null) 'tenant_id': tenantId,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineSalesCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? totalAmount,
      Value<String?>? customerName,
      Value<String?>? customerPhone,
      Value<String?>? customerEmail,
      Value<DateTime>? saleDate,
      Value<DateTime>? createdAt,
      Value<bool>? needsSync,
      Value<String>? tenantId,
      Value<String>? userId,
      Value<int>? rowid}) {
    return OfflineSalesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      needsSync: needsSync ?? this.needsSync,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSalesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('saleDate: $saleDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineUsersTable extends OfflineUsers
    with TableInfo<$OfflineUsersTable, OfflineUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastLoginMeta =
      const VerificationMeta('lastLogin');
  @override
  late final GeneratedColumn<DateTime> lastLogin = GeneratedColumn<DateTime>(
      'last_login', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, email, name, role, lastLogin, isActive, tenantId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_users';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('last_login')) {
      context.handle(_lastLoginMeta,
          lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      lastLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
    );
  }

  @override
  $OfflineUsersTable createAlias(String alias) {
    return $OfflineUsersTable(attachedDatabase, alias);
  }
}

class OfflineUser extends DataClass implements Insertable<OfflineUser> {
  final String id;
  final String email;
  final String? name;
  final String role;
  final DateTime? lastLogin;
  final bool isActive;
  final String tenantId;
  const OfflineUser(
      {required this.id,
      required this.email,
      this.name,
      required this.role,
      this.lastLogin,
      required this.isActive,
      required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || lastLogin != null) {
      map['last_login'] = Variable<DateTime>(lastLogin);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  OfflineUsersCompanion toCompanion(bool nullToAbsent) {
    return OfflineUsersCompanion(
      id: Value(id),
      email: Value(email),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      role: Value(role),
      lastLogin: lastLogin == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogin),
      isActive: Value(isActive),
      tenantId: Value(tenantId),
    );
  }

  factory OfflineUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineUser(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String?>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      lastLogin: serializer.fromJson<DateTime?>(json['lastLogin']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String?>(name),
      'role': serializer.toJson<String>(role),
      'lastLogin': serializer.toJson<DateTime?>(lastLogin),
      'isActive': serializer.toJson<bool>(isActive),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  OfflineUser copyWith(
          {String? id,
          String? email,
          Value<String?> name = const Value.absent(),
          String? role,
          Value<DateTime?> lastLogin = const Value.absent(),
          bool? isActive,
          String? tenantId}) =>
      OfflineUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name.present ? name.value : this.name,
        role: role ?? this.role,
        lastLogin: lastLogin.present ? lastLogin.value : this.lastLogin,
        isActive: isActive ?? this.isActive,
        tenantId: tenantId ?? this.tenantId,
      );
  OfflineUser copyWithCompanion(OfflineUsersCompanion data) {
    return OfflineUser(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineUser(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('isActive: $isActive, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, name, role, lastLogin, isActive, tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineUser &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.role == this.role &&
          other.lastLogin == this.lastLogin &&
          other.isActive == this.isActive &&
          other.tenantId == this.tenantId);
}

class OfflineUsersCompanion extends UpdateCompanion<OfflineUser> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> name;
  final Value<String> role;
  final Value<DateTime?> lastLogin;
  final Value<bool> isActive;
  final Value<String> tenantId;
  final Value<int> rowid;
  const OfflineUsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.isActive = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineUsersCompanion.insert({
    required String id,
    required String email,
    this.name = const Value.absent(),
    required String role,
    this.lastLogin = const Value.absent(),
    this.isActive = const Value.absent(),
    required String tenantId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        role = Value(role),
        tenantId = Value(tenantId);
  static Insertable<OfflineUser> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? role,
    Expression<DateTime>? lastLogin,
    Expression<bool>? isActive,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (lastLogin != null) 'last_login': lastLogin,
      if (isActive != null) 'is_active': isActive,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String?>? name,
      Value<String>? role,
      Value<DateTime?>? lastLogin,
      Value<bool>? isActive,
      Value<String>? tenantId,
      Value<int>? rowid}) {
    return OfflineUsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<DateTime>(lastLogin.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineUsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('isActive: $isActive, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineCategoriesTable extends OfflineCategories
    with TableInfo<$OfflineCategoriesTable, OfflineCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncActionMeta =
      const VerificationMeta('syncAction');
  @override
  late final GeneratedColumn<String> syncAction = GeneratedColumn<String>(
      'sync_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        isActive,
        createdAt,
        updatedAt,
        needsSync,
        syncAction,
        tenantId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_categories';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('sync_action')) {
      context.handle(
          _syncActionMeta,
          syncAction.isAcceptableOrUnknown(
              data['sync_action']!, _syncActionMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      syncAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_action']),
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
    );
  }

  @override
  $OfflineCategoriesTable createAlias(String alias) {
    return $OfflineCategoriesTable(attachedDatabase, alias);
  }
}

class OfflineCategory extends DataClass implements Insertable<OfflineCategory> {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final String? syncAction;
  final String tenantId;
  const OfflineCategory(
      {required this.id,
      required this.name,
      this.description,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.needsSync,
      this.syncAction,
      required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || syncAction != null) {
      map['sync_action'] = Variable<String>(syncAction);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  OfflineCategoriesCompanion toCompanion(bool nullToAbsent) {
    return OfflineCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      needsSync: Value(needsSync),
      syncAction: syncAction == null && nullToAbsent
          ? const Value.absent()
          : Value(syncAction),
      tenantId: Value(tenantId),
    );
  }

  factory OfflineCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      syncAction: serializer.fromJson<String?>(json['syncAction']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'syncAction': serializer.toJson<String?>(syncAction),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  OfflineCategory copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? needsSync,
          Value<String?> syncAction = const Value.absent(),
          String? tenantId}) =>
      OfflineCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        needsSync: needsSync ?? this.needsSync,
        syncAction: syncAction.present ? syncAction.value : this.syncAction,
        tenantId: tenantId ?? this.tenantId,
      );
  OfflineCategory copyWithCompanion(OfflineCategoriesCompanion data) {
    return OfflineCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      syncAction:
          data.syncAction.present ? data.syncAction.value : this.syncAction,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, isActive, createdAt,
      updatedAt, needsSync, syncAction, tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.needsSync == this.needsSync &&
          other.syncAction == this.syncAction &&
          other.tenantId == this.tenantId);
}

class OfflineCategoriesCompanion extends UpdateCompanion<OfflineCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> needsSync;
  final Value<String?> syncAction;
  final Value<String> tenantId;
  final Value<int> rowid;
  const OfflineCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineCategoriesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    required String tenantId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        tenantId = Value(tenantId);
  static Insertable<OfflineCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? needsSync,
    Expression<String>? syncAction,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (syncAction != null) 'sync_action': syncAction,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? needsSync,
      Value<String?>? syncAction,
      Value<String>? tenantId,
      Value<int>? rowid}) {
    return OfflineCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      syncAction: syncAction ?? this.syncAction,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (syncAction.present) {
      map['sync_action'] = Variable<String>(syncAction.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineSuppliersTable extends OfflineSuppliers
    with TableInfo<$OfflineSuppliersTable, OfflineSupplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncActionMeta =
      const VerificationMeta('syncAction');
  @override
  late final GeneratedColumn<String> syncAction = GeneratedColumn<String>(
      'sync_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        contactPerson,
        email,
        phone,
        address,
        isActive,
        createdAt,
        updatedAt,
        needsSync,
        syncAction,
        tenantId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineSupplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('sync_action')) {
      context.handle(
          _syncActionMeta,
          syncAction.isAcceptableOrUnknown(
              data['sync_action']!, _syncActionMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineSupplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSupplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      syncAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_action']),
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
    );
  }

  @override
  $OfflineSuppliersTable createAlias(String alias) {
    return $OfflineSuppliersTable(attachedDatabase, alias);
  }
}

class OfflineSupplier extends DataClass implements Insertable<OfflineSupplier> {
  final String id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final String? syncAction;
  final String tenantId;
  const OfflineSupplier(
      {required this.id,
      required this.name,
      this.contactPerson,
      this.email,
      this.phone,
      this.address,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.needsSync,
      this.syncAction,
      required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || syncAction != null) {
      map['sync_action'] = Variable<String>(syncAction);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  OfflineSuppliersCompanion toCompanion(bool nullToAbsent) {
    return OfflineSuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      needsSync: Value(needsSync),
      syncAction: syncAction == null && nullToAbsent
          ? const Value.absent()
          : Value(syncAction),
      tenantId: Value(tenantId),
    );
  }

  factory OfflineSupplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSupplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      syncAction: serializer.fromJson<String?>(json['syncAction']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'syncAction': serializer.toJson<String?>(syncAction),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  OfflineSupplier copyWith(
          {String? id,
          String? name,
          Value<String?> contactPerson = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> address = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? needsSync,
          Value<String?> syncAction = const Value.absent(),
          String? tenantId}) =>
      OfflineSupplier(
        id: id ?? this.id,
        name: name ?? this.name,
        contactPerson:
            contactPerson.present ? contactPerson.value : this.contactPerson,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        address: address.present ? address.value : this.address,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        needsSync: needsSync ?? this.needsSync,
        syncAction: syncAction.present ? syncAction.value : this.syncAction,
        tenantId: tenantId ?? this.tenantId,
      );
  OfflineSupplier copyWithCompanion(OfflineSuppliersCompanion data) {
    return OfflineSupplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      syncAction:
          data.syncAction.present ? data.syncAction.value : this.syncAction,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSupplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contactPerson, email, phone,
      address, isActive, createdAt, updatedAt, needsSync, syncAction, tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSupplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.needsSync == this.needsSync &&
          other.syncAction == this.syncAction &&
          other.tenantId == this.tenantId);
}

class OfflineSuppliersCompanion extends UpdateCompanion<OfflineSupplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> needsSync;
  final Value<String?> syncAction;
  final Value<String> tenantId;
  final Value<int> rowid;
  const OfflineSuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineSuppliersCompanion.insert({
    required String id,
    required String name,
    this.contactPerson = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.needsSync = const Value.absent(),
    this.syncAction = const Value.absent(),
    required String tenantId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        tenantId = Value(tenantId);
  static Insertable<OfflineSupplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? needsSync,
    Expression<String>? syncAction,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (syncAction != null) 'sync_action': syncAction,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineSuppliersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? contactPerson,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? address,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? needsSync,
      Value<String?>? syncAction,
      Value<String>? tenantId,
      Value<int>? rowid}) {
    return OfflineSuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      syncAction: syncAction ?? this.syncAction,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (syncAction.present) {
      map['sync_action'] = Variable<String>(syncAction.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('syncAction: $syncAction, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recordTableNameMeta =
      const VerificationMeta('recordTableName');
  @override
  late final GeneratedColumn<String> recordTableName = GeneratedColumn<String>(
      'record_table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recordTableName,
        recordId,
        action,
        data,
        createdAt,
        retryCount,
        errorMessage,
        tenantId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_table_name')) {
      context.handle(
          _recordTableNameMeta,
          recordTableName.isAcceptableOrUnknown(
              data['record_table_name']!, _recordTableNameMeta));
    } else if (isInserting) {
      context.missing(_recordTableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recordTableName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}record_table_name'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;
  final String recordTableName;
  final String recordId;
  final String action;
  final String? data;
  final DateTime createdAt;
  final int retryCount;
  final String? errorMessage;
  final String tenantId;
  const SyncQueueItem(
      {required this.id,
      required this.recordTableName,
      required this.recordId,
      required this.action,
      this.data,
      required this.createdAt,
      required this.retryCount,
      this.errorMessage,
      required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_table_name'] = Variable<String>(recordTableName);
    map['record_id'] = Variable<String>(recordId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      recordTableName: Value(recordTableName),
      recordId: Value(recordId),
      action: Value(action),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      tenantId: Value(tenantId),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      recordTableName: serializer.fromJson<String>(json['recordTableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      action: serializer.fromJson<String>(json['action']),
      data: serializer.fromJson<String?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordTableName': serializer.toJson<String>(recordTableName),
      'recordId': serializer.toJson<String>(recordId),
      'action': serializer.toJson<String>(action),
      'data': serializer.toJson<String?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  SyncQueueItem copyWith(
          {int? id,
          String? recordTableName,
          String? recordId,
          String? action,
          Value<String?> data = const Value.absent(),
          DateTime? createdAt,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent(),
          String? tenantId}) =>
      SyncQueueItem(
        id: id ?? this.id,
        recordTableName: recordTableName ?? this.recordTableName,
        recordId: recordId ?? this.recordId,
        action: action ?? this.action,
        data: data.present ? data.value : this.data,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        tenantId: tenantId ?? this.tenantId,
      );
  SyncQueueItem copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      recordTableName: data.recordTableName.present
          ? data.recordTableName.value
          : this.recordTableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      action: data.action.present ? data.action.value : this.action,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('recordTableName: $recordTableName, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recordTableName, recordId, action, data,
      createdAt, retryCount, errorMessage, tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.recordTableName == this.recordTableName &&
          other.recordId == this.recordId &&
          other.action == this.action &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.tenantId == this.tenantId);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> recordTableName;
  final Value<String> recordId;
  final Value<String> action;
  final Value<String?> data;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<String> tenantId;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.recordTableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.action = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.tenantId = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String recordTableName,
    required String recordId,
    required String action,
    this.data = const Value.absent(),
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required String tenantId,
  })  : recordTableName = Value(recordTableName),
        recordId = Value(recordId),
        action = Value(action),
        createdAt = Value(createdAt),
        tenantId = Value(tenantId);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? recordTableName,
    Expression<String>? recordId,
    Expression<String>? action,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<String>? tenantId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordTableName != null) 'record_table_name': recordTableName,
      if (recordId != null) 'record_id': recordId,
      if (action != null) 'action': action,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (tenantId != null) 'tenant_id': tenantId,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? recordTableName,
      Value<String>? recordId,
      Value<String>? action,
      Value<String?>? data,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? errorMessage,
      Value<String>? tenantId}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      recordTableName: recordTableName ?? this.recordTableName,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordTableName.present) {
      map['record_table_name'] = Variable<String>(recordTableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('recordTableName: $recordTableName, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineDatabase extends GeneratedDatabase {
  _$OfflineDatabase(QueryExecutor e) : super(e);
  $OfflineDatabaseManager get managers => $OfflineDatabaseManager(this);
  late final $OfflineProductsTable offlineProducts =
      $OfflineProductsTable(this);
  late final $OfflineSalesTable offlineSales = $OfflineSalesTable(this);
  late final $OfflineUsersTable offlineUsers = $OfflineUsersTable(this);
  late final $OfflineCategoriesTable offlineCategories =
      $OfflineCategoriesTable(this);
  late final $OfflineSuppliersTable offlineSuppliers =
      $OfflineSuppliersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        offlineProducts,
        offlineSales,
        offlineUsers,
        offlineCategories,
        offlineSuppliers,
        syncQueue
      ];
}

typedef $$OfflineProductsTableCreateCompanionBuilder = OfflineProductsCompanion
    Function({
  required String id,
  required String name,
  required String category,
  Value<String?> description,
  required double price,
  required int quantity,
  Value<int> minStock,
  required List<String> imageUrls,
  Value<String?> sku,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  required String tenantId,
  Value<int> rowid,
});
typedef $$OfflineProductsTableUpdateCompanionBuilder = OfflineProductsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String?> description,
  Value<double> price,
  Value<int> quantity,
  Value<int> minStock,
  Value<List<String>> imageUrls,
  Value<String?> sku,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  Value<String> tenantId,
  Value<int> rowid,
});

class $$OfflineProductsTableFilterComposer
    extends Composer<_$OfflineDatabase, $OfflineProductsTable> {
  $$OfflineProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minStock => $composableBuilder(
      column: $table.minStock, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get imageUrls => $composableBuilder(
          column: $table.imageUrls,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$OfflineProductsTableOrderingComposer
    extends Composer<_$OfflineDatabase, $OfflineProductsTable> {
  $$OfflineProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minStock => $composableBuilder(
      column: $table.minStock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$OfflineProductsTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $OfflineProductsTable> {
  $$OfflineProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get minStock =>
      $composableBuilder(column: $table.minStock, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get imageUrls =>
      $composableBuilder(column: $table.imageUrls, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$OfflineProductsTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $OfflineProductsTable,
    OfflineProduct,
    $$OfflineProductsTableFilterComposer,
    $$OfflineProductsTableOrderingComposer,
    $$OfflineProductsTableAnnotationComposer,
    $$OfflineProductsTableCreateCompanionBuilder,
    $$OfflineProductsTableUpdateCompanionBuilder,
    (
      OfflineProduct,
      BaseReferences<_$OfflineDatabase, $OfflineProductsTable, OfflineProduct>
    ),
    OfflineProduct,
    PrefetchHooks Function()> {
  $$OfflineProductsTableTableManager(
      _$OfflineDatabase db, $OfflineProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> minStock = const Value.absent(),
            Value<List<String>> imageUrls = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineProductsCompanion(
            id: id,
            name: name,
            category: category,
            description: description,
            price: price,
            quantity: quantity,
            minStock: minStock,
            imageUrls: imageUrls,
            sku: sku,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            Value<String?> description = const Value.absent(),
            required double price,
            required int quantity,
            Value<int> minStock = const Value.absent(),
            required List<String> imageUrls,
            Value<String?> sku = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            required String tenantId,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineProductsCompanion.insert(
            id: id,
            name: name,
            category: category,
            description: description,
            price: price,
            quantity: quantity,
            minStock: minStock,
            imageUrls: imageUrls,
            sku: sku,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineProductsTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $OfflineProductsTable,
    OfflineProduct,
    $$OfflineProductsTableFilterComposer,
    $$OfflineProductsTableOrderingComposer,
    $$OfflineProductsTableAnnotationComposer,
    $$OfflineProductsTableCreateCompanionBuilder,
    $$OfflineProductsTableUpdateCompanionBuilder,
    (
      OfflineProduct,
      BaseReferences<_$OfflineDatabase, $OfflineProductsTable, OfflineProduct>
    ),
    OfflineProduct,
    PrefetchHooks Function()>;
typedef $$OfflineSalesTableCreateCompanionBuilder = OfflineSalesCompanion
    Function({
  required String id,
  required String productId,
  required int quantity,
  required double unitPrice,
  required double totalAmount,
  Value<String?> customerName,
  Value<String?> customerPhone,
  Value<String?> customerEmail,
  required DateTime saleDate,
  required DateTime createdAt,
  Value<bool> needsSync,
  required String tenantId,
  required String userId,
  Value<int> rowid,
});
typedef $$OfflineSalesTableUpdateCompanionBuilder = OfflineSalesCompanion
    Function({
  Value<String> id,
  Value<String> productId,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> totalAmount,
  Value<String?> customerName,
  Value<String?> customerPhone,
  Value<String?> customerEmail,
  Value<DateTime> saleDate,
  Value<DateTime> createdAt,
  Value<bool> needsSync,
  Value<String> tenantId,
  Value<String> userId,
  Value<int> rowid,
});

class $$OfflineSalesTableFilterComposer
    extends Composer<_$OfflineDatabase, $OfflineSalesTable> {
  $$OfflineSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));
}

class $$OfflineSalesTableOrderingComposer
    extends Composer<_$OfflineDatabase, $OfflineSalesTable> {
  $$OfflineSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));
}

class $$OfflineSalesTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $OfflineSalesTable> {
  $$OfflineSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<String> get customerEmail => $composableBuilder(
      column: $table.customerEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$OfflineSalesTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $OfflineSalesTable,
    OfflineSale,
    $$OfflineSalesTableFilterComposer,
    $$OfflineSalesTableOrderingComposer,
    $$OfflineSalesTableAnnotationComposer,
    $$OfflineSalesTableCreateCompanionBuilder,
    $$OfflineSalesTableUpdateCompanionBuilder,
    (
      OfflineSale,
      BaseReferences<_$OfflineDatabase, $OfflineSalesTable, OfflineSale>
    ),
    OfflineSale,
    PrefetchHooks Function()> {
  $$OfflineSalesTableTableManager(
      _$OfflineDatabase db, $OfflineSalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String?> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String?> customerEmail = const Value.absent(),
            Value<DateTime> saleDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSalesCompanion(
            id: id,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            totalAmount: totalAmount,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            saleDate: saleDate,
            createdAt: createdAt,
            needsSync: needsSync,
            tenantId: tenantId,
            userId: userId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required int quantity,
            required double unitPrice,
            required double totalAmount,
            Value<String?> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<String?> customerEmail = const Value.absent(),
            required DateTime saleDate,
            required DateTime createdAt,
            Value<bool> needsSync = const Value.absent(),
            required String tenantId,
            required String userId,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSalesCompanion.insert(
            id: id,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            totalAmount: totalAmount,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            saleDate: saleDate,
            createdAt: createdAt,
            needsSync: needsSync,
            tenantId: tenantId,
            userId: userId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineSalesTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $OfflineSalesTable,
    OfflineSale,
    $$OfflineSalesTableFilterComposer,
    $$OfflineSalesTableOrderingComposer,
    $$OfflineSalesTableAnnotationComposer,
    $$OfflineSalesTableCreateCompanionBuilder,
    $$OfflineSalesTableUpdateCompanionBuilder,
    (
      OfflineSale,
      BaseReferences<_$OfflineDatabase, $OfflineSalesTable, OfflineSale>
    ),
    OfflineSale,
    PrefetchHooks Function()>;
typedef $$OfflineUsersTableCreateCompanionBuilder = OfflineUsersCompanion
    Function({
  required String id,
  required String email,
  Value<String?> name,
  required String role,
  Value<DateTime?> lastLogin,
  Value<bool> isActive,
  required String tenantId,
  Value<int> rowid,
});
typedef $$OfflineUsersTableUpdateCompanionBuilder = OfflineUsersCompanion
    Function({
  Value<String> id,
  Value<String> email,
  Value<String?> name,
  Value<String> role,
  Value<DateTime?> lastLogin,
  Value<bool> isActive,
  Value<String> tenantId,
  Value<int> rowid,
});

class $$OfflineUsersTableFilterComposer
    extends Composer<_$OfflineDatabase, $OfflineUsersTable> {
  $$OfflineUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$OfflineUsersTableOrderingComposer
    extends Composer<_$OfflineDatabase, $OfflineUsersTable> {
  $$OfflineUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$OfflineUsersTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $OfflineUsersTable> {
  $$OfflineUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$OfflineUsersTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $OfflineUsersTable,
    OfflineUser,
    $$OfflineUsersTableFilterComposer,
    $$OfflineUsersTableOrderingComposer,
    $$OfflineUsersTableAnnotationComposer,
    $$OfflineUsersTableCreateCompanionBuilder,
    $$OfflineUsersTableUpdateCompanionBuilder,
    (
      OfflineUser,
      BaseReferences<_$OfflineDatabase, $OfflineUsersTable, OfflineUser>
    ),
    OfflineUser,
    PrefetchHooks Function()> {
  $$OfflineUsersTableTableManager(
      _$OfflineDatabase db, $OfflineUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineUsersCompanion(
            id: id,
            email: email,
            name: name,
            role: role,
            lastLogin: lastLogin,
            isActive: isActive,
            tenantId: tenantId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            Value<String?> name = const Value.absent(),
            required String role,
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String tenantId,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineUsersCompanion.insert(
            id: id,
            email: email,
            name: name,
            role: role,
            lastLogin: lastLogin,
            isActive: isActive,
            tenantId: tenantId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineUsersTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $OfflineUsersTable,
    OfflineUser,
    $$OfflineUsersTableFilterComposer,
    $$OfflineUsersTableOrderingComposer,
    $$OfflineUsersTableAnnotationComposer,
    $$OfflineUsersTableCreateCompanionBuilder,
    $$OfflineUsersTableUpdateCompanionBuilder,
    (
      OfflineUser,
      BaseReferences<_$OfflineDatabase, $OfflineUsersTable, OfflineUser>
    ),
    OfflineUser,
    PrefetchHooks Function()>;
typedef $$OfflineCategoriesTableCreateCompanionBuilder
    = OfflineCategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  required String tenantId,
  Value<int> rowid,
});
typedef $$OfflineCategoriesTableUpdateCompanionBuilder
    = OfflineCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  Value<String> tenantId,
  Value<int> rowid,
});

class $$OfflineCategoriesTableFilterComposer
    extends Composer<_$OfflineDatabase, $OfflineCategoriesTable> {
  $$OfflineCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$OfflineCategoriesTableOrderingComposer
    extends Composer<_$OfflineDatabase, $OfflineCategoriesTable> {
  $$OfflineCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$OfflineCategoriesTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $OfflineCategoriesTable> {
  $$OfflineCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$OfflineCategoriesTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $OfflineCategoriesTable,
    OfflineCategory,
    $$OfflineCategoriesTableFilterComposer,
    $$OfflineCategoriesTableOrderingComposer,
    $$OfflineCategoriesTableAnnotationComposer,
    $$OfflineCategoriesTableCreateCompanionBuilder,
    $$OfflineCategoriesTableUpdateCompanionBuilder,
    (
      OfflineCategory,
      BaseReferences<_$OfflineDatabase, $OfflineCategoriesTable,
          OfflineCategory>
    ),
    OfflineCategory,
    PrefetchHooks Function()> {
  $$OfflineCategoriesTableTableManager(
      _$OfflineDatabase db, $OfflineCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCategoriesCompanion(
            id: id,
            name: name,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            required String tenantId,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCategoriesCompanion.insert(
            id: id,
            name: name,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $OfflineCategoriesTable,
    OfflineCategory,
    $$OfflineCategoriesTableFilterComposer,
    $$OfflineCategoriesTableOrderingComposer,
    $$OfflineCategoriesTableAnnotationComposer,
    $$OfflineCategoriesTableCreateCompanionBuilder,
    $$OfflineCategoriesTableUpdateCompanionBuilder,
    (
      OfflineCategory,
      BaseReferences<_$OfflineDatabase, $OfflineCategoriesTable,
          OfflineCategory>
    ),
    OfflineCategory,
    PrefetchHooks Function()>;
typedef $$OfflineSuppliersTableCreateCompanionBuilder
    = OfflineSuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> contactPerson,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> address,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  required String tenantId,
  Value<int> rowid,
});
typedef $$OfflineSuppliersTableUpdateCompanionBuilder
    = OfflineSuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> contactPerson,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> address,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<String?> syncAction,
  Value<String> tenantId,
  Value<int> rowid,
});

class $$OfflineSuppliersTableFilterComposer
    extends Composer<_$OfflineDatabase, $OfflineSuppliersTable> {
  $$OfflineSuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$OfflineSuppliersTableOrderingComposer
    extends Composer<_$OfflineDatabase, $OfflineSuppliersTable> {
  $$OfflineSuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$OfflineSuppliersTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $OfflineSuppliersTable> {
  $$OfflineSuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<String> get syncAction => $composableBuilder(
      column: $table.syncAction, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$OfflineSuppliersTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $OfflineSuppliersTable,
    OfflineSupplier,
    $$OfflineSuppliersTableFilterComposer,
    $$OfflineSuppliersTableOrderingComposer,
    $$OfflineSuppliersTableAnnotationComposer,
    $$OfflineSuppliersTableCreateCompanionBuilder,
    $$OfflineSuppliersTableUpdateCompanionBuilder,
    (
      OfflineSupplier,
      BaseReferences<_$OfflineDatabase, $OfflineSuppliersTable, OfflineSupplier>
    ),
    OfflineSupplier,
    PrefetchHooks Function()> {
  $$OfflineSuppliersTableTableManager(
      _$OfflineDatabase db, $OfflineSuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineSuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineSuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> contactPerson = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSuppliersCompanion(
            id: id,
            name: name,
            contactPerson: contactPerson,
            email: email,
            phone: phone,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> contactPerson = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> needsSync = const Value.absent(),
            Value<String?> syncAction = const Value.absent(),
            required String tenantId,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineSuppliersCompanion.insert(
            id: id,
            name: name,
            contactPerson: contactPerson,
            email: email,
            phone: phone,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            syncAction: syncAction,
            tenantId: tenantId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineSuppliersTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $OfflineSuppliersTable,
    OfflineSupplier,
    $$OfflineSuppliersTableFilterComposer,
    $$OfflineSuppliersTableOrderingComposer,
    $$OfflineSuppliersTableAnnotationComposer,
    $$OfflineSuppliersTableCreateCompanionBuilder,
    $$OfflineSuppliersTableUpdateCompanionBuilder,
    (
      OfflineSupplier,
      BaseReferences<_$OfflineDatabase, $OfflineSuppliersTable, OfflineSupplier>
    ),
    OfflineSupplier,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String recordTableName,
  required String recordId,
  required String action,
  Value<String?> data,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> errorMessage,
  required String tenantId,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> recordTableName,
  Value<String> recordId,
  Value<String> action,
  Value<String?> data,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<String> tenantId,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$OfflineDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordTableName => $composableBuilder(
      column: $table.recordTableName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$OfflineDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordTableName => $composableBuilder(
      column: $table.recordTableName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$OfflineDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordTableName => $composableBuilder(
      column: $table.recordTableName, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$OfflineDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$OfflineDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$OfflineDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> recordTableName = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            recordTableName: recordTableName,
            recordId: recordId,
            action: action,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMessage: errorMessage,
            tenantId: tenantId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String recordTableName,
            required String recordId,
            required String action,
            Value<String?> data = const Value.absent(),
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required String tenantId,
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            recordTableName: recordTableName,
            recordId: recordId,
            action: action,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMessage: errorMessage,
            tenantId: tenantId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$OfflineDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$OfflineDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;

class $OfflineDatabaseManager {
  final _$OfflineDatabase _db;
  $OfflineDatabaseManager(this._db);
  $$OfflineProductsTableTableManager get offlineProducts =>
      $$OfflineProductsTableTableManager(_db, _db.offlineProducts);
  $$OfflineSalesTableTableManager get offlineSales =>
      $$OfflineSalesTableTableManager(_db, _db.offlineSales);
  $$OfflineUsersTableTableManager get offlineUsers =>
      $$OfflineUsersTableTableManager(_db, _db.offlineUsers);
  $$OfflineCategoriesTableTableManager get offlineCategories =>
      $$OfflineCategoriesTableTableManager(_db, _db.offlineCategories);
  $$OfflineSuppliersTableTableManager get offlineSuppliers =>
      $$OfflineSuppliersTableTableManager(_db, _db.offlineSuppliers);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
