import React, { useState, useEffect } from 'react';
import { familyApiService } from '../services/familyApi';

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

const FamilyMemberForm = ({ member, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    photo: '',
    allergies: [],
    conditions: [],
    emergencyContact: '',
    emergencyPhone: '',
    role: 'member'
  });
  const [allergyInput, setAllergyInput] = useState('');
  const [conditionInput, setConditionInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (member) {
      setFormData({
        name: member.name || '',
        age: member.age || '',
        photo: member.photo || '',
        allergies: safeParseArrayField(member.allergies),
        conditions: safeParseArrayField(member.conditions),
        emergencyContact: member.emergencyContact || '',
        emergencyPhone: member.emergencyPhone || '',
        role: member.role || 'member'
      });
    }
  }, [member]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const addAllergy = () => {
    if (allergyInput.trim() && !formData.allergies.includes(allergyInput.trim())) {
      setFormData(prev => ({
        ...prev,
        allergies: [...prev.allergies, allergyInput.trim()]
      }));
      setAllergyInput('');
    }
  };

  const removeAllergy = (allergyToRemove) => {
    setFormData(prev => ({
      ...prev,
      allergies: prev.allergies.filter(allergy => allergy !== allergyToRemove)
    }));
  };

  const addCondition = () => {
    if (conditionInput.trim() && !formData.conditions.includes(conditionInput.trim())) {
      setFormData(prev => ({
        ...prev,
        conditions: [...prev.conditions, conditionInput.trim()]
      }));
      setConditionInput('');
    }
  };

  const removeCondition = (conditionToRemove) => {
    setFormData(prev => ({
      ...prev,
      conditions: prev.conditions.filter(condition => condition !== conditionToRemove)
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const submitData = {
        ...formData,
        age: formData.age ? parseInt(formData.age) : null,
        allergies: formData.allergies,
        conditions: formData.conditions
      };

      if (member) {
        await familyApiService.updateFamilyMember(member.id, submitData);
      } else {
        await familyApiService.createFamilyMember(submitData);
      }

      onSave();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const commonAllergies = [
    'Penicillin', 'Aspirin', 'Ibuprofen', 'Sulfa drugs', 'Latex',
    'Peanuts', 'Shellfish', 'Eggs', 'Milk', 'Dust mites'
  ];

  const commonConditions = [
    'Hypertension', 'Diabetes', 'Asthma', 'Heart Disease', 'Arthritis',
    'High Cholesterol', 'Depression', 'Anxiety', 'Migraine', 'COPD'
  ];

  return (
    <div className="modal-overlay">
      <div className="family-member-form">
        <div className="form-header">
          <h2>{member ? 'Edit Family Member' : 'Add Family Member'}</h2>
          <button onClick={onCancel} className="close-btn">×</button>
        </div>

        {error && (
          <div className="error-message">
            <span className="error-icon">⚠️</span>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-section">
            <h3>Basic Information</h3>
            
            <div className="form-group">
              <label htmlFor="name">Name *</label>
              <input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleInputChange}
                required
                placeholder="Enter full name"
                autoComplete="off"
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="age">Age</label>
                <input
                  type="number"
                  id="age"
                  name="age"
                  value={formData.age}
                  onChange={handleInputChange}
                  min="0"
                  max="120"
                  placeholder="Age"
                  autoComplete="off"
                />
              </div>

              <div className="form-group">
                <label htmlFor="role">Role</label>
                <select
                  id="role"
                  name="role"
                  value={formData.role}
                  onChange={handleInputChange}
                >
                  <option value="member">Member</option>
                  <option value="admin">Admin</option>
                  <option value="child">Child</option>
                </select>
              </div>
            </div>
          </div>

          <div className="form-section">
            <h3>Medical Information</h3>
            
            <div className="form-group">
              <label htmlFor="allergyInput">Allergies</label>
              <div className="tag-input">
                              <input
                type="text"
                id="allergyInput"
                name="allergyInput"
                value={allergyInput}
                onChange={(e) => setAllergyInput(e.target.value)}
                placeholder="Add an allergy"
                onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addAllergy())}
                autoComplete="off"
              />
                <button type="button" onClick={addAllergy} className="add-tag-btn">Add</button>
              </div>
              
              <div className="common-options">
                <small>Common allergies:</small>
                {commonAllergies.map(allergy => (
                  <button
                    key={allergy}
                    type="button"
                    onClick={() => {
                      setAllergyInput(allergy);
                      addAllergy();
                    }}
                    className="common-option-btn"
                    disabled={formData.allergies.includes(allergy)}
                  >
                    {allergy}
                  </button>
                ))}
              </div>

              <div className="tags-list">
                {formData.allergies.map(allergy => (
                  <span key={allergy} className="tag allergy-tag">
                    {allergy}
                    <button
                      type="button"
                      onClick={() => removeAllergy(allergy)}
                      className="remove-tag-btn"
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="conditionInput">Medical Conditions</label>
              <div className="tag-input">
                              <input
                type="text"
                id="conditionInput"
                name="conditionInput"
                value={conditionInput}
                onChange={(e) => setConditionInput(e.target.value)}
                placeholder="Add a condition"
                onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addCondition())}
                autoComplete="off"
              />
                <button type="button" onClick={addCondition} className="add-tag-btn">Add</button>
              </div>

              <div className="common-options">
                <small>Common conditions:</small>
                {commonConditions.map(condition => (
                  <button
                    key={condition}
                    type="button"
                    onClick={() => {
                      setConditionInput(condition);
                      addCondition();
                    }}
                    className="common-option-btn"
                    disabled={formData.conditions.includes(condition)}
                  >
                    {condition}
                  </button>
                ))}
              </div>

              <div className="tags-list">
                {formData.conditions.map(condition => (
                  <span key={condition} className="tag condition-tag">
                    {condition}
                    <button
                      type="button"
                      onClick={() => removeCondition(condition)}
                      className="remove-tag-btn"
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            </div>
          </div>

          <div className="form-section">
            <h3>Emergency Contact</h3>
            
            <div className="form-group">
              <label htmlFor="emergencyContact">Contact Name</label>
              <input
                type="text"
                id="emergencyContact"
                name="emergencyContact"
                value={formData.emergencyContact}
                onChange={handleInputChange}
                placeholder="Emergency contact name"
                autoComplete="off"
              />
            </div>

            <div className="form-group">
              <label htmlFor="emergencyPhone">Phone Number</label>
              <input
                type="tel"
                id="emergencyPhone"
                name="emergencyPhone"
                value={formData.emergencyPhone}
                onChange={handleInputChange}
                placeholder="Emergency contact phone"
                autoComplete="off"
              />
            </div>
          </div>

          <div className="form-actions">
            <button type="button" onClick={onCancel} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" disabled={loading} className="btn-primary">
              {loading ? 'Saving...' : (member ? 'Update' : 'Add')} Member
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default FamilyMemberForm;