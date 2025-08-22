# SeedData::JobApplicationSeeder.call
module SeedData
  class JobApplicationSeeder < BaseService
    attr_reader :company, :faker_count

    def initialize(company, faker_count = 20)
      @company = company
      @faker_count = faker_count
    end

    def call
      ActsAsTenant.with_tenant(company) do
        seed_job_applications
      end
    end

    private

    def seed_job_applications
      Rails.logger.debug { "📝 Seeding #{faker_count} job applications for #{company.name}..." }

      published_jobs = company.jobs.published
      return Rails.logger.debug '⚠️ No published jobs found for applications' if published_jobs.empty?

      # Get candidates from all companies for variety
      all_candidates = Candidate.includes(:user, :candidate_roles).limit(50)
      return Rails.logger.debug '⚠️ No candidates found for applications' if all_candidates.empty?

      application_count = 0

      # Create applications for each published job
      published_jobs.each do |job|
        # Create 2-8 applications per job
        rand(2..8).times do
          candidate = all_candidates.sample
          next if job.has_applicant?(candidate) # Avoid duplicate applications

          status = weighted_status_sample

          JobApplication.create!(
            job: job,
            candidate: candidate,
            user: candidate.user,
            status: status,
            cover_letter: generate_cover_letter(job, candidate),
            portfolio_url: generate_portfolio_url(candidate),
            additional_notes: generate_additional_notes,
            applied_at: generate_applied_date,
            reviewed_at: generate_reviewed_date(status),
            reviewed_by: generate_reviewer(job),
            view_count: rand(1..15)
          )

          # Update job application count
          job.increment!(:job_applications_count)
          application_count += 1

          break if application_count >= faker_count
        end

        break if application_count >= faker_count
      end

      Rails.logger.debug { "✅ Created #{application_count} job applications" }
    end

    def weighted_status_sample
      # Weighted distribution for more realistic status distribution
      weights = {
        'applied' => 40,      # 40% - Most applications are just applied
        'reviewing' => 25,    # 25% - Under review
        'shortlisted' => 15,  # 15% - Shortlisted
        'interviewed' => 10,  # 10% - Interviewed
        'offered' => 5,       # 5% - Offered
        'rejected' => 5       # 5% - Rejected
      }

      total_weight = weights.values.sum
      random = rand(total_weight)

      current_weight = 0
      weights.each do |status, weight|
        current_weight += weight
        return status if random < current_weight
      end

      'applied' # fallback
    end

    def generate_cover_letter(job, candidate)
      templates = [
        {
          intro: 'Dear Hiring Manager,',
          body: "I am writing to express my strong interest in the **#{job.title}** position at #{job.company.name}. With my background in #{candidate.candidate_roles.first&.name || 'software development'}, I believe I would be a valuable addition to your team.\n\nI am particularly drawn to this opportunity because of #{job.company.name}'s reputation for innovation and the chance to work on challenging projects. My experience aligns well with the requirements you've outlined, and I am excited about the possibility of contributing to your team's success.",
          closing: "Thank you for considering my application. I look forward to discussing how my skills and experience can benefit #{job.company.name}.\n\nBest regards,\n#{candidate.user.display_name}"
        },
        {
          intro: 'Hello,',
          body: "I'm excited to apply for the **#{job.title}** role. My experience in #{candidate.candidate_roles.first&.name || 'development'} makes me a great fit for this position.\n\nI've been following #{job.company.name}'s work and am impressed by your commitment to #{[
            'innovation', 'quality', 'user experience', 'growth', 'excellence'
          ].sample}. I'm eager to contribute to your continued success and bring my expertise in #{candidate.candidate_roles.first&.name || 'software development'} to your team.",
          closing: "Looking forward to discussing this opportunity further.\n\nRegards,\n#{candidate.user.display_name}"
        },
        {
          intro: "Dear #{job.company.name} Team,",
          body: "I'm applying for the **#{job.title}** position. With #{candidate.experience} years of experience in #{candidate.candidate_roles.first&.name || 'software development'}, I'm confident I can make meaningful contributions to your team.\n\nWhat excites me most about this role is the opportunity to work on #{[
            'cutting-edge technology', 'impactful projects', 'innovative solutions', 'scalable systems', 'user-centric products'
          ].sample} while collaborating with talented professionals. I'm particularly interested in #{job.company.name}'s approach to #{[
            'problem-solving', 'team collaboration', 'technical excellence', 'user experience'
          ].sample}.",
          closing: "I'm available for an interview at your convenience and look forward to learning more about this opportunity.\n\nSincerely,\n#{candidate.user.display_name}"
        },
        {
          intro: 'Dear Hiring Team,',
          body: "I am thrilled to submit my application for the **#{job.title}** position at #{job.company.name}. As a passionate #{candidate.candidate_roles.first&.name || 'developer'} with #{candidate.experience} years of experience, I am excited about the opportunity to contribute to your innovative team.\n\nMy background in #{candidate.candidate_roles.first&.name || 'software development'} has equipped me with the skills necessary to excel in this role. I am particularly drawn to #{job.company.name}'s mission and values, and I believe my technical expertise and collaborative approach would be a great fit for your organization.",
          closing: "I would welcome the opportunity to discuss how my skills and enthusiasm can contribute to #{job.company.name}'s continued success.\n\nThank you for your consideration.\n\nBest regards,\n#{candidate.user.display_name}"
        },
        {
          intro: 'Hello Hiring Manager,',
          body: "I'm writing to express my interest in the **#{job.title}** position. With my experience in #{candidate.candidate_roles.first&.name || 'software development'}, I believe I can bring valuable insights and skills to your team.\n\nI'm impressed by #{job.company.name}'s commitment to #{%w[
            excellence innovation quality growth
          ].sample} and would love to be part of your mission. My background in #{candidate.candidate_roles.first&.name || 'development'} aligns perfectly with your requirements, and I'm excited about the opportunity to contribute to your success.",
          closing: "I look forward to discussing how I can help #{job.company.name} achieve its goals.\n\nRegards,\n#{candidate.user.display_name}"
        }
      ]

      template = templates.sample
      "#{template[:intro]}\n\n#{template[:body]}\n\n#{template[:closing]}"
    end

    def generate_portfolio_url(candidate)
      return nil if rand < 0.3 # 30% chance of no portfolio

      domains = ['github.com', 'portfolio.com', 'dev.to', 'dribbble.com', 'behance.net']
      domain = domains.sample

      case domain
      when 'github.com'
        "https://github.com/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}"
      when 'portfolio.com'
        "https://#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}.portfolio.com"
      when 'dev.to'
        "https://dev.to/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}"
      when 'dribbble.com'
        "https://dribbble.com/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}"
      when 'behance.net'
        "https://behance.net/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}"
      end
    end

    def generate_additional_notes
      return nil if rand < 0.7 # 70% chance of no additional notes

      notes = [
        "I'm very excited about this opportunity and believe my skills align perfectly with your requirements.",
        "I'm available to start immediately and can work flexible hours.",
        "I'm particularly interested in your company's approach to remote work and team collaboration.",
        'I have experience working with similar technologies and would love to discuss how I can contribute.',
        "I'm passionate about continuous learning and would appreciate the opportunity to grow with your team.",
        "I'm open to relocation if required and can start within 2 weeks of receiving an offer.",
        'I have experience leading small teams and would be interested in growth opportunities.',
        "I'm excited about the possibility of working on cutting-edge projects with your team."
      ]

      notes.sample
    end

    def generate_applied_date
      # Applications from 1-30 days ago
      rand(1..30).days.ago
    end

    def generate_reviewed_date(status)
      return nil unless %w[reviewing shortlisted interviewed offered rejected].include?(status)

      # Reviewed 1-7 days after application
      rand(1..7).days.ago
    end

    def generate_reviewer(job)
      # 80% chance of having a reviewer for reviewed applications
      return nil if rand < 0.2

      job.company.users.sample
    end
  end
end
