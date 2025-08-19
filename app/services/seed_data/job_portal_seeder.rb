# SeedData::JobPortalSeeder.call
module SeedData
  class JobPortalSeeder < BaseService
    attr_reader :company, :faker_count

    def initialize(company, faker_count = 5)
      @company = company
      @faker_count = faker_count
    end

    def call
      ActsAsTenant.with_tenant(company) do
        seed_jobs if faker_count > 0
        seed_job_applications if faker_count > 0
        seed_job_board_integrations
        seed_job_board_sync_logs
      end
    end

    private

    def seed_jobs
      puts "🌐 Seeding jobs for #{company.name}..."

      job_titles = [
        "Senior Ruby on Rails Developer",
        "Frontend React Developer",
        "Full Stack Developer",
        "DevOps Engineer",
        "Product Manager",
        "UI/UX Designer",
        "Data Scientist",
        "Mobile App Developer",
        "QA Engineer",
        "Technical Lead"
      ]

      job_descriptions = [
        "We're looking for a passionate Senior Ruby on Rails Developer to join our growing team. You'll work on exciting projects and help shape our technical direction.",
        "Join our frontend team and build amazing user experiences with React. We value clean code and user-centric design.",
        "As a Full Stack Developer, you'll work across our entire tech stack, from database design to frontend implementation.",
        "Help us scale our infrastructure and implement best practices for deployment and monitoring.",
        "Lead product development from ideation to launch. Work closely with engineering and design teams.",
        "Create beautiful and intuitive user interfaces. You'll work on both web and mobile applications.",
        "Build machine learning models and analyze data to drive business decisions.",
        "Develop native mobile applications for iOS and Android platforms.",
        "Ensure our software quality through comprehensive testing and quality assurance processes.",
        "Lead technical teams and mentor junior developers while contributing to architecture decisions."
      ]

      job_requirements = [
        "• 5+ years of experience with Ruby on Rails\n• Strong understanding of web technologies\n• Experience with PostgreSQL and Redis\n• Knowledge of testing frameworks (RSpec)\n• Experience with Git and collaborative development",
        "• 3+ years of React experience\n• Strong JavaScript/TypeScript skills\n• Experience with modern CSS and responsive design\n• Knowledge of state management (Redux, Context API)\n• Understanding of web performance optimization",
        "• 4+ years of full-stack development experience\n• Proficiency in Ruby, JavaScript, and SQL\n• Experience with modern frontend frameworks\n• Knowledge of cloud platforms (AWS, GCP)\n• Understanding of CI/CD pipelines",
        "• 3+ years of DevOps experience\n• Experience with Docker and Kubernetes\n• Knowledge of cloud platforms (AWS, Azure, GCP)\n• Experience with monitoring tools (Prometheus, Grafana)\n• Understanding of infrastructure as code",
        "• 5+ years of product management experience\n• Strong analytical and problem-solving skills\n• Experience with agile methodologies\n• Excellent communication and leadership skills\n• Technical background preferred",
        "• 3+ years of UI/UX design experience\n• Proficiency in design tools (Figma, Sketch)\n• Strong understanding of user-centered design\n• Experience with design systems\n• Portfolio demonstrating web and mobile work",
        "• 3+ years of data science experience\n• Strong Python programming skills\n• Experience with machine learning frameworks\n• Knowledge of statistics and data analysis\n• Experience with big data technologies",
        "• 3+ years of mobile development experience\n• Proficiency in Swift (iOS) and Kotlin (Android)\n• Experience with React Native or Flutter\n• Understanding of mobile app architecture\n• Knowledge of app store guidelines",
        "• 3+ years of QA experience\n• Experience with automated testing frameworks\n• Knowledge of testing methodologies\n• Experience with CI/CD integration\n• Strong attention to detail",
        "• 7+ years of software development experience\n• Experience leading technical teams\n• Strong architectural design skills\n• Excellent mentoring and communication skills\n• Experience with multiple programming languages"
      ]

      job_benefits = [
        "• Competitive salary and equity\n• Flexible remote work options\n• Health, dental, and vision insurance\n• 401(k) matching\n• Unlimited PTO\n• Professional development budget\n• Home office setup allowance",
        "• Competitive salary and benefits\n• Remote-first culture\n• Health and wellness benefits\n• Flexible working hours\n• Learning and development opportunities\n• Team building events",
        "• Competitive compensation package\n• Comprehensive health benefits\n• Flexible work arrangements\n• Professional development opportunities\n• Modern tech stack and tools\n• Collaborative team environment",
        "• Competitive salary and equity\n• Comprehensive health coverage\n• Flexible work schedule\n• Professional development budget\n• Latest tools and technologies\n• Collaborative team culture",
        "• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness programs\n• Professional development opportunities\n• Collaborative work environment\n• Impact on product strategy",
        "• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development budget\n• Creative and collaborative environment\n• Latest design tools and resources",
        "• Competitive salary and equity\n• Comprehensive health benefits\n• Flexible work arrangements\n• Professional development opportunities\n• Access to cutting-edge technologies\n• Collaborative research environment",
        "• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development opportunities\n• Latest mobile development tools\n• Collaborative team environment",
        "• Competitive salary and benefits\n• Flexible work arrangements\n• Health and wellness benefits\n• Professional development opportunities\n• Modern testing tools and frameworks\n• Collaborative team environment",
        "• Competitive salary and equity\n• Comprehensive health benefits\n• Flexible work arrangements\n• Leadership development opportunities\n• Impact on technical strategy\n• Mentoring and growth opportunities"
      ]

      faker_count.times do |i|
        job_type = Job::JOB_TYPES.sample
        experience_level = Job::EXPERIENCE_LEVELS.sample
        remote_policy = Job::REMOTE_POLICIES.sample
        status = [ "draft", "published", "published", "published", "closed" ].sample # More published jobs
        featured = [ true, false, false, false ].sample # 25% chance of being featured

        salary_min = case experience_level
        when "entry"
          rand(40000..60000)
        when "junior"
          rand(50000..80000)
        when "mid"
          rand(70000..120000)
        when "senior"
          rand(100000..160000)
        when "lead"
          rand(130000..200000)
        when "executive"
          rand(180000..300000)
        end

        salary_max = salary_min + rand(20000..50000)

        job = Job.create!(
          company: company,
          created_by: company.users.sample,
          title: job_titles[i % job_titles.length],
          description: job_descriptions[i % job_descriptions.length],
          requirements: job_requirements[i % job_requirements.length],
          benefits: job_benefits[i % job_benefits.length],
          job_type: job_type,
          experience_level: experience_level,
          remote_policy: remote_policy,
          status: status,
          featured: featured,
          salary_min: salary_min,
          salary_max: salary_max,
          salary_currency: "USD",
          salary_period: "yearly",
          city: [ "San Francisco", "New York", "Austin", "Seattle", "Boston", "Denver", "Chicago", "Los Angeles" ].sample,
          state: [ "CA", "NY", "TX", "WA", "MA", "CO", "IL", "CA" ].sample,
          country: "United States",
          location: "#{[ 'San Francisco', 'New York', 'Austin', 'Seattle', 'Boston', 'Denver', 'Chicago', 'Los Angeles' ].sample}, #{[ 'CA', 'NY', 'TX', 'WA', 'MA', 'CO', 'IL', 'CA' ].sample}, United States",
          allow_cover_letter: [ true, false ].sample,
          require_portfolio: [ true, false, false ].sample,
          application_instructions: "Please submit your resume and a brief cover letter explaining why you're interested in this position.",
          expires_at: status == "published" ? rand(30..90).days.from_now : nil,
          published_at: status == "published" ? rand(1..30).days.ago : nil,
          views_count: status == "published" ? rand(10..500) : 0,
          job_applications_count: status == "published" ? rand(0..20) : 0
        )

        # Set external data for some jobs to simulate external integrations
        if rand < 0.3 # 30% chance
          job.update!(
            external_id: "ext_#{job.id}_#{Time.current.to_i}",
            external_source: [ "linkedin", "indeed", "glassdoor" ].sample,
            external_data: {
              posted_at: job.published_at,
              external_url: "https://#{job.external_source}.com/jobs/#{job.external_id}",
              views: rand(50..1000),
              applications: rand(5..50)
            }
          )
        end
      end

      puts "✅ Created #{faker_count} jobs for #{company.name}"
    end

    def seed_job_applications
      puts "📝 Seeding job applications..."

      published_jobs = company.jobs.published
      return puts "⚠️ No published jobs found for applications" if published_jobs.empty?

      # Get some candidates from other companies for variety
      all_candidates = Candidate.includes(:user).limit(20)
      return puts "⚠️ No candidates found for applications" if all_candidates.empty?

      application_count = 0

      published_jobs.each do |job|
        # Create 1-5 applications per job
        rand(1..5).times do
          candidate = all_candidates.sample
          next if job.has_applicant?(candidate) # Avoid duplicate applications

          status = [ "applied", "applied", "reviewing", "shortlisted", "interviewed", "offered", "rejected" ].sample

          application = JobApplication.create!(
            job: job,
            candidate: candidate,
            user: candidate.user,
            status: status,
            cover_letter: generate_cover_letter(job, candidate),
            portfolio_url: rand < 0.7 ? "https://#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}.com" : nil,
            additional_notes: rand < 0.3 ? "I'm very excited about this opportunity and believe my skills align perfectly with your requirements." : nil,
            applied_at: rand(1..30).days.ago,
            reviewed_at: [ "reviewing", "shortlisted", "interviewed", "offered", "rejected" ].include?(status) ? rand(1..7).days.ago : nil,
            reviewed_by: job.company.users.sample,
            view_count: rand(1..10)
          )

          # Update job application count
          job.increment!(:job_applications_count)
          application_count += 1
        end
      end

      puts "✅ Created #{application_count} job applications"
    end

    def seed_job_board_integrations
      puts "🔗 Seeding job board integrations..."

      providers = JobBoardProvider.active
      return puts "⚠️ No job board providers found" if providers.empty?

      # Create 1-3 integrations per company
      rand(1..3).times do
        provider = providers.sample

        integration = JobBoardIntegration.create!(
          company: company,
          name: "#{provider.name} Integration",
          provider: provider.slug,
          api_key: "api_key_#{SecureRandom.hex(16)}",
          api_secret: "api_secret_#{SecureRandom.hex(16)}",
          webhook_url: rand < 0.5 ? "https://#{company.subdomain}.com/webhooks/#{provider.slug}" : nil,
          status: [ "active", "active", "inactive" ].sample,
          settings: {
            auto_sync: [ true, false ].sample,
            sync_interval: [ 1800, 3600, 7200 ].sample, # 30min, 1hr, 2hr
            post_new_jobs: [ true, false ].sample,
            update_existing_jobs: [ true, false ].sample,
            delete_closed_jobs: [ true, false, false ].sample,
            custom_fields: {}
          },
          last_sync_at: rand < 0.7 ? rand(1..7).days.ago : nil
        )
      end

      puts "✅ Created job board integrations for #{company.name}"
    end

    def seed_job_board_sync_logs
      puts "📊 Seeding job board sync logs..."

      integrations = company.job_board_integrations
      return puts "⚠️ No integrations found for sync logs" if integrations.empty?

      jobs = company.jobs.published.limit(10)
      return puts "⚠️ No published jobs found for sync logs" if jobs.empty?

      log_count = 0

      integrations.each do |integration|
        # Create sync logs for this integration
        rand(5..15).times do
          action = [ "sync_job", "test_connection", "integration_created", "integration_updated" ].sample
          status = [ "success", "success", "success", "error" ].sample

          job = action == "sync_job" ? jobs.sample : nil

          log = JobBoardSyncLog.create!(
            job_board_integration: integration,
            job: job,
            action: action,
            status: status,
            message: generate_sync_message(action, status, job, integration),
            metadata: generate_sync_metadata(action, status, job, integration),
            created_at: rand(1..30).days.ago,
            updated_at: rand(1..30).days.ago
          )

          log_count += 1
        end
      end

      puts "✅ Created #{log_count} sync logs"
    end

    private

    def generate_cover_letter(job, candidate)
      templates = [
        "Dear Hiring Manager,\n\nI am writing to express my strong interest in the #{job.title} position at #{job.company.name}. With my background in #{candidate.candidate_roles.first&.name || 'software development'}, I believe I would be a valuable addition to your team.\n\nI am particularly drawn to this opportunity because of #{job.company.name}'s reputation for innovation and the chance to work on challenging projects. My experience aligns well with the requirements you've outlined, and I am excited about the possibility of contributing to your team's success.\n\nThank you for considering my application. I look forward to discussing how my skills and experience can benefit #{job.company.name}.\n\nBest regards,\n#{candidate.user.display_name}",

        "Hello,\n\nI'm excited to apply for the #{job.title} role. My experience in #{candidate.candidate_roles.first&.name || 'development'} makes me a great fit for this position.\n\nI've been following #{job.company.name}'s work and am impressed by your commitment to #{[ 'innovation', 'quality', 'user experience', 'growth' ].sample}. I'm eager to contribute to your continued success.\n\nLooking forward to discussing this opportunity further.\n\nRegards,\n#{candidate.user.display_name}",

        "Dear #{job.company.name} Team,\n\nI'm applying for the #{job.title} position. With #{candidate.experience} years of experience in #{candidate.candidate_roles.first&.name || 'software development'}, I'm confident I can make meaningful contributions to your team.\n\nWhat excites me most about this role is the opportunity to work on #{[ 'cutting-edge technology', 'impactful projects', 'innovative solutions', 'scalable systems' ].sample} while collaborating with talented professionals.\n\nI'm available for an interview at your convenience and look forward to learning more about this opportunity.\n\nSincerely,\n#{candidate.user.display_name}"
      ]

      templates.sample
    end

    def generate_sync_message(action, status, job, integration)
      case action
      when "sync_job"
        if status == "success"
          "Job '#{job.title}' successfully synced to #{integration.provider}"
        else
          "Failed to sync job '#{job.title}' to #{integration.provider}: API rate limit exceeded"
        end
      when "test_connection"
        if status == "success"
          "Successfully connected to #{integration.provider} API"
        else
          "Connection test failed for #{integration.provider}: Invalid API credentials"
        end
      when "integration_created"
        "Integration '#{integration.name}' created for #{integration.provider}"
      when "integration_updated"
        "Integration '#{integration.name}' settings updated"
      else
        "Action completed for #{integration.provider}"
      end
    end

    def generate_sync_metadata(action, status, job, integration)
      case action
      when "sync_job"
        if status == "success"
          {
            external_id: "ext_#{job.id}_#{Time.current.to_i}",
            provider: integration.provider,
            job_id: job.id,
            timestamp: Time.current
          }
        else
          {
            provider: integration.provider,
            job_id: job.id,
            error: "rate_limit_exceeded",
            retry_after: 3600
          }
        end
      when "test_connection"
        {
          provider: integration.provider,
          timestamp: Time.current,
          response_time: rand(100..500)
        }
      else
        {
          provider: integration.provider,
          timestamp: Time.current
        }
      end
    end
  end
end
