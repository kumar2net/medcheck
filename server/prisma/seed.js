const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting drug seed...');

  // Drugs to upsert
  const drugs = [
    {
      name: 'Startglim M2',
      category: 'Diabetes',
      combination: 'Glimepiride + Metformin Hydrochloride',
      strength: 'Glimepiride 2 mg + Metformin 500 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Mankind Pharma Ltd',
      price: 10.00,
      sideEffects: [
        'Hypoglycemia',
        'Headache',
        'Nausea',
        'Dizziness',
        'Weight gain',
        'Stomach upset',
        'Diarrhea',
        'Metallic taste',
        'Anemia (rare)',
        'Lactic acidosis (rare)'
      ],
      alternatives: [
        'Glimestar M2',
        'Glycomet GP2',
        'Glimy M2',
        'Azulix 2 MF',
        'Gluconorm G2'
      ]
    },
    {
      name: 'Dapa 10 mg',
      category: 'Diabetes',
      combination: 'Dapagliflozin',
      strength: 'Dapagliflozin 10 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Shrrishti Health Care Products Pvt Ltd',
      price: 15.00,
      sideEffects: [
        'Increased urination',
        'Urinary tract infection',
        'Genital fungal infection',
        'Dehydration',
        'Dizziness',
        'Back pain',
        'Hypoglycemia (with other antidiabetics)',
        'Ketoacidosis (rare)'
      ],
      alternatives: [
        'Forxiga',
        'Dapanorm',
        'Dapamac',
        'Sugaflo',
        'Dapaford'
      ]
    },
    {
      name: 'Sacurise',
      category: 'Diabetes',
      combination: 'Vildagliptin + Metformin',
      strength: 'Vildagliptin 50 mg + Metformin 500 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Novartis India Ltd',
      price: 18.50,
      sideEffects: [
        'Nausea',
        'Diarrhea',
        'Upper respiratory tract infection',
        'Headache',
        'Dizziness',
        'Vomiting',
        'Hypoglycemia (when used with insulin or sulfonylureas)',
        'Metallic taste',
        'Stomach upset'
      ],
      alternatives: [
        'Jalra M',
        'Zomelis Met',
        'Viglim M',
        'Vildaray M',
        'Dynaglipt M'
      ]
    },
    {
      name: 'Dolo 650',
      category: 'Pain Relief',
      combination: 'Paracetamol',
      strength: 'Paracetamol 650 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Micro Labs Ltd',
      price: 2.50,
      sideEffects: [
        'Nausea',
        'Vomiting',
        'Stomach upset',
        'Liver damage (with overdose)',
        'Allergic reactions (rare)',
        'Skin rash (rare)'
      ],
      alternatives: [
        'Crocin 650',
        'Calpol 650',
        'Pacimol 650',
        'Paracip 650',
        'Tylenol'
      ]
    },
    {
      name: 'Azithral 500',
      category: 'Antibiotics',
      combination: 'Azithromycin',
      strength: 'Azithromycin 500 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Alembic Pharmaceuticals Ltd',
      price: 12.00,
      sideEffects: [
        'Nausea',
        'Vomiting',
        'Diarrhea',
        'Stomach pain',
        'Headache',
        'Dizziness',
        'Hearing problems (rare)',
        'Heart rhythm changes (rare)'
      ],
      alternatives: [
        'Zithromax',
        'Azimax',
        'Azax',
        'Zady',
        'Azicip'
      ]
    },
    {
      name: 'Amlodac 5',
      category: 'Hypertension',
      combination: 'Amlodipine',
      strength: 'Amlodipine 5 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Cadila Healthcare Ltd',
      price: 4.25,
      sideEffects: [
        'Ankle swelling',
        'Fatigue',
        'Dizziness',
        'Flushing',
        'Headache',
        'Palpitations',
        'Nausea',
        'Abdominal pain'
      ],
      alternatives: [
        'Amlong',
        'Stamlo 5',
        'Lupidip',
        'Amlovas',
        'Norvasc'
      ]
    },
    {
      name: 'Lipikind CV 20',
      category: 'Cardiovascular',
      combination: 'Atorvastatin + Clopidogrel',
      strength: 'Atorvastatin 20 mg + Clopidogrel 75 mg',
      dosageForm: 'Capsule',
      manufacturer: 'Mankind Pharma Ltd',
      price: 22.00,
      sideEffects: [
        'Muscle pain',
        'Headache',
        'Nausea',
        'Diarrhea',
        'Bleeding risk',
        'Stomach upset',
        'Dizziness',
        'Liver enzyme elevation (rare)'
      ],
      alternatives: [
        'Rosulip Plus',
        'Ecosprin AV',
        'Storvas CV',
        'Atorlip CV',
        'Lipitor Plus'
      ]
    },
    {
      name: 'Neurobion Forte',
      category: 'Supplements',
      combination: 'Vitamin B Complex',
      strength: 'B1(10mg) + B6(3mg) + B12(15mcg)',
      dosageForm: 'Tablet',
      manufacturer: 'Merck Ltd',
      price: 8.75,
      sideEffects: [
        'Mild stomach upset',
        'Nausea',
        'Allergic reactions (rare)',
        'Flushing',
        'Tingling sensation (rare)'
      ],
      alternatives: [
        'Becosules',
        'Supradyn',
        'Nervijen Plus',
        'Cobadex CZS',
        'Vitcofol'
      ]
    },
    {
      name: 'Bisolong 5',
      category: 'Hypertension',
      combination: 'Bisoprolol Fumarate',
      strength: 'Bisoprolol 5 mg',
      dosageForm: 'Tablet',
      manufacturer: 'Micro Labs Ltd',
      price: 6.75,
      sideEffects: [
        'Fatigue',
        'Dizziness',
        'Headache',
        'Cold hands and feet',
        'Nausea',
        'Diarrhea',
        'Slow heart rate',
        'Low blood pressure',
        'Sleep disturbances',
        'Depression (rare)'
      ],
      alternatives: [
        'Concor 5',
        'Corbis 5',
        'Bisoprol',
        'Bisocar',
        'Cardivas'
      ]
    }
  ];

  let upserted = 0;
  for (const drug of drugs) {
    try {
          const drugData = {
      ...drug,
      sideEffects: JSON.stringify(drug.sideEffects),
      alternatives: JSON.stringify(drug.alternatives)
    };
    
    await prisma.drug.upsert({
      where: { name: drug.name },
      update: drugData,
      create: drugData
    });
      console.log(`✅ Upserted: ${drug.name}`);
      upserted++;
    } catch (err) {
      console.error(`❌ Error upserting ${drug.name}:`, err);
    }
  }

  // Print summary
  const allDrugs = await prisma.drug.findMany({ select: { id: true, name: true, category: true } });
  console.log(`\n📋 Drugs table summary (${allDrugs.length} rows):`);
  allDrugs.forEach(d => console.log(`- [${d.id}] ${d.name} (${d.category})`));

  if (upserted === drugs.length) {
    console.log('\n🌱 Drug seed completed successfully.');
  } else {
    console.log(`\n⚠️  Drug seed completed with errors. Upserted ${upserted}/${drugs.length}.`);
  }
}

main()
  .then(() => prisma.$disconnect())
  .catch(e => {
    console.error('❌ Seed script failed:', e);
    prisma.$disconnect();
    process.exit(1);
  }); 