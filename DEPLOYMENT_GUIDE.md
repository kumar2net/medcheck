# 🚀 Netlify Deployment Guide

## Quick Start Deployment

### Prerequisites
- ✅ Netlify CLI installed: `npm install -g netlify-cli`
- ✅ Neon database account: [neon.tech](https://neon.tech)
- ✅ GitHub repository connected

---

## Step 1: Set Up Neon Database

### 1.1 Create Neon Account
1. Go to [neon.tech](https://neon.tech)
2. Sign up with GitHub or email
3. Create a new project:
   - **Project name**: `drugreco-db`
   - **Region**: Choose closest to your users
   - **Database**: `drugreco`

### 1.2 Get Connection Strings
1. In your Neon dashboard, go to **Connection Details**
2. Copy both connection strings:
   - **Pooled connection** (for `DATABASE_URL`)
   - **Direct connection** (for `DIRECT_URL`)

### 1.3 Update Environment Variables
```bash
# Run the setup script
./setup-env.sh

# Edit the environment file
nano netlify/.env
```

**Required Variables:**
```bash
DATABASE_URL="postgresql://username:password@host:port/database?sslmode=require"
DIRECT_URL="postgresql://username:password@host:port/database?sslmode=require"
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="24h"
ENABLE_AUTHENTICATION="true"
ENABLE_RATE_LIMITING="true"
ENABLE_LOGGING="true"
PASSWORD_MIN_LENGTH="6"
BCRYPT_ROUNDS="10"
ALLOWED_ORIGINS="http://localhost:3000,https://your-netlify-app.netlify.app"
NODE_ENV="production"
```

---

## Step 2: Set Up Database Schema

### 2.1 Run Database Setup
```bash
# Set environment variables for local setup
export DATABASE_URL="your-neon-pooled-url"
export DIRECT_URL="your-neon-direct-url"

# Run database setup
./scripts/setup-neon-db.sh
```

### 2.2 Verify Database Connection
```bash
# Test database connection
npx prisma studio --schema=server/prisma/schema.prisma
```

---

## Step 3: Deploy to Netlify

### 3.1 Initialize Netlify Project
```bash
# Login to Netlify (if not already logged in)
netlify login

# Initialize project
netlify init
```

**Choose these options:**
- **Create & configure a new site**
- **Team**: Your team
- **Site name**: `drugreco-app` (or your preferred name)

### 3.2 Configure Environment Variables
```bash
# Set environment variables in Netlify
netlify env:set DATABASE_URL "your-neon-pooled-url"
netlify env:set DIRECT_URL "your-neon-direct-url"
netlify env:set JWT_SECRET "your-super-secret-jwt-key"
netlify env:set JWT_EXPIRES_IN "24h"
netlify env:set ENABLE_AUTHENTICATION "true"
netlify env:set ENABLE_RATE_LIMITING "true"
netlify env:set ENABLE_LOGGING "true"
netlify env:set PASSWORD_MIN_LENGTH "6"
netlify env:set BCRYPT_ROUNDS "10"
netlify env:set NODE_ENV "production"
```

### 3.3 Deploy Application
```bash
# Deploy using the script
./deploy-netlify.sh
```

**Or deploy manually:**
```bash
# Build the application
npm run build

# Deploy to Netlify
netlify deploy --prod --dir=client/build
```

---

## Step 4: Post-Deployment Configuration

### 4.1 Update CORS Settings
After deployment, update the `ALLOWED_ORIGINS` with your Netlify domain:
```bash
netlify env:set ALLOWED_ORIGINS "https://your-app-name.netlify.app"
```

### 4.2 Verify Deployment
1. **Check Function Logs**:
   ```bash
   netlify functions:list
   netlify functions:invoke api
   ```

2. **Test API Endpoints**:
   ```bash
   # Test health check
   curl https://your-app-name.netlify.app/.netlify/functions/api/health
   
   # Test drugs endpoint
   curl https://your-app-name.netlify.app/.netlify/functions/api/drugs
   ```

3. **Test Frontend**:
   - Visit your Netlify URL
   - Test family member creation
   - Test medication addition
   - Test drug interaction checking

---

## Step 5: Monitoring and Maintenance

### 5.1 Function Monitoring
```bash
# View function logs
netlify functions:list
netlify functions:logs

# Monitor specific function
netlify functions:logs api
```

### 5.2 Database Monitoring
- Monitor Neon dashboard for:
  - Connection usage
  - Query performance
  - Storage usage
  - Error rates

### 5.3 Performance Monitoring
- Check Netlify analytics
- Monitor function response times
- Track cold start performance

---

## Troubleshooting

### Common Issues

#### 1. Function Timeout Errors
**Problem**: Functions timing out after 10 seconds
**Solution**: Optimize database queries and implement caching

#### 2. Database Connection Errors
**Problem**: Cannot connect to Neon database
**Solution**: 
- Verify connection strings
- Check Neon project status
- Ensure proper SSL configuration

#### 3. CORS Errors
**Problem**: Frontend cannot access API
**Solution**: Update `ALLOWED_ORIGINS` with correct domain

#### 4. Build Failures
**Problem**: Netlify build fails
**Solution**:
- Check build logs
- Verify all dependencies installed
- Ensure proper Node.js version

### Debug Commands
```bash
# Test functions locally
netlify dev

# Check environment variables
netlify env:list

# View deployment logs
netlify deploy:list

# Rollback deployment
netlify rollback
```

---

## Performance Optimization

### 1. Function Optimization
- Keep functions lightweight
- Use connection pooling
- Implement caching strategies

### 2. Database Optimization
- Use indexed queries
- Implement query caching
- Monitor slow queries

### 3. Frontend Optimization
- Enable gzip compression
- Use CDN for static assets
- Implement lazy loading

---

## Security Considerations

### 1. Environment Variables
- Never commit secrets to Git
- Use Netlify's environment variable management
- Rotate JWT secrets regularly

### 2. Database Security
- Use SSL connections
- Implement proper access controls
- Regular security updates

### 3. API Security
- Rate limiting enabled
- Input validation
- CORS configuration

---

## Cost Optimization

### 1. Netlify Costs
- Monitor function invocations
- Optimize function size
- Use appropriate plan

### 2. Neon Costs
- Monitor database usage
- Optimize queries
- Use appropriate tier

---

## Migration Checklist

### Pre-Deployment
- [ ] Neon database created and configured
- [ ] Environment variables set up
- [ ] Database schema migrated
- [ ] Local testing completed
- [ ] Netlify CLI installed

### Deployment
- [ ] Netlify project initialized
- [ ] Environment variables configured
- [ ] Application deployed
- [ ] CORS settings updated
- [ ] Domain configured

### Post-Deployment
- [ ] All features tested
- [ ] Performance monitored
- [ ] Error tracking set up
- [ ] Documentation updated
- [ ] Old deployment archived

---

## Support Resources

- **Netlify Docs**: [docs.netlify.com](https://docs.netlify.com)
- **Neon Docs**: [neon.tech/docs](https://neon.tech/docs)
- **Prisma Docs**: [prisma.io/docs](https://prisma.io/docs)
- **GitHub Issues**: Report issues in the repository

---

**Deployment Status**: Ready for production  
**Last Updated**: 2025-07-28  
**Version**: 1.0.0 