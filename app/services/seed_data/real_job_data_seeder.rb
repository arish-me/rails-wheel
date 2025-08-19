# SeedData::RealJobDataSeeder.call
module SeedData
  class RealJobDataSeeder < BaseService
    # Constants for configuration
    DEFAULT_JOB_COUNT = 20
    EXTERNAL_DATA_CHANCE = 0.4
    MIN_SALARY = 30000
    MIN_SALARY_RANGE = 20000

    # Status distribution weights
    STATUS_WEIGHTS = {
      "draft" => 15,      # 15% - Draft jobs
      "published" => 70,  # 70% - Published jobs (most common)
      "closed" => 15      # 15% - Closed jobs
    }.freeze

    attr_reader :company, :faker_count

    def initialize(company, faker_count = DEFAULT_JOB_COUNT)
      @company = company
      @faker_count = faker_count
      validate_company!
    end

    def call
      ActsAsTenant.with_tenant(company) do
        seed_real_job_data
      end
    end

    private

    def seed_real_job_data
      puts "🌐 Seeding real job data for #{company.name}..."

      # Real job data from various sources
      real_jobs = [
        # Tech Jobs
        {
          title: Faker::Job.title,
          description: "We're looking for a Senior Software Engineer to join our backend team. You'll be responsible for designing, building, and maintaining scalable services that power our platform.\n\n**Key Responsibilities:**\n- Design and implement high-performance, scalable backend services\n- Collaborate with cross-functional teams to define and implement new features\n- Mentor junior engineers and participate in code reviews\n- Contribute to technical architecture decisions\n- Ensure code quality through testing and documentation\n\n**Required Experience:**\n• 5+ years of software development experience\n• Strong proficiency in Ruby, Python, Java, or Go\n• Experience with distributed systems and microservices\n• Knowledge of database design and optimization\n• Experience with cloud platforms (AWS, GCP, or Azure)\n\n**Preferred Skills:**\n• Experience with containerization (Docker, Kubernetes)\n• Knowledge of CI/CD pipelines\n• Understanding of system design and scalability\n• Experience with monitoring and observability tools\n\n**Benefits:**\n• Competitive salary and equity package\n• Comprehensive health, dental, and vision coverage\n• Flexible work arrangements and remote options\n• Professional development and conference budgets\n• Modern tech stack and tools\n• Collaborative and inclusive team culture",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "hybrid",
          salary_min: 120000,
          salary_max: 180000,
          city: "San Francisco",
          state: "CA",
          featured: true
        },
        {
          title: Faker::Job.title,
          description: "Join our frontend team to build amazing user experiences with React. We're looking for someone passionate about creating intuitive, performant web applications.\n\n**What you'll do:**\n- Build responsive, accessible web applications using React\n- Collaborate with designers to implement pixel-perfect UIs\n- Optimize application performance and user experience\n- Write clean, maintainable code with comprehensive tests\n- Participate in code reviews and technical discussions\n\n**Required Experience:**\n• 3+ years of frontend development experience\n• Strong proficiency in JavaScript/TypeScript and React\n• Experience with modern CSS and responsive design\n• Knowledge of web accessibility standards\n• Experience with build tools and bundlers\n\n**Preferred Skills:**\n• Experience with state management (Redux, Zustand)\n• Knowledge of testing frameworks (Jest, React Testing Library)\n• Understanding of performance optimization\n• Experience with design systems and component libraries\n\n**Benefits:**\n• Competitive salary and benefits package\n• Health, dental, and vision insurance\n• Flexible work schedule and remote options\n• Professional development opportunities\n• Latest tools and technologies\n• Supportive team environment",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "remote",
          salary_min: 80000,
          salary_max: 130000,
          city: "New York",
          state: "NY",
          featured: false
        },
        {
          title: Faker::Job.title,
          description: "Help us scale our infrastructure and implement best practices for deployment and monitoring. You'll work on automating our deployment processes and ensuring our systems are reliable and secure.\n\n**Key Areas:**\n- Automate deployment and infrastructure management\n- Monitor system performance and reliability\n- Implement security best practices\n- Optimize cloud infrastructure costs\n- Collaborate with development teams on CI/CD improvements\n\n**Required Experience:**\n• 3+ years of DevOps or infrastructure experience\n• Experience with Docker and Kubernetes\n• Knowledge of cloud platforms (AWS, GCP, or Azure)\n• Experience with monitoring and logging tools\n• Understanding of infrastructure as code (Terraform, CloudFormation)\n• Scripting skills (Python, Bash, or similar)\n\n**Preferred Skills:**\n• Experience with CI/CD tools (Jenkins, GitLab CI, GitHub Actions)\n• Knowledge of security best practices and compliance\n• Experience with service mesh technologies\n• Understanding of database administration\n\n**Benefits Package:**\n• Competitive salary and equity\n• Comprehensive health coverage\n• Flexible work schedule\n• Professional development budget\n• Latest tools and technologies\n• Collaborative team culture\n• Conference and training opportunities",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "hybrid",
          salary_min: 100000,
          salary_max: 160000,
          city: "Austin",
          state: "TX",
          featured: true
        },
        {
          title: Faker::Job.title,
          description: "Join our data science team to build machine learning models and analyze data to drive business decisions. You'll work on predictive modeling, data analysis, and developing insights from our vast datasets.\n\n**Research Areas:**\n- Develop predictive models for business applications\n- Analyze large datasets to extract actionable insights\n- Design and implement A/B testing frameworks\n- Create data visualizations and dashboards\n- Collaborate with product teams on data-driven features\n\n**Required Experience:**\n• 3+ years of data science or machine learning experience\n• Strong proficiency in Python and data science libraries\n• Experience with statistical analysis and modeling\n• Knowledge of SQL and data manipulation\n• Experience with machine learning frameworks\n\n**Preferred Skills:**\n• Experience with deep learning (TensorFlow, PyTorch)\n• Knowledge of big data technologies (Spark, Hadoop)\n• Understanding of MLOps and model deployment\n• Experience with cloud platforms and data pipelines\n\n**Benefits:**\n• Competitive salary and equity options\n• Comprehensive health and wellness benefits\n• Flexible work arrangements\n• Professional development and learning budget\n• Access to cutting-edge tools and datasets\n• Collaborative research environment",
          salary_min: 90000,
          salary_max: 150000,
          city: "Seattle",
          state: "WA",
          featured: false
        },
        {
          title: Faker::Job.title,
          description: "Lead product development from ideation to launch. You'll work closely with engineering, design, and business teams to define and execute product strategy.\n\n**Your Impact:**\n- Define product strategy and roadmap\n- Gather and prioritize user requirements\n- Coordinate cross-functional teams\n- Analyze user feedback and product metrics\n- Drive product decisions based on data and user research\n\n**Required Experience:**\n• 5+ years of product management experience\n• Experience leading cross-functional teams\n• Strong analytical and problem-solving skills\n• Experience with product analytics and user research\n• Knowledge of agile development methodologies\n\n**Preferred Skills:**\n• Experience with product strategy and roadmap planning\n• Knowledge of user experience design principles\n• Understanding of technical architecture and constraints\n• Experience with A/B testing and experimentation\n\n**Benefits:**\n• Competitive salary and equity package\n• Comprehensive health and wellness benefits\n• Flexible work arrangements and remote options\n• Professional development and conference budgets\n• Collaborative and innovative team culture\n• Opportunity to shape product strategy",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "hybrid",
          salary_min: 110000,
          salary_max: 170000,
          city: "Boston",
          state: "MA",
          featured: true
        },
        {
          title: Faker::Job.title,
          description: "Create beautiful and intuitive user interfaces. You'll work on both web and mobile applications, focusing on user experience and visual design.\n\n**Design Focus:**\n- Design user interfaces for web and mobile applications\n- Conduct user research and usability testing\n- Create wireframes, prototypes, and high-fidelity designs\n- Develop and maintain design systems\n- Collaborate with product and engineering teams",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "remote",
          salary_min: 70000,
          salary_max: 120000,
          city: "Los Angeles",
          state: "CA",
          featured: false
        },
        {
          title: Faker::Job.title,
          description: "Develop native mobile applications for iOS and Android platforms. You'll work on creating high-performance, user-friendly mobile experiences.\n\n**Development Focus:**\n- Build native iOS and Android applications\n- Implement cross-platform solutions when appropriate\n- Optimize app performance and user experience\n- Work with app store guidelines and best practices\n- Collaborate with design and backend teams",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "hybrid",
          salary_min: 80000,
          salary_max: 140000,
          city: "Denver",
          state: "CO",
          featured: false
        },
        {
          title: Faker::Job.title,
          description: "Ensure our software quality through comprehensive testing and quality assurance processes. You'll work on both manual and automated testing to maintain high standards.\n\n**Quality Focus:**\n- Design and implement automated testing strategies\n- Perform manual testing and bug reporting\n- Develop test plans and test cases\n- Work with development teams on quality improvements\n- Monitor and track quality metrics",
          role_type: RoleType::TYPES.sample.to_s,
          role_level: RoleLevel::TYPES.sample.to_s,
          remote_policy: "remote",
          salary_min: 65000,
          salary_max: 110000,
          city: "Chicago",
          state: "IL",
          featured: false
        }
      ]

      created_count = 0

      faker_count.times do |i|
        job_info = real_jobs[i % real_jobs.length]

        # Generate variations for uniqueness
        title = generate_title_variations(job_info[:title])
        status = generate_status_distribution
        salary_min, salary_max = generate_salary_variation(job_info[:salary_min], job_info[:salary_max])

        begin
          job = Job.create!(
            company: company,
            created_by: company.users.sample,
            title: title,
            description: enhance_job_description(job_info[:description], job_info[:role_type]),
            role_type: job_info[:role_type],
            role_level: job_info[:role_level],
            remote_policy: job_info[:remote_policy],
            status: status,
            featured: job_info[:featured],
            salary_min: salary_min,
            salary_max: salary_max,
            salary_currency: "USD",
            salary_period: "yearly",
            allow_cover_letter: [ true, false ].sample,
            require_portfolio: [ true, false, false ].sample,
            application_instructions: generate_application_instructions,
            expires_at: status == "published" ? rand(30..90).days.from_now : nil,
            published_at: status == "published" ? rand(1..30).days.ago : nil,
            views_count: status == "published" ? rand(10..500) : 0,
            job_applications_count: 0,
            location_attributes: {
              city: job_info[:city],
              state: job_info[:state],
              country: "United States"
            }
          )

          created_count += 1
        rescue => e
          puts "⚠️  Failed to create job: #{e.message}"
          next
        end

        # Set external data for some jobs to simulate external integrations
        if rand < EXTERNAL_DATA_CHANCE
          add_external_data(job)
        end
      end

      puts "✅ Created #{created_count} real job listings for #{company.name}"
    end

    def validate_company!
      raise ArgumentError, "Company must have at least one user" if company.users.empty?
    end

    def add_external_data(job)
      external_sources = [ "linkedin", "indeed", "glassdoor", "ziprecruiter" ]
      external_source = external_sources.sample

      job.update!(
        external_id: "ext_#{job.id}_#{Time.current.to_i}",
        external_source: external_source,
        external_data: {
          posted_at: job.published_at,
          external_url: "https://#{external_source}.com/jobs/#{job.external_id}",
          views: rand(50..1000),
          applications: rand(5..50),
          source_company: company.name
        }
      )
    rescue => e
      puts "⚠️  Failed to add external data for job #{job.id}: #{e.message}"
    end

    def generate_application_instructions
      instructions = [
        "Please submit your resume and a brief cover letter explaining why you're interested in this position. Include any relevant projects or portfolio links.",
        "To apply, please send your resume and a cover letter highlighting your relevant experience. We'd love to see examples of your work.",
        "Submit your application with a resume and cover letter. Feel free to include links to your portfolio, GitHub, or any relevant projects.",
        "Please apply with your resume and a cover letter. We're particularly interested in seeing your previous work and understanding your approach to problem-solving.",
        "Send us your resume and a cover letter explaining your interest in this role. Include any relevant experience or projects that demonstrate your skills."
      ]
      instructions.sample
    end

    def generate_title_variations(base_title)
      variations = [
        base_title,
        base_title.gsub("Senior", "Lead"),
        base_title.gsub("Senior", "Principal"),
        base_title + " - Remote",
        base_title + " (Full Stack)",
        base_title + " - Backend Focus",
        base_title + " - Frontend Focus",
        base_title + " - Full Time",
        base_title + " - Contract"
      ]
      variations.sample
    end

    def generate_status_distribution
      total_weight = STATUS_WEIGHTS.values.sum
      random = rand(total_weight)

      current_weight = 0
      STATUS_WEIGHTS.each do |status, weight|
        current_weight += weight
        return status if random < current_weight
      end

      "published" # fallback
    end

    def generate_salary_variation(base_min, base_max)
      min_variation = rand(-10000..10000)
      max_variation = rand(-15000..15000)

      # Ensure max is always greater than min
      new_min = [ base_min + min_variation, MIN_SALARY ].max
      new_max = [ base_max + max_variation, new_min + MIN_SALARY_RANGE ].max

      [ new_min, new_max ]
    end

    def enhance_job_description(base_description, job_type)
      # Add more context and structure for Action Text
      enhanced_description = base_description

      # Add company culture section for some jobs
      if rand < 0.7
        culture_sections = [
          "\n\n**Our Culture:**\nWe believe in fostering a collaborative, inclusive environment where innovation thrives. We value diversity, continuous learning, and work-life balance.",
          "\n\n**Team Culture:**\nJoin a team that values creativity, collaboration, and continuous improvement. We support each other's growth and celebrate our successes together.",
          "\n\n**Work Environment:**\nWe offer a dynamic, fast-paced environment where you can make a real impact. Our team is passionate about technology and solving complex challenges."
        ]
        enhanced_description += culture_sections.sample
      end

      # Add growth opportunities section
      if rand < 0.8
        growth_sections = [
          "\n\n**Growth Opportunities:**\n• Mentorship and career development programs\n• Regular skill-building workshops and training\n• Clear career progression paths\n• Exposure to cutting-edge technologies",
          "\n\n**Professional Development:**\n• Continuous learning and skill development\n• Conference attendance and speaking opportunities\n• Internal knowledge sharing sessions\n• Mentorship from senior team members"
        ]
        enhanced_description += growth_sections.sample
      end

      enhanced_description
    end
  end
end
