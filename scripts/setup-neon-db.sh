#!/bin/bash

# Neon Database Setup Script for DrugReco App
# This script sets up the Neon database with Prisma

echo "🗄️ Setting up Neon database..."

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL environment variable is not set."
    echo "Please set it to your Neon database connection string."
    echo "Example: export DATABASE_URL='postgresql://username:password@host:port/database?sslmode=require'"
    exit 1
fi

# Check if DIRECT_URL is set
if [ -z "$DIRECT_URL" ]; then
    echo "❌ DIRECT_URL environment variable is not set."
    echo "Please set it to your Neon direct connection string."
    echo "Example: export DIRECT_URL='postgresql://username:password@host:port/database?sslmode=require'"
    exit 1
fi

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate --schema=server/prisma/schema.prisma

# Run database migrations
echo "🔄 Running database migrations..."
npx prisma migrate deploy --schema=server/prisma/schema.prisma

# Seed the database
echo "🌱 Seeding database..."
cd server && node seed.js && cd ..

echo "✅ Neon database setup completed!"
echo "📝 Your database is ready for use with Netlify functions." 