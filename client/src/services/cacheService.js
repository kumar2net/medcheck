class CacheService {
  constructor() {
    this.cache = new Map();
    this.maxAge = 5 * 60 * 1000; // 5 minutes default
  }

  // Generate cache key from parameters
  generateKey(endpoint, params = {}) {
    const sortedParams = Object.keys(params)
      .sort()
      .map(key => `${key}:${params[key]}`)
      .join('|');
    return `${endpoint}${sortedParams ? `?${sortedParams}` : ''}`;
  }

  // Set cache entry
  set(key, data, maxAge = this.maxAge) {
    const entry = {
      data,
      timestamp: Date.now(),
      maxAge
    };
    this.cache.set(key, entry);
  }

  // Get cache entry
  get(key) {
    const entry = this.cache.get(key);
    if (!entry) return null;

    const isExpired = Date.now() - entry.timestamp > entry.maxAge;
    if (isExpired) {
      this.cache.delete(key);
      return null;
    }

    return entry.data;
  }

  // Clear expired entries
  cleanup() {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (now - entry.timestamp > entry.maxAge) {
        this.cache.delete(key);
      }
    }
  }

  // Clear all cache
  clear() {
    this.cache.clear();
  }

  // Get cache size
  size() {
    return this.cache.size;
  }

  // Cache with automatic key generation
  cacheRequest(endpoint, params, data, maxAge = this.maxAge) {
    const key = this.generateKey(endpoint, params);
    this.set(key, data, maxAge);
    return key;
  }

  // Get cached request
  getCachedRequest(endpoint, params) {
    const key = this.generateKey(endpoint, params);
    return this.get(key);
  }

  // Invalidate cache by pattern
  invalidate(pattern) {
    for (const key of this.cache.keys()) {
      if (key.includes(pattern)) {
        this.cache.delete(key);
      }
    }
  }
}

// Create singleton instance
const cacheService = new CacheService();

// Cleanup expired entries every minute
setInterval(() => {
  cacheService.cleanup();
}, 60 * 1000);

export default cacheService; 