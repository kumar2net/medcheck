#!/bin/bash

# Database startup script for medicinechk
# This script ensures PostgreSQL is running before starting the app

echo "🔄 Checking PostgreSQL service status..."

# Check if PostgreSQL is running
if ! brew services list | grep -q "postgresql@17.*started"; then
    echo "⚠️  PostgreSQL is not running. Starting service..."
    brew services start postgresql@17
    echo "✅ PostgreSQL service started and configured for auto-start"
else
    echo "✅ PostgreSQL is already running"
fi

# Wait a moment for service to be ready
sleep 2

# Test database connection
echo "🔍 Testing database connection..."
if psql -d medicinechk_dev -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed. Running migrations..."
    npm run db:migrate
    npm run db:seed
fi

echo "🚀 Database is ready!"