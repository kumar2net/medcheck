/**
 * RxNav API Service - Free FDA drug interaction and information service
 * Integrates with NIH RxNav APIs for real-time clinical drug data
 * 
 * API Documentation: https://rxnav.nlm.nih.gov/RxNavAPIs.html
 * No authentication required - Free government service
 */

const fetch = require('node-fetch');
const logger = require('./logger');

class RxNavService {
  constructor() {
    this.baseURL = 'https://rxnav.nlm.nih.gov/REST';
    this.timeout = 10000; // 10 seconds
    this.retryAttempts = 3;
    this.retryDelay = 1000; // 1 second
  }

  /**
   * Make HTTP request with retry logic
   */
  async makeRequest(endpoint, params = {}) {
    const url = new URL(`${this.baseURL}${endpoint}`);
    
    // Add query parameters
    Object.keys(params).forEach(key => {
      if (params[key] !== undefined && params[key] !== null) {
        url.searchParams.append(key, params[key]);
      }
    });

    let lastError;
    
    for (let attempt = 1; attempt <= this.retryAttempts; attempt++) {
      try {
        logger.logInfo('rxnav_request', `Attempt ${attempt}: ${url.toString()}`);
        
        const response = await fetch(url.toString(), {
          method: 'GET',
          timeout: this.timeout,
          headers: {
            'User-Agent': 'DrugReco/1.0 (Healthcare Application)',
            'Accept': 'application/json'
          }
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        
        logger.logInfo('rxnav_success', `RxNav API request successful: ${endpoint}`);
        return data;

      } catch (error) {
        lastError = error;
        logger.logError('rxnav_error', `Attempt ${attempt} failed: ${error.message}`);
        
        if (attempt < this.retryAttempts) {
          await this.delay(this.retryDelay * attempt);
        }
      }
    }

    logger.logError('rxnav_failure', `All ${this.retryAttempts} attempts failed for ${endpoint}`);
    throw lastError;
  }

  /**
   * Delay utility for retry logic
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Search for drugs by name
   * @param {string} drugName - Name of the drug to search
   * @param {number} maxEntries - Maximum number of results (default: 20)
   */
  async searchDrugs(drugName, maxEntries = 20) {
    try {
      const data = await this.makeRequest('/drugs.json', {
        name: drugName,
        maxEntries
      });

      if (!data || !data.drugGroup || !data.drugGroup.conceptGroup) {
        return [];
      }

      const results = [];
      const conceptGroups = Array.isArray(data.drugGroup.conceptGroup) 
        ? data.drugGroup.conceptGroup 
        : [data.drugGroup.conceptGroup];

      for (const group of conceptGroups) {
        if (group.conceptProperties) {
          const concepts = Array.isArray(group.conceptProperties)
            ? group.conceptProperties
            : [group.conceptProperties];

          for (const concept of concepts) {
            results.push({
              rxcui: concept.rxcui,
              name: concept.name,
              synonym: concept.synonym,
              tty: concept.tty, // Term type
              language: concept.language,
              suppress: concept.suppress,
              umlscui: concept.umlscui
            });
          }
        }
      }

      logger.logInfo('rxnav_search', `Found ${results.length} drugs for "${drugName}"`);
      return results;

    } catch (error) {
      logger.logError('rxnav_search_error', `Failed to search drugs: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get drug interactions for a specific RXCUI
   * @param {string} rxcui - RxNorm Concept Unique Identifier
   */
  async getDrugInteractions(rxcui) {
    try {
      const data = await this.makeRequest('/interaction/interaction.json', {
        rxcui: rxcui
      });

      if (!data || !data.interactionTypeGroup) {
        return [];
      }

      const interactions = [];
      const typeGroups = Array.isArray(data.interactionTypeGroup)
        ? data.interactionTypeGroup
        : [data.interactionTypeGroup];

      for (const typeGroup of typeGroups) {
        if (typeGroup.interactionType) {
          const interactionTypes = Array.isArray(typeGroup.interactionType)
            ? typeGroup.interactionType
            : [typeGroup.interactionType];

          for (const intType of interactionTypes) {
            if (intType.interactionPair) {
              const pairs = Array.isArray(intType.interactionPair)
                ? intType.interactionPair
                : [intType.interactionPair];

              for (const pair of pairs) {
                interactions.push({
                  severity: intType.minConceptItem?.name || 'Unknown',
                  drug1: {
                    rxcui: pair.interactionConcept[0]?.minConceptItem?.rxcui,
                    name: pair.interactionConcept[0]?.minConceptItem?.name
                  },
                  drug2: {
                    rxcui: pair.interactionConcept[1]?.minConceptItem?.rxcui,
                    name: pair.interactionConcept[1]?.minConceptItem?.name
                  },
                  description: pair.description,
                  source: 'RxNav/NIH',
                  sourceUrl: `https://rxnav.nlm.nih.gov/REST/interaction/interaction.json?rxcui=${rxcui}`,
                  lastUpdated: new Date().toISOString()
                });
              }
            }
          }
        }
      }

      logger.logInfo('rxnav_interactions', `Found ${interactions.length} interactions for RXCUI ${rxcui}`);
      return interactions;

    } catch (error) {
      logger.logError('rxnav_interactions_error', `Failed to get interactions for ${rxcui}: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get detailed drug information by RXCUI
   * @param {string} rxcui - RxNorm Concept Unique Identifier
   */
  async getDrugInfo(rxcui) {
    try {
      const data = await this.makeRequest('/rxcui/${rxcui}/properties.json'.replace('${rxcui}', rxcui));

      if (!data || !data.properties) {
        return null;
      }

      const props = data.properties;
      
      return {
        rxcui: props.rxcui,
        name: props.name,
        synonym: props.synonym,
        tty: props.tty,
        language: props.language,
        suppress: props.suppress,
        umlscui: props.umlscui
      };

    } catch (error) {
      logger.logError('rxnav_drug_info_error', `Failed to get drug info for ${rxcui}: ${error.message}`);
      throw error;
    }
  }

  /**
   * Find RxNorm concept by name (exact match)
   * @param {string} drugName - Exact drug name
   */
  async findExactConcept(drugName) {
    try {
      const data = await this.makeRequest('/rxcui.json', {
        name: drugName,
        search: 0 // Exact match
      });

      if (!data || !data.idGroup || !data.idGroup.rxnormId) {
        return null;
      }

      const rxcuis = Array.isArray(data.idGroup.rxnormId)
        ? data.idGroup.rxnormId
        : [data.idGroup.rxnormId];

      return rxcuis[0]; // Return first exact match

    } catch (error) {
      logger.logError('rxnav_exact_concept_error', `Failed to find exact concept for "${drugName}": ${error.message}`);
      throw error;
    }
  }

  /**
   * Get related concepts (generics, brands, etc.)
   * @param {string} rxcui - RxNorm Concept Unique Identifier
   * @param {Array} tty - Term types to include (e.g., ['SCD', 'SBD'])
   */
  async getRelatedConcepts(rxcui, tty = ['SCD', 'SBD', 'GPCK', 'BPCK']) {
    try {
      const data = await this.makeRequest('/rxcui/${rxcui}/related.json'.replace('${rxcui}', rxcui), {
        tty: tty.join('+')
      });

      if (!data || !data.relatedGroup) {
        return [];
      }

      const related = [];
      const relatedGroup = data.relatedGroup;

      if (relatedGroup.conceptGroup) {
        const conceptGroups = Array.isArray(relatedGroup.conceptGroup)
          ? relatedGroup.conceptGroup
          : [relatedGroup.conceptGroup];

        for (const group of conceptGroups) {
          if (group.conceptProperties) {
            const concepts = Array.isArray(group.conceptProperties)
              ? group.conceptProperties
              : [group.conceptProperties];

            for (const concept of concepts) {
              related.push({
                rxcui: concept.rxcui,
                name: concept.name,
                tty: concept.tty,
                umlscui: concept.umlscui
              });
            }
          }
        }
      }

      logger.logInfo('rxnav_related', `Found ${related.length} related concepts for RXCUI ${rxcui}`);
      return related;

    } catch (error) {
      logger.logError('rxnav_related_error', `Failed to get related concepts for ${rxcui}: ${error.message}`);
      throw error;
    }
  }

  /**
   * Check for drug-drug interactions between two RXCUIs
   * @param {string} rxcui1 - First drug RXCUI
   * @param {string} rxcui2 - Second drug RXCUI
   */
  async checkInteractionBetweenDrugs(rxcui1, rxcui2) {
    try {
      const data = await this.makeRequest('/interaction/list.json', {
        rxcuis: `${rxcui1}+${rxcui2}`
      });

      if (!data || !data.fullInteractionTypeGroup) {
        return [];
      }

      const interactions = [];
      const typeGroups = Array.isArray(data.fullInteractionTypeGroup)
        ? data.fullInteractionTypeGroup
        : [data.fullInteractionTypeGroup];

      for (const typeGroup of typeGroups) {
        if (typeGroup.fullInteractionType) {
          const interactionTypes = Array.isArray(typeGroup.fullInteractionType)
            ? typeGroup.fullInteractionType
            : [typeGroup.fullInteractionType];

          for (const intType of interactionTypes) {
            if (intType.interactionPair) {
              const pairs = Array.isArray(intType.interactionPair)
                ? intType.interactionPair
                : [intType.interactionPair];

              for (const pair of pairs) {
                interactions.push({
                  severity: this.mapSeverity(intType.minConceptItem?.name),
                  drug1: {
                    rxcui: pair.interactionConcept[0]?.minConceptItem?.rxcui,
                    name: pair.interactionConcept[0]?.minConceptItem?.name
                  },
                  drug2: {
                    rxcui: pair.interactionConcept[1]?.minConceptItem?.rxcui,
                    name: pair.interactionConcept[1]?.minConceptItem?.name
                  },
                  description: pair.description,
                  source: 'RxNav/NIH',
                  confidence: 'high', // RxNav data is authoritative
                  lastUpdated: new Date().toISOString()
                });
              }
            }
          }
        }
      }

      logger.logInfo('rxnav_pair_interaction', `Found ${interactions.length} interactions between ${rxcui1} and ${rxcui2}`);
      return interactions;

    } catch (error) {
      logger.logError('rxnav_pair_interaction_error', `Failed to check interaction between ${rxcui1} and ${rxcui2}: ${error.message}`);
      throw error;
    }
  }

  /**
   * Map RxNav severity levels to standardized levels
   * @param {string} rxnavSeverity - RxNav severity description
   * @returns {string} Standardized severity level
   */
  mapSeverity(rxnavSeverity) {
    if (!rxnavSeverity) return 'unknown';
    
    const severity = rxnavSeverity.toLowerCase();
    
    if (severity.includes('contraindicated') || severity.includes('major')) {
      return 'critical';
    } else if (severity.includes('moderate')) {
      return 'high';
    } else if (severity.includes('minor')) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  /**
   * Health check for RxNav service
   */
  async healthCheck() {
    try {
      const startTime = Date.now();
      await this.makeRequest('/drugs.json', { name: 'aspirin', maxEntries: 1 });
      const responseTime = Date.now() - startTime;
      
      return {
        status: 'healthy',
        responseTime,
        timestamp: new Date().toISOString(),
        service: 'RxNav/NIH'
      };
      
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date().toISOString(),
        service: 'RxNav/NIH'
      };
    }
  }
}

module.exports = new RxNavService();