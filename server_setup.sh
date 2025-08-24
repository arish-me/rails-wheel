#!/bin/bash

echo "🖥️ DigitalOcean Server Setup Script"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 Updating system packages...${NC}"
apt update && apt upgrade -y

echo -e "${BLUE}👤 Creating deploy user...${NC}"
adduser --gecos "" deploy
usermod -aG sudo deploy

echo -e "${BLUE}🔑 Setting up SSH for deploy user...${NC}"
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

echo -e "${BLUE}🐳 Installing Docker...${NC}"
# Install prerequisites
apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Add deploy user to docker group
usermod -aG docker deploy

# Start and enable Docker
systemctl start docker
systemctl enable docker

echo -e "${BLUE}📦 Installing Docker Compose...${NC}"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo -e "${BLUE}🌐 Installing Nginx...${NC}"
apt install -y nginx

echo -e "${BLUE}🔒 Installing Certbot for SSL...${NC}"
apt install -y certbot python3-certbot-nginx

echo -e "${BLUE}📊 Installing monitoring tools...${NC}"
apt install -y htop logrotate

echo -e "${BLUE}🔧 Configuring SSH security...${NC}"
# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Update SSH config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "AllowUsers deploy" >> /etc/ssh/sshd_config

# Restart SSH
systemctl restart ssh

echo -e "${BLUE}📁 Creating application directory...${NC}"
mkdir -p /home/deploy/rails-wheel
chown deploy:deploy /home/deploy/rails-wheel

echo -e "${GREEN}✅ Server setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Switch to deploy user: su - deploy"
echo "2. Clone your repository to /home/deploy/rails-wheel"
echo "3. Set up environment variables"
echo "4. Run the deployment script"
echo ""
echo -e "${RED}⚠️  Important:${NC}"
echo "- Root login is now disabled"
echo "- Only deploy user can SSH"
echo "- Make sure your SSH key is working before disconnecting"
echo ""
echo -e "${GREEN}🎉 Server is ready for deployment!${NC}"
