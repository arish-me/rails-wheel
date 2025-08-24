class JobBoardAdapters::BaseAdapter
  attr_reader :integration

  def initialize(integration)
    @integration = integration
  end

  # Abstract methods that must be implemented by each provider
  def fetch_jobs
    raise NotImplementedError, "#{self.class} must implement fetch_jobs"
  end

  def push_job(job_data)
    raise NotImplementedError, "#{self.class} must implement push_job"
  end

  def delete_job(job_id)
    raise NotImplementedError, "#{self.class} must implement delete_job"
  end

  def test_connection
    raise NotImplementedError, "#{self.class} must implement test_connection"
  end

  # Transform external job data to local format
  def transform_external_job(external_job_data)
    raise NotImplementedError, "#{self.class} must implement transform_external_job"
  end

  # Transform local job data to external format
  def transform_local_job(job)
    raise NotImplementedError, "#{self.class} must implement transform_local_job"
  end

  # Get supported fields for this provider
  def supported_fields
    raise NotImplementedError, "#{self.class} must implement supported_fields"
  end

  protected

  def make_request(method, url, options = {})
    headers = options[:headers] || {}
    body = options[:body]
    timeout = options[:timeout] || 30

    case method.to_s.downcase
    when "get"
      HTTParty.get(url, headers: headers, timeout: timeout)
    when "post"
      HTTParty.post(url, headers: headers, body: body, timeout: timeout)
    when "put"
      HTTParty.put(url, headers: headers, body: body, timeout: timeout)
    when "delete"
      HTTParty.delete(url, headers: headers, timeout: timeout)
    else
      raise ArgumentError, "Unsupported HTTP method: #{method}"
    end
  rescue StandardError => e
    log_error("HTTP request failed", error: e.message, url: url, method: method)
    mock_error_response(e.message)
  end

  def log_error(message, metadata = {})
    integration.log_sync(
      "adapter_error",
      "error",
      message,
      metadata: metadata
    )
  end

  def mock_error_response(error_message)
    response = double("HTTParty::Response")
    allow(response).to receive(:success?).and_return(false)
    allow(response).to receive(:code).and_return(500)
    allow(response).to receive(:body).and_return({ error: error_message }.to_json)
    response
  end

  def mock_success_response(data = {})
    response = double("HTTParty::Response")
    allow(response).to receive(:success?).and_return(true)
    allow(response).to receive(:code).and_return(200)
    allow(response).to receive(:body).and_return(data.to_json)
    response
  end

  def build_headers(provider)
    headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }

    case provider.auth_type
    when 'api_key'
      headers['X-API-Key'] = integration.api_key
    when 'oauth'
      headers['Authorization'] = "Bearer #{integration.api_key}"
    when 'basic_auth'
      credentials = Base64.strict_encode64("#{integration.api_key}:#{integration.api_secret}")
      headers['Authorization'] = "Basic #{credentials}"
    when 'public_api'
      # No authentication required (public APIs)
      headers
    end

    headers
  end
end
