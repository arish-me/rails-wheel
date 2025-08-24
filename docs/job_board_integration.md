# Job Board Integration Feature

## Overview

The Job Board Integration feature allows companies to sync their job postings with external job board platforms. This feature provides a flexible and extensible system for managing job board integrations with support for field mapping, automatic syncing, and comprehensive logging.

## Architecture

### Core Models

1. **JobBoardProvider** - Defines available job board platforms
2. **JobBoardIntegration** - Company-specific integration configurations
3. **JobBoardFieldMapping** - Maps local job fields to external API fields
4. **JobBoardSyncLog** - Tracks sync operations and results

### Key Features

- **Dynamic Field Mapping**: Map local job fields to external API fields
- **Multiple Authentication Types**: Support for API key, OAuth, and Basic Auth
- **Automatic Syncing**: Scheduled background jobs for automatic synchronization
- **Comprehensive Logging**: Detailed logs of all sync operations
- **Flexible Settings**: Configurable sync intervals and behavior
- **Admin Management**: Platform admins can manage available providers

## Setup and Configuration

### 1. Database Setup

The feature requires several database tables. Run the migrations:

```bash
rails db:migrate
```

### 2. Seed Job Board Providers

Seed the default job board providers:

```bash
rails runner "JobBoardProvider.seed_providers"
```

This creates providers for popular job boards like:

- Adzuna
- Arbeitnow
- Careerjet
- Findwork
- GraphQL Jobs
- Jooble
- Reed
- The Muse
- USAJOBS
- ZipRecruiter

### 3. Background Job Configuration

Ensure your background job system is configured. The feature uses Active Job with Solid Queue:

```ruby
# config/application.rb
config.active_job.queue_adapter = :solid_queue
```

## Usage

### For Platform Admins

#### Managing Job Board Providers

1. Navigate to Admin → Job Board Providers
2. View, create, edit, or delete job board providers
3. Configure provider settings including:
   - API endpoints
   - Authentication types
   - Supported fields
   - Rate limits

#### Adding a New Provider

```ruby
JobBoardProvider.create!(
  name: "New Job Board",
  slug: "new_job_board",
  description: "Description of the job board",
  api_documentation_url: "https://api.example.com/docs",
  auth_type: "api_key",
  base_url: "https://api.example.com",
  status: "active",
  settings: {
    supported_fields: %w[title description location salary],
    rate_limit: 1000,
    rate_limit_period: "hour"
  }
)
```

### For Company Users

#### Creating an Integration

1. Navigate to Integrations → Add Integration
2. Select a job board provider
3. Enter API credentials (API key, secret if required)
4. Configure sync settings:
   - Auto sync enabled/disabled
   - Sync interval
   - Which operations to perform (post new, update existing, delete closed)

#### Field Mapping

1. After creating an integration, configure field mappings
2. Map local job fields to external API fields
3. Set field types and validation rules
4. Mark required fields

#### Testing and Monitoring

1. Test the connection to verify API credentials
2. View sync logs to monitor operations
3. Check sync statistics and status

## API Integration

### JobBoardSyncService

The core service handles API interactions:

```ruby
# Test connection
integration = JobBoardIntegration.find(1)
service = JobBoardSyncService.new(integration)
result = service.test_connection

# Sync a job
job = Job.find(1)
service = JobBoardSyncService.new(integration, job)
result = service.sync

# Delete a job
result = service.delete_job
```

### Field Transformation

The system automatically transforms job data based on field mappings:

```ruby
# Example field mapping
mapping = JobBoardFieldMapping.create!(
  job_board_integration: integration,
  local_field: "title",
  external_field: "job_title",
  field_type: "string",
  is_required: true
)

# Transform value
transformed_value = mapping.transform_value("Software Engineer")
# Returns: "Software Engineer"
```

## Background Jobs

### Automatic Syncing

The system includes background jobs for automatic synchronization:

```ruby
# Queue a sync job for all integrations
JobBoardSyncJob.perform_later

# Queue a sync job for a specific integration
JobBoardSyncJob.perform_later(integration_id)
```

### Scheduling

Set up a cron job or scheduler to run automatic syncs:

```bash
# Using whenever gem
every 1.hour do
  runner "JobBoardSyncJob.perform_later"
end
```

## Rake Tasks

The feature includes several rake tasks for management:

```bash
# Sync all active integrations
rake job_board_sync:sync_all

# Sync a specific integration
rake job_board_sync:sync_integration[123]

# Test all connections
rake job_board_sync:test_connections

# Show sync statistics
rake job_board_sync:stats

# Clean old logs
rake job_board_sync:clean_logs

# Reset integration statuses
rake job_board_sync:reset_status
```

## Monitoring and Logging

### Sync Logs

All sync operations are logged with detailed information:

```ruby
# View recent logs
integration.job_board_sync_logs.recent

# View logs by status
integration.job_board_sync_logs.successful
integration.job_board_sync_logs.failed

# Get sync statistics
integration.sync_stats
```

### Log Structure

Each log entry includes:

- Action performed (test_connection, sync_job, delete_job, etc.)
- Status (success, error, warning, info)
- Message describing the operation
- Metadata with additional details (response codes, timing, etc.)

## Security Considerations

### API Credentials

- API keys and secrets are stored in the database
- Consider encrypting sensitive credentials
- Implement proper access controls for viewing credentials

### Rate Limiting

- Respect API rate limits configured in provider settings
- Implement exponential backoff for failed requests
- Monitor and log rate limit violations

### Data Validation

- Validate job data before sending to external APIs
- Implement field-level validation based on mapping rules
- Handle API errors gracefully

## Extending the Feature

### Adding New Providers

1. Create a new JobBoardProvider record
2. Configure the provider's API endpoints and settings
3. Test the integration with sample data
4. Update field mappings as needed

### Custom Field Types

The system supports various field types:

- string
- integer
- float
- boolean
- date
- datetime
- array
- object

### Custom Authentication

Extend the authentication system by modifying the `build_headers` method in `JobBoardSyncService`.

## Troubleshooting

### Common Issues

1. **Connection Failures**

   - Verify API credentials
   - Check network connectivity
   - Review API documentation for changes

2. **Field Mapping Errors**

   - Ensure required fields are mapped
   - Validate field types match expected values
   - Check for missing or invalid data

3. **Rate Limiting**
   - Monitor sync frequency
   - Implement appropriate delays
   - Contact provider for rate limit increases

### Debugging

1. Check sync logs for detailed error messages
2. Use the test connection feature to verify API access
3. Review field mappings for data transformation issues
4. Monitor background job queues for failed jobs

## Future Enhancements

### Planned Features

1. **Webhook Support**: Receive updates from job boards
2. **Bulk Operations**: Sync multiple jobs efficiently
3. **Advanced Scheduling**: More granular sync scheduling
4. **Analytics Dashboard**: Detailed sync performance metrics
5. **API Versioning**: Support for multiple API versions
6. **Custom Transformers**: User-defined data transformation rules

### Integration Ideas

1. **Real-time Sync**: WebSocket-based real-time updates
2. **Multi-tenant Support**: Enhanced isolation between companies
3. **API Gateway**: Centralized API management
4. **Machine Learning**: Intelligent field mapping suggestions
5. **Compliance Tools**: GDPR and data protection features

## Support

For technical support or feature requests, please refer to the project documentation or contact the development team.
