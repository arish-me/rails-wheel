# frozen_string_literal: true

module SeedData
  class MainSeeder < BaseService
    attr_reader :faker_count

    def initialize(faker_count = nil, fake_data = false)
      @faker_count = faker_count || 100
      @fake_data = fake_data
    end

    def call
      log "Starting database seeding process..."
      # Only run faker seeds in development or test environment
      if @fake_data
        seed_faker_data
      else
        seed_initial_data
      end

      log "Seeding completed successfully!"
    end

    def seed_initial_data
      seed_roles
      seed_permissions
      seed_role_permissions
      seed_users
    end

    private

    def seed_roles
      SeedData::RolesService.call
    end

    def seed_permissions
      SeedData::PermissionsService.call
    end

    def seed_role_permissions
      SeedData::RolePermissionsService.call
    end

    def seed_users
      SeedData::UsersService.call
    end

    def seed_faker_data
      SeedData::BulkFakerSeeder.new(faker_count).call
    end
  end
end
