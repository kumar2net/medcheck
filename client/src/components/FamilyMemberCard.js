import React from 'react';

const FamilyMemberCard = ({ member, onEdit, onDelete, onManageMedications }) => {
  const allergies = member.allergies ? JSON.parse(member.allergies) : [];
  const conditions = member.conditions ? JSON.parse(member.conditions) : [];
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