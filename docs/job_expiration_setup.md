# Job Expiration Setup

This document explains how job expiration works in the Rails Wheel application.

## Overview

Jobs can have the following statuses:
- `draft` - Job is being created/edited
- `published` - Job is live and accepting applications
- `closed` - Job was manually closed by the company
- `expired` - Job automatically expired due to expiration date
- `archived` - Job is archived for historical purposes

## How It Works

### 1. Job Expiration Check
- Jobs are automatically checked for expiration using a background job
- When a job's `expires_at` date passes, it's automatically marked as `expired`
- This is different from `closed` status which is manually set by companies

### 2. Background Job
The `ExpireJobsJob` runs periodically to check for expired jobs:

```ruby
# app/jobs/expire_jobs_job.rb
class ExpireJobsJob < ApplicationJob
  def perform
    expired_count = Job.expire_expired_jobs
    # Sends notifications to companies about expired jobs
  end
end
```

### 3. Rake Tasks
Two rake tasks are available:

```bash
# Run job expiration check immediately
rails jobs:expire

# Schedule job expiration check (for background processing)
rails jobs:schedule_expiration_check
```

### 4. Cron Setup (Using Whenever Gem)

The application uses the `whenever` gem for cron job management.

#### Installation
```bash
bundle install
```

#### Generate Cron Configuration
```bash
bundle exec whenever --update-crontab
```

#### View Current Cron Jobs
```bash
bundle exec whenever --list
```

#### Remove Cron Jobs
```bash
bundle exec whenever --clear-crontab
```

### 5. Schedule Configuration

The cron schedule is defined in `config/schedule.rb`:

```ruby
# Run job expiration check daily at 2 AM
every 1.day, at: '2:00 am' do
  rake "jobs:expire"
end

# Alternative: Run every hour for more frequent checks
# every 1.hour do
#   rake "jobs:expire"
# end
```

## Database Migration

Run the migration to add expired status to existing jobs:

```bash
rails db:migrate
```

This will:
- Add the `expired` status to the enum
- Update existing published jobs that have passed their expiration date to `expired` status

## Job Model Methods

### Class Methods
```ruby
Job.expire_expired_jobs  # Expires jobs that have passed expiration date
```

### Instance Methods
```ruby
job.expired?           # Returns true if job status is 'expired'
job.past_expiration_date?  # Returns true if expires_at has passed
job.active?            # Returns true if published and not past expiration
```

### Scopes
```ruby
Job.expired            # Jobs with 'expired' status
Job.expired_by_date    # Jobs where expires_at has passed
Job.active             # Published jobs that haven't expired
```

## Notifications

When jobs expire, the system can send notifications to company users. This is handled in the `ExpireJobsJob`:

```ruby
def notify_company_about_expired_job(job)
  job.company.users.each do |user|
    # Send email, push notification, etc.
  end
end
```

## Testing

To test the expiration functionality:

```bash
# Test the rake task
rails jobs:expire

# Test the background job
rails console
ExpireJobsJob.perform_now
```

## Monitoring

- Check logs at `log/cron.log` for cron job execution
- Monitor the `jobs` table for status changes
- Set up alerts for failed job expiration checks

## Troubleshooting

### Common Issues

1. **Jobs not expiring**: Check if the cron job is running
2. **Wrong timezone**: Ensure the server timezone is correct
3. **Permission issues**: Make sure the cron user has proper permissions

### Debug Commands

```bash
# Check if cron is running
crontab -l

# Check cron logs
tail -f log/cron.log

# Test job expiration manually
rails runner "Job.expire_expired_jobs"
```
