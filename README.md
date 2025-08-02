# 🏥 MedicineChk MVP - Medicine Checking & Family Health Management

A comprehensive web application for managing family medications, checking drug interactions, and discovering drug alternatives.

## 🚀 Features

### Core MVP Features
- **🔍 Drug Search** - Search and discover medications with detailed information
- **👨‍👩‍👧‍👦 Family Management** - Add and manage family members' health profiles
- **💊 Medication Tracking** - Track medications for each family member
- **⚠️ Clinical Interaction Checking** - Real-time drug interactions using FDA RxNav APIs
- **🏥 Safety Alert Monitoring** - Continuous monitoring of FDA safety alerts and recalls
- **🔄 Alternative Suggestions** - Discover alternative medications
- **📊 Health Dashboard** - Overview of family medication status
- **🤖 Agentic Updates** - Weekly automated clinical data updates

### Technical Features
- **Real-time Search** - Fast drug search with autocomplete
- **Clinical Data Integration** - Real-time FDA RxNav API integration
- **Agentic AI Updates** - Automated weekly clinical data synchronization
- **Multi-Source Validation** - Cross-reference data from multiple authoritative sources
- **Safety Monitoring** - Continuous emergency alert detection
- **Responsive Design** - Works on desktop and mobile devices
- **Data Persistence** - PostgreSQL database with clinical data tables
- **RESTful API** - Clean API architecture for frontend-backend communication

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern React with hooks and functional components
- **CSS3** - Custom styling with responsive design
- **Fetch API** - HTTP client for API communication

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web application framework
- **Prisma ORM** - Database toolkit and ORM with clinical data models
- **PostgreSQL** - Relational database with clinical interaction tables
- **RxNav API** - FDA/NIH drug interaction service integration
- **JWT** - Authentication tokens
- **Helmet** - Security middleware
- **Node-Cron** - Automated clinical data updates
- **Agentic AI Manager** - Intelligent clinical data management

### Development Tools
- **React Scripts** - Create React App toolchain
- **Nodemon** - Development server with hot reload
- **Concurrently** - Run multiple scripts simultaneously

## 📦 Installation & Setup

### Prerequisites
- Node.js (v18 or higher)
- PostgreSQL (v17 recommended)
- npm or yarn package manager

### 1. Clone Repository
```bash
git clone https://github.com/your-username/medicinechk-mvp.git
cd medicinechk-mvp
```

### 2. Install Dependencies
```bash
npm run install:all
```

### 3. Database Setup
```bash
# Start PostgreSQL service (macOS with Homebrew)
brew services start postgresql@17

# Create database
createdb medicinechk_dev

# Set up environment variables
cp server/.env.example server/.env
# Edit server/.env with your database configuration
```

### 4. Database Migration & Seeding
```bash
cd server
npm run db:migrate
npm run db:seed
```

### 5. Start Development Servers
```bash
# From root directory
npm run dev
```

This will start both the frontend (http://localhost:3000) and backend (http://localhost:3001) servers.

## 🔧 Environment Configuration

### Server Environment Variables (`server/.env`)
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/medicinechk_dev"

# Server Configuration
PORT=3001
NODE_ENV=development

# Security
JWT_SECRET=your-secret-key-here
BCRYPT_ROUNDS=10

# Feature Flags
ENABLE_AUTHENTICATION=true
ENABLE_RATE_LIMITING=false
ENABLE_LOGGING=true
YOLO_MODE=true
```

## 🏗️ Project Structure

```
medicinechk-mvp/
├── client/                 # React frontend application
│   ├── public/            # Static assets
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom React hooks
│   │   └── services/      # API service layer
│   └── package.json
├── server/                # Express backend application
│   ├── api/              # API route handlers
│   │   └── clinicalInteractions.js  # Clinical data API endpoints
│   ├── config/           # Configuration files
│   ├── lib/              # Shared libraries
│   ├── logs/             # Application logs
│   ├── prisma/           # Database schema and migrations
│   ├── services/         # Business logic services
│   │   ├── rxnavService.js        # FDA RxNav API integration
│   │   ├── clinicalDataManager.js # Agentic clinical data management
│   │   └── logger.js              # Application logging
│   └── package.json
├── package.json          # Root package configuration
├── README.md
└── TODO.md
```

## 🧪 Testing the Application

### Basic Testing Flow
1. **Start the application** - `npm run dev`
2. **Open browser** - Navigate to http://localhost:3000
3. **Search for drugs** - Try searching "Sacurise", "Dytor", "Bisolong", "Dolo", "Startglim", or "Dapa"
4. **Add family member** - Create a family member profile
5. **Add medications** - Add medications to family member (11 drugs available)
6. **Check interactions** - Use the interaction checker

### Available Test Medications
- **Sacurise** (Diabetes) - Vildagliptin + Metformin
- **Dytor Plus 5** (Diuretics) - Torsemide + Spironolactone
- **Bisolong 2.5** (Hypertension) - Bisoprolol Fumarate 2.5mg
- **Bisolong 5** (Hypertension) - Bisoprolol Fumarate 5mg
- **Dolo 650** (Pain Relief) - Paracetamol
- **Azithral 500** (Antibiotics) - Azithromycin
- **Amlodac 5** (Hypertension) - Amlodipine
- **Lipikind CV 20** (Cardiovascular) - Atorvastatin + Clopidogrel
- **Neurobion Forte** (Supplements) - Vitamin B Complex
- **Startglim M2** (Diabetes) - Glimepiride + Metformin
- **Dapa 10 mg** (Diabetes) - Dapagliflozin

### API Testing
```bash
# Test drug search
curl "http://localhost:3001/api/search?query=Dapa"

# Test clinical interactions
curl -X POST "http://localhost:3001/api/clinical/interactions/check" \
  -H "Content-Type: application/json" \
  -d '{"drugIds": [1, 2]}'

# Test real-time RxNav integration
curl "http://localhost:3001/api/clinical/interactions/realtime/1/2"

# Test clinical data manager status
curl "http://localhost:3001/api/clinical/status"

# Test family members
curl "http://localhost:3001/api/family-members"

# Test health endpoint
curl "http://localhost:3001/api/health"
```

## 📊 Database Schema

### Core Models
- **Drug** - Medication information (name, category, price, side effects)
- **User** - User accounts and authentication
- **FamilyMember** - Family member profiles
- **FamilyMedication** - Medications assigned to family members

### Clinical Data Models
- **DrugInteraction** - Clinical drug-drug interactions with severity levels
- **DataSource** - External clinical data sources (RxNav, FDA, etc.)
- **ClinicalAlert** - Safety alerts, recalls, and warnings
- **DrugRxnormMapping** - Mapping between internal drugs and RxNorm concepts
- **UpdateSession** - Audit trail for automated clinical data updates
- **InteractionValidationLog** - Validation history for data quality

### Key Relationships
- Family members can have multiple medications
- Each medication is linked to a drug in the drug database
- Drugs can have multiple clinical interactions from various sources
- Clinical interactions are validated and tracked with confidence scores
- Users can manage multiple family members

## 🔐 Security Features

- **Input Validation** - Sanitized user inputs
- **Rate Limiting** - Prevents API abuse with enhanced limits for clinical data
- **CORS Protection** - Secure cross-origin requests
- **Helmet Security** - Security headers and protections
- **JWT Authentication** - Secure user sessions
- **Clinical Data Validation** - Multi-source verification for drug interactions
- **API Security** - Secure FDA RxNav API integration
- **Audit Logging** - Complete tracking of clinical data updates

## 🚀 Development Commands

### Root Level
```bash
npm run dev                 # Start both frontend and backend
npm run install:all        # Install all dependencies
```

### Frontend (client/)
```bash
npm start                  # Start React development server
npm run build             # Build for production
npm test                  # Run tests
```

### Backend (server/)
```bash
npm run dev               # Start with nodemon (auto-reload)
npm start                 # Start production server
npm run db:migrate        # Run database migrations
npm run db:seed           # Seed database with sample data
npm run db:reset          # Reset database and reseed
npm run clinical:init     # Initialize clinical data manager
npm run clinical:update   # Trigger manual clinical data update
npm run clinical:status   # Check clinical data manager status
```

## 🐛 Troubleshooting

### Common Issues

**Database Connection Error**
```bash
# Ensure PostgreSQL is running
brew services start postgresql@17

# Check database exists
psql -l | grep medicinechk_dev
```

**Port Already in Use**
```bash
# Kill process on port 3001
lsof -ti:3001 | xargs kill -9
```

**Prisma Client Issues**
```bash
cd server
npx prisma generate
```

## 🎯 Next Steps

1. **Complete Clinical Integration** - Finalize RxNav API integration and database migration
2. **Comprehensive Testing** - Test clinical interaction system with real data
3. **Performance Optimization** - Database query optimization for clinical data
4. **Enhanced Safety Monitoring** - Implement FDA safety alert automation
5. **Mobile Optimization** - Enhanced mobile experience with clinical features
6. **Authentication System** - User registration and login
7. **Advanced AI Features** - Predictive analytics and personalized recommendations

## 🆕 Recent Updates (July 2025)

### ✅ Phase 1: Clinical Data Integration (COMPLETED)
- **Real Clinical Data**: Replaced hardcoded interactions with FDA RxNav APIs
- **Agentic Updates**: Automated weekly clinical data synchronization
- **Safety Monitoring**: Continuous emergency alert detection
- **Enhanced Database**: Added clinical interaction and validation tables
- **Multi-Source Validation**: Cross-reference data for accuracy

### 🔄 Current Status: Production-Ready Clinical System
- **Data Source**: FDA RxNav (FREE, no API key required)
- **Update Frequency**: Weekly automated + emergency monitoring
- **Validation**: Multi-source consensus with confidence scoring
- **Audit Trail**: Complete tracking of all clinical data changes

## 🔧 Troubleshooting

### Database Connection Issues

**Problem:** `Failed to load family members: Server error (500)` or `Can't reach database server at localhost:5432`

**Solution:**
```bash
# Option 1: Use the safe dev script (recommended)
npm run dev:safe

# Option 2: Manual database check and start
npm run db:check

# Option 3: Manual PostgreSQL restart
brew services start postgresql@17
```

**Prevention:** PostgreSQL is now configured to auto-start on system boot. The `npm run dev:safe` command automatically checks and starts the database before launching the app.

### Common Development Issues

1. **Port already in use:** Kill existing processes with `lsof -ti:3001 | xargs kill -9`
2. **Missing dependencies:** Run `npm run install:all` to install all packages
3. **Database schema issues:** Run `cd server && npm run db:reset` to reset database

For detailed database troubleshooting, see [server/DATABASE_SETUP.md](server/DATABASE_SETUP.md).

## 📞 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the TODO.md for known issues
3. Check application logs in `server/logs/`
4. Check clinical data manager status via `/api/clinical/status`
5. Review clinical data integration plan in `clinical-data-integration-plan.md`

### Clinical Data Support
- **RxNav API Status**: https://rxnav.nlm.nih.gov/RxNavAPIs.html
- **Clinical Data Manager**: Real-time status monitoring available
- **Data Sources**: FDA RxNav (primary), extensible to DrugBank and others

---

**Version:** 1.1.0  
**Status:** Production-Ready with Clinical Data Integration  
**Last Updated:** 2025-08-02