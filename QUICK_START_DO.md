# 🚀 Quick Start: DigitalOcean Deployment

Get your Rails Wheel application deployed on DigitalOcean in 30 minutes!

## 📋 Prerequisites

- [ ] DigitalOcean account
- [ ] Domain name (optional)
- [ ] SSH key pair
- [ ] Git repository access

## ⚡ Quick Deployment Steps

### Step 1: Create DigitalOcean Droplet

1. **Go to DigitalOcean Dashboard**

   - Visit [cloud.digitalocean.com](https://cloud.digitalocean.com)
   - Click "Create" → "Droplets"

2. **Choose Configuration**

   - **Distribution**: Ubuntu 22.04 LTS
   - **Plan**: Basic
   - **Size**: $12/month (2GB RAM, 1 CPU) - recommended for production
   - **Datacenter**: Choose closest to your users
   - **Authentication**: SSH Key (add your public key)

3. **Create Droplet**
   - **Hostname**: `rails-wheel-production`
   - Click "Create Droplet"

### Step 2: Initial Server Setup

1. **Connect to Server**

   ```bash
   ssh root@your_server_ip
   ```

2. **Run Server Setup Script**

   ```bash
   # Copy the server_setup.sh script to your server
   # Then run:
   chmod +x server_setup.sh
   ./server_setup.sh
   ```

3. **Switch to Deploy User**
   ```bash
   su - deploy
   ```

### Step 3: Deploy Application

1. **Clone Repository**

   ```bash
   cd ~/rails-wheel
   git clone https://github.com/yourusername/rails-wheel.git .
   ```

2. **Generate Application Keys**

   ```bash
   # Generate secret key base
   rails secret

   # Generate master key (if needed)
   rails credentials:edit
   ```

3. **Create Environment File**

   ```bash
   nano .env
   ```

   Add your environment variables (see `digitalocean_env_vars.md`)

4. **Deploy Application**
   ```bash
   chmod +x deploy_digitalocean.sh
   ./deploy_digitalocean.sh
   ```

### Step 4: Set Up Domain & SSL

1. **Configure Nginx**

   ```bash
   sudo nano /etc/nginx/sites-available/rails-wheel
   ```

   Use the nginx configuration from the main guide

2. **Enable Site**

   ```bash
   sudo ln -s /etc/nginx/sites-available/rails-wheel /etc/nginx/sites-enabled/
   sudo rm /etc/nginx/sites-enabled/default
   sudo nginx -t
   sudo systemctl restart nginx
   ```

3. **Get SSL Certificate**
   ```bash
   sudo certbot --nginx -d your-domain.com -d www.your-domain.com
   ```

## 🎉 Success!

Your application is now deployed at: `https://your-domain.com`

## 📊 Useful Commands

```bash
# View application logs
docker-compose -f docker-compose.app.yml logs -f web

# Restart application
docker-compose -f docker-compose.app.yml restart

# Access Rails console
docker-compose -f docker-compose.app.yml exec web rails console

# Run database commands
docker-compose -f docker-compose.app.yml exec web rails db:migrate

# Deploy updates
cd ~/rails-wheel && git pull && docker-compose -f docker-compose.app.yml up -d --build
```

## 🔧 Troubleshooting

### Common Issues:

1. **Build Fails**

   ```bash
   # Check Docker logs
   docker-compose -f docker-compose.app.yml logs web
   ```

2. **Database Connection Issues**

   ```bash
   # Check database service
   docker-compose ps
   docker-compose logs db
   ```

3. **Nginx Issues**

   ```bash
   # Check nginx configuration
   sudo nginx -t
   sudo systemctl status nginx
   ```

4. **SSL Issues**
   ```bash
   # Check certificate
   sudo certbot certificates
   sudo certbot renew --dry-run
   ```

## 💰 Cost Breakdown

- **Droplet**: $12/month (2GB RAM, 1 CPU)
- **Domain**: $10-15/year
- **Total**: ~$13/month

## 🚀 Next Steps

1. **Set up monitoring** with htop and log monitoring
2. **Configure backups** for database and files
3. **Set up CI/CD** for automatic deployments
4. **Optimize performance** with caching and CDN
5. **Set up monitoring alerts**

---

**Need help?** Check the full guide in `DIGITALOCEAN_DEPLOYMENT_GUIDE.md`
