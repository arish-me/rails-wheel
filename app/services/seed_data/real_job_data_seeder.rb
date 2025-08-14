# SeedData::RealJobDataSeeder.call
module SeedData
  class RealJobDataSeeder < BaseService
    attr_reader :company, :faker_count

    def initialize(company, faker_count = 20)
      @company = company
      @faker_count = faker_count
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
          title: "Senior Software Engineer - Backend",
          description: "We're looking for a Senior Software Engineer to join our backend team. You'll be responsible for designing, building, and maintaining scalable services that power our platform.\n\n**Key Responsibilities:**\n- Design and implement high-performance, scalable backend services\n- Collaborate with cross-functional teams to define and implement new features\n- Mentor junior engineers and participate in code reviews\n- Contribute to technical architecture decisions\n- Ensure code quality through testing and documentation",
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
          title: "Frontend Developer - React",
          description: "Join our frontend team to build amazing user experiences with React. We're looking for someone passionate about creating intuitive, performant web applications.\n\n**What you'll do:**\n- Build responsive, accessible web applications using React\n- Collaborate with designers to implement pixel-perfect UIs\n- Optimize application performance and user experience\n- Write clean, maintainable code with comprehensive tests\n- Participate in code reviews and technical discussions",
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
          title: "DevOps Engineer",
          description: "Help us scale our infrastructure and implement best practices for deployment and monitoring. You'll work on automating our deployment processes and ensuring our systems are reliable and secure.\n\n**Key Areas:**\n- Automate deployment and infrastructure management\n- Monitor system performance and reliability\n- Implement security best practices\n- Optimize cloud infrastructure costs\n- Collaborate with development teams on CI/CD improvements",
          requirements: "**Required Experience:**\n• 3+ years of DevOps or infrastructure experience\n• Experience with Docker and Kubernetes\n• Knowledge of cloud platforms (AWS, GCP, or Azure)\n• Experience with monitoring and logging tools\n• Understanding of infrastructure as code (Terraform, CloudFormation)\n• Scripting skills (Python, Bash, or similar)\n\n**Preferred Skills:**\n• Experience with CI/CD tools (Jenkins, GitLab CI, GitHub Actions)\n• Knowledge of security best practices and compliance\n• Experience with service mesh technologies\n• Understanding of database administration",
          benefits: "**Benefits Package:**\n• Competitive salary and equity\n• Comprehensive health coverage\n• Flexible work schedule\n• Professional development budget\n• Latest tools and technologies\n• Collaborative team culture\n• Conference and training opportunities",
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
          title: "Data Scientist",
          description: "Join our data science team to build machine learning models and analyze data to drive business decisions. You'll work on predictive modeling, data analysis, and developing insights from our vast datasets.\n\n**Research Areas:**\n- Develop predictive models for business applications\n- Analyze large datasets to extract actionable insights\n- Design and implement A/B testing frameworks\n- Create data visualizations and dashboards\n- Collaborate with product teams on data-driven features",
          salary_min: 90000,
          salary_max: 150000,
          city: "Seattle",
          state: "WA",
          featured: false
        },
        {
          title: "Product Manager",
          description: "Lead product development from ideation to launch. You'll work closely with engineering, design, and business teams to define and execute product strategy.\n\n**Your Impact:**\n- Define product strategy and roadmap\n- Gather and prioritize user requirements\n- Coordinate cross-functional teams\n- Analyze user feedback and product metrics\n- Drive product decisions based on data and user research",
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
          title: "UI/UX Designer",
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
          title: "Mobile App Developer",
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
          title: "QA Engineer",
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

      faker_count.times do |i|
        job_info = real_jobs[i % real_jobs.length]

        # Add some variation to make jobs unique
        title_variations = [
          job_info[:title],
          job_info[:title].gsub("Senior", "Lead"),
          job_info[:title].gsub("Senior", "Principal"),
          job_info[:title] + " - Remote",
          job_info[:title] + " (Full Stack)",
          job_info[:title] + " - Backend Focus"
        ]

        status = [ "draft", "published", "published", "published", "closed" ].sample

        job = Job.create!(
          company: company,
          created_by: company.users.sample,
          title: title_variations.sample,
          description: job_info[:description],
          requirements: job_info[:requirements],
          benefits: job_info[:benefits],
          role_type: job_info[:job_type],
          role_level: job_info[:experience_level],
          remote_policy: job_info[:remote_policy],
          status: status,
          featured: job_info[:featured],
          salary_min: job_info[:salary_min] + rand(-10000..10000),
          salary_max: job_info[:salary_max] + rand(-15000..15000),
          salary_currency: "USD",
          salary_period: "yearly",
          allow_cover_letter: [ true, false ].sample,
          require_portfolio: [ true, false, false ].sample,
          application_instructions: "Please submit your resume and a brief cover letter explaining why you're interested in this position. Include any relevant projects or portfolio links.",
          expires_at: status == "published" ? rand(30..90).days.from_now : nil,
          published_at: status == "published" ? rand(1..30).days.ago : nil,
          views_count: status == "published" ? rand(10..500) : 0,
          applications_count: status == "published" ? rand(0..20) : 0,
          location_attributes: {
            city: job_info[:city],
            state: job_info[:state],
            country: "United States"
          }
        )

        # Set external data for some jobs to simulate external integrations
        if rand < 0.4 # 40% chance
          external_sources = [ "linkedin", "indeed", "glassdoor", "ziprecruiter" ]
          job.update!(
            external_id: "ext_#{job.id}_#{Time.current.to_i}",
            external_source: external_sources.sample,
            external_data: {
              posted_at: job.published_at,
              external_url: "https://#{job.external_source}.com/jobs/#{job.external_id}",
              views: rand(50..1000),
              applications: rand(5..50),
              source_company: company.name
            }
          )
        end
      end

      puts "✅ Created #{faker_count} real job listings for #{company.name}"
    end
  end
end
