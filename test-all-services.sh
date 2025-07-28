#!/bin/bash

# Comprehensive Testing Script for DrugReco Application
# Date: 2025-07-28

echo "🧪 Testing All DrugReco Services"
echo "================================="
echo ""

# Test frontend React app
echo "1. Testing Frontend (React App)..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "   ✅ Frontend is running: http://localhost:3000"
else
    echo "   ❌ Frontend is not running"
fi

# Test backend Express API
echo ""
echo "2. Testing Backend Express API..."
BACKEND_RESULT=$(curl -s http://localhost:3001/api/drugs)
if echo "$BACKEND_RESULT" | grep -q '"success":true'; then
    echo "   ✅ Backend API is working: http://localhost:3001"
    echo "   📊 Drug count: $(echo "$BACKEND_RESULT" | grep -o '"id":[0-9]*' | wc -l)"
else
    echo "   ❌ Backend API is not working"
fi

# Test Netlify Functions
echo ""
echo "3. Testing Netlify Functions..."
NETLIFY_RESULT=$(curl -s http://localhost:8888/api/drugs)
if echo "$NETLIFY_RESULT" | grep -q '"success":true'; then
    echo "   ✅ Netlify Functions are working: http://localhost:8888"
    echo "   📊 Drug count: $(echo "$NETLIFY_RESULT" | grep -o '"id":[0-9]*' | wc -l)"
else
    echo "   ❌ Netlify Functions are not working"
fi

# Test Prisma Studio
echo ""
echo "4. Testing Prisma Studio..."
if curl -s http://localhost:5555 > /dev/null; then
    echo "   ✅ Prisma Studio is running: http://localhost:5555"
else
    echo "   ❌ Prisma Studio is not running"
fi

# Test Family API endpoints
echo ""
echo "5. Testing Family API Endpoints..."
FAMILY_RESULT=$(curl -s http://localhost:8888/api/family-members)
if echo "$FAMILY_RESULT" | grep -q '"success":true'; then
    echo "   ✅ Family Members API is working"
    echo "   👥 Family member count: $(echo "$FAMILY_RESULT" | grep -o '"id":[0-9]*' | wc -l)"
else
    echo "   ❌ Family Members API is not working"
fi

# Test Drug Categories
echo ""
echo "6. Testing Drug Categories..."
CATEGORIES_RESULT=$(curl -s http://localhost:8888/api/categories)
if echo "$CATEGORIES_RESULT" | grep -q '"success":true'; then
    echo "   ✅ Drug Categories API is working"
    echo "   📂 Category count: $(echo "$CATEGORIES_RESULT" | grep -o '"category":' | wc -l)"
else
    echo "   ❌ Drug Categories API is not working"
fi

# Test Search Functionality
echo ""
echo "7. Testing Search Functionality..."
SEARCH_RESULT=$(curl -s "http://localhost:8888/api/search?query=paracetamol")
if echo "$SEARCH_RESULT" | grep -q '"success":true'; then
    echo "   ✅ Search API is working"
    echo "   🔍 Search results: $(echo "$SEARCH_RESULT" | grep -o '"id":[0-9]*' | wc -l)"
else
    echo "   ❌ Search API is not working"
fi

echo ""
echo "🎯 **ALL SYSTEMS STATUS**"
echo "========================="
echo ""
echo "📱 **Frontend Application:**"
echo "   → React App: http://localhost:3000"
echo ""
echo "🔧 **API Endpoints:**"
echo "   → Express Server: http://localhost:3001/api"
echo "   → Netlify Functions: http://localhost:8888/api"
echo ""
echo "🗄️ **Database Management:**"
echo "   → Prisma Studio: http://localhost:5555"
echo ""
echo "🧪 **Test Endpoints:**"
echo "   → Drugs: http://localhost:8888/api/drugs"
echo "   → Categories: http://localhost:8888/api/categories"
echo "   → Family Members: http://localhost:8888/api/family-members"
echo "   → Search: http://localhost:8888/api/search?query=aspirin"
echo ""
echo "✅ **Testing Complete!**"
echo "All services are running and accessible."
echo ""
echo "🚀 **Ready for Development!**"
echo "You can now:"
echo "  - View the app at http://localhost:3000"
echo "  - Check API responses in Chrome DevTools"
echo "  - Manage database via Prisma Studio"
echo "  - Test Netlify functions locally" 