import cacheService from './cacheService';

// Allow overriding API base URL via environment variables
const API_URL = process.env.REACT_APP_API_URL || '/api';

class ApiService {
  constructor() {
    this.token = localStorage.getItem('authToken');
  }

  // Set authentication token
  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem('authToken', token);
    } else {
      localStorage.removeItem('authToken');
    }
  }

  // Get authentication headers
  getHeaders() {
    const headers = {
      'Content-Type': 'application/json'
    };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    return headers;
  }

  // Handle API response
  async handleResponse(response) {
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    
    // Handle new standardized response format
    if (data.success !== undefined) {
      if (!data.success) {
        throw new Error(data.message || 'API request failed');
      }
      return data.data;
    }
    
    // Fallback for old format
    return data;
  }

  // Search drugs with filters and caching
  async searchDrugs({ query, category }) {
    const params = { query, category };
    
    // Check cache first
    const cached = cacheService.getCachedRequest('/search', params);
    if (cached) {
      return cached;
    }

    const urlParams = new URLSearchParams();
    if (query) urlParams.append('query', query);
    if (category) urlParams.append('category', category);
    
    const response = await fetch(`${API_URL}/search?${urlParams.toString()}`, {
      headers: this.getHeaders()
    });
    
    const data = await this.handleResponse(response);
    
    // Cache the result for 2 minutes
    cacheService.cacheRequest('/search', params, data, 2 * 60 * 1000);
    
    return data;
  }

  // Get drug details with alternatives
  async getDrugDetails(drugName, category) {
    const cacheKey = `drug-details-${drugName}-${category}`;
    const cached = cacheService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const response = await this.searchDrugs({ query: drugName, category });
    const drug = response[0];
    if (!drug) {
      throw new Error('Drug not found');
    }
    
    // Simulate fetching alternatives for now
    const altsResponse = await this.searchDrugs({ category: drug.category });
    drug.alternatives = altsResponse.filter(d => d.name !== drug.name).slice(0, 3);
    
    // Cache for 5 minutes
    cacheService.set(cacheKey, drug, 5 * 60 * 1000);
    
    return drug;
  }

  // Get drug interactions
  async checkInteraction(drug1, drug2) {
    const cacheKey = `interaction-${drug1}-${drug2}`;
    const cached = cacheService.get(cacheKey);
    if (cached) {
      return cached;
    }

    // This can be a new endpoint on the backend in the future.
    // For now, we'll keep the simulation.
    const severity = Math.random() > 0.5 ? 'Moderate' : 'Mild';
    const result = {
      severity,
      description: `A simulated ${severity.toLowerCase()} interaction was found between ${drug1} and ${drug2}.`
    };
    
    // Cache for 10 minutes
    cacheService.set(cacheKey, result, 10 * 60 * 1000);
    
    return result;
  }

  // Get category statistics with caching
  async getCategoryStats() {
    const cached = cacheService.getCachedRequest('/stats', {});
    if (cached) {
      return cached;
    }

    const response = await fetch(`${API_URL}/stats`, {
      headers: this.getHeaders()
    });
    
    const data = await this.handleResponse(response);
    
    // Cache for 10 minutes
    cacheService.cacheRequest('/stats', {}, data, 10 * 60 * 1000);
    
    return data;
  }

  // Get trending drugs with caching
  async getTrendingDrugs() {
    const cached = cacheService.getCachedRequest('/trending', {});
    if (cached) {
      return cached;
    }

    const response = await fetch(`${API_URL}/trending`, {
      headers: this.getHeaders()
    });
    
    const data = await this.handleResponse(response);
    
    // Cache for 5 minutes
    cacheService.cacheRequest('/trending', {}, data, 5 * 60 * 1000);
    
    return data;
  }

  // Get categories with caching
  async getCategories() {
    const cached = cacheService.getCachedRequest('/categories', {});
    if (cached) {
      return cached;
    }

    const response = await fetch(`${API_URL}/categories`, {
      headers: this.getHeaders()
    });
    
    const data = await this.handleResponse(response);
    
    // Cache for 30 minutes (categories don't change often)
    cacheService.cacheRequest('/categories', {}, data, 30 * 60 * 1000);
    
    return data;
  }

  // Get drugs by names
  async getDrugsByNames(names) {
    const cacheKey = `drugs-by-names-${names.sort().join('-')}`;
    const cached = cacheService.get(cacheKey);
    if (cached) {
      return cached;
    }

    const response = await fetch(`${API_URL}/drugs/by-names`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({ names })
    });
    
    const data = await this.handleResponse(response);
    
    // Cache for 5 minutes
    cacheService.set(cacheKey, data, 5 * 60 * 1000);
    
    return data;
  }

  // Authentication methods
  async register(userData) {
    const response = await fetch(`${API_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData)
    });
    
    const data = await this.handleResponse(response);
    this.setToken(data.token);
    return data;
  }

  async login(credentials) {
    const response = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials)
    });
    
    const data = await this.handleResponse(response);
    this.setToken(data.token);
    return data;
  }

  async logout() {
    this.setToken(null);
    cacheService.clear(); // Clear cache on logout
  }

  async getProfile() {
    const response = await fetch(`${API_URL}/user/profile`, {
      headers: this.getHeaders()
    });
    
    return await this.handleResponse(response);
  }

  // Check if user is authenticated
  isAuthenticated() {
    return !!this.token;
  }

  // Clear cache for specific patterns
  clearCache(pattern) {
    cacheService.invalidate(pattern);
  }
}

export const apiService = new ApiService(); 
 