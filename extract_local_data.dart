import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Looking for local database...');
  
  try {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'memtechnology_shop.db');
    
    if (!await File(dbPath).exists()) {
      print('❌ Local database not found at: $dbPath');
      print('Make sure you have used the app before and have local data.');
      return;
    }
    
    print('✅ Found database at: $dbPath');
    
    final db = await openDatabase(dbPath);
    
    // Get products
    print('📦 Extracting products...');
    final products = await db.query('products');
    print('Found ${products.length} products');
    
    // Get sales
    print('💰 Extracting sales...');
    final sales = await db.query('sales');
    print('Found ${sales.length} sales');
    
    // Create backup directory
    final backupDir = Directory('backup');
    if (!await backupDir.exists()) {
      await backupDir.create();
    }
    
    // Save to JSON files
    await File('backup/products.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(products)
    );
    
    await File('backup/sales.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(sales)
    );
    
    print('✅ Backup completed successfully!');
    print('📁 Files saved in backup/ directory');
    print('   - products.json (${products.length} records)');
    print('   - sales.json (${sales.length} records)');
    
    await db.close();
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
