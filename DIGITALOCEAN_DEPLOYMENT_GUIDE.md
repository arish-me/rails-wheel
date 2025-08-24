# 🐳 DigitalOcean Deployment Guide for Rails Wheel

Complete step-by-step guide to deploy your Rails application with job board integrations to DigitalOcean.

## 📋 Prerequisites

- [ ] DigitalOcean account (sign up at [digitalocean.com](https://digitalocean.com))
- [ ] Domain name (optional but recommended)
- [ ] SSH key pair
- [ ] Git repository with your Rails application

## 🛠️ Step 1: Prepare Your Application

### 1.1 Update Production Configuration

Your application is already configured for production deployment.

### 1.2 Generate Application Keys

```bash
# Generate secret key base
rails secret

# Generate master key (if not exists)
rails credentials:edit
```

### 1.3 Create Deployment Scripts

We'll create these in the next steps.

## 🖥️ Step 2: Create DigitalOcean Droplet

### 2.1 Choose Droplet Configuration

1. Go to [DigitalOcean Dashboard](https://cloud.digitalocean.com)
2. Click "Create" → "Droplets"
3. Choose configuration:
   - **Distribution**: Ubuntu 22.04 LTS
   - **Plan**: Basic
   - **Size**:
     - **Development**: $6/month (1GB RAM, 1 CPU)
     - **Production**: $12/month (2GB RAM, 1 CPU) or higher
   - **Datacenter**: Choose closest to your users
   - **Authentication**: SSH Key (recommended) or Password

### 2.2 Add SSH Key (Recommended)

1. Generate SSH key locally:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```
2. Copy public key to DigitalOcean
3. Select your SSH key when creating droplet

### 2.3 Create Droplet

- **Hostname**: `rails-wheel-production` (or your preferred name)
- Click "Create Droplet"

## 🔧 Step 3: Initial Server Setup

### 3.1 Connect to Your Server

```bash
ssh root@your_server_ip
```

### 3.2 Create Deploy User

```bash
# Create deploy user
adduser deploy
usermod -aG sudo deploy

# Switch to deploy user
su - deploy
```

### 3.3 Set Up SSH for Deploy User

```bash
# Create .ssh directory
mkdir ~/.ssh
chmod 700 ~/.ssh

# Copy your public key
nano ~/.ssh/authorized_keys
# Paste your public key here

chmod 600 ~/.ssh/authorized_keys
```

### 3.4 Configure SSH (as root)

```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Add/modify these lines:
PermitRootLogin no
PasswordAuthentication no
AllowUsers deploy

# Restart SSH
systemctl restart ssh
```

## 🐳 Step 4: Install Docker and Docker Compose

### 4.1 Install Docker

```bash
# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add deploy user to docker group
sudo usermod -aG docker deploy

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 4.2 Install Docker Compose

```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 🗄️ Step 5: Set Up PostgreSQL Database

### 5.1 Create Docker Compose File

```bash
# Create app directory
mkdir -p ~/rails-wheel
cd ~/rails-wheel

# Create docker-compose.yml
nano docker-compose.yml
```

### 5.2 Docker Compose Configuration

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_DB: rails_wheel_production
      POSTGRES_USER: rails_wheel
      POSTGRES_PASSWORD: your_secure_password_here
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'

  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - redis_data:/data
    ports:
      - '6379:6379'

volumes:
  postgres_data:
  redis_data:
```

### 5.3 Start Database Services

```bash
# Start services
docker-compose up -d

# Verify services are running
docker-compose ps
```

## 🚀 Step 6: Deploy Your Application

### 6.1 Create Application Directory

```bash
# Create app directory
mkdir -p ~/rails-wheel/app
cd ~/rails-wheel/app
```

### 6.2 Clone Your Repository

```bash
# Clone your repository
git clone https://github.com/yourusername/rails-wheel.git .

# Or if using SSH
git clone git@github.com:yourusername/rails-wheel.git .
```

### 6.3 Create Production Dockerfile

```bash
# Create Dockerfile
nano Dockerfile
```

```dockerfile
FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    yarn \
    git

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy package.json and install node modules
COPY package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile
RUN bundle exec rails assets:clean

# Create non-root user
RUN addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails

# Change ownership
RUN chown -R rails:rails /app
USER rails

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
```

### 6.4 Create Application Docker Compose

```bash
# Create app docker-compose.yml
nano docker-compose.app.yml
```

```yaml
version: '3.8'

services:
  web:
    build: .
    restart: always
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://rails_wheel:your_secure_password_here@db:5432/rails_wheel_production
      REDIS_URL: redis://redis:6379/0
      RAILS_MASTER_KEY: your_master_key_here
      SECRET_KEY_BASE: your_secret_key_base_here
      RAILS_LOG_TO_STDOUT: 'true'
      RAILS_SERVE_STATIC_FILES: 'true'
    depends_on:
      - db
      - redis
    ports:
      - '3000:3000'
    volumes:
      - ./storage:/app/storage
      - ./log:/app/log

  worker:
    build: .
    restart: always
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://rails_wheel:your_secure_password_here@db:5432/rails_wheel_production
      REDIS_URL: redis://redis:6379/0
      RAILS_MASTER_KEY: your_master_key_here
      SECRET_KEY_BASE: your_secret_key_base_here
      RAILS_LOG_TO_STDOUT: 'true'
    depends_on:
      - db
      - redis
    volumes:
      - ./storage:/app/storage
      - ./log:/app/log
    command: bundle exec rails solid_queue:start
```

### 6.5 Build and Deploy

```bash
# Build and start application
docker-compose -f docker-compose.app.yml up -d --build

# Run database migrations
docker-compose -f docker-compose.app.yml exec web rails db:migrate

# Seed database (if needed)
docker-compose -f docker-compose.app.yml exec web rails db:seed
```

## 🌐 Step 7: Set Up Nginx Reverse Proxy

### 7.1 Install Nginx

```bash
sudo apt update
sudo apt install -y nginx
```

### 7.2 Configure Nginx

```bash
# Create nginx configuration
sudo nano /etc/nginx/sites-available/rails-wheel
```

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL Configuration (we'll set this up with Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Proxy to Rails app
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }

    # Serve static assets
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_pass http://localhost:3000;
    }

    # Health check
    location /up {
        proxy_pass http://localhost:3000;
        access_log off;
    }
}
```

### 7.3 Enable Site

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/rails-wheel /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## 🔒 Step 8: Set Up SSL with Let's Encrypt

### 8.1 Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 8.2 Get SSL Certificate

```bash
# Get certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Set up auto-renewal
sudo crontab -e
# Add this line:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Step 9: Set Up Monitoring and Logs

### 9.1 Install Monitoring Tools

```bash
# Install htop for system monitoring
sudo apt install -y htop

# Install logrotate
sudo apt install -y logrotate
```

### 9.2 Configure Log Rotation

```bash
# Create logrotate configuration
sudo nano /etc/logrotate.d/rails-wheel
```

```
/home/deploy/rails-wheel/app/log/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 deploy deploy
    postrotate
        docker-compose -f /home/deploy/rails-wheel/docker-compose.app.yml restart web
    endscript
}
```

## 🚀 Step 10: Set Up Backup Strategy

### 10.1 Database Backup Script

```bash
# Create backup script
nano ~/backup.sh
```

```bash
#!/bin/bash

# Backup database
docker-compose exec -T db pg_dump -U rails_wheel rails_wheel_production > ~/backups/db_backup_$(date +%Y%m%d_%H%M%S).sql

# Keep only last 7 days of backups
find ~/backups -name "db_backup_*.sql" -mtime +7 -delete
```

### 10.2 Set Up Automated Backups

```bash
# Make script executable
chmod +x ~/backup.sh

# Create backups directory
mkdir -p ~/backups

# Add to crontab
crontab -e
# Add this line for daily backups at 2 AM:
# 0 2 * * * /home/deploy/backup.sh
```

## 🔄 Step 11: Set Up Deployment Automation

### 11.1 Create Deployment Script

```bash
# Create deployment script
nano ~/deploy.sh
```

```bash
#!/bin/bash

echo "🚀 Deploying Rails Wheel..."

# Navigate to app directory
cd ~/rails-wheel/app

# Pull latest changes
git pull origin main

# Build and restart containers
docker-compose -f ../docker-compose.app.yml down
docker-compose -f ../docker-compose.app.yml up -d --build

# Run migrations
docker-compose -f ../docker-compose.app.yml exec -T web rails db:migrate

# Restart nginx
sudo systemctl restart nginx

echo "✅ Deployment complete!"
```

### 11.2 Make Script Executable

```bash
chmod +x ~/deploy.sh
```

## 📊 Step 12: Performance Optimization

### 12.1 Configure Swap (if needed)

```bash
# Check if swap exists
free -h

# If no swap, create one
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 12.2 Optimize PostgreSQL

```bash
# Edit PostgreSQL configuration
docker-compose exec db nano /var/lib/postgresql/data/postgresql.conf

# Add these optimizations:
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

## 🎉 Success!

Your Rails application with job board integrations is now deployed on DigitalOcean!

### 🌐 Your Application URLs:

- **Production**: https://your-domain.com
- **Health Check**: https://your-domain.com/up

### 📋 Useful Commands:

```bash
# View logs
docker-compose -f docker-compose.app.yml logs -f web

# Restart application
docker-compose -f docker-compose.app.yml restart

# Deploy updates
~/deploy.sh

# Access Rails console
docker-compose -f docker-compose.app.yml exec web rails console

# Run database commands
docker-compose -f docker-compose.app.yml exec web rails db:migrate
```

### 🔧 Maintenance:

- **Updates**: Run `~/deploy.sh` to deploy updates
- **Backups**: Automatic daily backups at 2 AM
- **SSL**: Auto-renewed by Let's Encrypt
- **Monitoring**: Use `htop` to monitor system resources

### 💰 Estimated Costs:

- **Droplet**: $6-12/month
- **Domain**: $10-15/year
- **Total**: ~$7-15/month

---

**Happy Deploying! 🚀**
