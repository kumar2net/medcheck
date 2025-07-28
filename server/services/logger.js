const fs = require('fs');
const path = require('path');

class Logger {
  constructor() {
    this.logDir = path.join(__dirname, '../logs');
    this.ensureLogDirectory();
    
    // Different log levels
    this.levels = {
      ERROR: 0,
      WARN: 1,
      INFO: 2,
      DEBUG: 3
    };
    
    // Current log level (can be set via environment variable)
    this.currentLevel = this.levels[process.env.LOG_LEVEL?.toUpperCase()] ?? this.levels.INFO;
  }

  ensureLogDirectory() {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }
  }

  getTimestamp() {
    return new Date().toISOString();
  }

  formatMessage(level, message, data = null) {
    const timestamp = this.getTimestamp();
    const logEntry = {
      timestamp,
      level,
      message,
      ...(data && { data })
    };
    return JSON.stringify(logEntry);
  }

  writeToFile(level, message, data = null) {
    const today = new Date().toISOString().split('T')[0];
    const logFile = path.join(this.logDir, `${level.toLowerCase()}-${today}.log`);
    
    const logEntry = this.formatMessage(level, message, data);
    
    fs.appendFileSync(logFile, logEntry + '\n', 'utf8');
  }

  shouldLog(level) {
    return this.levels[level] <= this.currentLevel;
  }

  error(message, data = null) {
    if (this.shouldLog('ERROR')) {
      console.error(`[ERROR] ${message}`, data || '');
      this.writeToFile('ERROR', message, data);
    }
  }

  warn(message, data = null) {
    if (this.shouldLog('WARN')) {
      console.warn(`[WARN] ${message}`, data || '');
      this.writeToFile('WARN', message, data);
    }
  }

  info(message, data = null) {
    if (this.shouldLog('INFO')) {
      console.info(`[INFO] ${message}`, data || '');
      this.writeToFile('INFO', message, data);
    }
  }

  debug(message, data = null) {
    if (this.shouldLog('DEBUG')) {
      console.debug(`[DEBUG] ${message}`, data || '');
      this.writeToFile('DEBUG', message, data);
    }
  }

  // Specialized logging methods
  logRequest(req, res, responseTime = null) {
    const logData = {
      method: req.method,
      url: req.url,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      ...(responseTime && { responseTime: `${responseTime}ms` }),
      ...(req.user && { userId: req.user.userId })
    };
    
    this.info(`${req.method} ${req.url}`, logData);
  }

  logError(error, context = '') {
    const errorData = {
      message: error.message,
      stack: error.stack,
      ...(error.code && { code: error.code }),
      ...(context && { context })
    };
    
    this.error(`Error: ${error.message}`, errorData);
  }

  logDatabaseQuery(query, params = null, duration = null) {
    const queryData = {
      query,
      ...(params && { params }),
      ...(duration && { duration: `${duration}ms` })
    };
    
    this.debug('Database query executed', queryData);
  }

  logAuthentication(action, userId = null, success = true) {
    const authData = {
      action,
      ...(userId && { userId }),
      success
    };
    
    this.info(`Authentication: ${action}`, authData);
  }

  logCache(method, key, hit = false) {
    const cacheData = {
      method,
      key,
      hit
    };
    
    this.debug(`Cache ${method}: ${hit ? 'HIT' : 'MISS'}`, cacheData);
  }

  // Performance logging
  logPerformance(operation, duration, details = null) {
    const perfData = {
      operation,
      duration: `${duration}ms`,
      ...(details && { details })
    };
    
    if (duration > 1000) {
      this.warn(`Slow operation: ${operation}`, perfData);
    } else {
      this.debug(`Performance: ${operation}`, perfData);
    }
  }

  // Search logging
  logSearch(type, query, resultCount) {
    const searchData = {
      type,
      query,
      resultCount,
      timestamp: this.getTimestamp()
    };
    
    this.info(`Search performed: ${type}`, searchData);
  }

  // Security logging
  logSecurity(event, details = null) {
    const securityData = {
      event,
      timestamp: this.getTimestamp(),
      ...(details && { details })
    };
    
    this.warn(`Security event: ${event}`, securityData);
  }

  // Clean up old log files (keep last 30 days)
  cleanupOldLogs() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    try {
      const files = fs.readdirSync(this.logDir);
      
      files.forEach(file => {
        const filePath = path.join(this.logDir, file);
        const stats = fs.statSync(filePath);
        
        if (stats.mtime < thirtyDaysAgo) {
          fs.unlinkSync(filePath);
          this.info(`Deleted old log file: ${file}`);
        }
      });
    } catch (error) {
      this.error('Error cleaning up old log files', { error: error.message });
    }
  }
}

// Create singleton instance
const logger = new Logger();

// Clean up old logs daily
setInterval(() => {
  logger.cleanupOldLogs();
}, 24 * 60 * 60 * 1000); // 24 hours

module.exports = logger; 