# 🧪 Local Testing Guide - Netlify Migration

**Date**: 2025-07-28  
**Status**: Local testing environment ready

---

## 🚀 **Clickable Links for Testing**

### **Frontend Application**
- **React App**: [http://localhost:3000](http://localhost:3000)
  - Main application interface
  - Family management dashboard
  - Drug interaction checker
  - All UI components

### **API Endpoints (Original Server)**
- **API Base**: [http://localhost:3001](http://localhost:3001)
- **Drugs Endpoint**: [http://localhost:3001/api/drugs](http://localhost:3001/api/drugs)
- **Categories Endpoint**: [http://localhost:3001/api/categories](http://localhost:3001/api/categories)
- **Search Endpoint**: [http://localhost:3001/api/search?query=aspirin](http://localhost:3001/api/search?query=aspirin)
- **Trending Endpoint**: [http://localhost:3001/api/trending](http://localhost:3001/api/trending)
- **Stats Endpoint**: [http://localhost:3001/api/stats](http://localhost:3001/api/stats)

### **Netlify Functions (API) - In Development**
- **API Base**: [http://localhost:8888](http://localhost:8888)
- **Drugs Endpoint**: [http://localhost:8888/.netlify/functions/api/drugs](http://localhost:8888/.netlify/functions/api/drugs)
- **Categories Endpoint**: [http://localhost:8888/.netlify/functions/api/categories](http://localhost:8888/.netlify/functions/api/categories)
- **Search Endpoint**: [http://localhost:8888/.netlify/functions/api/search?query=aspirin](http://localhost:8888/.netlify/functions/api/search?query=aspirin)
- **Trending Endpoint**: [http://localhost:8888/.netlify/functions/api/trending](http://localhost:8888/.netlify/functions/api/trending)
- **Stats Endpoint**: [http://localhost:8888/.netlify/functions/api/stats](http://localhost:8888/.netlify/functions/api/stats)

### **Database Management**
- **Prisma Studio**: [http://localhost:5555](http://localhost:5555)
  - Database management interface
  - View and edit data
  - Run queries

---

## 🧪 **Testing Checklist**

### **1. Frontend Testing**
- [ ] **Homepage**: [http://localhost:3000](http://localhost:3000)
  - Verify page loads correctly
  - Check responsive design
  - Test navigation

- [ ] **Family Dashboard**: [http://localhost:3000](http://localhost:3000)
  - Add family members
  - Edit member profiles
  - Test member deletion

- [ ] **Drug Interaction Checker**: [http://localhost:3000](http://localhost:3000)
  - Search for drugs
  - Check interactions
  - Test family member selection

### **2. API Testing**
- [ ] **Drugs API**: [http://localhost:3001/api/drugs](http://localhost:3001/api/drugs)
  - Should return JSON with all drugs
  - Check response format

- [ ] **Search API**: [http://localhost:3001/api/search?query=aspirin](http://localhost:3001/api/search?query=aspirin)
  - Test search functionality
  - Verify results

- [ ] **Categories API**: [http://localhost:3001/api/categories](http://localhost:3001/api/categories)
  - Should return all drug categories

### **3. Database Testing**
- [ ] **Prisma Studio**: [http://localhost:5555](http://localhost:5555)
  - Verify database connection
  - Check data integrity
  - Test CRUD operations

---

## 🔧 **Local Development Commands**

### **Start Services**
```bash
# Terminal 1: Start Netlify Functions
netlify dev --port 8888

# Terminal 2: Start React Frontend
cd client && npm start

# Terminal 3: Start Prisma Studio (optional)
npx prisma studio --schema=server/prisma/schema.prisma
```

### **Test API Endpoints**
```bash
# Test drugs endpoint
curl http://localhost:8888/.netlify/functions/api/drugs

# Test search endpoint
curl "http://localhost:8888/.netlify/functions/api/search?query=aspirin"

# Test categories endpoint
curl http://localhost:8888/.netlify/functions/api/categories
```

---

## 📊 **Expected Results**

### **API Responses**
- **Status**: 200 OK
- **Content-Type**: application/json
- **Format**: Standardized response with success/data/message

### **Frontend Features**
- **Family Management**: Add, edit, delete family members
- **Drug Search**: Search and filter medications
- **Interaction Checking**: Check drug interactions
- **Responsive Design**: Works on mobile and desktop

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Port Already in Use**
```bash
# Kill processes on ports
lsof -ti:3000 | xargs kill -9
lsof -ti:8888 | xargs kill -9
lsof -ti:5555 | xargs kill -9
```

#### **2. Database Connection Issues**
```bash
# Check database connection
npx prisma db push --schema=server/prisma/schema.prisma
```

#### **3. Function Not Found**
```bash
# Restart Netlify dev server
netlify dev --port 8888
```

---

## 📝 **Testing Notes**

### **Test Data**
- **Drugs**: 39 medications in database
- **Categories**: 10+ drug categories
- **Family Members**: Test with 2-3 members

### **Performance Expectations**
- **API Response**: < 2 seconds
- **Page Load**: < 5 seconds
- **Search Results**: < 3 seconds

---

## 🎯 **Success Criteria**

### **✅ All Features Working**
- [ ] Family member management
- [ ] Drug search and filtering
- [ ] Interaction checking
- [ ] Emergency information
- [ ] Responsive design

### **✅ API Endpoints Responding**
- [ ] All GET endpoints working
- [ ] POST endpoints for data creation
- [ ] PUT/DELETE for data modification
- [ ] Proper error handling

### **✅ Database Operations**
- [ ] Data persistence
- [ ] CRUD operations
- [ ] Relationship queries
- [ ] Data integrity

---

**Local Testing Status**: Ready  
**Last Updated**: 2025-07-28  
**Next Step**: Test all features and verify functionality 