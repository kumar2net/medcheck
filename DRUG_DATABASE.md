# 💊 Drug Database Reference

## Available Medications

The DrugReco MVP comes pre-loaded with 8 common medications across different categories:

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
- **Bisolong 5** - Bisoprolol Fumarate (Micro Labs)

### 🫀 **Cardiovascular**
- **Lipikind CV 20** - Atorvastatin + Clopidogrel (Mankind Pharma)

### 💊 **Supplements**
- **Neurobion Forte** - Vitamin B Complex (Merck Ltd)

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

---

**Last Updated:** 2025-07-30  
**Database Version:** 8 medications across 6 categories  
**Status:** Ready for user testing and expansion