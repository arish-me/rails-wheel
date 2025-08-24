# DigitalOcean Environment Variables

Copy these environment variables to your `.env` file on the server:

## Required Variables

### Database Configuration
```
POSTGRES_PASSWORD=your_secure_password_here
DATABASE_URL=postgresql://rails_wheel:your_secure_password_here@db:5432/rails_wheel_production
```

### Rails Configuration
```
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_here
SECRET_KEY_BASE=your_secret_key_base_here
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

### Application Configuration
```
HOST=your-domain.com
```

## Optional Variables

### Redis Configuration
```
REDIS_URL=redis://redis:6379/0
```

### Job Board Integration Settings
```
JOB_BOARD_SYNC_ENABLED=true
JOB_BOARD_SYNC_INTERVAL=3600
```

### External API Keys
```
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key
REMOTIVE_API_KEY=not_needed_for_public_api
```

### Email Configuration
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_DOMAIN=your-domain.com
```

## How to Generate Keys

### Generate Secret Key Base
```bash
rails secret
```

### Generate Master Key
```bash
rails credentials:edit
```

### Generate Secure Password
```bash
openssl rand -base64 32
```

## Example .env File

```bash
# DigitalOcean Deployment Environment Variables
POSTGRES_PASSWORD=your_generated_secure_password
RAILS_MASTER_KEY=your_master_key_from_credentials
SECRET_KEY_BASE=your_generated_secret_key_base
HOST=your-domain.com
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
REDIS_URL=redis://redis:6379/0
JOB_BOARD_SYNC_ENABLED=true
JOB_BOARD_SYNC_INTERVAL=3600
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key
```

## Security Notes

1. **Never commit .env files** to version control
2. **Use strong passwords** for database
3. **Keep keys secure** and rotate regularly
4. **Use environment-specific** configurations
5. **Backup your keys** securely
