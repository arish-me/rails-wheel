class JobBoardAdapters::AdzunaAdapter < JobBoardAdapters::BaseAdapter
  def fetch_jobs
    url = build_search_url
    response = make_request("get", url)

    if response.success?
      data = JSON.parse(response.body)
      jobs = data["results"] || []

      {
        success: true,
        data: jobs,
        total_count: data["count"],
        mean_salary: data["mean"]
      }
    else
      {
        success: false,
        message: "Failed to fetch jobs: #{response.code}",
        error: response.body
      }
    end
  end

  def push_job(job_data)
    # Adzuna doesn't support pushing jobs via API
    # This would typically be done through their web interface
    {
      success: false,
      message: "Adzuna doesn't support job posting via API. Please use their web interface."
    }
  end

  def delete_job(job_id)
    # Adzuna doesn't support job deletion via API
    {
      success: false,
      message: "Adzuna doesn't support job deletion via API. Please use their web interface."
    }
  end

  def test_connection
    # Test by fetching a small number of jobs
    url = build_search_url(limit: 1)
    response = make_request("get", url)

    if response.success?
      {
        success: true,
        message: "Successfully connected to Adzuna API"
      }
    else
      {
        success: false,
        message: "Failed to connect to Adzuna API: #{response.code}"
      }
    end
  end

  def transform_external_job(external_job_data)
    location_string = extract_location(external_job_data["location"])
    debugger

    {
      external_job_id: external_job_data["id"],
      external_source: "adzuna",
      title: external_job_data["title"],
      description: external_job_data["description"],
      salary_min: external_job_data["salary_min"],
      salary_max: external_job_data["salary_max"],
      salary_currency: "INR", # Adzuna India uses INR
      role_type: map_contract_type(external_job_data["contract_type"]),
      role_level: extract_experience_level(external_job_data["description"]),
      remote_policy: map_remote_work(external_job_data["contract_time"]),
      created_at: parse_datetime(external_job_data["created"]),
      updated_at: parse_datetime(external_job_data["created"]),
      expires_at: 1.year.from_now, # Set default expiry
      status: "published",
      created_by_id: integration.company.users.first&.id, # Set created_by
      redirect_url: external_job_data["redirect_url"],

      # category: external_job_data.dig('category', 'label'), # Not a direct attribute
      # contract_time: external_job_data['contract_time'], # Not a direct attribute
      latitude: external_job_data["latitude"],
      longitude: external_job_data["longitude"],
      # adref: external_job_data['adref'], # Not a direct attribute
      # Location attributes for nested association
      location_attributes: {
        location_search: location_string,
        latitude: external_job_data["latitude"],
        longitude: external_job_data["longitude"]
      }
    }
  end

  def transform_local_job(job)
    # Transform local job to Adzuna format for posting
    # Note: This is for reference as Adzuna doesn't support API posting
    {
      title: job.title,
      description: job.description,
      location: job.location,
      salary_min: job.salary_min,
      salary_max: job.salary_max,
      company: job.company.name,
      contract_type: map_contract_type_back(job.job_type),
      contract_time: map_remote_work_back(job.remote_work)
    }
  end

  def supported_fields
    [
      "title",
      "description",
      "location",
      "salary_min",
      "salary_max",
      "salary_currency",
      "job_type",
      "experience_level",
      "remote_work",
      "company_name",
      "application_url",
      "created_at",
      "updated_at",
      "status",
      "category",
      "contract_time",
      "latitude",
      "longitude"
    ]
  end

  private

  def build_search_url(limit: 50, page: 1)
    base_url = "https://api.adzuna.com/v1/api/jobs/in/search/#{page}"
    params = {
      app_id: integration.api_key,
      app_key: integration.api_secret,
      results_per_page: limit
    }

    "#{base_url}?#{params.to_query}"
  end

  def extract_location(location_data)
    return nil unless location_data

    location_data["display_name"] || location_data["area"]&.join(", ")
  end

  def map_contract_type(adzuna_contract_type)
    case adzuna_contract_type&.downcase
    when "permanent"
      "full_time_employment"
    when "contract"
      "full_time_contract"
    when "part_time"
      "part_time_contract"
    when "temporary"
      "full_time_contract"
    else
      "full_time_employment"
    end
  end

  def map_contract_type_back(local_job_type)
    case local_job_type&.downcase
    when "full_time_employment"
      "permanent"
    when "contract"
      "full_time_contract"
    when "part_time"
      "part_time"
    when "part_time_contract"
      "temporary"
    else
      "full_time_employment"
    end
  end

  def map_remote_work(adzuna_contract_time)
    case adzuna_contract_time&.downcase
    when "part_time"
      "remote"
    else
      "on_site"
    end
  end

  def map_remote_work_back(remote_work)
    remote_work ? "part_time" : "full_time"
  end

  def extract_experience_level(description)
    return nil unless description

    # Simple keyword-based extraction
    description_lower = description.downcase
    if description_lower.include?("senior") || description_lower.include?("lead")
      "senior"
    elsif description_lower.include?("junior") || description_lower.include?("entry")
      "junior"
    elsif description_lower.include?("intern") || description_lower.include?("internship")
      "intern"
    else
      "mid"
    end
  end

  def parse_datetime(datetime_string)
    return nil unless datetime_string

    begin
      DateTime.parse(datetime_string)
    rescue ArgumentError
      nil
    end
  end
end
