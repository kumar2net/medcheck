const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const serverless = require('serverless-http');
const prisma = require('./prisma');

const app = express();

// Environment configuration
const config = {
  get: (key) => process.env[key],
  getRateLimitConfig: () => ({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
  }),
  getSearchRateLimitConfig: () => ({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 50, // limit each IP to 50 search requests per windowMs
    message: 'Too many search requests from this IP, please try again later.'
  }),
  getCorsConfig: () => ({
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000', 'https://your-netlify-app.netlify.app'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
  })
};

// Security middleware
app.use(helmet());

// Rate limiting configuration
const limiter = rateLimit(config.getRateLimitConfig());
const searchLimiter = rateLimit(config.getSearchRateLimitConfig());

// Speed limiting for API endpoints
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 50, // allow 50 requests per 15 minutes, then...
  delayMs: () => 500 // begin adding 500ms of delay uniformly for each request after delayAfter
});

// Apply rate limiting if enabled
if (config.get('ENABLE_RATE_LIMITING') !== 'false') {
  app.use('/api/', limiter);
  app.use('/api/search', searchLimiter);
  app.use('/api/', speedLimiter);
}

// CORS configuration
app.use(cors(config.getCorsConfig()));

app.use(express.json({ limit: '10mb' }));

// Simple logger
const logger = {
  info: (message) => console.log(`[INFO] ${new Date().toISOString()}: ${message}`),
  error: (message) => console.error(`[ERROR] ${new Date().toISOString()}: ${message}`),
  logRequest: (req, res, duration) => {
    console.log(`[REQUEST] ${req.method} ${req.path} - ${res.statusCode} - ${duration}ms`);
  },
  logSecurity: (message, data) => {
    console.log(`[SECURITY] ${new Date().toISOString()}: ${message}`, data);
  },
  logAuthentication: (action, userId, success) => {
    console.log(`[AUTH] ${new Date().toISOString()}: ${action} - User: ${userId} - Success: ${success}`);
  },
  logPerformance: (operation, duration, metadata) => {
    console.log(`[PERF] ${new Date().toISOString()}: ${operation} - ${duration}ms`, metadata);
  },
  logSearch: (type, query, count) => {
    console.log(`[SEARCH] ${new Date().toISOString()}: ${type} - Query: ${query} - Results: ${count}`);
  }
};

// Request logging middleware
if (config.get('ENABLE_LOGGING') !== 'false') {
  app.use((req, res, next) => {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - start;
      logger.logRequest(req, res, duration);
    });
    
    next();
  });
}

// JWT Authentication middleware
const authenticateToken = (req, res, next) => {
  if (config.get('ENABLE_AUTHENTICATION') === 'false') {
    return next();
  }

  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    logger.logSecurity('Missing authentication token', { url: req.url });
    return res.status(401).json({ 
      success: false, 
      message: 'Access token required' 
    });
  }

  jwt.verify(token, config.get('JWT_SECRET') || 'your-secret-key', (err, user) => {
    if (err) {
      logger.logSecurity('Invalid authentication token', { url: req.url, error: err.message });
      return res.status(403).json({ 
        success: false, 
        message: 'Invalid or expired token' 
      });
    }
    req.user = user;
    next();
  });
};

// Optional authentication for endpoints that can work with or without auth
const optionalAuth = (req, res, next) => {
  if (config.get('ENABLE_AUTHENTICATION') === 'false') {
    return next();
  }

  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token) {
    jwt.verify(token, config.get('JWT_SECRET') || 'your-secret-key', (err, user) => {
      if (!err) {
        req.user = user;
      }
      next();
    });
  } else {
    next();
  }
};

// Standardized response utility
function createResponse(success, data = null, message = '', errors = null) {
  return {
    success,
    data,
    message,
    ...(errors && { errors }),
    timestamp: new Date().toISOString()
  };
}

// Global error handler middleware
function errorHandler(err, req, res, next) {
  logger.error(`${req.method} ${req.path}: ${err.message}`);
  
  if (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND') {
    return res.status(503).json(createResponse(false, null, 'Database connection error'));
  }
  
  if (err.name === 'ValidationError') {
    return res.status(400).json(createResponse(false, null, 'Validation error', err.errors));
  }

  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json(createResponse(false, null, 'CORS policy violation'));
  }
  
  res.status(500).json(createResponse(false, null, 'Internal server error'));
}

// Input validation middleware
function validateSearchInput(req, res, next) {
  const { query, category } = req.query;
  
  if (query) {
    const sanitizedQuery = query.replace(/[^\w\s-]/gi, '').trim().substring(0, 100);
    if (sanitizedQuery !== query) {
      logger.logSecurity('Invalid search query', { original: query, sanitized: sanitizedQuery });
      return res.status(400).json(createResponse(false, null, 'Invalid characters in search query'));
    }
    req.query.query = sanitizedQuery;
  }
  
  if (category && category !== 'all') {
    const allowedCategories = ['Diabetes', 'Pain Relief', 'Antibiotics', 'Hypertension', 'Cardiovascular', 'Antiallergic', 'Gastrointestinal', 'Supplements', 'Thyroid', 'Sleep Aid'];
    if (!allowedCategories.includes(category)) {
      logger.logSecurity('Invalid category parameter', { category });
      return res.status(400).json(createResponse(false, null, 'Invalid category parameter'));
    }
  }
  
  next();
}

// Authentication routes
app.post('/api/auth/register', async (req, res, next) => {
  try {
    const { username, email, password } = req.body;
    
    if (!username || !email || !password) {
      return res.status(400).json(createResponse(false, null, 'Username, email, and password are required'));
    }
    
    if (password.length < (config.get('PASSWORD_MIN_LENGTH') || 6)) {
      return res.status(400).json(createResponse(false, null, `Password must be at least ${config.get('PASSWORD_MIN_LENGTH') || 6} characters long`));
    }
    
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      logger.logAuthentication('register', null, false);
      return res.status(409).json(createResponse(false, null, 'User already exists'));
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, parseInt(config.get('BCRYPT_ROUNDS')) || 10);
    
    // Create user
    const createdUser = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        created_at: new Date()
      },
      select: { id: true }
    });
    const userId = createdUser.id;
    
    // Generate JWT token
    const token = jwt.sign(
      { userId, username, email },
      config.get('JWT_SECRET') || 'your-secret-key',
      { expiresIn: config.get('JWT_EXPIRES_IN') || '24h' }
    );
    
    logger.logAuthentication('register', userId, true);
    res.status(201).json(createResponse(true, { token, user: { id: userId, username, email } }, 'User registered successfully'));
  } catch (err) {
    next(err);
  }
});

app.post('/api/auth/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json(createResponse(false, null, 'Email and password are required'));
    }
    
    // Find user
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      logger.logAuthentication('login', null, false);
      return res.status(401).json(createResponse(false, null, 'Invalid credentials'));
    }
    
    // Check password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      logger.logAuthentication('login', user.id, false);
      return res.status(401).json(createResponse(false, null, 'Invalid credentials'));
    }
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, username: user.username, email: user.email },
      config.get('JWT_SECRET') || 'your-secret-key',
      { expiresIn: config.get('JWT_EXPIRES_IN') || '24h' }
    );
    
    logger.logAuthentication('login', user.id, true);
    res.json(createResponse(true, { token, user: { id: user.id, username: user.username, email: user.email } }, 'Login successful'));
  } catch (err) {
    next(err);
  }
});

// API Routes with optional authentication
app.get('/api/drugs', optionalAuth, async (req, res, next) => {
  try {
    const startTime = Date.now();
    const drugs = await prisma.drug.findMany();
    const duration = Date.now() - startTime;
    
    logger.logPerformance('get_drugs', duration, { count: drugs.length });
    
    const transformedDrugs = drugs.map(drug => ({
      ...drug,
      sideEffects: typeof drug.sideEffects === 'string' ? JSON.parse(drug.sideEffects) : drug.sideEffects,
      alternatives: typeof drug.alternatives === 'string' ? JSON.parse(drug.alternatives) : drug.alternatives
    }));
    res.json(createResponse(true, transformedDrugs, 'Drugs retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.get('/api/search', validateSearchInput, optionalAuth, async (req, res, next) => {
  const { query, category } = req.query;
  try {
    const startTime = Date.now();
    const where = {};
    if (category && category !== 'all') {
      where.category = category;
    }
    if (query) {
      where.name = { contains: query, mode: 'insensitive' };
    }
    const drugs = await prisma.drug.findMany({ where });
    const duration = Date.now() - startTime;
    
    logger.logPerformance('search_drugs', duration, { query, category, count: drugs.length });
    
    const transformedDrugs = drugs.map(drug => ({
      ...drug,
      sideEffects: typeof drug.sideEffects === 'string' ? JSON.parse(drug.sideEffects) : drug.sideEffects,
      alternatives: typeof drug.alternatives === 'string' ? JSON.parse(drug.alternatives) : drug.alternatives
    }));
    res.json(createResponse(true, transformedDrugs, 'Search completed successfully'));
  } catch (err) {
    next(err);
  }
});

app.get('/api/categories', optionalAuth, async (req, res, next) => {
  try {
    const startTime = Date.now();
    const categories = await prisma.drug.findMany({
      select: { category: true },
      distinct: ['category']
    });
    const duration = Date.now() - startTime;
    
    logger.logPerformance('get_categories', duration, { count: categories.length });
    
    res.json(createResponse(true, ['all', ...categories.map(c => c.category)], 'Categories retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.get('/api/trending', optionalAuth, async (req, res, next) => {
  try {
    const startTime = Date.now();
    const trending = await prisma.drug.findMany({
      orderBy: { price: 'desc' },
      take: 5
    });
    const duration = Date.now() - startTime;
    
    logger.logPerformance('get_trending', duration, { count: trending.length });
    
    const transformedTrending = trending.map(drug => ({
      ...drug,
      sideEffects: typeof drug.sideEffects === 'string' ? JSON.parse(drug.sideEffects) : drug.sideEffects,
      alternatives: typeof drug.alternatives === 'string' ? JSON.parse(drug.alternatives) : drug.alternatives
    }));
    res.json(createResponse(true, transformedTrending, 'Trending drugs retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.get('/api/stats', optionalAuth, async (req, res, next) => {
  try {
    const startTime = Date.now();
    const stats = await prisma.drug
      .groupBy({
        by: ['category'],
        _count: { _all: true },
        _avg: { price: true }
      });
    const duration = Date.now() - startTime;
    
    logger.logPerformance('get_stats', duration, { count: stats.length });
    
    res.json(createResponse(true, stats, 'Statistics retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.post('/api/drugs/by-names', optionalAuth, async (req, res, next) => {
  const { names } = req.body;
  if (!names || !Array.isArray(names)) {
    return res.status(400).json(createResponse(false, null, '`names` must be an array of drug names.'));
  }

  try {
    const startTime = Date.now();
    const drugs = await prisma.drug.findMany({
      where: {
        name: {
          in: names
        }
      }
    });
    const duration = Date.now() - startTime;
    
    logger.logPerformance('get_drugs_by_names', duration, { names: names.length, found: drugs.length });
    
    const transformedDrugs = drugs.map(drug => ({
      ...drug,
      sideEffects: typeof drug.sideEffects === 'string' ? JSON.parse(drug.sideEffects) : drug.sideEffects,
      alternatives: typeof drug.alternatives === 'string' ? JSON.parse(drug.alternatives) : drug.alternatives
    }));
    res.json(createResponse(true, transformedDrugs, 'Drugs retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

// Protected routes (require authentication)
app.get('/api/user/profile', authenticateToken, async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: { id: true, username: true, email: true, created_at: true }
    });
    if (!user) {
      return res.status(404).json(createResponse(false, null, 'User not found'));
    }
    res.json(createResponse(true, user, 'Profile retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

// Family Members API endpoints
app.get('/api/family-members', async (req, res, next) => {
  try {
    const members = await prisma.familyMember.findMany({
      where: { isActive: true },
      include: {
        medications: {
          where: { isActive: true },
          include: { drug: true }
        }
      },
      orderBy: { name: 'asc' }
    });
    
    logger.logSearch('family-members', null, members.length);
    res.json(createResponse(true, members, 'Family members retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.post('/api/family-members', async (req, res, next) => {
  try {
    const { name, age, photo, allergies, conditions, emergencyContact, emergencyPhone, role } = req.body;
    
    if (!name) {
      return res.status(400).json(createResponse(false, null, 'Name is required'));
    }
    
    const member = await prisma.familyMember.create({
      data: {
        name,
        age: age ? parseInt(age) : null,
        photo,
        allergies: allergies ? JSON.stringify(allergies) : null,
        conditions: conditions ? JSON.stringify(conditions) : null,
        emergencyContact,
        emergencyPhone,
        role: role || 'member'
      }
    });
    
    res.status(201).json(createResponse(true, member, 'Family member created successfully'));
  } catch (err) {
    next(err);
  }
});

app.put('/api/family-members/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, age, photo, allergies, conditions, emergencyContact, emergencyPhone, role } = req.body;
    
    const member = await prisma.familyMember.update({
      where: { id: parseInt(id) },
      data: {
        name,
        age: age ? parseInt(age) : null,
        photo,
        allergies: allergies ? JSON.stringify(allergies) : null,
        conditions: conditions ? JSON.stringify(conditions) : null,
        emergencyContact,
        emergencyPhone,
        role
      }
    });
    
    res.json(createResponse(true, member, 'Family member updated successfully'));
  } catch (err) {
    next(err);
  }
});

app.delete('/api/family-members/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    await prisma.familyMember.update({
      where: { id: parseInt(id) },
      data: { isActive: false }
    });
    
    res.json(createResponse(true, null, 'Family member deleted successfully'));
  } catch (err) {
    next(err);
  }
});

// Family Medications API endpoints
app.get('/api/family-medications/:memberId', async (req, res, next) => {
  try {
    const { memberId } = req.params;
    
    const medications = await prisma.familyMedication.findMany({
      where: { 
        familyMemberId: parseInt(memberId),
        isActive: true 
      },
      include: { drug: true },
      orderBy: { created_at: 'desc' }
    });
    
    res.json(createResponse(true, medications, 'Medications retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

app.post('/api/family-medications', async (req, res, next) => {
  try {
    const { familyMemberId, drugId, dosage, frequency, notes, cost } = req.body;
    
    if (!familyMemberId || !drugId) {
      return res.status(400).json(createResponse(false, null, 'Family member ID and drug ID are required'));
    }
    
    const medication = await prisma.familyMedication.create({
      data: {
        familyMemberId: parseInt(familyMemberId),
        drugId: parseInt(drugId),
        dosage,
        frequency,
        notes,
        cost: cost ? parseFloat(cost) : null
      },
      include: { drug: true }
    });
    
    res.status(201).json(createResponse(true, medication, 'Medication added successfully'));
  } catch (err) {
    next(err);
  }
});

app.put('/api/family-medications/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { dosage, frequency, notes, cost, isActive } = req.body;
    
    const medication = await prisma.familyMedication.update({
      where: { id: parseInt(id) },
      data: {
        dosage,
        frequency,
        notes,
        cost: cost ? parseFloat(cost) : null,
        isActive
      },
      include: { drug: true }
    });
    
    res.json(createResponse(true, medication, 'Medication updated successfully'));
  } catch (err) {
    next(err);
  }
});

app.delete('/api/family-medications/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    await prisma.familyMedication.update({
      where: { id: parseInt(id) },
      data: { isActive: false }
    });
    
    res.json(createResponse(true, null, 'Medication removed successfully'));
  } catch (err) {
    next(err);
  }
});

// Drug interaction checking endpoint
app.post('/api/interactions/check', async (req, res, next) => {
  try {
    const { drugIds, memberId } = req.body;
    
    if (!drugIds || !Array.isArray(drugIds) || drugIds.length === 0) {
      return res.status(400).json(createResponse(false, null, 'Drug IDs array is required'));
    }
    
    // Get drug details
    const drugs = await prisma.drug.findMany({
      where: { id: { in: drugIds.map(id => parseInt(id)) } }
    });
    
    // Basic interaction checking logic (simplified for MVP)
    const interactions = [];
    const highRiskCombinations = [
      ['Aspirin', 'Ibuprofen'],
      ['Metformin', 'Alcohol'],
      ['Amlodipine', 'Simvastatin']
    ];
    
    for (let i = 0; i < drugs.length; i++) {
      for (let j = i + 1; j < drugs.length; j++) {
        const drug1 = drugs[i];
        const drug2 = drugs[j];
        
        // Check for known interactions
        const hasInteraction = highRiskCombinations.some(combo => 
          (drug1.name.includes(combo[0]) && drug2.name.includes(combo[1])) ||
          (drug1.name.includes(combo[1]) && drug2.name.includes(combo[0]))
        );
        
        if (hasInteraction) {
          interactions.push({
            severity: 'high',
            drug1: drug1.name,
            drug2: drug2.name,
            description: `Potential interaction between ${drug1.name} and ${drug2.name}`,
            recommendation: 'Consult healthcare provider before combining these medications'
          });
        }
      }
    }
    
    res.json(createResponse(true, { interactions, drugCount: drugs.length }, 'Interaction check completed'));
  } catch (err) {
    next(err);
  }
});

// Drug-specific interaction check
app.post('/api/interactions/drug-check', async (req, res, next) => {
  try {
    const { drugName, familyMemberId } = req.body;
    
    if (!drugName) {
      return res.status(400).json(createResponse(false, null, 'Drug name is required'));
    }

    if (!familyMemberId) {
      return res.status(400).json(createResponse(false, null, 'Family member ID is required'));
    }

    // Get active medications for the specific family member
    const memberMedications = await prisma.familyMedication.findMany({
      where: { 
        isActive: true,
        familyMemberId: parseInt(familyMemberId)
      },
      include: { 
        drug: true,
        familyMember: true
      }
    });

    // Get family member info
    const familyMember = await prisma.familyMember.findUnique({
      where: { id: parseInt(familyMemberId) }
    });

    if (!familyMember) {
      return res.status(404).json(createResponse(false, null, 'Family member not found'));
    }

    // Find the drug being checked
    const targetDrug = await prisma.drug.findFirst({
      where: {
        name: {
          contains: drugName,
          mode: 'insensitive'
        }
      }
    });

    if (!targetDrug) {
      return res.json(createResponse(true, { 
        interactions: [],
        message: `Drug '${drugName}' not found in database`
      }, 'Drug not found'));
    }

    const interactions = [];
    const highRiskCombinations = [
      ['Aspirin', 'Ibuprofen'],
      ['Metformin', 'Alcohol'],
      ['Amlodipine', 'Simvastatin'],
      ['Ciprofloxacin', 'Calcium'],
      ['Ciprofloxacin', 'Iron'],
      ['Ciprofloxacin', 'Antacids'],
      ['Warfarin', 'Aspirin'],
      ['Warfarin', 'Ibuprofen']
    ];

    // Check interactions with the specific family member's medications
    for (const medication of memberMedications) {
      const familyDrug = medication.drug;
      
      const hasInteraction = highRiskCombinations.some(combo => 
        (targetDrug.name.includes(combo[0]) && familyDrug.name.includes(combo[1])) ||
        (targetDrug.name.includes(combo[1]) && familyDrug.name.includes(combo[0]))
      );

      if (hasInteraction) {
        interactions.push({
          severity: 'high',
          familyMember: familyMember.name,
          drugs: [targetDrug.name, familyDrug.name],
          description: `Potential interaction between ${targetDrug.name} and ${familyDrug.name}`,
          recommendation: 'Consult with healthcare provider before taking together'
        });
      }
    }

    // Add general drug information
    const drugInfo = {
      name: targetDrug.name,
      category: targetDrug.category,
      strength: targetDrug.strength,
      manufacturer: targetDrug.manufacturer,
      price: targetDrug.price
    };

    // Create a clear message based on results
    let message = '';
    if (interactions.length === 0) {
      message = `✅ No drug interactions found! ${targetDrug.name} appears to be safe to use with ${familyMember.name}'s current medications.`;
    } else {
      message = `⚠️ Found ${interactions.length} potential interaction(s) with ${targetDrug.name} for ${familyMember.name}. Please review carefully.`;
    }

    res.json(createResponse(true, { 
      interactions, 
      drugInfo,
      familyMember: {
        id: familyMember.id,
        name: familyMember.name,
        age: familyMember.age
      },
      totalMedications: memberMedications.length,
      isSafe: interactions.length === 0,
      safetyMessage: message
    }, message));
  } catch (err) {
    next(err);
  }
});

// Family-wide interaction check
app.post('/api/interactions/family-check', async (req, res, next) => {
  try {
    // Get all active medications for all family members
    const allMedications = await prisma.familyMedication.findMany({
      where: { isActive: true },
      include: { 
        drug: true,
        familyMember: true
      }
    });
    
    const drugIds = allMedications.map(med => med.drugId);
    const uniqueDrugIds = [...new Set(drugIds)];
    
    // Check interactions across all family medications
    const drugs = await prisma.drug.findMany({
      where: { id: { in: uniqueDrugIds } }
    });
    
    const interactions = [];
    const highRiskCombinations = [
      ['Aspirin', 'Ibuprofen'],
      ['Metformin', 'Alcohol'],
      ['Amlodipine', 'Simvastatin']
    ];
    
    for (let i = 0; i < drugs.length; i++) {
      for (let j = i + 1; j < drugs.length; j++) {
        const drug1 = drugs[i];
        const drug2 = drugs[j];
        
        const hasInteraction = highRiskCombinations.some(combo => 
          (drug1.name.includes(combo[0]) && drug2.name.includes(combo[1])) ||
          (drug1.name.includes(combo[1]) && drug2.name.includes(combo[0]))
        );
        
        if (hasInteraction) {
          // Find which family members are taking these drugs
          const members1 = allMedications.filter(med => med.drugId === drug1.id).map(med => med.familyMember.name);
          const members2 = allMedications.filter(med => med.drugId === drug2.id).map(med => med.familyMember.name);
          
          interactions.push({
            severity: 'high',
            drug1: drug1.name,
            drug2: drug2.name,
            description: `Family interaction: ${drug1.name} and ${drug2.name}`,
            affectedMembers: [...new Set([...members1, ...members2])],
            recommendation: 'Review medications with healthcare provider'
          });
        }
      }
    }
    
    res.json(createResponse(true, { 
      interactions, 
      totalMedications: allMedications.length,
      uniqueDrugs: uniqueDrugIds.length,
      familyMembers: [...new Set(allMedications.map(med => med.familyMember.name))]
    }, 'Family interaction check completed'));
  } catch (err) {
    next(err);
  }
});

// Emergency information endpoint
app.get('/api/emergency/:memberId', async (req, res, next) => {
  try {
    const { memberId } = req.params;
    
    const member = await prisma.familyMember.findUnique({
      where: { id: parseInt(memberId) },
      include: {
        medications: {
          where: { isActive: true },
          include: { drug: true }
        }
      }
    });
    
    if (!member) {
      return res.status(404).json(createResponse(false, null, 'Family member not found'));
    }
    
    const emergencyInfo = {
      name: member.name,
      age: member.age,
      allergies: member.allergies ? JSON.parse(member.allergies) : [],
      conditions: member.conditions ? JSON.parse(member.conditions) : [],
      emergencyContact: member.emergencyContact,
      emergencyPhone: member.emergencyPhone,
      criticalMedications: member.medications.map(med => ({
        name: med.drug.name,
        dosage: med.dosage,
        frequency: med.frequency
      }))
    };
    
    res.json(createResponse(true, emergencyInfo, 'Emergency information retrieved'));
  } catch (err) {
    next(err);
  }
});

// Enhanced drug search endpoint
app.get('/api/drugs/search', async (req, res, next) => {
  try {
    const { query, category, manufacturer, limit = 50 } = req.query;
    
    let searchConditions = {};
    
    if (query) {
      searchConditions.OR = [
        { name: { contains: query, mode: 'insensitive' } },
        { combination: { contains: query, mode: 'insensitive' } },
        { manufacturer: { contains: query, mode: 'insensitive' } }
      ];
    }
    
    if (category) {
      searchConditions.category = { contains: category };
    }
    
    if (manufacturer) {
      searchConditions.manufacturer = { contains: manufacturer };
    }
    
    const drugs = await prisma.drug.findMany({
      where: searchConditions,
      take: parseInt(limit),
      orderBy: { name: 'asc' }
    });
    
    logger.logSearch('drugs', query || 'all', drugs.length);
    res.json(createResponse(true, drugs, 'Drugs retrieved successfully'));
  } catch (err) {
    next(err);
  }
});

// Apply error handler
app.use(errorHandler);

// Export the serverless function
module.exports.handler = serverless(app); 