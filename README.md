# 🏥 DrugReco MVP - Drug Recommendation & Family Health Management

A comprehensive web application for managing family medications, checking drug interactions, and discovering drug alternatives.

## 🚀 Features

### Core MVP Features
- **🔍 Drug Search** - Search and discover medications with detailed information
- **👨‍👩‍👧‍👦 Family Management** - Add and manage family members' health profiles
- **💊 Medication Tracking** - Track medications for each family member
- **⚠️ Interaction Checking** - Check for potential drug interactions
- **🔄 Alternative Suggestions** - Discover alternative medications
- **📊 Health Dashboard** - Overview of family medication status

### Technical Features
- **Real-time Search** - Fast drug search with autocomplete
- **Responsive Design** - Works on desktop and mobile devices
- **Data Persistence** - PostgreSQL database for reliable data storage
- **RESTful API** - Clean API architecture for frontend-backend communication

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern React with hooks and functional components
- **CSS3** - Custom styling with responsive design
- **Fetch API** - HTTP client for API communication

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web application framework
- **Prisma ORM** - Database toolkit and ORM
- **PostgreSQL** - Relational database
- **JWT** - Authentication tokens
- **Helmet** - Security middleware

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
git clone https://github.com/your-username/drugreco-mvp.git
cd drugreco-mvp
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
createdb drugreco_dev

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
DATABASE_URL="postgresql://username:password@localhost:5432/drugreco_dev"

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
drugreco-mvp/
├── client/                 # React frontend application
│   ├── public/            # Static assets
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom React hooks
│   │   └── services/      # API service layer
│   └── package.json
├── server/                # Express backend application
│   ├── config/           # Configuration files
│   ├── lib/              # Shared libraries
│   ├── logs/             # Application logs
│   ├── prisma/           # Database schema and migrations
│   ├── services/         # Business logic services
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

### Key Relationships
- Family members can have multiple medications
- Each medication is linked to a drug in the drug database
- Users can manage multiple family members

## 🔐 Security Features

- **Input Validation** - Sanitized user inputs
- **Rate Limiting** - Prevents API abuse
- **CORS Protection** - Secure cross-origin requests
- **Helmet Security** - Security headers and protections
- **JWT Authentication** - Secure user sessions

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
```

## 🐛 Troubleshooting

### Common Issues

**Database Connection Error**
```bash
# Ensure PostgreSQL is running
brew services start postgresql@17

# Check database exists
psql -l | grep drugreco_dev
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

1. **Complete Testing** - Comprehensive testing of all features
2. **Performance Optimization** - Database query optimization
3. **Real Drug Data** - Integration with pharmaceutical APIs
4. **Mobile Optimization** - Enhanced mobile experience
5. **Authentication System** - User registration and login

## 📞 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the TODO.md for known issues
3. Check application logs in `server/logs/`

---

**Version:** 1.0.0  
**Status:** MVP Ready for Testing  
**Last Updated:** 2025-07-31