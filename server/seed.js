const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');
  
  try {
    // Read the drug data from the JSON file
    const drugDataPath = path.join(__dirname, '..', 'localhost-drugs-export.json');
    const drugData = JSON.parse(fs.readFileSync(drugDataPath, 'utf8'));
    
    console.log(`Found ${drugData.length} drugs to import`);
    
    // Clear existing data in correct order to handle foreign key constraints
    await prisma.familyMedication.deleteMany({});
    console.log('Cleared existing family medications');
    
    await prisma.familyMember.deleteMany({});
    console.log('Cleared existing family members');
    
    await prisma.user.deleteMany({});
    console.log('Cleared existing users');
    
    await prisma.drug.deleteMany({});
    console.log('Cleared existing drugs');
    
    // Insert drugs one by one to handle duplicates
    let imported = 0;
    for (const drug of drugData) {
      try {
        await prisma.drug.create({
          data: {
            name: drug.name,
            category: drug.category || 'Unknown',
            combination: drug.combination || null,
            strength: drug.strength || null,
            dosageForm: drug.dosageForm || null,
            manufacturer: drug.manufacturer || null,
            price: drug.price ? parseFloat(drug.price) : null,
            sideEffects: drug.sideEffects ? JSON.stringify(drug.sideEffects) : null,
            alternatives: drug.alternatives ? JSON.stringify(drug.alternatives) : null
          }
        });
        imported++;
      } catch (error) {
        if (error.code !== 'P2002') { // P2002 is unique constraint violation
          console.error(`Error importing drug ${drug.name}:`, error.message);
        }
      }
    }
    
    console.log(`Successfully imported ${imported} drugs`);
    
    // Create a sample family member for testing
    const sampleMember = await prisma.familyMember.create({
      data: {
        name: 'Test User',
        age: 30,
        allergies: JSON.stringify(['Penicillin']),
        conditions: JSON.stringify(['Hypertension']),
        emergencyContact: 'Emergency Contact',
        emergencyPhone: '+1234567890',
        role: 'admin'
      }
    });
    
    console.log('Created sample family member:', sampleMember.name);
    
  } catch (error) {
    console.error('Error seeding database:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });