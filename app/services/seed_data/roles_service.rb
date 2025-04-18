# frozen_string_literal: true

module SeedData
  class RolesService < BaseService
    DEFAULT_ROLE = "User".freeze
    ROLES = %w[SuperAdmin Admin User Recruiter Guest].freeze

    def call
      create_roles
      ensure_default_role
    end

    private

    def create_roles
      log "Creating Roles..."
      ROLES.each do |role_name|
        role = Role.find_or_create_by!(name: role_name)
        # Set the default role
        if role_name == DEFAULT_ROLE
          role.update!(is_default: true)
        end
      end
      log "Roles created: #{ROLES.join(', ')}"
    end

    def ensure_default_role
      # Ensure only one role is marked as default
      Role.where.not(name: DEFAULT_ROLE).update_all(is_default: false)
      log "Default role set to: #{DEFAULT_ROLE}"
    end
  end
end
