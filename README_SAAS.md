# InventoryMaster SaaS - Multi-Tenant Edition

This branch contains the multi-tenant SaaS version of the InventoryMaster application. The app has been transformed from a single-tenant system to a full multi-tenant SaaS platform with proper data isolation and tenant management.

## 🚀 Key Features

### Multi-Tenant Architecture
- **Tenant Isolation**: Each customer (tenant) has completely isolated data
- **Row-Level Security (RLS)**: Database-level security ensuring data cannot leak between tenants
- **Shared Database**: Efficient resource utilization with tenant_id-based data scoping
- **Scalable Design**: Ready for thousands of tenants on a single infrastructure

### Tenant Management
- **Automated Provisioning**: Scripts to create new tenants and admin users
- **Role-Based Access Control**: `admin`, `tenant_admin`, `staff`, `user` roles
- **Tenant Dashboard**: Admin interface for managing client tenants (future enhancement)

### Local Development Environment
- **Supabase CLI Integration**: Full local development stack with Auth, Storage, REST API
- **Docker Support**: Alternative plain PostgreSQL setup for basic development
- **Environment Configuration**: Flutter app configurable for local/staging/production
- **Sample Data**: Automated creation of demo tenants and inventory items

## 📁 Project Structure

```
├── lib/
│   ├── services/supabase_service.dart   # Environment-aware Supabase client
│   └── ...                              # Existing Flutter app code
├── supabase/
│   ├── migrations/
│   │   ├── 20251009001_create_tenants_inventories.sql  # Core multi-tenant schema
│   │   └── ...                          # Other migrations
│   ├── admin-api/                       # Express.js tenant provisioning API
│   ├── scripts/create_tenant.sh         # Production tenant creation script
│   └── seed.sql                         # Initial data and functions
├── scripts/
│   ├── flutter_run_local.sh             # Run Flutter with local Supabase
│   ├── create_local_supabase_tenant.sh  # Create demo tenants locally
│   ├── add_sample_inventory.sh          # Add sample inventory data
│   └── setup_local.sh                   # Automated local environment setup
└── docker-compose.yml                   # Plain PostgreSQL for basic development
```

## 🛠 Database Schema

### Core Tables

#### `tenants`
- `id` (UUID) - Primary key
- `name` (TEXT) - Display name (e.g., "Acme Corp")
- `slug` (TEXT) - URL-friendly identifier (e.g., "acme-corp")
- `metadata` (JSONB) - Additional tenant configuration
- `created_at` (TIMESTAMPTZ)

#### `inventories` (tenant-scoped)
- `id` (UUID) - Primary key
- `tenant_id` (UUID) - Foreign key to tenants table
- `name` (TEXT) - Product name
- `sku` (TEXT) - Stock keeping unit
- `quantity` (INTEGER) - Current stock level
- `price` (NUMERIC) - Product price
- `metadata` (JSONB) - Additional product data
- `created_at`, `updated_at` (TIMESTAMPTZ)

#### `profiles` (extended)
- `id` (UUID) - References auth.users(id)
- `tenant_id` (UUID) - Links user to tenant
- `role` (TEXT) - User role within tenant
- `email` (TEXT) - User email
- `created_at`, `updated_at` (TIMESTAMPTZ)

### Row-Level Security Policies

#### Tenants Table
- **SELECT**: Public read access for basic tenant info
- **UPDATE/DELETE**: Only global admins

#### Inventories Table
- **SELECT**: Users can only see inventory from their tenant
- **INSERT**: Users with appropriate roles (`tenant_admin`, `admin`, `staff`)
- **UPDATE**: Same role restrictions as INSERT
- **DELETE**: Only `tenant_admin` and `admin` roles

## 🏃‍♂️ Getting Started

### Prerequisites
- Flutter SDK
- Docker & Docker Compose
- Supabase CLI (recommended) or PostgreSQL

### Option 1: Full Local Supabase (Recommended)

1. **Start Supabase locally**:
   ```bash
   sudo -E env PATH=$PATH supabase start
   ```

2. **Create a demo tenant**:
   ```bash
   ./scripts/create_local_supabase_tenant.sh
   ```

3. **Add sample inventory**:
   ```bash
   ./scripts/add_sample_inventory.sh
   ```

4. **Run Flutter app**:
   ```bash
   ./scripts/flutter_run_local.sh
   ```

5. **Login with demo credentials**:
   - Email: `admin@localdemo.com`
   - Password: `password123`

### Option 2: Plain PostgreSQL

1. **Start PostgreSQL**:
   ```bash
   docker compose up -d
   ```

2. **Run setup script**:
   ```bash
   ./scripts/setup_local.sh
   ```

3. **Run Flutter app**:
   ```bash
   flutter run -d chrome --dart-define=SUPABASE_URL=your_local_url
   ```

## 🔧 Development Tools

### Create New Tenant
```bash
# Local Supabase
./scripts/create_local_supabase_tenant.sh "Company Name" "company-slug" "admin@company.com" "password"

# Production (via API)
./supabase/scripts/create_tenant.sh "Company Name" "company-slug" "admin@company.com"
```

### Add Sample Data
```bash
./scripts/add_sample_inventory.sh [tenant_id]
```

### Database Management
- **Supabase Studio**: http://127.0.0.1:54323 (when using Supabase CLI)
- **Direct PostgreSQL**: `psql postgresql://postgres:postgres@localhost:5433/postgres`

## 🌐 Production Deployment

### Environment Variables
```bash
# Flutter build
flutter build web --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Server-side tenant provisioning
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_SERVICE_KEY=your-service-role-key
```

### Supabase Project Setup
1. Create new Supabase project
2. Run migrations: `supabase db push`
3. Deploy admin API for tenant provisioning
4. Configure custom domain and SSL

## 📊 Multi-Tenant Features

### Data Isolation
- ✅ Complete tenant data separation via RLS policies
- ✅ No cross-tenant data access possible
- ✅ Database-level security enforcement

### Tenant Provisioning
- ✅ Automated tenant creation scripts
- ✅ Admin user creation with proper role assignment
- ✅ Sample data generation for new tenants

### Role-Based Access
- ✅ Global admin: Can manage all tenants
- ✅ Tenant admin: Full access within their tenant
- ✅ Staff: Limited operations within their tenant
- ✅ User: Read-only access within their tenant

### Development Environment
- ✅ Local Supabase stack with all services
- ✅ Environment-specific configuration
- ✅ Sample data and demo tenants
- ✅ Automated setup scripts

## 🔄 Migration from Single-Tenant

This branch represents the evolution from the single-tenant `main` branch. Key changes:

1. **Database Schema**: Added `tenants` table and `tenant_id` foreign keys
2. **Security**: Implemented comprehensive RLS policies
3. **User Management**: Extended profiles with tenant association and roles
4. **Environment Config**: Made Supabase connection configurable
5. **Development Tools**: Added local development and provisioning scripts

## 🚧 Future Enhancements

- [ ] Central admin dashboard for managing all tenants
- [ ] Tenant-specific branding and customization
- [ ] Usage analytics and billing integration
- [ ] Multi-region deployment support
- [ ] Advanced role permissions matrix
- [ ] Automated tenant backup and restoration

## 📝 Notes

- The original single-tenant code remains in the `main` branch
- This SaaS version is designed for scalability and multi-tenancy
- All sensitive operations use the service role key for security
- Local development closely mirrors production Supabase environment