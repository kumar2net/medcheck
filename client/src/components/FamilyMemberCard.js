import React from 'react';

// Helper function to safely parse JSON or treat as array/text
const safeParseArrayField = (field) => {
  if (!field) return [];
  
  try {
    const parsed = JSON.parse(field);
    return Array.isArray(parsed) ? parsed : [parsed];
  } catch (error) {
    // If parsing fails, treat as comma-separated text
    return field.split(/[,;|]/).map(item => item.trim()).filter(item => item.length > 0);
  }
};

const FamilyMemberCard = ({ member, onEdit, onDelete, onManageMedications, onMemberInteraction, selectedForInteraction }) => {
  const allergies = safeParseArrayField(member.allergies);
  const conditions = safeParseArrayField(member.conditions);
  const medicationCount = member.medications ? member.medications.length : 0;

  return (
    <div className="family-member-card">
      <div className="member-header">
        <div className="member-avatar">
          {member.photo ? (
            <img src={member.photo} alt={member.name} />
          ) : (
            <div className="avatar-placeholder">
              {member.name.charAt(0).toUpperCase()}
            </div>
          )}
        </div>
        <div className="member-info">
          <h3 className="member-name">{member.name}</h3>
          <span className={`member-role role-${member.role}`}>
            {member.role === 'admin' ? '👑 Admin' : 
             member.role === 'child' ? '🧒 Child' : '👤 Member'}
          </span>
        </div>
      </div>

      <div className="member-details">
        <div className="detail-section">
          <h4>📋 Medications</h4>
          <p className="medication-count">
            {medicationCount === 0 ? 'No medications' : `${medicationCount} medication${medicationCount > 1 ? 's' : ''}`}
          </p>
          {medicationCount > 0 && (
            <div className="recent-medications">
              {member.medications.slice(0, 2).map(med => (
                <span key={med.id} className="medication-chip">
                  {med.drug.name}
                </span>
              ))}
              {medicationCount > 2 && (
                <span className="more-medications">+{medicationCount - 2} more</span>
              )}
            </div>
          )}
        </div>

        {allergies.length > 0 && (
          <div className="detail-section">
            <h4>⚠️ Allergies</h4>
            <div className="allergies-list">
              {allergies.slice(0, 3).map((allergy, index) => (
                <span key={index} className="allergy-chip">{allergy}</span>
              ))}
              {allergies.length > 3 && (
                <span className="more-allergies">+{allergies.length - 3} more</span>
              )}
            </div>
          </div>
        )}

        {conditions.length > 0 && (
          <div className="detail-section">
            <h4>🏥 Conditions</h4>
            <div className="conditions-list">
              {conditions.slice(0, 2).map((condition, index) => (
                <span key={index} className="condition-chip">{condition}</span>
              ))}
              {conditions.length > 2 && (
                <span className="more-conditions">+{conditions.length - 2} more</span>
              )}
            </div>
          </div>
        )}

        {member.emergencyContact && (
          <div className="detail-section">
            <h4>📞 Emergency Contact</h4>
            <p className="emergency-contact">{member.emergencyContact}</p>
            {member.emergencyPhone && (
              <p className="emergency-phone">{member.emergencyPhone}</p>
            )}
          </div>
        )}
      </div>

      <div className="member-actions">
        <button 
          onClick={() => onManageMedications(member)}
          className="action-btn primary"
        >
          💊 Medications
        </button>
        {medicationCount > 0 && onMemberInteraction && (
          <button 
            onClick={() => onMemberInteraction(member)}
            className={`action-btn ${selectedForInteraction ? 'active' : 'info'}`}
          >
            🔍 Interactions
          </button>
        )}
        <button 
          onClick={() => onEdit(member)}
          className="action-btn secondary"
        >
          ✏️ Edit
        </button>
        <button 
          onClick={() => onDelete(member.id)}
          className="action-btn danger"
        >
          🗑️ Remove
        </button>
      </div>
    </div>
  );
};

export default FamilyMemberCard;