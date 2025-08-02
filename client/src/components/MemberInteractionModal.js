import React, { useState, useEffect } from 'react';
import { familyApiService } from '../services/familyApi';

const MemberInteractionModal = ({ member, onClose }) => {
  const [interactions, setInteractions] = useState([]);
  const [memberMedications, setMemberMedications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [summary, setSummary] = useState(null);
  const [copySuccess, setCopySuccess] = useState(false);

  useEffect(() => {
    if (member) {
      loadMemberInteractions();
    }
  }, [member]); // eslint-disable-line react-hooks/exhaustive-deps

  const loadMemberInteractions = async () => {
    try {
      setLoading(true);
      
      // Load member medications
      const medications = await familyApiService.getFamilyMedications(member.id);
      setMemberMedications(medications);

      // Check interactions for this specific member
      if (medications.length > 1) {
        const drugIds = medications.map(med => med.drugId);
        const interactionResult = await familyApiService.checkInteractions(drugIds, member.id);
        setInteractions(interactionResult.interactions || []);
        setSummary(interactionResult.summary || null);
      } else {
        setInteractions([]);
        setSummary(null);
      }
      
      setError(null);
    } catch (err) {
      setError('Failed to load member interactions: ' + err.message);
    } finally {
      setLoading(false);
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

  const getSeverityIcon = (severity) => {
    switch (severity?.toLowerCase()) {
      case 'high':
        return '🚨';
      case 'moderate':
        return '⚠️';
      case 'low':
        return '💡';
      default:
        return 'ℹ️';
    }
  };

  const formatForWhatsApp = () => {
    let message = `🏥 *MedicineChk Member Health Check*\n\n`;
    
    // Member Overview
    message += `👤 *Patient:* ${member.name}\n`;
    message += `💊 *Total Medications:* ${memberMedications.length}\n\n`;
    
    // Current Medications
    if (memberMedications.length > 0) {
      message += `💊 *Current Medications:*\n`;
      memberMedications.forEach(medication => {
        let strengthDisplay = '';
        if (medication.drug.strength) {
          const match = medication.drug.strength.match(/(\d+(?:\.\d+)?)\s*(mg|mcg|ml|IU)/i);
          strengthDisplay = match ? ` (${match[1]}${match[2]})` : '';
        }
        
        const dosageText = medication.dosage ? ` - ${medication.dosage}` : '';
        const frequencyText = medication.frequency ? ` ${medication.frequency}` : '';
        
        message += `  • ${medication.drug.name}${strengthDisplay}${dosageText}${frequencyText}\n`;
      });
      message += `\n`;
    }
    
    // Interaction Analysis
    if (memberMedications.length > 1) {
      message += `🔍 *Interaction Analysis:*\n`;
      
      if (summary) {
        message += `✅ ${summary.totalInteractions || 0} interactions found\n`;
        message += `🛡️ Overall Safety: ${summary.overallSafety || 'Safe'}\n\n`;
      }
      
      // Interactions (if any)
      if (interactions && interactions.length > 0) {
        message += `⚠️ *DRUG INTERACTIONS DETECTED:*\n\n`;
        interactions.forEach((interaction, index) => {
          const severityEmoji = {
            'high': '🔴',
            'moderate': '🟡', 
            'low': '🟢'
          }[interaction.severity?.toLowerCase()] || '⚠️';
          
          message += `${severityEmoji} *${interaction.drug1} ↔ ${interaction.drug2}*\n`;
          message += `📊 Severity: ${interaction.severity}\n`;
          message += `📝 ${interaction.description}\n`;
          if (interaction.recommendation) {
            message += `💡 Recommendation: ${interaction.recommendation}\n`;
          }
          if (index < interactions.length - 1) message += `\n`;
        });
        message += `\n`;
      } else {
        message += `✅ *Great News!*\nNo significant drug interactions detected between ${member.name}'s medications.\n\n`;
      }
    } else if (memberMedications.length === 1) {
      message += `ℹ️ *Note:* Only one medication - no interaction analysis needed.\n\n`;
    } else {
      message += `ℹ️ *Note:* No medications recorded.\n\n`;
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
    <div className="modal-overlay">
      <div className="member-interaction-modal">
        <div className="modal-header">
          <h2>🔍 Drug Interactions for {member.name}</h2>
          <button onClick={onClose} className="close-btn">×</button>
        </div>

        <div className="modal-content">
          {loading ? (
            <div className="loading-spinner">
              <div className="spinner"></div>
              <p>Checking drug interactions...</p>
            </div>
          ) : error ? (
            <div className="error-message">
              <span className="error-icon">⚠️</span>
              {error}
            </div>
          ) : (
            <>
              {/* Member Medications Summary */}
              <div className="member-medications-summary">
                <h3>📋 Current Medications ({memberMedications.length})</h3>
                {memberMedications.length === 0 ? (
                  <p className="no-medications">No medications found for {member.name}</p>
                ) : (
                  <div className="medication-list">
                    {memberMedications.map(medication => (
                      <div key={medication.id} className="medication-item">
                        <strong>{medication.drug.name}</strong>
                        {medication.dosage && <span> - {medication.dosage}</span>}
                        {medication.frequency && <span> ({medication.frequency})</span>}
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Interaction Results */}
              {memberMedications.length > 1 && (
                <div className="interaction-results">
                  <h3>🔍 Interaction Analysis</h3>
                  
                  {summary && (
                    <div className="interaction-summary">
                      <div className={`summary-card ${summary.overallSafety === 'Safe' ? 'safe' : 'warning'}`}>
                        <h4>
                          {summary.overallSafety === 'Safe' ? '✅' : '⚠️'} 
                          Overall Safety: {summary.overallSafety}
                        </h4>
                        <p><strong>Total Interactions Found:</strong> {summary.totalInteractions}</p>
                        {summary.highSeverityCount > 0 && (
                          <p className="high-severity">🚨 High Severity: {summary.highSeverityCount}</p>
                        )}
                        {summary.moderateSeverityCount > 0 && (
                          <p className="moderate-severity">⚠️ Moderate Severity: {summary.moderateSeverityCount}</p>
                        )}
                        {summary.lowSeverityCount > 0 && (
                          <p className="low-severity">💡 Low Severity: {summary.lowSeverityCount}</p>
                        )}
                      </div>
                    </div>
                  )}

                  {interactions.length === 0 ? (
                    <div className="no-interactions">
                      <div className="success-message">
                        <span className="success-icon">✅</span>
                        <h4>No Significant Interactions Found</h4>
                        <p>The medications for {member.name} appear to be safe to take together.</p>
                      </div>
                    </div>
                  ) : (
                    <div className="interactions-list">
                      {interactions.map((interaction, index) => (
                        <div key={index} className="interaction-card">
                          <div className="interaction-header">
                            <span className="severity-icon">
                              {getSeverityIcon(interaction.severity)}
                            </span>
                            <h4 style={{ color: getSeverityColor(interaction.severity) }}>
                              {interaction.severity} Severity
                            </h4>
                          </div>
                          
                          <div className="interaction-details">
                            <p><strong>Between:</strong> {interaction.drug1} ↔ {interaction.drug2}</p>
                            <p><strong>Description:</strong> {interaction.description}</p>
                            {interaction.mechanism && (
                              <p><strong>Mechanism:</strong> {interaction.mechanism}</p>
                            )}
                            {interaction.recommendation && (
                              <div className="recommendation">
                                <strong>Recommendation:</strong> {interaction.recommendation}
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* Disclaimer */}
              <div className="interaction-disclaimer">
                <p>
                  <strong>⚠️ Medical Disclaimer:</strong> This interaction analysis provides general information only. 
                  Always consult with a qualified healthcare provider or pharmacist for personalized medical advice.
                </p>
              </div>
            </>
          )}
        </div>

        <div className="modal-actions">
          <button onClick={onClose} className="btn-secondary">
            Close
          </button>
          <button onClick={loadMemberInteractions} className="btn-primary">
            🔄 Refresh Analysis
          </button>
          {memberMedications.length > 0 && (
            <>
              <button 
                onClick={copyToClipboard} 
                className={`btn-success ${copySuccess ? 'copied' : ''}`}
                disabled={copySuccess}
              >
                {copySuccess ? '✅ Copied!' : '📋 Copy to Clipboard'}
              </button>
              <button onClick={openWhatsApp} className="btn-whatsapp">
                📱 Share on WhatsApp
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default MemberInteractionModal;