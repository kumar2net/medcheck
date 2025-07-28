const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient();

async function importFamilyData() {
  try {
    console.log('🎯 Importing family data from template...\n');

    // Read the template file
    const templatePath = path.join(__dirname, 'family-data-template.json');
    const familyData = JSON.parse(fs.readFileSync(templatePath, 'utf8'));

    // 1. Import custom drugs first
    console.log('📦 Importing custom drugs...');
    for (const customDrug of familyData.customDrugs) {
      try {
        await prisma.drug.create({
          data: {
            name: customDrug.name,
            category: customDrug.category,
            strength: customDrug.strength,
            dosageForm: customDrug.dosageForm,
            manufacturer: customDrug.manufacturer,
            price: customDrug.price,
            sideEffects: customDrug.sideEffects ? JSON.stringify(customDrug.sideEffects) : null,
            alternatives: customDrug.alternatives ? JSON.stringify(customDrug.alternatives) : null
          }
        });
        console.log(`✅ Created custom drug: ${customDrug.name}`);
      } catch (error) {
        if (error.code === 'P2002') {
          console.log(`⚠️  Drug ${customDrug.name} already exists, skipping...`);
        } else {
          console.error(`❌ Error creating drug ${customDrug.name}:`, error.message);
        }
      }
    }

    // 2. Import family members and their medications
    console.log('\n👨‍👩‍👧‍👦 Importing family members...');
    for (const member of familyData.familyMembers) {
      // Create family member
      const familyMember = await prisma.familyMember.create({
        data: {
          name: member.name,
          age: member.age,
          allergies: JSON.stringify(member.allergies),
          conditions: JSON.stringify(member.conditions),
          emergencyContact: member.emergencyContact,
          emergencyPhone: member.emergencyPhone,
          role: member.role
        }
      });

      console.log(`✅ Created family member: ${familyMember.name}`);

      // Assign medications to family member
      for (const medication of member.medications) {
        try {
          // Find the drug
          const drug = await prisma.drug.findFirst({
            where: {
              name: {
                contains: medication.drugName,
                mode: 'insensitive'
              }
            }
          });

          if (drug) {
            await prisma.familyMedication.create({
              data: {
                familyMemberId: familyMember.id,
                drugId: drug.id,
                dosage: medication.dosage,
                frequency: medication.frequency,
                notes: medication.notes,
                cost: medication.cost
              }
            });
            console.log(`💊 Assigned ${drug.name} to ${familyMember.name}`);
          } else {
            console.log(`⚠️  Drug not found: ${medication.drugName} for ${familyMember.name}`);
          }
        } catch (error) {
          console.error(`❌ Error assigning medication ${medication.drugName} to ${familyMember.name}:`, error.message);
        }
      }
    }

    console.log('\n🎉 Family data import completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`- Custom drugs created: ${familyData.customDrugs.length}`);
    console.log(`- Family members created: ${familyData.familyMembers.length}`);

  } catch (error) {
    console.error('❌ Error importing family data:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the import
importFamilyData(); 