#!/bin/bash

echo "🚀 Quick Railway Deployment for Rails Wheel"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Railway CLI...${NC}"
    npm install -g @railway/cli
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Please login to Railway...${NC}"
    railway login
fi

# Generate keys if needed
echo -e "${GREEN}🔑 Generating application keys...${NC}"
SECRET_KEY_BASE=$(rails secret)
echo "Your SECRET_KEY_BASE: $SECRET_KEY_BASE"

# Check if master key exists
if [ ! -f "config/master.key" ]; then
    echo -e "${YELLOW}🔑 Generating master key...${NC}"
    rails credentials:edit
fi

# Initialize Railway project if not already done
if [ ! -f ".railway" ]; then
    echo -e "${GREEN}📁 Initializing Railway project...${NC}"
    railway init
fi

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Go to Railway dashboard: https://railway.app/dashboard"
echo "2. Add PostgreSQL database service"
echo "3. Set environment variables:"
echo "   - RAILS_ENV=production"
echo "   - RAILS_MASTER_KEY=$(cat config/master.key)"
echo "   - SECRET_KEY_BASE=$SECRET_KEY_BASE"
echo "   - RAILS_LOG_TO_STDOUT=true"
echo "   - RAILS_SERVE_STATIC_FILES=true"
echo "4. Run: railway up"
echo "5. Run: railway run rails db:migrate"
echo ""
echo -e "${GREEN}🎉 Your app will be live at: https://your-app-name.railway.app${NC}"
