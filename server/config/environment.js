const logger = require('../services/logger');

class EnvironmentConfig {
  constructor() {
    this.config = this.loadConfig();
    this.validateConfig();
  }

  loadConfig() {
    return {
      // Server configuration
      NODE_ENV: process.env.NODE_ENV || 'development',
      PORT: parseInt(process.env.PORT) || 3001,
      
      // Database configuration
      DB_HOST: process.env.DB_HOST || 'localhost',
      DB_PORT: parseInt(process.env.DB_PORT) || 5432,
      DB_NAME: process.env.DB_NAME || 'drugreco_dev',
      DB_USER: process.env.DB_USER || 'kumar',
      DB_PASSWORD: process.env.DB_PASSWORD,
      DATABASE_URL: process.env.DATABASE_URL,
      
      // JWT configuration
      JWT_SECRET: process.env.JWT_SECRET || 'your-secret-key',
      JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h',
      
      // CORS configuration
      CLIENT_URL: process.env.CLIENT_URL || 'http://localhost:3000',
      ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS ? 
        process.env.ALLOWED_ORIGINS.split(',') : 
        ['http://localhost:3000', 'https://your-app.netlify.app'],
      
      // Rate limiting configuration
      RATE_LIMIT_WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
      RATE_LIMIT_MAX_REQUESTS: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || (process.env.NODE_ENV === 'development' ? 1000 : 100),
      SEARCH_RATE_LIMIT_WINDOW_MS: parseInt(process.env.SEARCH_RATE_LIMIT_WINDOW_MS) || 60 * 1000,
      SEARCH_RATE_LIMIT_MAX_REQUESTS: parseInt(process.env.SEARCH_RATE_LIMIT_MAX_REQUESTS) || (process.env.NODE_ENV === 'development' ? 300 : 30),
      
      // Logging configuration
      LOG_LEVEL: process.env.LOG_LEVEL || 'INFO',
      LOG_RETENTION_DAYS: parseInt(process.env.LOG_RETENTION_DAYS) || 30,
      
      // Security configuration
      BCRYPT_ROUNDS: parseInt(process.env.BCRYPT_ROUNDS) || 10,
      PASSWORD_MIN_LENGTH: parseInt(process.env.PASSWORD_MIN_LENGTH) || 6,
      
      // Cache configuration
      CACHE_TTL: parseInt(process.env.CACHE_TTL) || 5 * 60 * 1000, // 5 minutes
      
      // Performance configuration
      DB_POOL_MIN: parseInt(process.env.DB_POOL_MIN) || 2,
      DB_POOL_MAX: parseInt(process.env.DB_POOL_MAX) || 10,
      
      // Feature flags
      ENABLE_AUTHENTICATION: process.env.ENABLE_AUTHENTICATION !== 'false',
      ENABLE_RATE_LIMITING: process.env.ENABLE_RATE_LIMITING !== 'false',
      ENABLE_LOGGING: process.env.ENABLE_LOGGING !== 'false',
      ENABLE_CACHING: process.env.ENABLE_CACHING !== 'false',
      // YOLO mode - disables certain safeguards for experimental testing
      YOLO_MODE: process.env.YOLO_MODE !== 'false'
    };
  }

  validateConfig() {
    const errors = [];

    // Validate required environment variables
    if (this.config.NODE_ENV === 'production') {
      if (!this.config.DB_PASSWORD && !this.config.DATABASE_URL) {
        errors.push('DB_PASSWORD or DATABASE_URL is required in production');
      }
      
      if (this.config.JWT_SECRET === 'your-secret-key') {
        errors.push('JWT_SECRET must be set in production');
      }
      
      if (!this.config.CLIENT_URL) {
        errors.push('CLIENT_URL must be set in production');
      }
    } else {
      // In development, only warn about missing database password
      if (!this.config.DB_PASSWORD && !this.config.DATABASE_URL) {
        console.warn('Warning: DB_PASSWORD or DATABASE_URL not set. Using default development settings.');
      }
    }

    // Validate numeric values
    if (this.config.PORT < 1 || this.config.PORT > 65535) {
      errors.push('PORT must be between 1 and 65535');
    }

    if (this.config.DB_PORT < 1 || this.config.DB_PORT > 65535) {
      errors.push('DB_PORT must be between 1 and 65535');
    }

    if (this.config.RATE_LIMIT_MAX_REQUESTS < 1) {
      errors.push('RATE_LIMIT_MAX_REQUESTS must be greater than 0');
    }

    if (this.config.SEARCH_RATE_LIMIT_MAX_REQUESTS < 1) {
      errors.push('SEARCH_RATE_LIMIT_MAX_REQUESTS must be greater than 0');
    }

    if (this.config.BCRYPT_ROUNDS < 8 || this.config.BCRYPT_ROUNDS > 14) {
      errors.push('BCRYPT_ROUNDS must be between 8 and 14');
    }

    if (this.config.PASSWORD_MIN_LENGTH < 4) {
      errors.push('PASSWORD_MIN_LENGTH must be at least 4');
    }

    // Log validation errors
    if (errors.length > 0) {
      logger.error('Environment configuration validation failed', { errors });
      throw new Error(`Environment configuration errors: ${errors.join(', ')}`);
    }

    logger.info('Environment configuration validated successfully', {
      NODE_ENV: this.config.NODE_ENV,
      PORT: this.config.PORT,
      DB_HOST: this.config.DB_HOST,
      DB_NAME: this.config.DB_NAME,
      ENABLE_AUTHENTICATION: this.config.ENABLE_AUTHENTICATION,
      ENABLE_RATE_LIMITING: this.config.ENABLE_RATE_LIMITING,
      LOG_LEVEL: this.config.LOG_LEVEL,
      YOLO_MODE: this.config.YOLO_MODE
    });
  }

  get(key) {
    return this.config[key];
  }

  getAll() {
    return { ...this.config };
  }

  isDevelopment() {
    return this.config.NODE_ENV === 'development';
  }

  isProduction() {
    return this.config.NODE_ENV === 'production';
  }

  isTest() {
    return this.config.NODE_ENV === 'test';
  }

  // Get database configuration for Knex
  getDatabaseConfig() {
    const baseConfig = {
      development: {
        client: 'pg',
        connection: {
          host: this.config.DB_HOST,
          port: this.config.DB_PORT,
          database: this.config.DB_NAME,
          user: this.config.DB_USER,
          password: this.config.DB_PASSWORD
        },
        pool: {
          min: this.config.DB_POOL_MIN,
          max: this.config.DB_POOL_MAX
        }
      },
      production: {
        client: 'pg',
        connection: {
          connectionString: this.config.DATABASE_URL,
          ssl: {
            rejectUnauthorized: false
          }
        },
        pool: {
          min: this.config.DB_POOL_MIN,
          max: this.config.DB_POOL_MAX
        }
      }
    };

    return baseConfig;
  }

  // Get CORS configuration
  getCorsConfig() {
    return {
      origin: (origin, callback) => {
        // Allow requests with no origin (like mobile apps or curl requests)
        if (!origin) return callback(null, true);
        
        // In development, be more permissive
        if (this.isDevelopment()) {
          const devOrigins = [
            'http://localhost:3000',
            'http://localhost:3001',
            'http://localhost:3002',
            'http://localhost:3003',
            'http://localhost:3004',
            'http://localhost:3005',
            'http://127.0.0.1:3000',
            'http://127.0.0.1:3001',
            'http://127.0.0.1:3002',
            'http://127.0.0.1:3003',
            'http://127.0.0.1:3004',
            'http://127.0.0.1:3005'
          ];
          if (devOrigins.includes(origin)) {
            return callback(null, true);
          }
        }
        
        const allowedOrigins = [
          ...this.config.ALLOWED_ORIGINS,
          this.config.CLIENT_URL
        ].filter(Boolean);

        if (allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization']
    };
  }

  // Get rate limiting configuration
  getRateLimitConfig() {
    return {
      windowMs: this.config.RATE_LIMIT_WINDOW_MS,
      max: this.config.RATE_LIMIT_MAX_REQUESTS,
      message: {
        error: 'Too many requests from this IP, please try again later.',
        retryAfter: `${Math.floor(this.config.RATE_LIMIT_WINDOW_MS / 60000)} minutes`
      },
      standardHeaders: true,
      legacyHeaders: false
    };
  }

  // Get search rate limiting configuration
  getSearchRateLimitConfig() {
    return {
      windowMs: this.config.SEARCH_RATE_LIMIT_WINDOW_MS,
      max: this.config.SEARCH_RATE_LIMIT_MAX_REQUESTS,
      message: {
        error: 'Too many search requests, please try again later.',
        retryAfter: `${Math.floor(this.config.SEARCH_RATE_LIMIT_WINDOW_MS / 60000)} minutes`
      }
    };
  }
}

// Create singleton instance
const environmentConfig = new EnvironmentConfig();

module.exports = environmentConfig; 