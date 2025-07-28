#!/bin/bash

# Netlify Deployment Script for DrugReco App
# This script sets up the app for Netlify deployment with Neon database

echo "🚀 Starting Netlify deployment setup..."

# Check if Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo "❌ Netlify CLI not found. Please install it first:"
    echo "npm install -g netlify-cli"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install
cd client && npm install && cd ..

# Build the application
echo "🔨 Building application..."
npm run build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi

echo "✅ Build completed successfully!"

# Deploy to Netlify
echo "🌐 Deploying to Netlify..."
netlify deploy --prod --dir=client/build

echo "🎉 Deployment completed!"
echo "📝 Don't forget to:"
echo "   1. Set up environment variables in Netlify dashboard"
echo "   2. Configure your Neon database connection"
echo "   3. Update CORS settings with your Netlify domain" 