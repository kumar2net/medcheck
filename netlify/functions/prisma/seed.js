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
    }
  ];

  let upserted = 0;
  for (const drug of drugs) {
    try {
      await prisma.drug.upsert({
        where: { name: drug.name },
        update: drug,
        create: drug
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