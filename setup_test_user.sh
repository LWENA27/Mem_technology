#!/bin/bash

echo "🚀 Setting up Test User for InventoryMaster SaaS"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}Step 1: Create a user in Supabase Auth${NC}"
echo "1. Go to: https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb/auth/users"
echo "2. Click 'Add user'"
echo "3. Enter email: test@lwenatech.com"
echo "4. Enter password: TestPass123!"
echo "5. Click 'Create user'"

echo -e "\n${BLUE}Step 2: Set up the user as admin of Test Store${NC}"
echo "1. Go to: https://supabase.com/dashboard/project/kzjgdeqfmxkmpmadtbpb/sql"
echo "2. Run this SQL command:"
echo ""
echo -e "${YELLOW}SELECT setup_test_admin('test@lwenatech.com');${NC}"
echo ""

echo -e "\n${BLUE}Step 3: Test the login${NC}"
echo "1. Run your Flutter app: flutter run"
echo "2. Login with:"
echo "   Email: test@lwenatech.com"
echo "   Password: TestPass123!"

echo -e "\n${GREEN}You should now have access to the Test Store with sample products!${NC}"
echo ""
echo "Sample products included:"
echo "- Laptop Computer (15 units)"
echo "- Wireless Mouse (50 units)"
echo "- USB-C Cable (100 units)"
echo "- 24\" Monitor (12 units)"
echo "- Bluetooth Headphones (25 units)"
echo "- Smartphone Case (75 units)"
echo "- Power Bank (30 units)"

echo -e "\n${BLUE}Ready to test! 🎉${NC}"