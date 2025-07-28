const { PrismaClient } = require('@prisma/client');

// Create a single PrismaClient instance that can be shared throughout the app
const globalForPrisma = global;

const prisma = globalForPrisma.prisma || new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

module.exports = prisma; 