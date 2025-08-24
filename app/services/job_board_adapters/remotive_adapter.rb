class JobBoardAdapters::RemotiveAdapter < JobBoardAdapters::BaseAdapter
  def fetch_jobs
    url = "https://remotive.com/api/remote-jobs"
    headers = build_headers(integration.provider_info)
    response = make_request("get", url, headers: headers)

    if response.success?
      data = JSON.parse(response.body)
      jobs = data["jobs"] || []

      {
        success: true,
        data: jobs,
        total_count: data["total-job-count"],
        job_count: data["job-count"]
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
    # Remotive doesn't support pushing jobs via API
    # This would typically be done through their web interface
    {
      success: false,
      message: "Remotive doesn't support job posting via API. Please use their web interface."
    }
  end

  def delete_job(job_id)
    # Remotive doesn't support job deletion via API
    {
      success: false,
      message: "Remotive doesn't support job deletion via API. Please use their web interface."
    }
  end

  def test_connection
    # Test by fetching a small number of jobs
    url = "https://remotive.com/api/remote-jobs"
    headers = build_headers(integration.provider_info)
    response = make_request("get", url, headers: headers)

    if response.success?
      {
        success: true,
        message: "Successfully connected to Remotive API"
      }
    else
      {
        success: false,
        message: "Failed to connect to Remotive API: #{response.code}"
      }
    end
  end

  def transform_external_job(external_job_data)
    {
      external_job_id: external_job_data["id"].to_s,
      external_source: "remotive",
      title: external_job_data["title"],
      description: clean_html_description(external_job_data["description"]),
      salary_min: extract_salary_min(external_job_data["salary"]),
      salary_max: extract_salary_max(external_job_data["salary"]),
      salary_currency: extract_salary_currency(external_job_data["salary"]),
      role_type: map_job_type(external_job_data["job_type"]),
      role_level: extract_experience_level(external_job_data["title"], external_job_data["description"]),
      remote_policy: "remote", # All Remotive jobs are remote
      created_at: parse_datetime(external_job_data["publication_date"]),
      updated_at: parse_datetime(external_job_data["publication_date"]),
      expires_at: 1.year.from_now, # Set default expiry
      status: "published",
      created_by_id: integration.company.users.first&.id, # Set created_by
      redirect_url: external_job_data["url"],

      # Location attributes for nested association
      location_attributes: {
        location_search: external_job_data["candidate_required_location"],
        country: extract_country(external_job_data["candidate_required_location"])
      }
    }
  end

  def transform_local_job(job)
    # Transform local job to Remotive format for posting
    # Note: This is for reference as Remotive doesn't support API posting
    {
      title: job.title,
      description: job.description,
      company_name: job.company.name,
      job_type: map_job_type_back(job.role_type),
      category: job.category || "Other",
      candidate_required_location: job.location&.location_search || "Worldwide"
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
      "role_type",
      "role_level",
      "remote_policy",
      "company_name",
      "application_url",
      "created_at",
      "updated_at",
      "status",
      "category",
      "tags",
      "publication_date",
      "candidate_required_location"
    ]
  end

  private

  def clean_html_description(html_description)
    return nil unless html_description

    # Remove HTML tags and decode HTML entities
    ActionView::Base.full_sanitizer.sanitize(html_description)
  end

  def extract_salary_min(salary_string)
    return nil if salary_string.blank?

    # Parse salary ranges like "$50k-$80k" or "$6/hr"
    if salary_string.include?("-")
      parts = salary_string.split("-")
      parse_salary_amount(parts.first.strip)
    else
      parse_salary_amount(salary_string)
    end
  end

  def extract_salary_max(salary_string)
    return nil if salary_string.blank?

    # Parse salary ranges like "$50k-$80k"
    if salary_string.include?("-")
      parts = salary_string.split("-")
      parse_salary_amount(parts.last.strip)
    else
      parse_salary_amount(salary_string)
    end
  end

  def extract_salary_currency(salary_string)
    return "USD" if salary_string.blank?

    # Default to USD for Remotive jobs
    "USD"
  end

  def parse_salary_amount(salary_string)
    return nil if salary_string.blank?

    # Remove currency symbols and common suffixes
    cleaned = salary_string.gsub(/[$,€£]/, "").downcase

    if cleaned.include?("k")
      # Convert "50k" to 50000
      cleaned.gsub("k", "").to_i * 1000
    elsif cleaned.include?("hr") || cleaned.include?("/hr")
      # Convert hourly to annual (assuming 40 hours/week, 52 weeks/year)
      hourly_rate = cleaned.gsub(/hr.*/, "").to_f
      (hourly_rate * 40 * 52).to_i
    else
      # Try to parse as direct number
      cleaned.to_i
    end
  rescue
    nil
  end

  def map_job_type(remotive_job_type)
    case remotive_job_type&.downcase
    when "full_time"
      "full_time_employment"
    when "part_time"
      "part_time_contract"
    when "contract"
      "full_time_contract"
    when "freelance"
      "part_time_contract"
    else
      "full_time_employment"
    end
  end

  def map_job_type_back(local_job_type)
    case local_job_type&.downcase
    when "full_time_employment"
      "full_time"
    when "part_time_contract"
      "part_time"
    when "full_time_contract"
      "contract"
    else
      "full_time"
    end
  end

  def extract_experience_level(title, description)
    return nil unless title || description

    text = "#{title} #{description}".downcase

    if text.include?("senior") || text.include?("lead") || text.include?("principal")
      "senior"
    elsif text.include?("junior") || text.include?("entry") || text.include?("graduate")
      "junior"
    elsif text.include?("intern") || text.include?("internship")
      "intern"
    elsif text.include?("mid") || text.include?("intermediate")
      "mid"
    else
      "mid" # Default to mid-level
    end
  end

  def extract_country(location_string)
    return nil unless location_string

    # Extract country from location strings like "Netherlands, Georgia, Turkey, Azerbaijan"
    # or "Australia" or "Worldwide"
    if location_string.downcase == "worldwide"
      "Worldwide"
    else
      # Take the first country mentioned
      location_string.split(",").first&.strip
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
