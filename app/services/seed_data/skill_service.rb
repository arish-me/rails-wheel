module SeedData
  class SkillService < BaseService
    DEFAULT_SKILLS = [
      # Programming Languages
      "Ruby", "Python", "JavaScript", "TypeScript", "Java", "C#", "C++", "Go", "Rust", "PHP", "Kotlin", "Swift", "Scala", "Perl", "Elixir", "Haskell", "Dart", "Objective-C", "R", "MATLAB",
      # Web Frameworks
      "Ruby on Rails", "Django", "Flask", "Express.js", "React", "Vue.js", "Angular", "Next.js", "Nuxt.js", "Svelte", "Ember.js", "ASP.NET", "Spring Boot", "Laravel", "Symfony", "Phoenix", "Gatsby",
      # Databases
      "PostgreSQL", "MySQL", "SQLite", "MongoDB", "Redis", "Cassandra", "Elasticsearch", "Oracle", "SQL Server", "DynamoDB", "Firebase",
      # DevOps & Cloud
      "Docker", "Kubernetes", "AWS", "Azure", "Google Cloud", "Heroku", "Terraform", "Ansible", "Jenkins", "CircleCI", "GitHub Actions", "Travis CI", "Vercel", "Netlify",
      # Frontend
      "HTML", "CSS", "Sass", "Less", "Tailwind CSS", "Bootstrap", "Material UI", "Chakra UI", "Shadcn UI",
      # Mobile
      "React Native", "Flutter", "SwiftUI", "Android SDK", "iOS SDK", "Xamarin",
      # Design & Prototyping
      "Figma", "Sketch", "Adobe XD", "Adobe Photoshop", "Adobe Illustrator", "InVision", "Zeplin",
      # Testing
      "RSpec", "Jest", "Mocha", "Cypress", "Selenium", "Capybara", "JUnit", "PyTest",
      # Other Tools
      "Git", "Webpack", "Babel", "ESLint", "Prettier", "Storybook", "Postman", "Swagger", "GraphQL", "REST API", "gRPC",
      # Soft Skills
      "Communication", "Teamwork", "Problem Solving", "Leadership", "Time Management", "Adaptability", "Creativity", "Critical Thinking", "Attention to Detail"
    ].freeze

    def call
      create_skills
    end

    private

    def create_skills
      log "Seeding default skills..."
      DEFAULT_SKILLS.each do |skill_name|
        Skill.find_or_create_by!(name: skill_name)
      end
      log "Default skills seeded successfully."
    rescue StandardError => e
      log_error "Failed to seed skills: #{e.message}"
    end
  end
end 