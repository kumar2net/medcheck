/**
 * Clinical Interactions API Routes
 * Enhanced drug interaction checking using real clinical data
 */

const express = require('express');
const { PrismaClient } = require('@prisma/client');
const rxnavService = require('../services/rxnavService');
const clinicalDataManager = require('../services/clinicalDataManager');
const logger = require('../services/logger');

const router = express.Router();
const prisma = new PrismaClient();

/**
 * Enhanced drug interaction check using clinical database
 * POST /api/clinical/interactions/check
 */
router.post('/check', async (req, res, next) => {
  try {
    const { drugIds, memberId } = req.body;
    
    if (!drugIds || !Array.isArray(drugIds) || drugIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Drug IDs array is required'
      });
    }

    const startTime = Date.now();
    
    // Get drugs with their RxNorm mappings
    const drugs = await prisma.drug.findMany({
      where: { id: { in: drugIds.map(id => parseInt(id)) } },
      include: {
        rxnormMappings: {
          where: { verified: true },
          orderBy: { confidenceScore: 'desc' }
        }
      }
    });

    if (drugs.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'No drugs found'
      });
    }

    // Step 1: Check clinical database for known interactions
    const clinicalInteractions = await checkClinicalInteractions(drugs);
    
    // Step 2: If we have RxNorm mappings, check RxNav for additional interactions
    const rxnavInteractions = await checkRxNavInteractions(drugs);
    
    // Step 3: Merge and prioritize interactions
    const allInteractions = mergeInteractions(clinicalInteractions, rxnavInteractions);
    
    // Step 4: Get safety alerts for these drugs
    const safetyAlerts = await getSafetyAlerts(drugs);
    
    // Calculate processing time
    const processingTime = Date.now() - startTime;
    
    // Log the interaction check
    logger.info('clinical_interaction_check', {
      drugCount: drugs.length,
      interactionsFound: allInteractions.length,
      alertsFound: safetyAlerts.length,
      processingTime
    });

    res.json({
      success: true,
      data: {
        interactions: allInteractions,
        safetyAlerts: safetyAlerts,
        drugsChecked: drugs.map(drug => ({
          id: drug.id,
          name: drug.name,
          hasRxNormMapping: drug.rxnormMappings.length > 0
        })),
        summary: {
          totalInteractions: allInteractions.length,
          criticalInteractions: allInteractions.filter(i => i.severity === 'critical').length,
          highInteractions: allInteractions.filter(i => i.severity === 'high').length,
          processingTime,
          dataSource: 'clinical_database_and_rxnav',
          lastUpdated: new Date().toISOString()
        }
      }
    });

  } catch (error) {
    logger.logError('clinical_interaction_error', `Clinical interaction check failed: ${error.message}`);
    next(error);
  }
});

/**
 * Get real-time interaction data from RxNav for specific drug pair
 * GET /api/clinical/interactions/realtime/:drug1Id/:drug2Id
 */
router.get('/realtime/:drug1Id/:drug2Id', async (req, res, next) => {
  try {
    const { drug1Id, drug2Id } = req.params;
    
    // Get drugs with RxNorm mappings
    const [drug1, drug2] = await Promise.all([
      prisma.drug.findUnique({
        where: { id: parseInt(drug1Id) },
        include: { rxnormMappings: { where: { verified: true }, orderBy: { confidenceScore: 'desc' } } }
      }),
      prisma.drug.findUnique({
        where: { id: parseInt(drug2Id) },
        include: { rxnormMappings: { where: { verified: true }, orderBy: { confidenceScore: 'desc' } } }
      })
    ]);

    if (!drug1 || !drug2) {
      return res.status(404).json({
        success: false,
        error: 'One or both drugs not found'
      });
    }

    let realTimeInteractions = [];
    
    // Check if both drugs have RxNorm mappings
    if (drug1.rxnormMappings.length > 0 && drug2.rxnormMappings.length > 0) {
      const rxcui1 = drug1.rxnormMappings[0].rxcui;
      const rxcui2 = drug2.rxnormMappings[0].rxcui;
      
      // Get real-time interaction data from RxNav
      realTimeInteractions = await rxnavService.checkInteractionBetweenDrugs(rxcui1, rxcui2);
    }

    // Also check our clinical database
    const clinicalInteraction = await prisma.drugInteraction.findFirst({
      where: {
        OR: [
          { drug1Id: parseInt(drug1Id), drug2Id: parseInt(drug2Id) },
          { drug1Id: parseInt(drug2Id), drug2Id: parseInt(drug1Id) }
        ]
      },
      include: { source: true }
    });

    res.json({
      success: true,
      data: {
        drug1: { id: drug1.id, name: drug1.name },
        drug2: { id: drug2.id, name: drug2.name },
        realTimeInteractions,
        clinicalInteraction,
        hasRxNormMapping: {
          drug1: drug1.rxnormMappings.length > 0,
          drug2: drug2.rxnormMappings.length > 0
        },
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.logError('realtime_interaction_error', `Real-time interaction check failed: ${error.message}`);
    next(error);
  }
});

/**
 * Get clinical alerts for specific drugs
 * POST /api/clinical/alerts/check
 */
router.post('/alerts/check', async (req, res, next) => {
  try {
    const { drugNames } = req.body;
    
    if (!drugNames || !Array.isArray(drugNames)) {
      return res.status(400).json({
        success: false,
        error: 'Drug names array is required'
      });
    }

    // Get active clinical alerts that affect these drugs
    const alerts = await prisma.clinicalAlert.findMany({
      where: {
        isActive: true,
        OR: drugNames.map(name => ({
          affectedDrugs: { has: name }
        }))
      },
      include: { source: true },
      orderBy: [
        { priority: 'asc' },
        { severity: 'desc' },
        { createdAt: 'desc' }
      ]
    });

    res.json({
      success: true,
      data: {
        alerts,
        summary: {
          totalAlerts: alerts.length,
          criticalAlerts: alerts.filter(a => a.severity === 'critical').length,
          highAlerts: alerts.filter(a => a.severity === 'high').length,
          drugsChecked: drugNames
        }
      }
    });

  } catch (error) {
    logger.logError('clinical_alerts_error', `Clinical alerts check failed: ${error.message}`);
    next(error);
  }
});

/**
 * Trigger manual clinical data update
 * POST /api/clinical/update/trigger
 */
router.post('/update/trigger', async (req, res, next) => {
  try {
    const status = clinicalDataManager.getStatus();
    
    if (status.isUpdateRunning) {
      return res.status(409).json({
        success: false,
        error: 'Update already running',
        status
      });
    }

    // Trigger manual update (async)
    clinicalDataManager.triggerManualUpdate().catch(error => {
      logger.logError('manual_update_error', `Manual update failed: ${error.message}`);
    });

    res.json({
      success: true,
      message: 'Manual update triggered',
      status: clinicalDataManager.getStatus()
    });

  } catch (error) {
    logger.logError('update_trigger_error', `Failed to trigger update: ${error.message}`);
    next(error);
  }
});

/**
 * Get clinical data manager status
 * GET /api/clinical/status
 */
router.get('/status', async (req, res, next) => {
  try {
    const status = clinicalDataManager.getStatus();
    
    // Get recent update sessions
    const recentSessions = await prisma.updateSession.findMany({
      take: 5,
      orderBy: { startTime: 'desc' }
    });

    // Get data source health
    const sources = await prisma.dataSource.findMany({
      where: { isActive: true }
    });

    res.json({
      success: true,
      data: {
        manager: status,
        recentSessions,
        dataSources: sources,
        systemHealth: {
          totalSources: sources.length,
          activeSources: sources.filter(s => s.isActive).length,
          lastUpdate: recentSessions[0]?.startTime || null
        }
      }
    });

  } catch (error) {
    logger.logError('status_error', `Failed to get status: ${error.message}`);
    next(error);
  }
});

/**
 * Get interaction statistics
 * GET /api/clinical/stats
 */
router.get('/stats', async (req, res, next) => {
  try {
    const [
      totalInteractions,
      totalAlerts,
      totalMappings,
      recentInteractions,
      severityStats
    ] = await Promise.all([
      prisma.drugInteraction.count(),
      prisma.clinicalAlert.count({ where: { isActive: true } }),
      prisma.drugRxnormMapping.count({ where: { verified: true } }),
      prisma.drugInteraction.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // Last 7 days
          }
        }
      }),
      prisma.drugInteraction.groupBy({
        by: ['severity'],
        _count: { severity: true }
      })
    ]);

    res.json({
      success: true,
      data: {
        overview: {
          totalInteractions,
          totalAlerts,
          totalMappings,
          recentInteractions
        },
        severityBreakdown: severityStats.reduce((acc, stat) => {
          acc[stat.severity] = stat._count.severity;
          return acc;
        }, {}),
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.logError('stats_error', `Failed to get statistics: ${error.message}`);
    next(error);
  }
});

// Helper Functions

/**
 * Check clinical database for known interactions
 */
async function checkClinicalInteractions(drugs) {
  const drugIds = drugs.map(d => d.id);
  
  const interactions = await prisma.drugInteraction.findMany({
    where: {
      OR: [
        { drug1Id: { in: drugIds }, drug2Id: { in: drugIds } },
        { drug2Id: { in: drugIds }, drug1Id: { in: drugIds } }
      ]
    },
    include: {
      drug1: true,
      drug2: true,
      source: true
    }
  });

  return interactions.map(interaction => ({
    id: interaction.id,
    severity: interaction.severity,
    drug1: interaction.drug1.name,
    drug2: interaction.drug2.name,
    description: interaction.mechanism || interaction.clinicalSignificance,
    recommendation: interaction.managementRecommendation,
    source: interaction.source.name,
    evidenceLevel: interaction.evidenceLevel,
    confidence: parseFloat(interaction.confidenceScore) || 0.8,
    lastVerified: interaction.lastVerified,
    type: 'clinical_database'
  }));
}

/**
 * Check RxNav for additional interactions
 */
async function checkRxNavInteractions(drugs) {
  const interactions = [];
  
  const drugsWithMappings = drugs.filter(d => d.rxnormMappings.length > 0);
  
  for (let i = 0; i < drugsWithMappings.length; i++) {
    for (let j = i + 1; j < drugsWithMappings.length; j++) {
      try {
        const drug1 = drugsWithMappings[i];
        const drug2 = drugsWithMappings[j];
        
        const rxnavInteractions = await rxnavService.checkInteractionBetweenDrugs(
          drug1.rxnormMappings[0].rxcui,
          drug2.rxnormMappings[0].rxcui
        );
        
        for (const interaction of rxnavInteractions) {
          interactions.push({
            severity: interaction.severity,
            drug1: drug1.name,
            drug2: drug2.name,
            description: interaction.description,
            recommendation: 'Consult healthcare provider',
            source: 'RxNav/NIH',
            evidenceLevel: 'B',
            confidence: 0.9,
            lastVerified: new Date().toISOString(),
            type: 'rxnav_realtime'
          });
        }
      } catch (error) {
        logger.logError('rxnav_check_error', `RxNav check failed: ${error.message}`);
      }
    }
  }
  
  return interactions;
}

/**
 * Merge and prioritize interactions from multiple sources
 */
function mergeInteractions(clinicalInteractions, rxnavInteractions) {
  const allInteractions = [...clinicalInteractions, ...rxnavInteractions];
  
  // Remove duplicates based on drug pair and severity
  const uniqueInteractions = [];
  const seen = new Set();
  
  for (const interaction of allInteractions) {
    const key = `${interaction.drug1}-${interaction.drug2}-${interaction.severity}`;
    const reverseKey = `${interaction.drug2}-${interaction.drug1}-${interaction.severity}`;
    
    if (!seen.has(key) && !seen.has(reverseKey)) {
      uniqueInteractions.push(interaction);
      seen.add(key);
    }
  }
  
  // Sort by severity (critical first)
  const severityOrder = { critical: 0, high: 1, moderate: 2, low: 3, unknown: 4 };
  uniqueInteractions.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);
  
  return uniqueInteractions;
}

/**
 * Get safety alerts for drugs
 */
async function getSafetyAlerts(drugs) {
  const drugNames = drugs.map(d => d.name);
  
  const alerts = await prisma.clinicalAlert.findMany({
    where: {
      isActive: true,
      OR: drugNames.map(name => ({
        affectedDrugs: { has: name }
      }))
    },
    include: { source: true },
    orderBy: { priority: 'asc' }
  });
  
  return alerts.map(alert => ({
    id: alert.id,
    type: alert.alertType,
    severity: alert.severity,
    title: alert.title,
    description: alert.description,
    recommendation: alert.recommendation,
    affectedDrugs: alert.affectedDrugs,
    source: alert.source?.name || 'Unknown',
    effectiveDate: alert.effectiveDate,
    priority: alert.priority
  }));
}

module.exports = router;