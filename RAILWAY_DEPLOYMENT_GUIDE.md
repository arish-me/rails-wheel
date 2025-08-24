# 🚀 Railway Deployment Guide for Rails Wheel

Complete step-by-step guide to deploy your Rails application with job board integrations to Railway.

## 📋 Prerequisites

- [ ] Git repository with your Rails application
- [ ] Railway account (free at [railway.app](https://railway.app))
- [ ] Node.js installed (for Railway CLI)
- [ ] Your Rails application ready for production

## 🛠️ Step 1: Prepare Your Application

### 1.1 Update Database Configuration

Your `config/database.yml` is already configured for Railway.

### 1.2 Update Production Environment

Your `config/environments/production.rb` is already configured.

### 1.3 Generate Master Key

```bash
# Generate a new master key
rails credentials:edit
```

### 1.4 Generate Secret Key Base

```bash
# Generate secret key base
rails secret
```

## 🚀 Step 2: Install Railway CLI

```bash
# Install Railway CLI globally
npm install -g @railway/cli

# Login to Railway
railway login
```

## 📁 Step 3: Initialize Railway Project

```bash
# Navigate to your Rails project directory
cd /path/to/your/rails-wheel

# Initialize Railway project
railway init

# This will create a .railway directory and link your project
```

## 🗄️ Step 4: Add PostgreSQL Database

1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Create a new project or select existing one
3. Click "New Service" → "Database" → "PostgreSQL"
4. Railway will automatically provide database credentials

## ⚙️ Step 5: Configure Environment Variables

1. In Railway dashboard, go to your project
2. Click "Variables" tab
3. Add the following environment variables:

### Required Variables:

```
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_from_step_1
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=your_secret_key_from_step_1
HOST=your-app-name.railway.app
```

### Database Variables (Railway provides these):

```
DATABASE_URL=postgresql://username:password@host:port/database
DATABASE_NAME=your_database_name
DATABASE_USERNAME=your_database_username
DATABASE_PASSWORD=your_database_password
DATABASE_HOST=your_database_host
DATABASE_PORT=5432
```

### Optional Variables:

```
JOB_BOARD_SYNC_ENABLED=true
JOB_BOARD_SYNC_INTERVAL=3600
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key
```

## 🚀 Step 6: Deploy Your Application

### Option A: Using Railway CLI

```bash
# Deploy to Railway
railway up

# Or use the deployment script
./deploy_railway.sh
```

### Option B: Using Railway Dashboard

1. Connect your GitHub repository to Railway
2. Railway will automatically deploy on every push
3. Or manually trigger deployment from dashboard

## 🗄️ Step 7: Run Database Migrations

```bash
# Run migrations on Railway
railway run rails db:migrate

# Seed initial data (if needed)
railway run rails db:seed
```

## 🔧 Step 8: Configure Background Jobs

### Option A: Using Railway's Built-in Redis

1. Add Redis service in Railway dashboard
2. Add `REDIS_URL` environment variable
3. Update your background job configuration

### Option B: Using Solid Queue (Default)

Your app is already configured to use Solid Queue for background jobs.

## 🌐 Step 9: Set Up Custom Domain (Optional)

1. In Railway dashboard, go to "Settings" → "Domains"
2. Add your custom domain
3. Update DNS records as instructed
4. Railway will automatically provision SSL certificate

## 📊 Step 10: Monitor Your Application

1. **Logs**: View real-time logs in Railway dashboard
2. **Metrics**: Monitor CPU, memory, and network usage
3. **Health Checks**: Railway automatically checks `/up` endpoint

## 🔍 Step 11: Test Your Deployment

1. Visit your Railway URL: `https://your-app-name.railway.app`
2. Test job board integrations
3. Verify background jobs are working
4. Check database connections

## 🛠️ Troubleshooting

### Common Issues:

1. **Build Fails**

   - Check `nixpacks.toml` configuration
   - Verify all dependencies in `Gemfile`
   - Check build logs in Railway dashboard

2. **Database Connection Issues**

   - Verify `DATABASE_URL` environment variable
   - Check database service is running
   - Run `railway run rails db:migrate`

3. **Asset Compilation Fails**

   - Check `config/environments/production.rb`
   - Verify `RAILS_SERVE_STATIC_FILES=true`
   - Check `nixpacks.toml` build commands

4. **Background Jobs Not Working**
   - Verify Redis configuration
   - Check `Procfile` configuration
   - Monitor worker logs

### Useful Commands:

```bash
# View logs
railway logs

# Run Rails console
railway run rails console

# Run database commands
railway run rails db:migrate

# Check environment variables
railway variables
```

## 📈 Step 12: Scale Your Application

### Automatic Scaling:

- Railway automatically scales based on traffic
- No manual intervention needed

### Manual Scaling:

1. Go to Railway dashboard
2. Select your service
3. Adjust CPU and memory allocation
4. Railway will handle the rest

## 💰 Cost Optimization

### Free Tier:

- $5/month base cost
- Pay for actual usage
- Good for development and small applications

### Production Recommendations:

- Monitor usage in Railway dashboard
- Set up usage alerts
- Optimize database queries
- Use caching where appropriate

## 🔄 Continuous Deployment

### GitHub Integration:

1. Connect your GitHub repository to Railway
2. Railway will automatically deploy on every push
3. Set up branch protection rules
4. Use feature branches for testing

### Environment Management:

- Use different Railway projects for staging/production
- Set up environment-specific variables
- Test deployments in staging first

## 🎉 Success!

Your Rails application with job board integrations is now deployed on Railway!

### Next Steps:

1. Set up monitoring and alerts
2. Configure backup strategies
3. Set up CI/CD pipelines
4. Optimize performance
5. Set up custom domains

### Support:

- [Railway Documentation](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway)
- [Railway Status](https://status.railway.app)

---

**Happy Deploying! 🚀**
