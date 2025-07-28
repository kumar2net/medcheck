import React, { useState, useEffect } from 'react';
import { familyApiService } from '../services/familyApi';
import FamilyMemberCard from './FamilyMemberCard';
import FamilyMemberForm from './FamilyMemberForm';
import MedicationModal from './MedicationModal';
import InteractionAlerts from './InteractionAlerts';
import './FamilyDashboard.css';

const FamilyDashboard = () => {
  const [familyMembers, setFamilyMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showMemberForm, setShowMemberForm] = useState(false);
  const [showMedicationModal, setShowMedicationModal] = useState(false);
  const [selectedMember, setSelectedMember] = useState(null);
  const [editingMember, setEditingMember] = useState(null);
  const [interactions, setInteractions] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadFamilyMembers();
    checkFamilyInteractions();
  }, []);

  const loadFamilyMembers = async () => {
    try {
      setLoading(true);
      const members = await familyApiService.getFamilyMembers();
      setFamilyMembers(members);
      setError(null);
    } catch (err) {
      setError('Failed to load family members: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const checkFamilyInteractions = async () => {
    try {
      const result = await familyApiService.checkFamilyInteractions();
      setInteractions(result.interactions || []);
    } catch (err) {
      console.warn('Failed to check family interactions:', err);
    }
  };

  const handleAddMember = () => {
    setEditingMember(null);
    setShowMemberForm(true);
  };

  const handleEditMember = (member) => {
    setEditingMember(member);
    setShowMemberForm(true);
  };

  const handleDeleteMember = async (memberId) => {
    if (!window.confirm('Are you sure you want to remove this family member?')) {
      return;
    }

    try {
      await familyApiService.deleteFamilyMember(memberId);
      await loadFamilyMembers();
      await checkFamilyInteractions();
    } catch (err) {
      setError('Failed to delete family member: ' + err.message);
    }
  };

  const handleMemberSaved = async () => {
    setShowMemberForm(false);
    setEditingMember(null);
    await loadFamilyMembers();
    await checkFamilyInteractions();
  };

  const handleManageMedications = (member) => {
    setSelectedMember(member);
    setShowMedicationModal(true);
  };

  const handleMedicationsSaved = async () => {
    setShowMedicationModal(false);
    setSelectedMember(null);
    await loadFamilyMembers();
    await checkFamilyInteractions();
  };

  const filteredMembers = familyMembers.filter(member =>
    member.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const totalMedications = familyMembers.reduce((total, member) => 
    total + (member.medications ? member.medications.length : 0), 0
  );

  if (loading) {
    return (
      <div className="family-dashboard">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Loading family members...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="family-dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>Family Drug Management</h1>
          <div className="dashboard-stats">
            <div className="stat-card">
              <h3>{familyMembers.length}</h3>
              <p>Family Members</p>
            </div>
            <div className="stat-card">
              <h3>{totalMedications}</h3>
              <p>Total Medications</p>
            </div>
            <div className="stat-card">
              <h3>{interactions.length}</h3>
              <p>Interactions Found</p>
            </div>
          </div>
        </div>
      </header>

      {error && (
        <div className="error-message">
          <span className="error-icon">⚠️</span>
          {error}
          <button onClick={() => setError(null)} className="error-close">×</button>
        </div>
      )}

      {interactions.length > 0 && (
        <InteractionAlerts interactions={interactions} />
      )}

      <div className="dashboard-disclaimer">
        <p>
          <strong>⚠️ Medical Disclaimer:</strong> This application is for informational purposes only. 
          Always consult with a qualified healthcare provider or pharmacist before making any decisions about medications, 
          drug interactions, or treatment plans. The information provided here should not replace professional medical advice.
        </p>
      </div>

      <div className="dashboard-controls">
        <div className="search-bar">
          <input
            type="text"
            id="memberSearch"
            name="memberSearch"
            placeholder="Search family members..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
            autoComplete="off"
          />
        </div>
        <button 
          onClick={handleAddMember}
          className="add-member-btn"
        >
          + Add Family Member
        </button>
      </div>

      <div className="family-members-grid">
        {filteredMembers.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">👨‍👩‍👧‍👦</div>
            <h3>No Family Members Found</h3>
            <p>
              {searchQuery 
                ? `No members match "${searchQuery}"`
                : "Start by adding your first family member"
              }
            </p>
            {!searchQuery && (
              <button onClick={handleAddMember} className="add-first-member-btn">
                Add First Family Member
              </button>
            )}
          </div>
        ) : (
          filteredMembers.map(member => (
            <FamilyMemberCard
              key={member.id}
              member={member}
              onEdit={handleEditMember}
              onDelete={handleDeleteMember}
              onManageMedications={handleManageMedications}
            />
          ))
        )}
      </div>

      {showMemberForm && (
        <FamilyMemberForm
          member={editingMember}
          onSave={handleMemberSaved}
          onCancel={() => {
            setShowMemberForm(false);
            setEditingMember(null);
          }}
        />
      )}

      {showMedicationModal && selectedMember && (
        <MedicationModal
          member={selectedMember}
          onSave={handleMedicationsSaved}
          onClose={() => {
            setShowMedicationModal(false);
            setSelectedMember(null);
          }}
        />
      )}
    </div>
  );
};

export default FamilyDashboard;