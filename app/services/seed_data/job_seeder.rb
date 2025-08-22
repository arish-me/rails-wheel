# SeedData::JobSeeder.call
module SeedData
  class JobSeeder < BaseService
    attr_reader :company, :faker_count

    def initialize(company, faker_count = 10)
      @company = company
      @faker_count = faker_count
    end

    def call
      ActsAsTenant.with_tenant(company) do
        seed_jobs
      end
    end

    private

    def seed_jobs
      Rails.logger.debug { "🌐 Seeding #{faker_count} jobs for #{company.name}..." }

      job_data = [
        {
          title: "Senior Ruby on Rails Developer",
          description: "We're looking for a passionate **Senior Ruby on Rails Developer** to join our growing team. You'll work on exciting projects and help shape our technical direction.\n\n**What you'll do:**\n- Build and maintain scalable web applications\n- Collaborate with cross-functional teams\n- Mentor junior developers\n- Contribute to technical architecture decisions",
          requirements: "**Required Skills:**\n• 5+ years of experience with Ruby on Rails\n• Strong understanding of web technologies\n• Experience with PostgreSQL and Redis\n• Knowledge of testing frameworks (RSpec)\n• Experience with Git and collaborative development\n\n**Nice to have:**\n• Experience with React/Vue.js\n• Knowledge of AWS/Docker\n• Open source contributions",
          benefits: "**Benefits:**\n• Competitive salary and equity\n• Flexible remote work options\n• Health, dental, and vision insurance\n• 401(k) matching\n• Unlimited PTO\n• Professional development budget\n• Home office setup allowance"
        },
        {
          title: "Frontend React Developer",
          description: "Join our frontend team and build **amazing user experiences** with React. We value clean code and user-centric design.\n\n**Your role:**\n- Develop responsive web applications\n- Implement modern UI/UX designs\n- Optimize application performance\n- Work with design and backend teams",
          requirements: "**Requirements:**\n• 3+ years of React experience\n• Strong JavaScript/TypeScript skills\n• Experience with modern CSS and responsive design\n• Knowledge of state management (Redux, Context API)\n• Understanding of web performance optimization\n\n**Bonus:**\n• Experience with Next.js\n• Knowledge of design systems\n• Animation and interaction skills",
          benefits: "**Perks:**\n• Competitive salary and benefits\n• Remote-first culture\n• Health and wellness benefits\n• Flexible working hours\n• Learning and development opportunities\n• Team building events"
        },
        {
          title: "Full Stack Developer",
          description: "As a **Full Stack Developer**, you'll work across our entire tech stack, from database design to frontend implementation.\n\n**Responsibilities:**\n- Develop end-to-end features\n- Design and implement APIs\n- Optimize database queries\n- Ensure code quality and testing",
          requirements: "**Skills needed:**\n• 4+ years of full-stack development experience\n• Proficiency in Ruby, JavaScript, and SQL\n• Experience with modern frontend frameworks\n• Knowledge of cloud platforms (AWS, GCP)\n• Understanding of CI/CD pipelines\n\n**Preferred:**\n• Experience with microservices\n• Knowledge of DevOps practices\n• Mobile development experience",
          benefits: "**What we offer:**\n• Competitive compensation package\n• Comprehensive health benefits\n• Flexible work arrangements\n• Professional development opportunities\n• Modern tech stack and tools\n• Collaborative team environment"
        },
        {
          title: "DevOps Engineer",
          description: "Help us **scale our infrastructure** and implement best practices for deployment and monitoring.\n\n**Key areas:**\n- Automate deployment processes\n- Monitor system performance\n- Ensure security and compliance\n- Optimize cloud infrastructure",
          requirements: "**Required experience:**\n• 3+ years of DevOps experience\n• Experience with Docker and Kubernetes\n• Knowledge of cloud platforms (AWS, Azure, GCP)\n• Experience with monitoring tools (Prometheus, Grafana)\n• Understanding of infrastructure as code\n\n**Additional skills:**\n• Experience with Terraform\n• Knowledge of security best practices\n• Scripting skills (Python, Bash)",
          benefits: "**Benefits package:**\n• Competitive salary and equity\n• Comprehensive health coverage\n• Flexible work schedule\n• Professional development budget\n• Latest tools and technologies\n• Collaborative team culture"
        },
        {
          title: "Product Manager",
          description: "Lead **product development** from ideation to launch. Work closely with engineering and design teams.\n\n**Your impact:**\n- Define product strategy and roadmap\n- Gather and prioritize requirements\n- Coordinate cross-functional teams\n- Analyze user feedback and metrics",
          requirements: "**Qualifications:**\n• 5+ years of product management experience\n• Strong analytical and problem-solving skills\n• Experience with agile methodologies\n• Excellent communication and leadership skills\n• Technical background preferred\n\n**Desired:**\n• Experience with SaaS products\n• Knowledge of user research methods\n• Data analysis skills",
          benefits: "**Compensation:**\n• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness programs\n• Professional development opportunities\n• Collaborative work environment\n• Impact on product strategy"
        },
        {
          title: "UI/UX Designer",
          description: "Create **beautiful and intuitive** user interfaces. You'll work on both web and mobile applications.\n\n**Design focus:**\n- User interface design\n- User experience research\n- Prototyping and testing\n- Design system development",
          requirements: "**Design skills:**\n• 3+ years of UI/UX design experience\n• Proficiency in design tools (Figma, Sketch)\n• Strong understanding of user-centered design\n• Experience with design systems\n• Portfolio demonstrating web and mobile work\n\n**Bonus skills:**\n• Experience with prototyping tools\n• Knowledge of accessibility standards\n• Animation and motion design",
          benefits: "**Designer benefits:**\n• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development budget\n• Creative and collaborative environment\n• Latest design tools and resources"
        },
        {
          title: "Data Scientist",
          description: "Build **machine learning models** and analyze data to drive business decisions.\n\n**Research areas:**\n- Predictive modeling\n- Data analysis and visualization\n- A/B testing and experimentation\n- Statistical analysis",
          requirements: "**Technical requirements:**\n• 3+ years of data science experience\n• Strong Python programming skills\n• Experience with machine learning frameworks\n• Knowledge of statistics and data analysis\n• Experience with big data technologies\n\n**Preferred:**\n• Experience with deep learning\n• Knowledge of MLOps\n• Experience with cloud ML platforms",
          benefits: "**Science benefits:**\n• Competitive salary and equity\n• Comprehensive health benefits\n• Flexible work arrangements\n• Professional development opportunities\n• Access to cutting-edge technologies\n• Collaborative research environment"
        },
        {
          title: "Mobile App Developer",
          description: "Develop **native mobile applications** for iOS and Android platforms.\n\n**Development focus:**\n- Native app development\n- Cross-platform solutions\n- Performance optimization\n- App store optimization",
          requirements: "**Mobile skills:**\n• 3+ years of mobile development experience\n• Proficiency in Swift (iOS) and Kotlin (Android)\n• Experience with React Native or Flutter\n• Understanding of mobile app architecture\n• Knowledge of app store guidelines\n\n**Additional:**\n• Experience with mobile testing\n• Knowledge of mobile security\n• Performance optimization skills",
          benefits: "**Mobile perks:**\n• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development opportunities\n• Latest mobile development tools\n• Collaborative team environment"
        },
        {
          title: "QA Engineer",
          description: "Ensure our **software quality** through comprehensive testing and quality assurance processes.\n\n**Quality focus:**\n- Automated testing implementation\n- Manual testing and bug reporting\n- Test strategy development\n- Quality metrics tracking",
          requirements: "**QA expertise:**\n• 3+ years of QA experience\n• Experience with automated testing frameworks\n• Knowledge of testing methodologies\n• Experience with CI/CD integration\n• Strong attention to detail\n\n**Preferred:**\n• Experience with performance testing\n• Knowledge of security testing\n• Experience with mobile testing",
          benefits: "**QA benefits:**\n• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development opportunities\n• Modern testing tools and frameworks\n• Collaborative team environment"
        },
        {
          title: "Technical Lead",
          description: "Lead **technical teams** and mentor junior developers while contributing to architecture decisions.\n\n**Leadership areas:**\n- Technical architecture design\n- Team mentoring and coaching\n- Code review and quality assurance\n- Technical strategy planning",
          requirements: "**Leadership skills:**\n• 7+ years of software development experience\n• Experience leading technical teams\n• Strong architectural design skills\n• Excellent mentoring and communication skills\n• Experience with multiple programming languages\n\n**Desired:**\n• Experience with system design\n• Knowledge of scalability patterns\n• Experience with technical hiring",
          benefits: "**Leadership benefits:**\n• Competitive salary and equity\n• Comprehensive health benefits\n• Flexible work arrangements\n• Leadership development opportunities\n• Impact on technical strategy\n• Mentoring and growth opportunities"
        }
      ]

      faker_count.times do |i|
        job_info = job_data[i % job_data.length]

        job_type = Job::JOB_TYPES.sample
        experience_level = Job::EXPERIENCE_LEVELS.sample
        remote_policy = Job::REMOTE_POLICIES.sample
        status = %w[draft published published published closed].sample # More published jobs
        featured = [ true, false, false, false ].sample # 25% chance of being featured

        salary_min = case experience_level
        when "entry"
                       rand(40_000..60_000)
        when "junior"
                       rand(50_000..80_000)
        when "mid"
                       rand(70_000..120_000)
        when "senior"
                       rand(100_000..160_000)
        when "lead"
                       rand(130_000..200_000)
        when "executive"
                       rand(180_000..300_000)
        end

        salary_max = salary_min + rand(20_000..50_000)

        job = Job.create!(
          company: company,
          created_by: company.users.sample,
          title: job_info[:title],
          description: job_info[:description],
          requirements: job_info[:requirements],
          benefits: job_info[:benefits],
          job_type: job_type,
          experience_level: experience_level,
          remote_policy: remote_policy,
          status: status,
          featured: featured,
          salary_min: salary_min,
          salary_max: salary_max,
          salary_currency: "USD",
          salary_period: "yearly",
          city: [ "San Francisco", "New York", "Austin", "Seattle", "Boston", "Denver", "Chicago",
                 "Los Angeles" ].sample,
          state: %w[CA NY TX WA MA CO IL CA].sample,
          country: "United States",
          location: "#{[ 'San Francisco', 'New York', 'Austin', 'Seattle', 'Boston', 'Denver', 'Chicago',
                        'Los Angeles' ].sample}, #{%w[CA NY TX WA MA CO IL CA].sample}, United States",
          allow_cover_letter: [ true, false ].sample,
          require_portfolio: [ true, false, false ].sample,
          application_instructions: "Please submit your resume and a brief cover letter explaining why you're interested in this position.",
          expires_at: status == "published" ? rand(30..90).days.from_now : nil,
          published_at: status == "published" ? rand(1..30).days.ago : nil,
          views_count: status == "published" ? rand(10..500) : 0,
          job_applications_count: status == "published" ? rand(0..20) : 0
        )

        # Set external data for some jobs to simulate external integrations
        next unless rand < 0.3 # 30% chance

        job.update!(
          external_id: "ext_#{job.id}_#{Time.current.to_i}",
          external_source: %w[linkedin indeed glassdoor].sample,
          external_data: {
            posted_at: job.published_at,
            external_url: "https://#{job.external_source}.com/jobs/#{job.external_id}",
            views: rand(50..1000),
            applications: rand(5..50)
          }
        )
      end

      Rails.logger.debug { "✅ Created #{faker_count} jobs for #{company.name}" }
    end
  end
end
