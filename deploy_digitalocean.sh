#!/bin/bash

echo "🐳 Deploying Rails Wheel to DigitalOcean..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creating .env file...${NC}"
    cat > .env << EOF
# DigitalOcean Deployment Environment Variables
POSTGRES_PASSWORD=$(openssl rand -base64 32)
RAILS_MASTER_KEY=$(cat config/master.key)
SECRET_KEY_BASE=$(rails secret)
HOST=your-domain.com
EOF
    echo -e "${GREEN}✅ .env file created${NC}"
fi

# Load environment variables
source .env

echo -e "${BLUE}🔧 Starting database and Redis services...${NC}"
docker-compose up -d

echo -e "${BLUE}⏳ Waiting for services to be healthy...${NC}"
sleep 10

echo -e "${BLUE}🚀 Building and starting Rails application...${NC}"
docker-compose -f docker-compose.app.yml up -d --build

echo -e "${BLUE}⏳ Waiting for application to start...${NC}"
sleep 15

echo -e "${BLUE}🗄️ Running database migrations...${NC}"
docker-compose -f docker-compose.app.yml exec -T web rails db:migrate

echo -e "${BLUE}🌱 Seeding database...${NC}"
docker-compose -f docker-compose.app.yml exec -T web rails db:seed

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Set up Nginx reverse proxy"
echo "2. Configure SSL with Let's Encrypt"
echo "3. Set up monitoring and backups"
echo "4. Configure your domain DNS"
echo ""
echo -e "${GREEN}🌐 Your app should be running at: http://localhost:3000${NC}"
echo -e "${GREEN}📊 Check logs with: docker-compose -f docker-compose.app.yml logs -f${NC}"
