# Database Setup Guide

## PostgreSQL Setup

This project uses PostgreSQL for production-ready database management.

### Prerequisites
- PostgreSQL 17 installed via Homebrew
- Database user: `kumar` (current system user)

### Quick Start

1. **Start PostgreSQL service:**
   ```bash
   brew services start postgresql@17
   ```

2. **Add PostgreSQL to PATH (if needed):**
   ```bash
   export PATH="/opt/homebrew/Cellar/postgresql@17/17.5/bin:$PATH"
   ```

3. **Run migrations and seed data:**
   ```bash
   npm run db:migrate
   npm run db:seed
   ```

### Available NPM Scripts

- `npm run db:migrate` - Run pending migrations
- `npm run db:seed` - Seed the database with sample data
- `npm run db:rollback` - Rollback last migration
- `npm run db:reset` - Reset database (rollback, migrate, and seed)

### Database Information

- **Database Name:** `medicinechk_dev`
- **User:** `kumar`
- **Host:** `localhost`
- **Port:** `5432`

### Sample Data

The database is seeded with 23 drug records including:
- Pain Relief medications (Paracetamol, Ibuprofen, etc.)
- Antibiotics (Azithromycin, Amoxicillin, etc.)
- Diabetes medications (Metformin, etc.)
- Cardiovascular drugs (Atorvastatin, Amlodipine, etc.)
- And more categories

### Connecting to Database

To connect directly to PostgreSQL:
```bash
psql -d medicinechk_dev
```

### Troubleshooting

#### Common Issue: "Can't reach database server at localhost:5432"

**Problem:** This error occurs when PostgreSQL service is not running.

**Permanent Solution:**
```bash
# Start PostgreSQL and enable auto-start
brew services start postgresql@17
```

**Quick Fix (if service is stopped):**
```bash
# Check service status
brew services list | grep postgresql

# Start service manually (temporary)
brew services start postgresql@17

# Verify connection
cd server && npm run db:migrate
```

#### Other Issues

If you get "role does not exist" errors, make sure:
1. PostgreSQL service is running
2. Your system user has access to PostgreSQL
3. The database `medicinechk_dev` exists

If PostgreSQL commands are not found:
```bash
export PATH="/opt/homebrew/Cellar/postgresql@17/17.5/bin:$PATH"
```

#### Auto-Start Configuration

The PostgreSQL service should automatically start on system boot. To verify:
```bash
# Check if service is configured to auto-start
brew services list | grep postgresql@17

# Should show: postgresql@17 started kumar ~/Library/LaunchAgents/homebrew.mxcl.postgresql@17.plist
```

#### Development Workflow

To prevent database connection issues:
1. Always use `brew services start postgresql@17` (enables auto-start)
2. Never use manual `pg_ctl` commands for persistent setup
3. Check service status if app shows database errors

---

**Last Updated:** 2025-08-02  
**PostgreSQL Version:** 17.5 via Homebrew  
**Status:** Production-ready database setup with auto-start configured 