# JobBoardApiService - Integrates with real job board APIs
class JobBoardApiService
  include HTTParty

  # Adzuna API (Free tier available)
  ADZUNA_CONFIG = {
    base_url: "https://api.adzuna.com/v1/api",
    app_id: ENV.fetch("ADZUNA_APP_ID", nil),
    app_key: ENV.fetch("ADZUNA_APP_KEY", nil),
    countries: %w[us gb au ca de in it mx nl nz pl sg es]
  }.freeze

  # Reed.co.uk API (UK jobs)
  REED_CONFIG = {
    base_url: "https://www.reed.co.uk/api/1.0",
    api_key: ENV.fetch("REED_API_KEY", nil)
  }.freeze

  # GitHub Jobs API (Historical data simulation)
  GITHUB_JOBS_DATA = [
    {
      title: "Senior Ruby Developer",
      company: "TechCorp",
      location: "San Francisco, CA",
      description: "We're looking for a senior Ruby developer to join our team...",
      salary_min: 120_000,
      salary_max: 160_000,
      job_type: "full_time",
      experience_level: "senior"
    },
    {
      title: "Frontend React Developer",
      company: "StartupXYZ",
      location: "New York, NY",
      description: "Join our frontend team to build amazing user experiences...",
      salary_min: 80_000,
      salary_max: 120_000,
      job_type: "full_time",
      experience_level: "mid"
    }
  ].freeze

  def self.fetch_adzuna_jobs(country: "us", location: nil, keywords: nil, limit: 10)
    return [] unless ADZUNA_CONFIG[:app_id] && ADZUNA_CONFIG[:app_key]

    begin
      params = {
        app_id: ADZUNA_CONFIG[:app_id],
        app_key: ADZUNA_CONFIG[:app_key],
        results_per_page: limit,
        what: keywords,
        where: location
      }.compact

      response = HTTParty.get("#{ADZUNA_CONFIG[:base_url]}/jobs/#{country}/search/1", query: params)

      if response.success?
        parse_adzuna_response(response.parsed_response)
      else
        Rails.logger.error "Adzuna API error: #{response.code} - #{response.body}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Adzuna API exception: #{e.message}"
      []
    end
  end

  def self.fetch_reed_jobs(keywords: nil, location: nil, limit: 10)
    return [] unless REED_CONFIG[:api_key]

    begin
      params = {
        keywords: keywords,
        locationName: location,
        distanceFromLocation: 10,
        resultsToTake: limit
      }.compact

      response = HTTParty.get("#{REED_CONFIG[:base_url]}/search",
                              query: params,
                              headers: { "Authorization" => "Basic #{Base64.strict_encode64("#{REED_CONFIG[:api_key]}:")}" })

      if response.success?
        parse_reed_response(response.parsed_response)
      else
        Rails.logger.error "Reed API error: #{response.code} - #{response.body}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Reed API exception: #{e.message}"
      []
    end
  end

  def self.fetch_github_jobs_simulation(keywords: nil, location: nil, limit: 10)
    # Simulate GitHub Jobs API with historical data
    jobs = GITHUB_JOBS_DATA.dup

    # Filter by keywords if provided
    if keywords.present?
      jobs = jobs.select do |job|
        job[:title].downcase.include?(keywords.downcase) ||
          job[:description].downcase.include?(keywords.downcase)
      end
    end

    # Filter by location if provided
    jobs = jobs.select { |job| job[:location].downcase.include?(location.downcase) } if location.present?

    jobs.first(limit).map { |job| transform_github_job(job) }
  end

  def self.fetch_all_sources(keywords: nil, location: nil, limit: 5)
    all_jobs = []

    # Fetch from multiple sources
    all_jobs += fetch_adzuna_jobs(keywords: keywords, location: location, limit: limit)
    all_jobs += fetch_reed_jobs(keywords: keywords, location: location, limit: limit)
    all_jobs += fetch_github_jobs_simulation(keywords: keywords, location: location, limit: limit)

    # Remove duplicates and limit total results
    all_jobs.uniq { |job| job[:external_id] }.first(limit * 3)
  end

  def self.parse_adzuna_response(response)
    return [] unless response["results"]

    response["results"].map do |job|
      {
        title: job["title"],
        company: job["company"]["display_name"],
        location: job["location"]["display_name"],
        description: job["description"],
        salary_min: job["salary_min"],
        salary_max: job["salary_max"],
        salary_currency: job["salary_currency"],
        job_type: map_adzuna_job_type(job["contract_time"]),
        experience_level: estimate_experience_level(job["title"]),
        remote_policy: job["location"]["area"].include?("Remote") ? "remote" : "on_site",
        external_id: "adzuna_#{job['id']}",
        external_source: "adzuna",
        external_url: job["redirect_url"],
        posted_at: job["created"],
        external_data: {
          category: job["category"]["label"],
          contract_time: job["contract_time"],
          area: job["location"]["area"]
        }
      }
    end
  end

  def self.parse_reed_response(response)
    return [] unless response["results"]

    response["results"].map do |job|
      {
        title: job["jobTitle"],
        company: job["employerName"],
        location: job["locationName"],
        description: job["jobDescription"],
        salary_min: job["minimumSalary"],
        salary_max: job["maximumSalary"],
        salary_currency: "GBP", # Reed is UK-focused
        job_type: map_reed_job_type(job["employmentType"]),
        experience_level: estimate_experience_level(job["jobTitle"]),
        remote_policy: job["locationName"].include?("Remote") ? "remote" : "on_site",
        external_id: "reed_#{job['jobId']}",
        external_source: "reed",
        external_url: job["jobUrl"],
        posted_at: job["datePosted"],
        external_data: {
          jobId: job["jobId"],
          employmentType: job["employmentType"],
          currency: job["currency"]
        }
      }
    end
  end

  def self.transform_github_job(job)
    {
      title: job[:title],
      company: job[:company],
      location: job[:location],
      description: job[:description],
      salary_min: job[:salary_min],
      salary_max: job[:salary_max],
      salary_currency: "USD",
      job_type: job[:job_type],
      experience_level: job[:experience_level],
      remote_policy: job[:location].include?("Remote") ? "remote" : "on_site",
      external_id: "github_#{SecureRandom.hex(8)}",
      external_source: "github",
      external_url: "https://jobs.github.com/positions/#{SecureRandom.hex(8)}",
      posted_at: rand(1..30).days.ago.iso8601,
      external_data: {
        source: "github_jobs",
        simulated: true
      }
    }
  end

  def self.map_adzuna_job_type(contract_time)
    case contract_time&.downcase
    when "full_time"
      "full_time"
    when "part_time"
      "part_time"
    when "contract"
      "contract"
    else
      "full_time"
    end
  end

  def self.map_reed_job_type(employment_type)
    case employment_type&.downcase
    when "permanent"
      "full_time"
    when "contract"
      "contract"
    when "part_time"
      "part_time"
    else
      "full_time"
    end
  end

  def self.estimate_experience_level(title)
    title_lower = title.downcase

    if title_lower.include?("senior") || title_lower.include?("lead") || title_lower.include?("principal")
      "senior"
    elsif title_lower.include?("junior") || title_lower.include?("entry") || title_lower.include?("graduate")
      "junior"
    elsif title_lower.include?("mid") || title_lower.include?("intermediate")
      "mid"
    elsif title_lower.include?("executive") || title_lower.include?("director") || title_lower.include?("vp")
      "executive"
    else
      %w[entry junior mid senior].sample
    end
  end
end
