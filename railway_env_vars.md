# Railway Environment Variables

Copy these environment variables to your Railway dashboard:

## Required Variables

### Rails Configuration

```
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_here
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

### Database Configuration (Railway will provide these)

```
DATABASE_URL=postgresql://username:password@host:port/database
DATABASE_NAME=your_database_name
DATABASE_USERNAME=your_database_username
DATABASE_PASSWORD=your_database_password
DATABASE_HOST=your_database_host
DATABASE_PORT=5432
```

### Application Configuration

```
SECRET_KEY_BASE=your_secret_key_base_here
HOST=your-app-name.railway.app
```

## Optional Variables

### Redis Configuration (for background jobs)

```
REDIS_URL=redis://username:password@host:port
```

### Job Board Integration Settings

```
JOB_BOARD_SYNC_ENABLED=true
JOB_BOARD_SYNC_INTERVAL=3600
```

### Email Configuration

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_DOMAIN=your-app-name.railway.app
```

### External API Keys

```
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key
REMOTIVE_API_KEY=not_needed_for_public_api
```

## How to Set Environment Variables in Railway

1. Go to your Railway dashboard
2. Select your project
3. Go to "Variables" tab
4. Add each variable above
5. Click "Deploy" to apply changes
