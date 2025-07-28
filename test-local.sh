#!/bin/bash

# Local Testing Script for DrugReco Application
# Date: 2025-07-28

echo "🧪 Testing Local DrugReco Application"
echo "====================================="
echo ""

# Test Frontend
echo "1. Testing Frontend (React App)..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "   ✅ Frontend is running: http://localhost:3000"
else
    echo "   ❌ Frontend is not running"
fi

# Test Backend API
echo ""
echo "2. Testing Backend API..."
if curl -s http://localhost:3001/api/drugs > /dev/null; then
    echo "   ✅ Backend API is running: http://localhost:3001"
else
    echo "   ❌ Backend API is not running"
fi

# Test Netlify Functions
echo ""
echo "3. Testing Netlify Functions..."
if curl -s http://localhost:8888 > /dev/null; then
    echo "   ✅ Netlify Functions is running: http://localhost:8888"
else
    echo "   ❌ Netlify Functions is not running"
fi

# Test Prisma Studio
echo ""
echo "4. Testing Prisma Studio..."
if curl -s http://localhost:5555 > /dev/null; then
    echo "   ✅ Prisma Studio is running: http://localhost:5555"
else
    echo "   ❌ Prisma Studio is not running"
fi

echo ""
echo "🎯 Clickable Links for Testing:"
echo "==============================="
echo ""
echo "📱 Frontend Application:"
echo "   http://localhost:3000"
echo ""
echo "🔧 API Endpoints:"
echo "   http://localhost:3001/api/drugs"
echo "   http://localhost:3001/api/categories"
echo "   http://localhost:3001/api/search?query=aspirin"
echo ""
echo "🗄️ Database Management:"
echo "   http://localhost:5555"
echo ""
echo "📊 Netlify Functions (Development):"
echo "   http://localhost:8888/.netlify/functions/api/drugs"
echo ""
echo "✅ Testing Complete!" 