#!/bin/bash

echo "🚀 Deploying Rails Wheel to Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Logging into Railway..."
railway login

# Initialize Railway project (if not already done)
if [ ! -f ".railway" ]; then
    echo "📁 Initializing Railway project..."
    railway init
fi

# Link to existing project (if you have one)
# railway link

# Deploy to Railway
echo "🚀 Deploying application..."
railway up

echo "✅ Deployment complete!"
echo "🌐 Your app should be available at: https://your-app-name.railway.app"
echo ""
echo "📋 Next steps:"
echo "1. Set up environment variables in Railway dashboard"
echo "2. Configure your database"
echo "3. Set up your custom domain (optional)"
echo "4. Configure background jobs"
