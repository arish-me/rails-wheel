# SeedData::RealJobImportService.call
module SeedData
  class RealJobImportService < BaseService
    attr_reader :company, :keywords, :location, :limit

    def initialize(company, keywords: nil, location: nil, limit: 10)
      @company = company
      @keywords = keywords
      @location = location
      @limit = limit
    end

    def call
      ActsAsTenant.with_tenant(company) do
        import_real_jobs
      end
    end

    private

    def import_real_jobs
      puts "🌐 Importing real job data from external APIs..."

      # Fetch jobs from multiple sources
      external_jobs = JobBoardApiService.fetch_all_sources(
        keywords: keywords,
        location: location,
        limit: limit
      )

      if external_jobs.empty?
        puts "⚠️ No jobs found from external APIs. Using simulated data..."
        external_jobs = generate_simulated_external_jobs
      end

      imported_count = 0

      external_jobs.each do |job_data|
        next if Job.exists?(external_id: job_data[:external_id])

        # Create a company for external jobs if it doesn't exist
        external_company = find_or_create_external_company(job_data[:company])

        job = Job.create!(
          company: external_company,
          created_by: external_company.users.first || company.users.first,
          title: job_data[:title],
          description: format_external_description(job_data),
          requirements: generate_requirements_from_description(job_data[:description]),
          benefits: generate_benefits_from_job_type(job_data[:job_type]),
          job_type: job_data[:job_type],
          experience_level: job_data[:experience_level],
          remote_policy: job_data[:remote_policy],
          status: "published",
          featured: rand < 0.2, # 20% chance of being featured
          salary_min: job_data[:salary_min],
          salary_max: job_data[:salary_max],
          salary_currency: job_data[:salary_currency] || "USD",
          salary_period: "yearly",
          city: extract_city(job_data[:location]),
          state: extract_state(job_data[:location]),
          country: extract_country(job_data[:location]),
          location: job_data[:location],
          allow_cover_letter: [ true, false ].sample,
          require_portfolio: [ true, false, false ].sample,
          application_instructions: "Please apply through our platform or visit the original posting for more details.",
          expires_at: rand(30..90).days.from_now,
          published_at: job_data[:posted_at] ? Time.parse(job_data[:posted_at]) : rand(1..30).days.ago,
          views_count: rand(10..500),
          applications_count: rand(0..20),
          external_id: job_data[:external_id],
          external_source: job_data[:external_source],
          external_data: job_data[:external_data]
        )

        imported_count += 1
        puts "✅ Imported: #{job.title} at #{job.company.name}"
      end

      puts "✅ Successfully imported #{imported_count} real jobs from external sources"
    end

    private

    def find_or_create_external_company(company_name)
      # Try to find existing company
      existing_company = Company.find_by("LOWER(name) = ?", company_name.downcase)
      return existing_company if existing_company

      # Create new company for external job
      external_company = Company.create!(
        name: company_name,
        subdomain: generate_subdomain(company_name),
        website: "https://#{generate_subdomain(company_name)}.com"
      )

      # Create a default user for the external company
      user = User.create!(
        email: "admin@#{generate_subdomain(company_name)}.com",
        first_name: "Admin",
        last_name: company_name.split(" ").first,
        user_type: "company",
        company: external_company,
        password: "password123",
        password_confirmation: "password123",
        confirmed_at: Time.current,
        onboarded_at: Time.current
      )

      # Assign default role
      SeedData::UserRoleAssigner.call(user, external_company)

      external_company
    end

    def generate_subdomain(company_name)
      # Convert company name to subdomain-friendly format
      subdomain = company_name.downcase
        .gsub(/[^a-z0-9]/, "")
        .gsub(/\s+/, "")
        .first(20)

      # Ensure uniqueness
      base_subdomain = subdomain
      counter = 1

      while Company.exists?(subdomain: subdomain)
        subdomain = "#{base_subdomain}#{counter}"
        counter += 1
      end

      subdomain
    end

    def format_external_description(job_data)
      description = job_data[:description] || "We're looking for a talented professional to join our team."

      # Format the description with proper Markdown
      formatted_description = "**#{job_data[:title]}**\n\n"
      formatted_description += "#{description}\n\n"
      formatted_description += "**Location:** #{job_data[:location]}\n"
      formatted_description += "**Company:** #{job_data[:company]}\n"

      if job_data[:salary_min] && job_data[:salary_max]
        formatted_description += "**Salary Range:** #{job_data[:salary_currency]} #{job_data[:salary_min]} - #{job_data[:salary_max]}\n"
      end

      formatted_description += "\n*This job was imported from #{job_data[:external_source].titleize}.*"

      formatted_description
    end

    def generate_requirements_from_description(description)
      return "Requirements will be discussed during the interview process." unless description.present?

      # Extract potential requirements from description
      requirements = "**Required Skills:**\n"

      # Common tech skills to look for
      tech_skills = [
        "JavaScript", "Python", "Ruby", "Java", "React", "Angular", "Vue",
        "Node.js", "Rails", "Django", "AWS", "Docker", "Kubernetes",
        "PostgreSQL", "MongoDB", "Redis", "Git", "Agile", "Scrum"
      ]

      found_skills = tech_skills.select { |skill| description.include?(skill) }

      if found_skills.any?
        requirements += found_skills.map { |skill| "• #{skill}" }.join("\n")
      else
        requirements += "• Relevant experience in the field\n• Strong problem-solving skills\n• Excellent communication abilities\n• Team collaboration experience"
      end

      requirements += "\n\n**Nice to have:**\n• Experience with modern development practices\n• Knowledge of industry best practices\n• Continuous learning mindset"

      requirements
    end

    def generate_benefits_from_job_type(job_type)
      base_benefits = "**Benefits:**\n• Competitive salary\n• Health insurance\n• Professional development opportunities"

      case job_type
      when "full_time"
        base_benefits += "\n• 401(k) matching\n• Paid time off\n• Flexible work arrangements"
      when "part_time"
        base_benefits += "\n• Flexible schedule\n• Pro-rated benefits\n• Growth opportunities"
      when "contract"
        base_benefits += "\n• Competitive hourly rates\n• Flexible project timelines\n• Remote work options"
      when "freelance"
        base_benefits += "\n• Project-based compensation\n• Flexible working hours\n• Remote work opportunities"
      else
        base_benefits += "\n• Flexible benefits package\n• Work-life balance\n• Career growth opportunities"
      end

      base_benefits
    end

    def extract_city(location)
      return "Remote" if location.include?("Remote")

      # Extract city from location string
      city_state = location.split(",").first&.strip
      city_state || "Unknown"
    end

    def extract_state(location)
      return nil if location.include?("Remote")

      # Extract state from location string
      parts = location.split(",")
      return nil if parts.length < 2

      state = parts[1]&.strip
      state&.length == 2 ? state : nil
    end

    def extract_country(location)
      return "United States" if location.include?("US") || location.include?("United States")
      return "United Kingdom" if location.include?("UK") || location.include?("United Kingdom")
      return "Canada" if location.include?("Canada")
      return "Australia" if location.include?("Australia")

      "United States" # Default
    end

    def generate_simulated_external_jobs
      # Generate simulated external jobs when APIs are not available
      [
        {
          title: "Senior Software Engineer - Remote",
          company: "TechStartup Inc",
          location: "Remote, United States",
          description: "Join our growing team as a Senior Software Engineer. We're building innovative solutions that impact millions of users worldwide.",
          salary_min: 120000,
          salary_max: 180000,
          salary_currency: "USD",
          job_type: "full_time",
          experience_level: "senior",
          remote_policy: "remote",
          external_id: "sim_#{SecureRandom.hex(8)}",
          external_source: "simulated",
          posted_at: rand(1..30).days.ago.iso8601,
          external_data: { source: "simulated", simulated: true }
        },
        {
          title: "Frontend Developer - React",
          company: "Digital Solutions Ltd",
          location: "London, UK",
          description: "We're looking for a talented Frontend Developer to join our team in London. Experience with React and modern JavaScript is essential.",
          salary_min: 60000,
          salary_max: 90000,
          salary_currency: "GBP",
          job_type: "full_time",
          experience_level: "mid",
          remote_policy: "hybrid",
          external_id: "sim_#{SecureRandom.hex(8)}",
          external_source: "simulated",
          posted_at: rand(1..30).days.ago.iso8601,
          external_data: { source: "simulated", simulated: true }
        },
        {
          title: "DevOps Engineer",
          company: "CloudTech Solutions",
          location: "San Francisco, CA",
          description: "Help us scale our infrastructure and implement best practices for deployment and monitoring.",
          salary_min: 100000,
          salary_max: 160000,
          salary_currency: "USD",
          job_type: "full_time",
          experience_level: "senior",
          remote_policy: "hybrid",
          external_id: "sim_#{SecureRandom.hex(8)}",
          external_source: "simulated",
          posted_at: rand(1..30).days.ago.iso8601,
          external_data: { source: "simulated", simulated: true }
        }
      ]
    end
  end
end
