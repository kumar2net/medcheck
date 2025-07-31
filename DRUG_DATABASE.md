# 💊 Drug Database Reference

## Available Medications

The DrugReco system now integrates **real clinical data from FDA RxNav APIs** plus a curated set of 8 common medications for testing:

### 🩺 **Diabetes**
- **Startglim M2** - Glimepiride + Metformin (Mankind Pharma)
- **Dapa 10 mg** - Dapagliflozin (Shrrishti Health Care)
- **Sacurise** - Vildagliptin + Metformin (Novartis India)

### 🏥 **Pain Relief**
- **Dolo 650** - Paracetamol (Micro Labs)

### 🦠 **Antibiotics**
- **Azithral 500** - Azithromycin (Alembic Pharmaceuticals)

### ❤️ **Hypertension**
- **Amlodac 5** - Amlodipine (Cadila Healthcare)
- **Bisolong 5** - Bisoprolol Fumarate 5mg (Micro Labs)
- **Bisolong 2.5** - Bisoprolol Fumarate 2.5mg (Micro Labs)

### 🫀 **Cardiovascular**
- **Lipikind CV 20** - Atorvastatin + Clopidogrel (Mankind Pharma)

### 💊 **Supplements**
- **Neurobion Forte** - Vitamin B Complex (Merck Ltd)

### 💧 **Diuretics**
- **Dytor Plus 5** - Torsemide + Spironolactone (Cipla Ltd)

## How to Add Medications

### 1. **Search and Select Method** (Current)
- Type the medication name in the search box
- Select from the dropdown results
- Click or press Enter to add

### 2. **Adding New Drugs to Database**
To add more drugs to the database:

1. Edit `server/prisma/seed.js`
2. Add new drug objects to the `drugs` array
3. Run: `npm run db:seed` from the `server` directory

### Drug Object Structure
```javascript
{
  name: 'Drug Name',
  category: 'Category',
  combination: 'Active Ingredients',
  strength: 'Dosage Strength',
  dosageForm: 'Tablet/Capsule/etc',
  manufacturer: 'Company Name',
  price: 10.50,
  sideEffects: [
    'Side effect 1',
    'Side effect 2'
  ],
  alternatives: [
    'Alternative 1',
    'Alternative 2'
  ]
}
```

## Search Tips

### ✅ **Effective Searches**
- **"Sacurise"** → Finds exact match
- **"Sacu"** → Finds partial matches
- **"Dolo"** → Finds pain relief medications
- **"Diabetes"** → Search by category

### 🔍 **Search Features**
- **Partial matching** - Type first few letters
- **Case insensitive** - works with any capitalization
- **Real-time results** - Updates as you type
- **Category filtering** - Search within specific categories

## Database Commands

### Useful Development Commands
```bash
# View all drugs
curl "http://localhost:3001/api/drugs" | jq '.data'

# Search for specific drug
curl "http://localhost:3001/api/search?query=Sacurise" | jq '.data'

# Reset and reseed database
cd server && npm run db:reset

# Just add new drugs
cd server && npm run db:seed
```

## 🏥 Clinical Data Integration (NEW)

### Real-Time Data Sources
- **FDA RxNav APIs** - 100,000+ drug concepts with real-time interaction data
- **RxNorm Database** - Standardized drug naming and identification
- **FDA Safety Alerts** - Continuous monitoring for drug recalls and warnings
- **Clinical Validation** - Multi-source verification with confidence scoring

### Clinical Features
- **Automated Updates** - Weekly synchronization every Monday at 2 AM
- **Emergency Monitoring** - Real-time safety alert detection every 6 hours
- **RxNorm Mapping** - Automatic mapping of internal drugs to FDA concepts
- **Interaction Validation** - Cross-reference system for data accuracy

### API Endpoints for Clinical Data
```bash
# Check clinical interactions
POST /api/clinical/interactions/check

# Real-time RxNav integration
GET /api/clinical/interactions/realtime/:drug1Id/:drug2Id

# Safety alerts monitoring
POST /api/clinical/alerts/check

# System status and statistics
GET /api/clinical/status
```

### Data Quality Assurance
- **Credibility Scoring** - RxNav (0.95), FDA Alerts (0.99), Manual (0.85)
- **Validation Logs** - Complete audit trail for all clinical data changes
- **Confidence Thresholds** - Minimum 75% confidence for validated interactions
- **Source Attribution** - Full traceability to original clinical sources

---

**Last Updated:** 2025-07-31  
**Database Version:** 8 test medications + 100,000+ RxNorm concepts  
**Status:** Production-ready with clinical data integration ✅