#!/bin/bash

# Environment Setup Script for DrugReco Netlify Migration
# This script helps set up environment variables for Neon database

echo "🔧 Setting up environment variables for DrugReco Netlify migration..."
echo ""

# Check if .env file exists
if [ -f "netlify/.env" ]; then
    echo "⚠️  netlify/.env already exists. Backing up..."
    cp netlify/.env netlify/.env.backup
fi

# Create .env file from template
echo "📝 Creating environment file from template..."
cp netlify/env.example netlify/.env

echo ""
echo "✅ Environment file created: netlify/.env"
echo ""
echo "🔑 Please update the following variables in netlify/.env:"
echo ""
echo "1. DATABASE_URL - Your Neon pooled connection string"
echo "   Format: postgresql://username:password@host:port/database?sslmode=require"
echo ""
echo "2. DIRECT_URL - Your Neon direct connection string"
echo "   Format: postgresql://username:password@host:port/database?sslmode=require"
echo ""
echo "3. JWT_SECRET - A secure random string for JWT tokens"
echo "   Example: $(openssl rand -base64 32)"
echo ""
echo "4. ALLOWED_ORIGINS - Your Netlify domain (update after deployment)"
echo "   Example: https://your-app-name.netlify.app"
echo ""
echo "📋 Steps to get Neon connection strings:"
echo "   1. Go to https://neon.tech"
echo "   2. Create account and new project"
echo "   3. Copy connection strings from dashboard"
echo "   4. Update netlify/.env with your values"
echo ""
echo "🚀 After updating .env, run: ./scripts/setup-neon-db.sh" 