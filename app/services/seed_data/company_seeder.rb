# frozen_string_literal: true

module SeedData
  class CompanySeeder < BaseService
    def initialize(companies_data = nil)
      @companies_data = companies_data || default_companies_data
    end

    def call
      log 'Starting Company seeding process...'
      created_companies = []

      @companies_data.each do |company_data|
        company = create_company(company_data)
        created_companies << company
      end

      log "✅ Company seeding completed. Created/updated #{created_companies.count} companies."
      created_companies
    end

    def create_company(company_data)
      # Check if company already exists
      existing_company = Company.find_by(
        name: company_data[:name],
        subdomain: company_data[:subdomain],
        website: company_data[:website]
      )

      if existing_company
        log "Company already exists: #{existing_company.name}"
        return existing_company
      end

      # Create company with avatar in a single transaction
      company = nil
      ActiveRecord::Base.transaction do
        # Create the company first
        company = Company.new(
          name: company_data[:name],
          subdomain: company_data[:subdomain],
          website: company_data[:website]
        )

        # Attach avatar before saving (to pass validation)
        unless attach_company_avatar(company)
          raise ActiveRecord::Rollback, "Failed to attach avatar for #{company_data[:name]}"
        end

        # Save the company (validation will pass since avatar is attached)
        company.save!
        log "✅ Created company with avatar: #{company.name}"
      end

      company
    end

    private

    def default_companies_data
      [
        {
          name: 'TTC Service',
          subdomain: 'wheel.in',
          website: 'www.wheel.in'
        }
      ]
    end

    def attach_company_avatar(company)
      # Generate avatar URL using UI Avatars API
      avatar_url = generate_avatar_url(company.name)

      # Download and attach the avatar
      uri = URI(avatar_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      http.open_timeout = 10

      response = http.get(uri.request_uri)

      if response.is_a?(Net::HTTPSuccess)
        # Use StringIO to avoid stream issues
        require 'stringio'
        io = StringIO.new(response.body)
        io.binmode

        company.avatar.attach(
          io: io,
          filename: "avatar_#{company.name.parameterize}.png",
          content_type: 'image/png'
        )

        log "✅ Avatar attached for company: #{company.name}"
        true
      else
        log "⚠️ Failed to download avatar for company: #{company.name}"
        false
      end
    rescue StandardError => e
      log "❌ Failed to attach avatar for company #{company.name}: #{e.message}"
      false
    end

    def generate_avatar_url(company_name)
      # Encode company name for URL
      encoded_name = URI.encode_www_form_component(company_name)
      "https://ui-avatars.com/api/?name=#{encoded_name}&size=200"
    end
  end
end
