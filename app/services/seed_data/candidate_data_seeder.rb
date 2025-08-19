# SeedData::CandidateDataSeeder.call
require "net/http"
require "tempfile"
module SeedData
  class CandidateDataSeeder < BaseService
    # Constants for configuration
    DEFAULT_CANDIDATE_COUNT = 20
    EXPERIENCE_WEIGHTS = {
      fresher: 10,           # 10% - Fresh graduates
      year_1: 15,           # 15% - 1 year experience
      year_2: 20,           # 20% - 2 years experience
      year_3: 25,           # 25% - 3 years experience
      year_4: 15,           # 15% - 4 years experience
      year_5: 10,           # 10% - 5 years experience
      year_6: 3,            # 3% - 6 years experience
      year_7: 1,            # 1% - 7 years experience
      year_8: 0.5,          # 0.5% - 8 years experience
      year_9: 0.3,          # 0.3% - 9 years experience
      year_10: 0.2,         # 0.2% - 10 years experience
      greater_than_10_years: 0 # 0% - More than 10 years (rare for demo)
    }.freeze

    SEARCH_STATUS_WEIGHTS = {
      actively_looking: 40,   # 40% - Actively looking
      open: 35,              # 35% - Open to opportunities
      not_interested: 20,    # 20% - Not interested
      invisible: 5           # 5% - Invisible
    }.freeze

    attr_reader :faker_count

    def initialize(faker_count = DEFAULT_CANDIDATE_COUNT)
      @faker_count = faker_count
    end

    def call
      seed_candidate_data
    end

    private

    def seed_candidate_data
      puts "👥 Seeding candidate data..."

      created_count = 0

      faker_count.times do |i|
                begin
          # Create user first
          user = create_user(i)

          # Create candidate with all associated data
          candidate = create_candidate(user)

      # Add skills
      add_skills_to_candidate(user.candidate)

      # Add experiences
      add_experiences_to_candidate(user.candidate)

      # Add social links
      add_social_links_to_candidate(user.candidate)

      # Add location
      add_location_to_candidate(user.candidate)

      created_count += 1
      print "." if (i + 1) % 5 == 0

      # Debug output
      puts "\n✅ Created candidate #{i + 1}:"
      puts "   - Skills: #{user.candidate.skills.count}"
      puts "   - Experiences: #{user.candidate.experiences.count}"
      puts "   - Role Types: #{user.candidate.role_types.join(', ')}"
      puts "   - Role Levels: #{user.candidate.role_levels.join(', ')}"
      puts "   - Bio: #{user.candidate.bio.present? ? 'Present' : 'Missing'}"
      puts "   - Social Links: #{user.candidate.social_link.present? ? 'Present' : 'Missing'}"
      puts "   - Location: #{user.candidate.location.present? ? 'Present' : 'Missing'}"
        rescue => e
          puts "⚠️  Failed to create candidate #{i + 1}: #{e.message}"
          puts "Backtrace: #{e.backtrace.first(3).join("\n")}" if Rails.env.development?
          next
        end
      end

      puts "\n✅ Created #{created_count} candidates"
    end

        def create_user(index)
      # Fetch user data from RandomUser.me API
      user_data = fetch_random_user_data

      # Generate email using the fetched data
      email = "#{user_data[:first_name].downcase}.#{user_data[:last_name].downcase}#{index + 1}@yopmail.com"

      # Check if user already exists
      user = User.find_by(email: email)

      unless user
        # Create user with data from RandomUser.me API
        user = User.new(
          email: email,
          password: email,
          password_confirmation: email,
          first_name: user_data[:first_name],
          last_name: user_data[:last_name],
          gender: user_data[:gender],
          phone_number: user_data[:phone],
          date_of_birth: user_data[:date_of_birth],
          confirmed_at: Time.current,
          onboarded_at: Time.current,
          set_onboarding_preferences_at: Time.current,
          set_onboarding_goals_at: Time.current,
          user_type: :user # Ensure candidates are marked as regular users, not company users
        )

        # Save the user first
        if user.save(validate: false)
          puts "Candidate User created with email #{user.email}"
          # Attach avatar from RandomUser.me API in a separate transaction
          begin
            attach_random_user_avatar(user, user_data[:avatar_url])
          rescue => e
            puts "⚠️  Avatar attachment failed for #{user.email}: #{e.message}"
            # Continue without avatar - user is still created successfully
          end
        else
          puts "Candidate User Failed to create #{user.errors.full_messages}"
        end
      end

      # Store location data for later use
      user.instance_variable_set(:@location_data, user_data[:location])

      user
    end

    def create_candidate(user)
      experience_level = generate_experience_distribution
      search_status = generate_search_status_distribution

      # Calculate hourly rate based on experience
      hourly_rate = calculate_hourly_rate(experience_level)

      # Generate headline based on experience and skills
      headline = generate_headline(experience_level)

      # Generate role types and levels for the candidate
      role_types = RoleType::TYPES.sample(rand(1..3))
      role_levels = RoleLevel::TYPES.sample(rand(1..3))

      candidate = user.candidate.update!(
        user: user,
        headline: headline,
        experience: experience_level,
        search_status: search_status,
        hourly_rate: hourly_rate,
        bio: generate_bio(experience_level),
        response_rate: rand(60..100),
        search_score: rand(50..95),
        role_type_attributes: { "part_time_contract"=>"1", "full_time_contract"=>"1", "full_time_employment"=>"0" },
        role_level_attributes: { "junior"=>"1", "mid"=>"1", "senior"=>"1", "principal"=>"1", "c_level"=>"1" }
      )
      # Add candidate roles (specializations)
      add_candidate_roles(user.candidate)

      candidate
    end

    def add_skills_to_candidate(candidate)
      # Get random skills based on experience level
      skill_count = case candidate.experience
      when "fresher"
                      rand(3..6)
      when "year_1", "year_2"
                      rand(4..8)
      when "year_3", "year_4", "year_5"
                      rand(6..12)
      else
                      rand(8..15)
      end

      available_skills = Skill.all.sample(skill_count)

      # Add skills through the association
      available_skills.each do |skill|
        candidate.candidate_skills.create!(skill: skill)
      end
    end

    def add_experiences_to_candidate(candidate)
      experience_count = case candidate.experience
      when "fresher"
                           0
      when "year_1"
                           rand(1..2)
      when "year_2", "year_3"
                           rand(1..3)
      when "year_4", "year_5"
                           rand(2..4)
      else
                           rand(3..6)
      end

      experience_count.times do |i|
        is_current = (i == experience_count - 1) && rand < 0.3 # 30% chance of current job

        start_date = if i == 0
                      Faker::Date.between(from: 5.years.ago, to: 2.years.ago)
        else
                      # Start date should be after previous job's end date
                      previous_experience = candidate.experiences.last
                      Faker::Date.between(from: previous_experience.end_date, to: 1.year.ago)
        end

        end_date = is_current ? nil : Faker::Date.between(from: start_date, to: Time.current)

        candidate.experiences.create!(
          company_name: Faker::Company.name,
          job_title: generate_job_title(candidate.experience),
          start_date: start_date,
          end_date: end_date,
          current_job: is_current,
          description: generate_experience_description
        )
      end
    end

    def add_social_links_to_candidate(candidate)
      social_link = candidate.build_social_link(
        github: rand < 0.8 ? "https://github.com/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}" : nil,
        linked_in: rand < 0.9 ? "https://linkedin.com/in/#{candidate.user.first_name.downcase}-#{candidate.user.last_name.downcase}" : nil,
        website: rand < 0.4 ? "https://#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}.com" : nil,
        twitter: rand < 0.3 ? "https://twitter.com/#{candidate.user.first_name.downcase}#{candidate.user.last_name.downcase}" : nil
      )
      social_link.save!
    end

    def add_location_to_candidate(candidate)
      # Use RandomUser.me location data if available, otherwise generate random location
      location_data = if candidate.user.instance_variable_defined?(:@location_data)
                        map_random_user_location(candidate.user.instance_variable_get(:@location_data))
      else
                        generate_location_data
      end

      # Create location with coordinates to bypass geocoding validation
      candidate.create_location!(
        city: location_data[:city],
        state: location_data[:state],
        country: location_data[:country],
        country_code: location_data[:country_code],
        time_zone: location_data[:time_zone],
        utc_offset: location_data[:utc_offset],
        latitude: location_data[:latitude],
        longitude: location_data[:longitude]
      )
    end



    def add_candidate_roles(candidate)
      # Get random candidate roles (specializations)
      role_count = rand(1..3)
      available_roles = CandidateRole.all.sample(role_count)

      available_roles.each do |role|
        candidate.specializations.create!(candidate_role: role)
      end
    end

    def generate_experience_distribution
      total_weight = EXPERIENCE_WEIGHTS.values.sum
      random = rand(total_weight)

      current_weight = 0
      EXPERIENCE_WEIGHTS.each do |experience, weight|
        current_weight += weight
        return experience if random < current_weight
      end

      "year_3" # fallback
    end

    def generate_search_status_distribution
      total_weight = SEARCH_STATUS_WEIGHTS.values.sum
      random = rand(total_weight)

      current_weight = 0
      SEARCH_STATUS_WEIGHTS.each do |status, weight|
        current_weight += weight
        return status if random < current_weight
      end

      "open" # fallback
    end

    def calculate_hourly_rate(experience_level)
      base_rates = {
        fresher: 15..25,
        year_1: 20..35,
        year_2: 25..45,
        year_3: 35..60,
        year_4: 45..75,
        year_5: 55..90,
        year_6: 65..100,
        year_7: 75..110,
        year_8: 85..120,
        year_9: 95..130,
        year_10: 105..140,
        greater_than_10_years: 120..200
      }

      range = base_rates[experience_level.to_sym] || base_rates[:year_3]
      rand(range)
    end

    def generate_headline(experience_level)
      headlines = {
        fresher: [
          "Recent Graduate Looking for Opportunities",
          "Entry-Level Developer Eager to Learn",
          "Fresh Graduate with Strong Foundation",
          "New Graduate Passionate About Technology"
        ],
        year_1: [
          "Junior Developer with 1 Year Experience",
          "Software Developer Building Web Applications",
          "Full Stack Developer with Modern Technologies",
          "Junior Engineer Focused on Quality Code"
        ],
        year_2: [
          "Software Developer with 2 Years Experience",
          "Full Stack Developer Building Scalable Solutions",
          "Web Developer Specializing in Modern Frameworks",
          "Developer with Strong Problem-Solving Skills"
        ],
        year_3: [
          "Mid-Level Software Engineer",
          "Full Stack Developer with 3 Years Experience",
          "Software Engineer Building Robust Applications",
          "Developer with Strong Technical Background"
        ],
        year_4: [
          "Experienced Software Engineer",
          "Senior Developer with 4 Years Experience",
          "Full Stack Engineer Building Complex Systems",
          "Software Engineer with Strong Architecture Skills"
        ],
        year_5: [
          "Senior Software Engineer",
          "Full Stack Developer with 5 Years Experience",
          "Software Engineer with Leadership Experience",
          "Senior Developer Building Enterprise Solutions"
        ]
      }

      level_key = experience_level.to_sym
      available_headlines = headlines[level_key] || headlines[:year_3]
      available_headlines.sample
    end

    def generate_bio(experience_level)
      bios = {
        fresher: [
          "Recent graduate with a strong foundation in computer science and a passion for software development. I'm eager to apply my knowledge and learn from experienced professionals while contributing to meaningful projects.",
          "Fresh graduate with hands-on experience in web development through personal projects and internships. I'm excited to start my career and grow as a developer while working on challenging problems.",
          "New graduate with a solid understanding of programming fundamentals and modern development practices. I'm looking for opportunities to apply my skills and continue learning in a collaborative environment."
        ],
        year_1: [
          "Software developer with 1 year of experience building web applications using modern technologies. I enjoy solving complex problems and creating user-friendly solutions that make a difference.",
          "Junior developer passionate about clean code and user experience. I've worked on various projects and am always eager to learn new technologies and best practices.",
          "Full stack developer with experience in both frontend and backend development. I focus on writing maintainable code and delivering high-quality solutions."
        ],
        year_2: [
          "Software developer with 2 years of experience creating scalable web applications. I specialize in modern frameworks and enjoy working on challenging problems that require creative solutions.",
          "Full stack developer with strong problem-solving skills and experience in multiple programming languages. I'm passionate about building robust, user-friendly applications.",
          "Developer with experience in both frontend and backend technologies. I enjoy collaborating with teams and contributing to projects that have real-world impact."
        ],
        year_3: [
          "Mid-level software engineer with 3 years of experience building complex applications. I specialize in scalable architecture and enjoy mentoring junior developers.",
          "Software engineer with strong technical skills and experience in full-stack development. I focus on writing clean, maintainable code and solving complex business problems.",
          "Developer with experience in multiple technologies and frameworks. I enjoy working on challenging projects and helping teams deliver high-quality software solutions."
        ],
        year_4: [
          "Experienced software engineer with 4 years of experience in building enterprise applications. I specialize in scalable architecture and enjoy leading technical initiatives.",
          "Senior developer with strong problem-solving skills and experience in multiple domains. I focus on delivering high-quality solutions and mentoring team members.",
          "Software engineer with experience in both technical and leadership roles. I enjoy working on complex problems and helping teams achieve their goals."
        ],
        year_5: [
          "Senior software engineer with 5 years of experience building large-scale applications. I specialize in system design and enjoy leading technical teams to deliver exceptional results.",
          "Experienced developer with strong leadership skills and technical expertise. I focus on building robust, scalable solutions and mentoring junior developers.",
          "Senior engineer with experience in multiple technologies and domains. I enjoy solving complex problems and helping organizations achieve their technical goals."
        ]
      }

      level_key = experience_level.to_sym
      available_bios = bios[level_key] || bios[:year_3]
      available_bios.sample
    end

    def generate_job_title(experience_level)
      titles = {
        fresher: [
          "Software Developer Intern",
          "Junior Developer",
          "Entry-Level Developer",
          "Graduate Software Engineer"
        ],
        year_1: [
          "Junior Software Developer",
          "Software Developer",
          "Web Developer",
          "Junior Engineer"
        ],
        year_2: [
          "Software Developer",
          "Full Stack Developer",
          "Web Developer",
          "Software Engineer"
        ],
        year_3: [
          "Software Engineer",
          "Full Stack Developer",
          "Senior Developer",
          "Software Developer"
        ],
        year_4: [
          "Senior Software Engineer",
          "Full Stack Engineer",
          "Software Engineer",
          "Senior Developer"
        ],
        year_5: [
          "Senior Software Engineer",
          "Lead Developer",
          "Software Engineer",
          "Senior Engineer"
        ]
      }

      level_key = experience_level.to_sym
      available_titles = titles[level_key] || titles[:year_3]
      available_titles.sample
    end

    def generate_experience_description
      descriptions = [
        "Developed and maintained web applications using modern technologies. Collaborated with cross-functional teams to deliver high-quality software solutions.",
        "Built scalable backend services and APIs. Worked on database design and optimization to improve application performance.",
        "Created responsive user interfaces and implemented frontend features. Ensured code quality through testing and code reviews.",
        "Contributed to the development of enterprise applications. Participated in agile development processes and technical discussions.",
        "Worked on full-stack development projects. Collaborated with designers and product managers to implement new features.",
        "Developed and optimized database queries and data processing pipelines. Contributed to system architecture and design decisions.",
        "Implemented new features and fixed bugs in existing applications. Participated in code reviews and knowledge sharing sessions.",
        "Built and deployed applications using cloud technologies. Worked on CI/CD pipelines and infrastructure automation."
      ]
      descriptions.sample
    end

    def map_random_user_location(random_user_location)
      # Map RandomUser.me location data to our format
      timezone_offset = random_user_location["timezone"]["offset"]
      utc_offset = parse_timezone_offset(timezone_offset)

      # Get coordinates from RandomUser.me
      coordinates = random_user_location["coordinates"]
      latitude = coordinates["latitude"].to_f
      longitude = coordinates["longitude"].to_f

      {
        city: random_user_location["city"],
        state: random_user_location["state"],
        country: random_user_location["country"],
        country_code: random_user_location["country"], # RandomUser.me doesn't provide country codes
        time_zone: map_timezone_description(random_user_location["timezone"]["description"]),
        utc_offset: utc_offset,
        latitude: latitude,
        longitude: longitude
      }
    end

    def parse_timezone_offset(offset_string)
      # Parse offset string like "-8:00" to seconds
      hours, minutes = offset_string.split(":").map(&:to_i)
      (hours * 3600) + (minutes * 60)
    end

    def map_timezone_description(description)
      # Map timezone descriptions to standard timezone names
      case description
      when /Pacific Time/
        "America/Los_Angeles"
      when /Mountain Time/
        "America/Denver"
      when /Central Time/
        "America/Chicago"
      when /Eastern Time/
        "America/New_York"
      else
        "UTC" # Default fallback
      end
    end

    def generate_location_data
      locations = [
        { city: "San Francisco", state: "CA", country: "United States", country_code: "US", time_zone: "America/Los_Angeles", utc_offset: -28800, latitude: 37.7749, longitude: -122.4194 },
        { city: "New York", state: "NY", country: "United States", country_code: "US", time_zone: "America/New_York", utc_offset: -18000, latitude: 40.7128, longitude: -74.0060 },
        { city: "Austin", state: "TX", country: "United States", country_code: "US", time_zone: "America/Chicago", utc_offset: -21600, latitude: 30.2672, longitude: -97.7431 },
        { city: "Seattle", state: "WA", country: "United States", country_code: "US", time_zone: "America/Los_Angeles", utc_offset: -28800, latitude: 47.6062, longitude: -122.3321 },
        { city: "Boston", state: "MA", country: "United States", country_code: "US", time_zone: "America/New_York", utc_offset: -18000, latitude: 42.3601, longitude: -71.0589 },
        { city: "Los Angeles", state: "CA", country: "United States", country_code: "US", time_zone: "America/Los_Angeles", utc_offset: -28800, latitude: 34.0522, longitude: -118.2437 },
        { city: "Denver", state: "CO", country: "United States", country_code: "US", time_zone: "America/Denver", utc_offset: -25200, latitude: 39.7392, longitude: -104.9903 },
        { city: "Chicago", state: "IL", country: "United States", country_code: "US", time_zone: "America/Chicago", utc_offset: -21600, latitude: 41.8781, longitude: -87.6298 },
        { city: "Atlanta", state: "GA", country: "United States", country_code: "US", time_zone: "America/New_York", utc_offset: -18000, latitude: 33.7490, longitude: -84.3880 },
        { city: "Portland", state: "OR", country: "United States", country_code: "US", time_zone: "America/Los_Angeles", utc_offset: -28800, latitude: 45.5152, longitude: -122.6784 }
      ]
      locations.sample
    end



    def fetch_random_user_data
      begin
        # Fetch data from RandomUser.me API
        uri = URI("https://randomuser.me/api/")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 10
        http.open_timeout = 10

        response = http.get(uri.request_uri)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          user_info = data["results"][0]

          # Map gender from API to our enum
          gender_mapping = {
            "male" => "he_him",
            "female" => "she_her"
          }

          {
            first_name: user_info["name"]["first"],
            last_name: user_info["name"]["last"],
            gender: gender_mapping[user_info["gender"]] || "other",
            phone: user_info["phone"],
            date_of_birth: Date.parse(user_info["dob"]["date"]),
            avatar_url: user_info["picture"]["large"],
            location: user_info["location"]
          }
        else
          # Fallback to Faker if API fails
          generate_fallback_user_data
        end
      rescue => e
        puts "⚠️  Failed to fetch from RandomUser.me API: #{e.message}"
        generate_fallback_user_data
      end
    end

    def generate_fallback_user_data
      {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        gender: User.genders.keys.sample,
        phone: Faker::PhoneNumber.phone_number,
        date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
        avatar_url: nil
      }
    end

    def attach_random_user_avatar(user, avatar_url)
      return attach_fallback_avatar(user) if avatar_url.nil?

      begin
        # Download the avatar from RandomUser.me
        uri = URI(avatar_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 10
        http.open_timeout = 10

        response = http.get(uri.request_uri)

        if response.is_a?(Net::HTTPSuccess) && response.body.size > 1000
          # Use StringIO instead of Tempfile to avoid stream issues
          require "stringio"
          io = StringIO.new(response.body)
          io.binmode

          # Attach the file to the user
          user.avatar.attach(
            io: io,
            filename: "avatar_#{user.first_name.downcase}_#{user.last_name.downcase}.jpg",
            content_type: "image/jpeg"
          )

          print "✅" # Success indicator
        else
          puts "⚠️  Failed to download avatar for #{user.email}: Invalid response"
          attach_fallback_avatar(user)
        end
      rescue => e
        puts "⚠️  Failed to attach avatar for #{user.email}: #{e.message}"
        # Don't call fallback here to avoid potential infinite loops
        print "❌" # Error indicator
      end
    end

    def attach_fallback_avatar(user)
      # Fallback: Use a simple placeholder avatar service
      begin
        # Use a simple placeholder service as fallback
        fallback_url = "https://via.placeholder.com/200x200/4F46E5/FFFFFF?text=#{user.first_name.first}#{user.last_name.first}"

        uri = URI(fallback_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 5
        http.open_timeout = 5

        response = http.get(uri.request_uri)

        if response.is_a?(Net::HTTPSuccess)
          # Use StringIO instead of Tempfile to avoid stream issues
          require "stringio"
          io = StringIO.new(response.body)
          io.binmode

          user.avatar.attach(
            io: io,
            filename: "avatar_#{user.first_name.downcase}_#{user.last_name.downcase}.png",
            content_type: "image/png"
          )

          print "🔄" # Fallback indicator
        else
          puts "❌ Failed to create fallback avatar for #{user.email}"
          print "❌" # Error indicator
        end
      rescue => e
        puts "❌ Failed to create fallback avatar for #{user.email}: #{e.message}"
        print "❌" # Error indicator
      end
    end

    # No validation needed since candidates are not tied to companies
  end
end
