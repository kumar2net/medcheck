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
  const [safetyMessage, setSafetyMessage] = useState('');
  const [isSafe, setIsSafe] = useState(false);
  const [familyMembers, setFamilyMembers] = useState([]);
  const [selectedFamilyMember, setSelectedFamilyMember] = useState('');
  const [checkMessage, setCheckMessage] = useState('');

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
      return;
    }

    try {
      const results = await familyApiService.searchDrugs(query);
      setSearchResults(results);
    } catch (err) {
      console.error('Failed to search drugs:', err);
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
                  <span className="family-member">{interaction.familyMember}</span>
                </div>
                
                <div className="interaction-drugs">
                  <strong>Drugs:</strong> {interaction.drugs?.join(' + ') || 'Unknown'}
                </div>
                
                {interaction.description && (
                  <div className="interaction-description">
                    <strong>Description:</strong> {interaction.description}
                  </div>
                )}
                
                {interaction.recommendation && (
                  <div className="interaction-recommendation">
                    <strong>Recommendation:</strong> {interaction.recommendation}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

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