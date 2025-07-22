#!/bin/bash

echo "🔄 Memtechnology Supabase Database Restoration Script"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Your Supabase configuration
SUPABASE_URL="https://kzjgdeqfmxkmpmadtbpb.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6amdkZXFmbXhrbXBtYWR0YnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyOTk3NjQsImV4cCI6MjA2NDg3NTc2NH0.NTEzbvVCQ_vNTJPS5bFPSOm5XNRjUrFpSUPEWQDm434"

echo -e "${BLUE}📋 Step 1: Checking Supabase CLI installation...${NC}"
if command -v supabase &> /dev/null; then
    echo -e "${GREEN}✅ Supabase CLI is installed ($(supabase --version))${NC}"
else
    echo -e "${RED}❌ Supabase CLI not found. Please install it first.${NC}"
    exit 1
fi

echo -e "\n${BLUE}📋 Step 2: Creating database schema...${NC}"
echo "You'll need to manually execute the following SQL in your Supabase dashboard:"
echo -e "${YELLOW}Go to: https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb/sql${NC}"
echo ""
echo "Execute this SQL:"
echo "========================================"
cat supabase/migrations/001_create_tables.sql
echo "========================================"

echo -e "\n${BLUE}📋 Step 3: Setting up storage bucket for product images...${NC}"
echo "Go to: https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb/storage/buckets"
echo "Create a new bucket named: 'product-images'"
echo "Make it public for read access"

echo -e "\n${BLUE}📋 Step 4: Instructions to backup and restore data...${NC}"

# Create a backup data extraction script
cat > extract_local_data.dart << 'EOF'
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
EOF

echo "4a. Run data extraction:"
echo "dart run extract_local_data.dart"

echo -e "\n4b. After running the extraction, you'll have backup JSON files."
echo "4c. Use the Supabase dashboard to import this data into your tables:"
echo "   - Go to: https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb/editor"
echo "   - Select the 'products' table and insert the data from backup/products.json"
echo "   - Select the 'sales' table and insert the data from backup/sales.json"

echo -e "\n${BLUE}📋 Step 5: Update your Flutter app configuration...${NC}"
echo "Your app is already configured with the correct Supabase URL and keys!"

echo -e "\n${GREEN}🎉 Setup Complete!${NC}"
echo "Your Supabase project should now be restored with:"
echo "• Database tables (products, sales)"
echo "• Proper indexes and security policies"
echo "• Storage bucket for product images"
echo "• Your local data (after manual import)"

echo -e "\n${YELLOW}📱 Test your app:${NC}"
echo "flutter run"

echo -e "\n${YELLOW}⚠️  Important Notes:${NC}"
echo "• Make sure to execute the SQL schema in Supabase dashboard"
echo "• Create the 'product-images' storage bucket"
echo "• Import your backup data manually"
echo "• Your app will work offline and sync when online"
