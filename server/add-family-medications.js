const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function addFamilyMemberWithMedications() {
  try {
    console.log('🎯 Adding family member and medications...\n');

    // 1. Add a family member
    const familyMember = await prisma.familyMember.create({
      data: {
        name: 'John Doe', // Change this to actual name
        age: 35, // Change this to actual age
        allergies: JSON.stringify(['Penicillin', 'Sulfa']), // Add actual allergies
        conditions: JSON.stringify(['Hypertension', 'Diabetes']), // Add actual conditions
        emergencyContact: 'Jane Doe', // Change this
        emergencyPhone: '+1234567890', // Change this
        role: 'admin'
      }
    });

    console.log(`✅ Created family member: ${familyMember.name}`);

    // 2. Find existing drugs (or create new ones)
    const existingDrugs = await prisma.drug.findMany({
      where: {
        name: {
          in: [
            'Metformin 500mg',
            'Amlodipine 5mg',
            'Paracetamol 500mg'
          ]
        }
      }
    });

    console.log(`📋 Found ${existingDrugs.length} existing drugs`);

    // 3. Assign medications to family member
    for (const drug of existingDrugs) {
      await prisma.familyMedication.create({
        data: {
          familyMemberId: familyMember.id,
          drugId: drug.id,
          dosage: '1 tablet', // Customize dosage
          frequency: 'Twice daily', // Customize frequency
          notes: 'Take with food', // Add notes
          cost: 65.00 // Add cost
        }
      });
      console.log(`💊 Assigned ${drug.name} to ${familyMember.name}`);
    }

    // 4. Add a custom drug if needed
    const customDrug = await prisma.drug.create({
      data: {
        name: 'Custom Medication', // Change this
        category: 'Custom Category', // Change this
        strength: '10mg', // Change this
        dosageForm: 'Tablet', // Change this
        manufacturer: 'Generic', // Change this
        price: 25.00 // Change this
      }
    });

    console.log(`💊 Created custom drug: ${customDrug.name}`);

    // 5. Assign custom drug
    await prisma.familyMedication.create({
      data: {
        familyMemberId: familyMember.id,
        drugId: customDrug.id,
        dosage: '1 tablet',
        frequency: 'Once daily',
        notes: 'Custom medication notes',
        cost: 25.00
      }
    });

    console.log(`✅ Successfully added family member with medications!`);
    console.log(`\n📊 Summary:`);
    console.log(`- Family Member: ${familyMember.name}`);
    console.log(`- Medications Assigned: ${existingDrugs.length + 1}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the function
addFamilyMemberWithMedications(); 