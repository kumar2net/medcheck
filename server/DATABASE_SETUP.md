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

- **Database Name:** `drugreco_dev`
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
psql -d drugreco_dev
```

### Troubleshooting

If you get "role does not exist" errors, make sure:
1. PostgreSQL service is running
2. Your system user has access to PostgreSQL
3. The database `drugreco_dev` exists

If PostgreSQL commands are not found:
```bash
export PATH="/opt/homebrew/Cellar/postgresql@17/17.5/bin:$PATH"
```

---

**Last Updated:** 2025-07-31  
**PostgreSQL Version:** 17.5 via Homebrew  
**Status:** Production-ready database setup 