#!/bin/bash

echo "Creating backup of local SQLite data..."

# Create backup directory
mkdir -p backup

# Run Flutter app to export data
cat > lib/backup_helper.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'services/DatabaseService.dart';
import 'models/product.dart';
import 'models/sale.dart';

Future<void> backupData() async {
  print('Starting local data backup...');
  
  try {
    // Initialize the database service
    final dbService = DatabaseService.instance;
    final db = await dbService.sqliteDb;
    
    // Get all products
    final productMaps = await db.query('products');
    final products = productMaps.map((map) => Product.fromJson(map)).toList();
    
    // Get all sales
    final saleMaps = await db.query('sales');
    final sales = saleMaps.map((map) => Sale.fromJson(map)).toList();
    
    // Create backup directory
    final backupDir = Directory('backup');
    if (!await backupDir.exists()) {
      await backupDir.create();
    }
    
    // Save products to JSON
    final productsFile = File('backup/products.json');
    final productsJson = products.map((p) => p.toJson()).toList();
    await productsFile.writeAsString(jsonEncode(productsJson));
    
    // Save sales to JSON
    final salesFile = File('backup/sales.json');
    final salesJson = sales.map((s) => s.toJson()).toList();
    await salesFile.writeAsString(jsonEncode(salesJson));
    
    print('Backup completed successfully!');
    print('Products backed up: ${products.length}');
    print('Sales backed up: ${sales.length}');
    print('Files saved in backup/ directory');
    
  } catch (e) {
    print('Error during backup: $e');
  }
}
EOF

echo "Backup helper created. Now we'll connect to Supabase web interface."
