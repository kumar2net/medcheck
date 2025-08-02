import React, { useState, useEffect } from 'react';
import { familyApiService } from '../services/familyApi';
import './InteractionChecker.css';

const InteractionChecker = () => {
  const [interactions, setInteractions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [selectedDrug, setSelectedDrug] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [checkingInteractions, setCheckingInteractions] = useState(false);
  const [searchingDrugs, setSearchingDrugs] = useState(false);
  const [searchStatus, setSearchStatus] = useState('');
  const [safetyMessage, setSafetyMessage] = useState('');
  const [isSafe, setIsSafe] = useState(false);
  const [familyMembers, setFamilyMembers] = useState([]);
  const [selectedFamilyMember, setSelectedFamilyMember] = useState('');
  const [checkMessage, setCheckMessage] = useState('');
  const [testedCombinations, setTestedCombinations] = useState([]);
  const [familyMemberMedications, setFamilyMemberMedications] = useState({});
  const [summary, setSummary] = useState(null);
  const [showDetailedResults, setShowDetailedResults] = useState(false);
  const [copySuccess, setCopySuccess] = useState(false);

  useEffect(() => {
    checkFamilyInteractions();
    loadFamilyMembers();
  }, []);

  const loadFamilyMembers = async () => {
    try {
      const members = await familyApiService.getFamilyMembers();
      setFamilyMembers(members);
    } catch (err) {
      console.error('Failed to load family members:', err);
    }
  };

  const checkFamilyInteractions = async () => {
    try {
      setLoading(true);
      const result = await familyApiService.checkFamilyInteractions();
      setInteractions(result.interactions || []);
      setTestedCombinations(result.testedCombinations || []);
      setFamilyMemberMedications(result.familyMemberMedications || {});
      setSummary(result.summary || null);
      setCheckMessage(result.detailMessage || '');
      setError(null);
    } catch (err) {
      setError('Failed to check family interactions: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const searchDrugs = async (query) => {
    if (!query.trim()) {
      setSearchResults([]);
      setSearchStatus('');
      return;
    }

    if (query.length < 3) {
      setSearchStatus('Type at least 3 characters to search...');
      return;
    }

    try {
      setSearchingDrugs(true);
      setSearchStatus('🔍 Searching local database...');
      
      const apiResponse = await familyApiService.searchDrugs(query);
      
      // familyApiService.searchDrugs() returns the response.data directly
      const drugs = apiResponse.data || apiResponse;
      const message = apiResponse.message || '';
      
      // Update status based on backend response
      if (message.includes('RxNav')) {
        if (message.includes('No drugs found')) {
          setSearchStatus('❌ No drugs found in RxNav API - try different spelling or generic name');
        } else if (message.includes('Found') && message.includes('added to database')) {
          setSearchStatus('✅ Found new drugs from RxNav API and added to database');
        } else if (message.includes('failed')) {
          setSearchStatus('❌ RxNav API search failed - please try again');
        }
      } else if (Array.isArray(drugs) && drugs.length === 0) {
        setSearchStatus('❌ No drugs found in local database');
      } else if (Array.isArray(drugs) && drugs.length > 0) {
        setSearchStatus('✅ Found drugs in local database');
      }
      
      setSearchResults(Array.isArray(drugs) ? drugs : []);
    } catch (err) {
      console.error('Failed to search drugs:', err);
      setSearchStatus('❌ Search failed - please try again');
    } finally {
      setSearchingDrugs(false);
    }
  };

  const checkDrugInteractions = async (drugName) => {
    if (!selectedFamilyMember) {
      setError('Please select a family member first');
      return;
    }

    try {
      setCheckingInteractions(true);
      const result = await familyApiService.checkDrugInteractions(drugName, selectedFamilyMember);
      setInteractions(result.interactions || []);
      setSafetyMessage(result.safetyMessage || '');
      setIsSafe(result.isSafe || false);
      setError(null);
    } catch (err) {
      setError('Failed to check drug interactions: ' + err.message);
    } finally {
      setCheckingInteractions(false);
    }
  };

  const getSeverityColor = (severity) => {
    switch (severity?.toLowerCase()) {
      case 'high':
        return '#dc3545';
      case 'moderate':
        return '#ffc107';
      case 'low':
        return '#28a745';
      default:
        return '#6c757d';
    }
  };

  const formatForWhatsApp = () => {
    const familyMemberNames = Object.keys(familyMemberMedications);
    const totalMedications = Object.values(familyMemberMedications)
      .reduce((total, meds) => total + meds.length, 0);
    
    let message = `🏥 *MedicineChk Family Health Check*\n\n`;
    
    // Family Overview
    if (familyMemberNames.length > 0) {
      message += `👨‍👩‍👧‍👦 *Family Members:* ${familyMemberNames.join(', ')}\n`;
      message += `💊 *Total Medications:* ${totalMedications}\n\n`;
    }
    
    // Summary
    if (summary) {
      message += `📊 *Interaction Analysis:*\n`;
      message += `✅ ${summary.totalCombinationsTested} drug combinations tested\n`;
      message += `${summary.interactionsFound > 0 ? '⚠️' : '✅'} ${summary.interactionsFound} interactions found\n`;
      message += `🛡️ ${summary.safeCombinationCount} safe combinations\n\n`;
    }
    
    // Interactions (if any)
    if (interactions && interactions.length > 0) {
      message += `⚠️ *IMPORTANT INTERACTIONS:*\n\n`;
      interactions.forEach((interaction, index) => {
        const severityEmoji = {
          'high': '🔴',
          'moderate': '🟡', 
          'low': '🟢'
        }[interaction.severity] || '⚠️';
        
        message += `${severityEmoji} *${interaction.drug1} + ${interaction.drug2}*\n`;
        message += `🎯 Risk: ${interaction.riskType}\n`;
        message += `👥 Affects: ${interaction.affectedMembers?.join(', ')}\n`;
        message += `💡 ${interaction.recommendation}\n`;
        if (index < interactions.length - 1) message += `\n`;
      });
      message += `\n`;
    } else {
      message += `✅ *Great News!*\nNo drug interactions detected in your family's current medications.\n\n`;
    }
    
    // Family Medications Breakdown
    if (Object.keys(familyMemberMedications).length > 0) {
      message += `💊 *Medications by Family Member:*\n\n`;
      Object.entries(familyMemberMedications).forEach(([memberName, medications]) => {
        message += `👤 *${memberName}:*\n`;
        medications.forEach(med => {
          // Extract key strength info for cleaner display
          let strengthDisplay = '';
          if (med.strength) {
            // For combination drugs, show simplified strength
            if (med.strength.includes('+')) {
              // Extract main component strengths for combination drugs
              const parts = med.strength.split('+').map(part => {
                const match = part.trim().match(/(\d+(?:\.\d+)?)\s*(mg|mcg|ml|IU)/i);
                return match ? `${match[1]}${match[2]}` : part.trim();
              });
              strengthDisplay = ` (${parts.join(' + ')})`;
            } else {
              // For single drugs, extract just the dose
              const match = med.strength.match(/(\d+(?:\.\d+)?)\s*(mg|mcg|ml|IU)/i);
              strengthDisplay = match ? ` (${match[1]}${match[2]})` : '';
            }
          }
          message += `  • ${med.drugName}${strengthDisplay} - ${med.dosage} ${med.frequency}\n`;
        });
        message += `\n`;
      });
    }
    
    // Timestamp and Disclaimer
    const now = new Date();
    const timestamp = now.toLocaleDateString() + ' ' + now.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
    
    message += `🕐 *Generated:* ${timestamp}\n\n`;
    message += `⚠️ *Medical Disclaimer:*\n`;
    message += `This is for informational purposes only. Always consult your healthcare provider before making any medication decisions.\n\n`;
    message += `📱 Generated by MedicineChk App`;
    
    return message;
  };

  const copyToClipboard = async () => {
    try {
      const formattedMessage = formatForWhatsApp();
      await navigator.clipboard.writeText(formattedMessage);
      setCopySuccess(true);
      
      // Reset success message after 3 seconds
      setTimeout(() => setCopySuccess(false), 3000);
    } catch (err) {
      console.error('Failed to copy to clipboard:', err);
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = formatForWhatsApp();
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      setCopySuccess(true);
      setTimeout(() => setCopySuccess(false), 3000);
    }
  };

  const openWhatsApp = () => {
    const formattedMessage = formatForWhatsApp();
    const encodedMessage = encodeURIComponent(formattedMessage);
    const whatsappUrl = `https://wa.me/?text=${encodedMessage}`;
    window.open(whatsappUrl, '_blank');
  };

  return (
    <div className="interaction-checker">
      <div className="interaction-header">
        <h2>🔍 Drug Interaction Checker</h2>
        <p>Check for potential drug interactions in your family</p>
      </div>
      
      <div className="interaction-disclaimer">
        <p>
          <strong>⚠️ Medical Disclaimer:</strong> This interaction checker provides general information only. 
          Always consult with a qualified healthcare provider or pharmacist before starting, stopping, or changing any medication. 
          The results shown here are not a substitute for professional medical advice.
        </p>
      </div>

      <div className="interaction-controls">
        <div className="family-member-section">
          <h3>Select Family Member</h3>
          <select 
            value={selectedFamilyMember}
            onChange={(e) => setSelectedFamilyMember(e.target.value)}
            className="family-member-select"
          >
            <option value="">Choose a family member...</option>
            {familyMembers.map((member) => (
              <option key={member.id} value={member.id}>
                {member.name}
              </option>
            ))}
          </select>
        </div>

        <div className="search-section">
          <h3>Search & Check New Drug</h3>
          <div className="search-box">
            <input
              type="text"
              placeholder="Enter drug name to check interactions..."
              value={selectedDrug}
              onChange={(e) => {
                setSelectedDrug(e.target.value);
                searchDrugs(e.target.value);
              }}
            />
            <button 
              onClick={() => checkDrugInteractions(selectedDrug)}
              disabled={!selectedDrug.trim() || !selectedFamilyMember || checkingInteractions}
            >
              {checkingInteractions ? 'Checking...' : 'Check Interactions'}
            </button>
          </div>
          
          {(searchingDrugs || searchStatus) && (
            <div className="search-status">
              {searchingDrugs && (
                <div className="search-loading">
                  <div className="spinner"></div>
                  <span>Searching...</span>
                </div>
              )}
              {searchStatus && (
                <div className={`search-status-message ${
                  searchStatus.includes('✅') ? 'success' : 
                  searchStatus.includes('❌') ? 'error' : 
                  'info'
                }`}>
                  {searchStatus}
                </div>
              )}
            </div>
          )}
          
          {searchResults.length > 0 && (
            <div className="search-results">
              <h4>Search Results:</h4>
              <div className="drug-list">
                {searchResults.map((drug) => (
                  <div 
                    key={drug.id} 
                    className="drug-item"
                    onClick={() => {
                      setSelectedDrug(drug.name);
                      setSearchResults([]);
                      checkDrugInteractions(drug.name);
                    }}
                  >
                    <strong>{drug.name}</strong>
                    <span>{drug.category} • {drug.strength}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="refresh-section">
          <button onClick={checkFamilyInteractions} disabled={loading}>
            {loading ? 'Checking...' : '🔄 Refresh Family Interactions'}
          </button>
          
          {(summary || interactions.length > 0 || Object.keys(familyMemberMedications).length > 0) && (
            <div className="share-section">
              <button onClick={copyToClipboard} className="copy-button">
                {copySuccess ? '✅ Copied!' : '📋 Copy to Clipboard'}
              </button>
              <button onClick={openWhatsApp} className="whatsapp-button">
                📱 Share on WhatsApp
              </button>
            </div>
          )}
        </div>
      </div>

      {error && (
        <div className="error-message">
          ⚠️ {error}
        </div>
      )}

      {checkMessage && (
        <div className="check-details">
          <h3>🔍 Interaction Check Details</h3>
          <pre className="check-message">{checkMessage}</pre>
        </div>
      )}

      {safetyMessage && (
        <div className={`safety-message ${isSafe ? 'safe' : 'warning'}`}>
          {safetyMessage}
        </div>
      )}

      <div className="interactions-section">
        <h3>Current Family Interactions</h3>
        
        {loading ? (
          <div className="loading">Checking interactions...</div>
        ) : interactions.length === 0 ? (
          <div className="no-interactions">
            ✅ No drug interactions found in your family
          </div>
        ) : (
          <div className="interactions-list">
            {interactions.map((interaction, index) => (
              <div 
                key={index} 
                className="interaction-item"
                style={{ borderLeftColor: getSeverityColor(interaction.severity) }}
              >
                <div className="interaction-header">
                  <span className="severity" style={{ color: getSeverityColor(interaction.severity) }}>
                    {interaction.severity?.toUpperCase() || 'UNKNOWN'}
                  </span>
                  <span className="risk-type">{interaction.riskType}</span>
                  <span className="affected-members">👥 {interaction.affectedMembers?.join(', ')}</span>
                </div>
                
                <div className="interaction-drugs">
                  <strong>Drugs:</strong> {interaction.drug1} + {interaction.drug2}
                </div>
                
                {interaction.description && (
                  <div className="interaction-description">
                    <strong>Description:</strong> {interaction.description}
                  </div>
                )}

                {interaction.mechanism && (
                  <div className="interaction-mechanism">
                    <strong>Mechanism:</strong> {interaction.mechanism}
                  </div>
                )}
                
                {interaction.recommendation && (
                  <div className="interaction-recommendation">
                    <strong>Recommendation:</strong> {interaction.recommendation}
                  </div>
                )}

                {interaction.memberDetails && (
                  <div className="member-details">
                    <div className="drug-users">
                      <strong>{interaction.drug1} users:</strong> 
                      {interaction.memberDetails.drug1Users.map(user => 
                        ` ${user.name} (${user.dosage} ${user.frequency})`
                      ).join(', ')}
                    </div>
                    <div className="drug-users">
                      <strong>{interaction.drug2} users:</strong> 
                      {interaction.memberDetails.drug2Users.map(user => 
                        ` ${user.name} (${user.dosage} ${user.frequency})`
                      ).join(', ')}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {summary && (
        <div className="summary-section">
          <div className="summary-header">
            <h3>📊 Interaction Analysis Summary</h3>
            <button 
              className="toggle-details"
              onClick={() => setShowDetailedResults(!showDetailedResults)}
            >
              {showDetailedResults ? '🔼 Hide Details' : '🔽 Show Details'}
            </button>
          </div>
          
          <div className="summary-stats">
            <div className="stat">
              <span className="stat-number">{summary.totalCombinationsTested}</span>
              <span className="stat-label">Drug Combinations Tested</span>
            </div>
            <div className="stat">
              <span className="stat-number">{summary.interactionsFound}</span>
              <span className="stat-label">Interactions Found</span>
            </div>
            <div className="stat">
              <span className="stat-number">{summary.safeCombinationCount}</span>
              <span className="stat-label">Safe Combinations</span>
            </div>
          </div>

          {summary.severityBreakdown && (summary.severityBreakdown.high > 0 || summary.severityBreakdown.moderate > 0) && (
            <div className="severity-breakdown">
              <h4>Severity Breakdown:</h4>
              <div className="severity-stats">
                {summary.severityBreakdown.high > 0 && (
                  <span className="severity-stat high">High: {summary.severityBreakdown.high}</span>
                )}
                {summary.severityBreakdown.moderate > 0 && (
                  <span className="severity-stat moderate">Moderate: {summary.severityBreakdown.moderate}</span>
                )}
                {summary.severityBreakdown.low > 0 && (
                  <span className="severity-stat low">Low: {summary.severityBreakdown.low}</span>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {showDetailedResults && (
        <div className="detailed-results">
          {Object.keys(familyMemberMedications).length > 0 && (
            <div className="family-medications">
              <h3>👨‍👩‍👧‍👦 Family Medications Overview</h3>
              {Object.entries(familyMemberMedications).map(([memberName, medications]) => (
                <div key={memberName} className="member-medications">
                  <h4>{memberName}</h4>
                  <div className="medication-list">
                    {medications.map((med, index) => (
                      <div key={index} className="medication-item">
                        <span className="drug-name">{med.drugName}</span>
                        <span className="drug-details">
                          {med.category} | {med.strength} | {med.dosage} {med.frequency}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}

          {testedCombinations.length > 0 && (
            <div className="tested-combinations">
              <h3>🔍 All Tested Drug Combinations</h3>
              <div className="combinations-grid">
                {testedCombinations.map((combo, index) => (
                  <div 
                    key={index} 
                    className={`combination-item ${combo.hasInteraction ? 'has-interaction' : 'safe'}`}
                  >
                    <div className="combination-header">
                      <span className="combination-status">
                        {combo.hasInteraction ? '⚠️ INTERACTION' : '✅ SAFE'}
                      </span>
                    </div>
                    <div className="combination-drugs">
                      <div className="drug-info">
                        <strong>{combo.drug1.name}</strong>
                        <span>{combo.drug1.category} | {combo.drug1.strength}</span>
                        <span>Users: {combo.drug1.takenBy.map(u => u.name).join(', ')}</span>
                      </div>
                      <div className="combination-plus">+</div>
                      <div className="drug-info">
                        <strong>{combo.drug2.name}</strong>
                        <span>{combo.drug2.category} | {combo.drug2.strength}</span>
                        <span>Users: {combo.drug2.takenBy.map(u => u.name).join(', ')}</span>
                      </div>
                    </div>
                    {combo.hasInteraction && combo.interactionDetails && (
                      <div className="interaction-summary">
                        <div className="risk-type">{combo.interactionDetails.riskType}</div>
                        <div className="quick-description">{combo.interactionDetails.description}</div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      <div className="interaction-info">
        <h4>ℹ️ About Drug Interactions</h4>
        <ul>
          <li><strong>High Severity:</strong> Serious interactions that require immediate attention</li>
          <li><strong>Moderate Severity:</strong> Interactions that may require dosage adjustments</li>
          <li><strong>Low Severity:</strong> Minor interactions with minimal risk</li>
        </ul>
        <p><em>Always consult with your healthcare provider before making any changes to your medication regimen.</em></p>
      </div>
    </div>
  );
};

export default InteractionChecker; 