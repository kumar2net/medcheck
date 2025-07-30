const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? '/api'  // Use relative URL for production (Netlify)
  : 'http://localhost:3001/api';  // Point to Express server for development

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
      console.log(`[API] Making request to: ${url}`);
      const response = await fetch(url, config);
      
      // Enhanced error handling for 502 and other HTTP errors
      if (!response.ok) {
        const errorText = await response.text();
        console.error(`[API] HTTP ${response.status} error:`, errorText);
        
        if (response.status === 502) {
          throw new Error('Server is temporarily unavailable. Please check your database connection.');
        } else if (response.status === 503) {
          throw new Error('Database service is unavailable. Please try again later.');
        } else if (response.status >= 500) {
          throw new Error(`Server error (${response.status}). Please try again later.`);
        } else {
          throw new Error(`Request failed with status ${response.status}`);
        }
      }
      
      const data = await response.json();
      
      if (!data.success) {
        throw new Error(data.message || 'API request failed');
      }
      
      console.log(`[API] Request successful: ${endpoint}`);
      return data.data;
    } catch (error) {
      console.error(`[API] Request failed for ${endpoint}:`, error);
      
      // Network or fetch errors
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new Error('Network error. Please check your internet connection.');
      }
      
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