const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? '/api'  // Use relative URL for production (Netlify)
  : '/api';  // Use relative URL for development too

class FamilyApiService {
  async request(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json();
      
      if (!data.success) {
        throw new Error(data.message || 'API request failed');
      }
      
      return data.data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Family Members API
  async getFamilyMembers() {
    return this.request('/family-members');
  }

  async createFamilyMember(memberData) {
    return this.request('/family-members', {
      method: 'POST',
      body: JSON.stringify(memberData),
    });
  }

  async updateFamilyMember(id, memberData) {
    return this.request(`/family-members/${id}`, {
      method: 'PUT',
      body: JSON.stringify(memberData),
    });
  }

  async deleteFamilyMember(id) {
    return this.request(`/family-members/${id}`, {
      method: 'DELETE',
    });
  }

  // Family Medications API
  async getFamilyMedications(memberId) {
    return this.request(`/family-medications/${memberId}`);
  }

  async addFamilyMedication(medicationData) {
    return this.request('/family-medications', {
      method: 'POST',
      body: JSON.stringify(medicationData),
    });
  }

  async updateFamilyMedication(id, medicationData) {
    return this.request(`/family-medications/${id}`, {
      method: 'PUT',
      body: JSON.stringify(medicationData),
    });
  }

  async deleteFamilyMedication(id) {
    return this.request(`/family-medications/${id}`, {
      method: 'DELETE',
    });
  }

  // Drug Search API
  async searchDrugs(query, filters = {}) {
    const params = new URLSearchParams();
    if (query) params.append('query', query);
    if (filters.category) params.append('category', filters.category);
    if (filters.manufacturer) params.append('manufacturer', filters.manufacturer);
    if (filters.limit) params.append('limit', filters.limit);

    return this.request(`/drugs/search?${params}`);
  }

  // Interaction Checking API
  async checkInteractions(drugIds, memberId = null) {
    return this.request('/interactions/check', {
      method: 'POST',
      body: JSON.stringify({ drugIds, memberId }),
    });
  }

  async checkFamilyInteractions() {
    return this.request('/interactions/family-check', {
      method: 'POST',
    });
  }

  async checkDrugInteractions(drugName, familyMemberId) {
    return this.request('/interactions/drug-check', {
      method: 'POST',
      body: JSON.stringify({ drugName, familyMemberId }),
    });
  }

  // Emergency Information API
  async getEmergencyInfo(memberId) {
    return this.request(`/emergency/${memberId}`);
  }
}

export const familyApiService = new FamilyApiService();