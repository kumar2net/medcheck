import React, { useState } from 'react';

const InteractionAlerts = ({ interactions }) => {
  const [expanded, setExpanded] = useState(false);

  if (!interactions || interactions.length === 0) {
    return null;
  }

  const criticalInteractions = interactions.filter(i => i.severity === 'high');
  const otherInteractions = interactions.filter(i => i.severity !== 'high');

  return (
    <div className="interaction-alerts">
      <div className="alerts-header">
        <div className="alert-icon">⚠️</div>
        <div className="alert-content">
          <h3>Drug Interaction Alerts</h3>
          <p>
            {criticalInteractions.length > 0 
              ? `${criticalInteractions.length} critical interaction${criticalInteractions.length > 1 ? 's' : ''} found`
              : `${interactions.length} interaction${interactions.length > 1 ? 's' : ''} detected`
            }
          </p>
        </div>
        <button 
          onClick={() => setExpanded(!expanded)}
          className="expand-btn"
        >
          {expanded ? '▼' : '▶'}
        </button>
      </div>

      {expanded && (
        <div className="alerts-details">
          {criticalInteractions.length > 0 && (
            <div className="critical-interactions">
              <h4 className="section-title critical">Critical Interactions</h4>
              {criticalInteractions.map((interaction, index) => (
                <InteractionCard key={index} interaction={interaction} />
              ))}
            </div>
          )}

          {otherInteractions.length > 0 && (
            <div className="other-interactions">
              <h4 className="section-title moderate">Other Interactions</h4>
              {otherInteractions.map((interaction, index) => (
                <InteractionCard key={index} interaction={interaction} />
              ))}
            </div>
          )}

          <div className="alert-actions">
            <button className="btn-secondary">
              📋 Download Report
            </button>
            <button className="btn-primary">
              👨‍⚕️ Consult Doctor
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

const InteractionCard = ({ interaction }) => {
  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'high': return '#dc3545';
      case 'medium': return '#fd7e14';
      case 'low': return '#ffc107';
      default: return '#6c757d';
    }
  };

  const getSeverityIcon = (severity) => {
    switch (severity) {
      case 'high': return '🚨';
      case 'medium': return '⚠️';
      case 'low': return '⚡';
      default: return 'ℹ️';
    }
  };

  return (
    <div className="interaction-card">
      <div className="interaction-header">
        <span 
          className="severity-badge"
          style={{ backgroundColor: getSeverityColor(interaction.severity) }}
        >
          {getSeverityIcon(interaction.severity)} {interaction.severity?.toUpperCase()}
        </span>
        <div className="drug-names">
          <span className="drug-name">{interaction.drug1}</span>
          <span className="interaction-symbol">⚡</span>
          <span className="drug-name">{interaction.drug2}</span>
        </div>
      </div>

      <div className="interaction-details">
        <p className="description">{interaction.description}</p>
        {interaction.recommendation && (
          <div className="recommendation">
            <strong>Recommendation:</strong> {interaction.recommendation}
          </div>
        )}
        {interaction.affectedMembers && interaction.affectedMembers.length > 0 && (
          <div className="affected-members">
            <strong>Affected Family Members:</strong>
            <div className="members-list">
              {interaction.affectedMembers.map((member, index) => (
                <span key={index} className="member-chip">{member}</span>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default InteractionAlerts;